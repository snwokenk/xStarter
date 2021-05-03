// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Interaction.sol";

// available voting points = (balance * (block.number - blockOfLastRefresh)) + accumulatedVP - spentVP
struct Voter {
    uint balance; // token balance
    uint lockedBalance; 
    uint blockOfLastRefresh; // block number of last deposit
    uint accumulatedVP;
    uint spentVP; 
}

struct ILOProposal {
    uint yesCount;
    uint noCount;
    address[] voters;
    bool isOpen;
    bool isApproved;
}

// todo: voting point calculation might cause an overflow issue
// todo: one solution is to refresh the Voter struct aat deposit or if refreshVoter is called (takes gas)
// todo: another solution is to cap block.number - blockOfLastRefresh at 6,000,000

contract xStarterGovernance is Context, Interaction {
    using SafeMath for uint256;
    using Address for address;
    
    
    address _xStarterToken;
    address _xStarterNFT;
    
    mapping (string => ILOProposal) _ILOProposals;
    mapping (address => Voter) _voters;
    
    uint totalBalance;
    uint totalAccumulated;
    uint totalSpent;
    
    function votingPoints(address voter_) public view returns(uint balance) {
        // voting points is accumulated by the number of blocks after deposit
        Voter memory voter = _voters[voter_];
        balance = (voter.balance * (block.number - voter.blockOfLastRefresh)) + voter.accumulatedVP - voter.spentVP;
        
    }
    
    event VotingPointsTransferred(address indexed from_, address indexed to_, uint indexed amount);
    function sendVotingPoints(address to_, uint amount_) public allowedToInteract returns(bool) {
         _disallowInteraction();
         require(votingPoints(_msgSender()) >= amount_, "Not enough voting points balance");
         
        _voters[_msgSender()].spentVP = _voters[_msgSender()].spentVP.add(amount_);
        _voters[to_].accumulatedVP = _voters[to_].accumulatedVP.add(amount_);
        
        _allowInteraction();
        
        emit VotingPointsTransferred(_msgSender(), to_, amount_);
        return true;
    }
    
    event Deposited(address indexed depositor_, uint indexed amount_);
    function deposit(uint amount_) external allowedToInteract returns(bool success) {
        _disallowInteraction();
        // check for approved amount
        uint approvedAmount = IERC20(_xStarterToken).allowance(_msgSender(), address(this));
        
        // verify approved amount is equal or greater than amount looking to deposit
        require(approvedAmount >= amount_, "allowance less than amount to deposit");
        Voter storage voter = _voters[_msgSender()];
        
        // set state to reflect deposit
        uint waitBlocks = block.number - voter.blockOfLastRefresh;
        voter.accumulatedVP = voter.balance * waitBlocks;
        voter.blockOfLastRefresh = block.number;
        // transfer balance with transferFrom
        success = IERC20(_xStarterToken).transferFrom(_msgSender(), address(this), amount_);
        
        // make sure transaction was succesfull
        require(success, "not able to transfer approved amount");
        voter.balance =  voter.balance + amount_;
        _allowInteraction();
        emit Deposited(_msgSender(), amount_);

    }
        
    
    
    function ILOApproved(string memory tokenSymbol_) public returns(bool) {
        return true;
    }
}