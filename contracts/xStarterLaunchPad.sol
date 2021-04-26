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
        require(depositBalance(_msgSender()) >= minDeposit, 'must have minimum deposit');
        _;
    }
    
    uint minDeposit;
    
    mapping(string => ILOProposal) private ILOProposals;
    mapping(string => GovernanceProposal) private govProposals;
    mapping(address => uint) private proposalRefundableDeposits;
    
    function depositBalance(address addr_) public view returns(uint) {
        return proposalRefundableDeposits[addr_];
    }
    
    function createProposal() external onlyDepositor returns(bool success) {
        
    }
    
    
    
    
}