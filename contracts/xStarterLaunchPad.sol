// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;


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
    address LaunchPad = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    
    function initialize(address launchPad_) external returns(bool) {
        require(msg.sender == LaunchPad, 'Not authorized');
        require(!initialized, "already initialized");
        LaunchPad = launchPad_;
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
    
    
    bool initialized;
    bool deploying;
    
    // min amount of tokens to have deposited 
    uint _depositPerProposal;
    address _xStarterToken;
    address _xStarterGovernance;
    address _xStarterNFT;
    address _xStarterDeployer;
    
    
    mapping(string => ILOProposal) private _ILOProposals;
    // mapping(string => DeployedILO) private _deployedILOs;
    // mapping(string => GovernanceProposal) private _govProposals;
    mapping(address => uint16) _numOfProposals;
    mapping(address => uint) private _tokenDeposits;
    mapping(address => bool) private _currentlyFunding;
    mapping(string => address) private supportedDex;

    function initialize(address xStarterToken_, address xStarterGovernance_, uint depositPerProposal_) external returns(bool) {
        require(!initialized, "contract has already been initialized");
        initialized = true;
        
        _xStarterToken = xStarterToken_;
        _xStarterGovernance = xStarterGovernance_;
        _depositPerProposal = depositPerProposal_;
        return true;
        
    }
    
    function ILOProposalExist(string memory tokenSymbol_) public view returns(bool) {
        return keccak256(bytes(_ILOProposals[tokenSymbol_].tokenSymbol)) == keccak256(bytes(tokenSymbol_));
        
    }
    function IsProposerOrAdmin(address msgSender_, string memory tokenSymbol_) public view returns(bool) {
        return _ILOProposals[tokenSymbol_].proposer != address(0) && (_ILOProposals[tokenSymbol_].proposer == msgSender_ || _ILOProposals[tokenSymbol_].admin == msgSender_);
    }
    
    function depositBalance(address addr_) public view returns(uint) {
        return _tokenDeposits[addr_];
    }
    function isDeployed(string memory tokenSymbol_) public view returns(bool) {
        
        return _ILOProposals[tokenSymbol_].isDeployed;
        
    }
    
    
    function depositApprovedToken() external allowedToInteract returns(bool success) {
        _disallowInteraction();
        uint approvedAmount = IERC20(_xStarterToken).allowance(_msgSender(), address(this));
        require(depositBalance(_msgSender()) + approvedAmount >= _depositPerProposal, 'new deposit plus current deposit must be greater than minimum Deposit');
        success = IERC20(_xStarterToken).transferFrom(_msgSender(), address(this), approvedAmount);
        require(success,'not able to transfer approved tokens');
        _tokenDeposits[_msgSender()] = _tokenDeposits[_msgSender()].add(approvedAmount);
        _allowInteraction();
        
        
    }
    function withdrawTokens(uint amount_) external allowedToInteract returns(bool success) {
        require(depositBalance(_msgSender()) >= amount_, 'Not enough funds');
        require(_canWithdraw(amount_), 'Must maintain a minimum deposit until proposal is completed');
        _disallowInteraction();
        _tokenDeposits[_msgSender()] = _tokenDeposits[_msgSender()].sub(amount_);
        
        // require(!_ILOProposals[_msgSender].isOpen || _ILOProposals[_msgSender].isOpen && _tokenDeposits[_msgSender()] >= _depositPerProposal, 'Open' )
        // if(_ILOProposals[_msgSender].isOpen && )
        
        success = IERC20(_xStarterToken).approve(_msgSender(), amount_);
        _allowInteraction();
    }
    
    

    
    function createILOProposal(string memory tokenName_, string memory tokenSymbol_, uint totalSupply_, uint8 percentOfTokensForILO_, address fundingToken_) external onlyEnoughDeposits returns(bool success) {
        
        success = _createILOProposal(tokenName_, tokenSymbol_, totalSupply_, percentOfTokensForILO_, fundingToken_);
        
    }
    
    function deployILOContract(string memory tokenSymbol_, address ILOAdmin_) external allowedToInteract returns(bool success) {
        // anyone can deploy an ILO, but if ILOAdmin_ != ILO proposer then, then the msg.sender must be the ILO proposer
        // ILO proposer also gets the NFT rewards, so it makes no sense for anyone but the 
        _disallowInteraction();
        
        require(!_ILOProposals[tokenSymbol_].isDeployed, "ILO already deployed or being deployed");
        
        bool isApproved = iXstarterGovernance(_xStarterGovernance).ILOApproved(tokenSymbol_);
        require(isApproved, "ILO has not been approved in the governance contract");
        
        success = _deployILO(tokenSymbol_, ILOAdmin_);
        require(success, "Not able to deploy ILO");
        
        _allowInteraction();
        
    }
    
    // function createGovernanceProposal() external onlyEnoughDeposits returns(bool success) {
        
    // }
    
    
    function _canWithdraw(uint amount_) internal view returns(bool) {
        if(_numOfProposals[_msgSender()] == 0) { return true; }
        
        return _tokenDeposits[_msgSender()].sub(amount_) >= _depositPerProposal * _numOfProposals[_msgSender()];
    }
    
    function _deployILO(string memory tokenSymbol_, address ILOAdmin_) internal returns (bool){
        
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
        
        return true;
        
    }
    
    event ILOProposalCreated(address indexed proposer, string indexed tokenSymbol_, string indexed tokenName_, uint totalSupply_);
    function _createILOProposal(string memory tokenName_, string memory tokenSymbol_, uint totalSupply_, uint8 percentOfTokensForILO_, address fundingToken_) internal returns(bool) {
        
        
        // bytes32 memory proposalHash = keccak256(abi.encode(tokenName_, tokenSymbol_, totalSupply_, percentOfTokensForILO_, _msgSender()));
        require(!_ILOProposals[tokenSymbol_].isOpen && !_ILOProposals[tokenSymbol_].isApproved, "proposal with token symbol is either in the process of voting or already approved");
        _ILOProposals[tokenSymbol_] = ILOProposal(
            _msgSender(),
            _msgSender(),
            fundingToken_,
            tokenName_, 
            tokenSymbol_, 
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
        
        emit ILOProposalCreated(_msgSender(), tokenSymbol_, tokenName_, totalSupply_);
        
        return true;
        
    }
        
    
    
    
    
}