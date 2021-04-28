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
    string proposalHash; // sha256 hash of proposer + tokenName+ tokenSymbol+ totalSupply(string)+ decimals(string) + percentOfTokensForILO(string)
    string tokenName;
    string tokenSymbol;
    uint totalSupply;
    uint8 decimals;
    uint8 percentOfTokensForILO; // (minimum 50%)
    address tokenAddress;
    uint blockNumber;
    bool isApproved;
    bool isOpen;
    
}

struct GovernanceProposal {
    address proposer;
    string proposalHash; // sha256 hash of proposer/title/description
    uint blockNumber;
    bool isApproved;
    
}

// contract launches xStarterPoolPairB contracts for approved ILO proposals and enforces
contract xStarterLaunchPad is Ownable{
    using SafeMath for uint256;
    using Address for address;
    modifier onlyDepositor() {
        require(depositBalance(_msgSender()) >= _minDeposit, 'must have minimum deposit');
        _;
    }
    
     modifier allowedToInteract() {
        require(!_currentlyInteracting[_msgSender()], "Locked From Interaction, A transaction you initiated has not been completed");
        _;
    }
    
    // min amount of tokens to have deposited 
    uint _minDeposit;
    address _xStarterToken;
    
    mapping(address => ILOProposal) private _ILOProposals;
    mapping(address => GovernanceProposal) private _govProposals;
    mapping(address => uint) private _tokenDeposits;
    mapping(address => bool) private _currentlyFunding;
    mapping(address => bool) private _currentlyInteracting;
    
    function _allowInteraction() internal {
        _currentlyInteracting[_msgSender()] = false;
    }
    function _disallowInteraction() internal {
        _currentlyInteracting[_msgSender()] = true;
    }
    
    function depositBalance(address addr_) public view returns(uint) {
        return _tokenDeposits[addr_];
    }
    
    function depositApprovedToken() external allowedToInteract returns(bool success) {
        _disallowInteraction();
        uint approvedAmount = IERC20(_xStarterToken).allowance(_msgSender(), address(this));
        require(depositBalance(_msgSender()) + approvedAmount >= _minDeposit, 'new deposit plus current deposit must be greater than minimum Deposit');
        success = IERC20(_xStarterToken).transferFrom(_msgSender(), address(this), approvedAmount);
        require(success,'not able to transfer approved tokens');
        _tokenDeposits[_msgSender()] = _tokenDeposits[_msgSender()].add(approvedAmount);
        _allowInteraction();
        
        
    }
    function withdrawTokens(uint amount_) external allowedToInteract returns(bool success) {
        // todo: before withdrawing tokens make sure there are no open  proposals by msg.sender, if there is make sure after withdrawal amount left is greater than _minDeposit
        require(depositBalance(_msgSender()) >= amount_, 'Not enough funds');
        _disallowInteraction();
        _tokenDeposits[_msgSender()] = _tokenDeposits[_msgSender()].sub(amount_);
        
        // require(!_ILOProposals[_msgSender].isOpen || _ILOProposals[_msgSender].isOpen && _tokenDeposits[_msgSender()] >= _minDeposit, 'Open' )
        // if(_ILOProposals[_msgSender].isOpen && )
        
        success = IERC20(_xStarterToken).approve(_msgSender(), amount_);
        _allowInteraction();
    }
    
    function createILOProposal() external onlyDepositor returns(bool success) {
        
    }
    
    function createGovernanceProposal() external onlyDepositor returns(bool success) {
        
    }
    
    
    
    
}