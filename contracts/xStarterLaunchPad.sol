// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC777/IERC777Recipient.sol";
import "@openzeppelin/contracts/token/ERC777/IERC777Sender.sol";
import "@openzeppelin/contracts/token/ERC777/ERC777.sol";
import "@openzeppelin/contracts/token/ERC777/ERC777.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "./Administration.sol";
import "./xStarterPoolPairB.sol";
import "./Interaction.sol";

interface iXstarterGovernance {
    function ILOApproved(string memory tokenSymbol_) external returns(bool);
}


struct ILOProposal {
    address proposer;
    address admin;
    address fundingToken;
    string tokenName;
    string tokenSymbol;
    string infoURL;
    uint totalSupply;
    uint8 decimals; // set at 18
    uint8 percentOfTokensForILO; // (minimum 50%)
    uint blockNumber;
    uint timestamp;
    bool isApproved;
    bool isOpen;
    uint deployedBlockNumber;
    uint deployedTimestamp;
    bool isDeployed;
    address ILOAddress;
    
}

// launched by user, directly deploying from launchpad increases the code size
contract xStarterDeployer {
    bool initialized;
    address public allowedCaller = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266; // address of deployer
    
    function initialize(address launchPad_) external returns(bool) {
        require(!initialized, "already initialized");
        require(msg.sender == allowedCaller, 'Not authorized');
        allowedCaller = launchPad_;
        return true;
    }
    
    function deployILO(address adminAddress,
        uint8 percentOfTokensForILO_,
        uint24 dexDeadlineLength_,
        uint48 contribTimeLock_,
        uint minPerSwap_,
        uint minFundPerAddr_,
        uint maxFundPerAddr_,
        uint minFundingTokenRequired_,
        uint maxFundingToken_,
        address fundingToken_,
        address addressOfDex_,
        address addressOfDexFactory_) external returns(address ILO_) {
            
            xStarterPoolPairB ILO = new xStarterPoolPairB(
                 adminAddress,
                 percentOfTokensForILO_,
                 dexDeadlineLength_,
                 contribTimeLock_,
                 minPerSwap_,
                 minFundPerAddr_,
                 maxFundPerAddr_,
                 minFundingTokenRequired_,
                 maxFundingToken_,
                 fundingToken_,
                 addressOfDex_,
                 addressOfDexFactory_
                );
            ILO_ = address(ILO);
        
    }
}

interface iXstarterDeployer {
    function deployILO(address adminAddress,
        uint8 percentOfTokensForILO_,
        uint24 dexDeadlineLength_,
        uint48 contribTimeLock_,
        uint minPerSwap_,
        uint minFundPerAddr_,
        uint maxFundPerAddr_,
        uint minFundingTokenRequired_,
        uint maxFundingToken_,
        address fundingToken_,
        address addressOfDex_,
        address addressOfDexFactory_) external returns(address ILO_);
}

// contract launches xStarterPoolPairB contracts for approved ILO proposals and enforces
contract xStarterLaunchPad is Ownable, Interaction{
    using SafeMath for uint256;
    using Address for address;
    modifier onlyEnoughDeposits() {
        // must add 1, given this checks to makes sure proposer has tokens for at least 1 proposal addional proposal
        require(depositBalance(_msgSender()) >= _depositPerProposal * (_numOfProposals[_msgSender()] + 1), 'must have minimum deposit');
        _;
    }
    
    bool private _isProd;
    bool _initialized;
    bool _deploying;
    address _allowedCaller = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266; // address of deployer
    
    // min amount of tokens to have deposited 
    uint _depositPerProposal;
    address public _xStarterToken;
    address public _xStarterGovernance;
    address public _xStarterNFT;
    address _xStarterDeployer;
    
    // todo: let mapping be string and uint in which index is the position of ILOproposal in array
    mapping(string => ILOProposal) private _ILOProposals;
    // mapping(string => DeployedILO) private _deployedILOs;
    // mapping(string => GovernanceProposal) private _govProposals;
    mapping(address => uint16) _numOfProposals;
    mapping(address => uint) private _tokenDeposits;
    mapping(address => bool) private _currentlyFunding;
    mapping(string => address) private supportedDex;
    
    ILOProposal[] private _ILOProposalArray;

    function initialize(address xStarterGovernance_, address xStarterToken_, address xStarterNFT_, address xStarterDeployer_, uint depositPerProposal_, bool isProd_) external returns(bool) {
        require(!_initialized, "contract has already been initialized");
        require(_allowedCaller != address(0) && _msgSender() == _allowedCaller, 'Not authorized');
        _initialized = true;
        _allowedCaller = address(0);
        _isProd = isProd_;
        
        
        _xStarterToken = xStarterToken_;
        _xStarterGovernance = xStarterGovernance_;
        _xStarterNFT = xStarterNFT_;
        _xStarterDeployer = xStarterDeployer_;
        _depositPerProposal = depositPerProposal_;
        return true;
        
    }
    function xStarterContracts() public view returns(address[4] memory) {
        return [_xStarterGovernance, _xStarterToken, _xStarterNFT, _xStarterDeployer];
    }
    function getProposal(string memory tokenSymbol_) public view returns(ILOProposal memory proposal) {
        proposal = _ILOProposals[tokenSymbol_];
    }
    
    // gets ILOProposals 5 at a time
    function getProposals(uint16 round_) public view returns(ILOProposal[] memory proposals, bool endOfArray) {
        // uint start = round_ * 5
        uint end = (round_*5) + 4;
        endOfArray =  end > _ILOProposalArray.length - 1;
        end = !endOfArray ? end : _ILOProposalArray.length - 1;
        uint start = end - 4;
        
        for (uint i=start ; i <= end; i++) {
            proposals[i] = _ILOProposalArray[i];
        }
        
    }
    
    // function ILOProposalExist(string memory tokenSymbol_) public view returns(bool) {
    //     return keccak256(bytes(_ILOProposals[tokenSymbol_].tokenSymbol)) == keccak256(bytes(tokenSymbol_));
        
    // }
    
    function IsProposerOrAdmin(address msgSender_, string memory tokenSymbol_) public view returns(bool) {
        return _ILOProposals[tokenSymbol_].proposer != address(0) && (_ILOProposals[tokenSymbol_].proposer == msgSender_ || _ILOProposals[tokenSymbol_].admin == msgSender_);
    }
    
    function depositBalance(address addr_) public view returns(uint) {
        return _tokenDeposits[addr_];
    }
    function isDeployed(string memory tokenSymbol_) public view returns(bool) {
        
        return _ILOProposals[tokenSymbol_].isDeployed;
        
    }
    
    event TokensDeposited(address indexed caller_, uint indexed amount_);
    function depositApprovedToken() external allowedToInteract returns(bool success) {
        _disallowInteraction();
        uint approvedAmount = IERC20(_xStarterToken).allowance(_msgSender(), address(this));
        require(depositBalance(_msgSender()) + approvedAmount >= _depositPerProposal, 'new deposit plus current deposit must be greater than minimum Deposit');
        success = IERC20(_xStarterToken).transferFrom(_msgSender(), address(this), approvedAmount);
        require(success,'not able to transfer approved tokens');
        _tokenDeposits[_msgSender()] = _tokenDeposits[_msgSender()].add(approvedAmount);
        _allowInteraction();
        emit TokensDeposited(_msgSender(), approvedAmount);
        
        
    }
    
    event TokensWithdrawn(address indexed caller_, uint indexed amount_);
    function withdrawTokens(uint amount_) external allowedToInteract returns(bool success) {
        require(depositBalance(_msgSender()) >= amount_, 'Not enough funds');
        require(_canWithdraw(amount_), 'Must maintain a minimum deposit until proposal is completed');
        _disallowInteraction();
        _tokenDeposits[_msgSender()] = _tokenDeposits[_msgSender()].sub(amount_);
        
        // require(!_ILOProposals[_msgSender].isOpen || _ILOProposals[_msgSender].isOpen && _tokenDeposits[_msgSender()] >= _depositPerProposal, 'Open' )
        // if(_ILOProposals[_msgSender].isOpen && )
        
        success = IERC20(_xStarterToken).approve(_msgSender(), amount_);
        _allowInteraction();
        emit TokensWithdrawn(_msgSender(), amount_);
    }
    
    
    event ILOProposalCreated(address indexed proposer, string indexed tokenSymbol_, string indexed tokenName_, uint totalSupply_);
    function createILOProposal(string memory tokenName_, string memory tokenSymbol_, string memory infoURL_, uint totalSupply_, uint8 percentOfTokensForILO_, address fundingToken_) external onlyEnoughDeposits returns(bool success) {
        success = _createILOProposal(tokenName_, tokenSymbol_, infoURL_, totalSupply_, percentOfTokensForILO_, fundingToken_);
        emit ILOProposalCreated(_msgSender(), tokenSymbol_, tokenName_, totalSupply_);
        
    }
    
    event ILODeployed(string indexed tokenSymbol_, address indexed caller_, address indexed ILO);
    function deployILOContract(string memory tokenSymbol_, address ILOAdmin_) external allowedToInteract returns(bool success) {
        // anyone can deploy an ILO, but if ILOAdmin_ != ILO proposer then, then the msg.sender must be the ILO proposer
        // ILO proposer also gets the NFT rewards, so it makes no sense for anyone but the 
        _disallowInteraction();
        
        require(!_ILOProposals[tokenSymbol_].isDeployed, "ILO already deployed or being deployed");
        bool isApproved;
        if(_isProd) {
            isApproved = iXstarterGovernance(_xStarterGovernance).ILOApproved(tokenSymbol_);
        }else {
            isApproved = true;
        }
        require(isApproved, "ILO has not been approved in the governance contract");
        address ILO;
        (success, ILO) = _deployILO(tokenSymbol_, ILOAdmin_);
        require(success, "Not able to deploy ILO");
        
        _allowInteraction();
        emit ILODeployed(tokenSymbol_, _msgSender(), ILO);
        
    }
    
    // function createGovernanceProposal() external onlyEnoughDeposits returns(bool success) {
        
    // }
    
    
    function _canWithdraw(uint amount_) internal view returns(bool) {
        if(_numOfProposals[_msgSender()] == 0) { return true; }
        
        return _tokenDeposits[_msgSender()].sub(amount_) >= _depositPerProposal * _numOfProposals[_msgSender()];
    }
    
    function _deployILO(string memory tokenSymbol_, address ILOAdmin_) internal returns (bool, address){
        
        ILOProposal storage proposal = _ILOProposals[tokenSymbol_];
        proposal.isOpen = false;
        proposal.isApproved = true;
        proposal.isDeployed = true;
        proposal.deployedBlockNumber = block.number;
        proposal.deployedTimestamp = block.timestamp;
        proposal.admin = ILOAdmin_;
        
        // todo: some of these parameters should be included in ILOProposal struct
        address ILO = iXstarterDeployer(_xStarterDeployer).deployILO(
            ILOAdmin_,
            proposal.percentOfTokensForILO,
            1800,
            60, // contrib lock
            1, // minPerswap
            1, // minFundPerAddr_
            1 ether, // maxfund
            1 ether, // min amount of funding tokens required (softcap)
            2 ether, // max amount of funding (hardcap),
            address(0), //fundong token address, address 0 means use native token (ether for ethereum main net, xDai for xDai sidechain, etc)
            address(0),
            address(0)
            
        );
        proposal.ILOAddress = ILO;
        
        return (true, ILO);
        
    }
    
    
    function _createILOProposal(string memory tokenName_, string memory tokenSymbol_, string memory infoURL_, uint totalSupply_, uint8 percentOfTokensForILO_, address fundingToken_) internal returns(bool) {
        
        
        // bytes32 memory proposalHash = keccak256(abi.encode(tokenName_, tokenSymbol_, totalSupply_, percentOfTokensForILO_, _msgSender()));
        require(!_ILOProposals[tokenSymbol_].isOpen && !_ILOProposals[tokenSymbol_].isApproved, "proposal with token symbol is either in the process of voting or already approved");
        _ILOProposals[tokenSymbol_] = ILOProposal(
            _msgSender(),
            _msgSender(),
            fundingToken_,
            tokenName_, 
            tokenSymbol_, 
            infoURL_,
            totalSupply_, 
            18, 
            percentOfTokensForILO_, 
            block.number, 
            block.timestamp, 
            false, 
            true,
            0,
            0,
            false,
            address(0)
        );
        
        return true;
        
    }
        
    
    
    
    
}