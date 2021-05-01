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

struct ILOProposal {
    address proposer;
    address fundingToken;
    string tokenName;
    string tokenSymbol;
    uint totalSupply;
    uint8 decimals; // set at 18
    uint8 percentOfTokensForILO; // (minimum 50%)
    address tokenAddress;
    uint blockNumber;
    uint timestamp;
    bool isApproved;
    bool isOpen;
    
}
struct DeployedILO {
    address ILO;
    address admin; // person responsible for calling functions that an admin is required
    address proposer; // initial proposer
    string tokenSymbol;
    string tokenName;
    uint totalSupply;
    uint blockNumber;
    uint timestamp;
    
}

// struct GovernanceProposal {
//     address proposer;
//     string proposalHash; // sha256 hash of proposer/title/description
//     uint blockNumber;
//     bool isApproved;
//     bool isOpen;
    
// }

// contract launches xStarterPoolPairB contracts for approved ILO proposals and enforces
contract xStarterLaunchPad is Ownable{
    using SafeMath for uint256;
    using Address for address;
    modifier onlyEnoughDeposits() {
        // must add 1, given this checks to makes sure proposer has tokens for at least 1 proposal addional proposal
        require(depositBalance(_msgSender()) >= _depositPerProposal * (_numOfProposals[_msgSender()] + 1), 'must have minimum deposit');
        _;
    }
    
     modifier allowedToInteract() {
        require(!_currentlyInteracting[_msgSender()], "Locked From Interaction, A transaction you initiated has not been completed");
        _;
    }
    
    bool initialized;
    bool deploying;
    
    // min amount of tokens to have deposited 
    uint _depositPerProposal;
    address _xStarterToken;
    address _xStarterGovernance;
    address _xStarterNFT;
    
    mapping(string => ILOProposal) private _ILOProposals;
    mapping(string => DeployedILO) private _deployedILOs;
    // mapping(string => GovernanceProposal) private _govProposals;
    mapping(address => uint16) _numOfProposals;
    mapping(address => uint) private _tokenDeposits;
    mapping(address => bool) private _currentlyFunding;
    mapping(address => bool) private _currentlyInteracting;

    function initialize(address xStarterToken_, address xStarterGovernance_, uint depositPerProposal_) external returns(bool) {
        require(!initialized, "contract has already been initialized");
        initialized = true;
        
        _xStarterToken = xStarterToken_;
        _xStarterGovernance = xStarterGovernance_;
        _depositPerProposal = depositPerProposal_;
        return true;
        
    }
    
    function depositBalance(address addr_) public view returns(uint) {
        return _tokenDeposits[addr_];
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

        ILOProposal storage proposal = _ILOProposals[tokenSymbol_];
        _deployedILOs[tokenSymbol_] = DeployedILO(
            address(0),
            ILOAdmin_,
            proposal.proposer,
            tokenSymbol_,
            proposal.tokenName,
            proposal.totalSupply,
            block.number,
            block.timestamp
            );
        
        success = _deployILO(tokenSymbol_, _deployedILOs[tokenSymbol_]);
        _allowInteraction();
        
    }
    
    // function createGovernanceProposal() external onlyEnoughDeposits returns(bool success) {
        
    // }
    
    function _allowInteraction() internal {
        _currentlyInteracting[_msgSender()] = false;
    }
    function _disallowInteraction() internal {
        _currentlyInteracting[_msgSender()] = true;
    }
    function _canWithdraw(uint amount_) internal view returns(bool) {
        if(_numOfProposals[_msgSender()] == 0) { return true; }
        
        return _tokenDeposits[_msgSender()].sub(amount_) >= _depositPerProposal * _numOfProposals[_msgSender()];
    }
    
    function _deployILO(string memory tokenSymbol_, DeployedILO memory deployedILO_) internal returns (bool){
        
    }
    
    event ILOProposalCreated(address indexed proposer, string indexed tokenSymbol_, string indexed tokenName_, uint totalSupply_);
    function _createILOProposal(string memory tokenName_, string memory tokenSymbol_, uint totalSupply_, uint8 percentOfTokensForILO_, address fundingToken_) internal returns(bool) {
        
        
        // bytes32 memory proposalHash = keccak256(abi.encode(tokenName_, tokenSymbol_, totalSupply_, percentOfTokensForILO_, _msgSender()));
        require(!_ILOProposals[tokenSymbol_].isOpen && !_ILOProposals[tokenSymbol_].isApproved, "proposal with token symbol is either in the process of voting or already approved");
        _ILOProposals[tokenSymbol_] = ILOProposal(
            _msgSender(), 
            fundingToken_,
            tokenName_, 
            tokenSymbol_, 
            totalSupply_, 
            18, 
            percentOfTokensForILO_, 
            address(0), 
            block.number, 
            block.timestamp, 
            false, 
            true
        );
        
        emit ILOProposalCreated(_msgSender(), tokenSymbol_, tokenName_, totalSupply_);
        
        return true;
        
    }
        
    
    
    
    
}