// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Interaction.sol";

// available voting points = (balance * (block.number - blockOfLastRefresh)) + accumulatedVP - spentVP

enum ProposalType{ ILO, GOV }
enum VoteChoice{ YES, NO }

struct Voter {
    uint balance; // token balance
    uint lockedBalance; // balance locked in
    ILOVoteInfo[] votes; // only allowed to have 3 active votes
    bool isVoter;
    // available balance is balance - lockedBalance
}

struct ILOVoteInfo {
    string name; // name of ILO proposal
    uint index; 
    uint amount;
    bool amtLocked; // if amount is part of locked balance, cleanVotes, should unlock any amount that current block > endBlock
    uint endBlock;
}
struct Vote {
    ProposalType proposalType;
    string name;
    uint amount; // amount stake
    address voter;
    VoteChoice choice;
    
}

struct ILOProposal {
    uint yesCount;
    uint noCount;
    Vote[] votes;
    bool isValidated; // validating 
    bool isApproved;
    uint startBlock;
    uint endBlock;
    address validator; // who validated the ILO, 
    
}

// todo: voting point calculation might cause an overflow issue
// todo: one solution is to refresh the Voter struct aat deposit or if refreshVoter is called (takes gas)
// todo: another solution is to cap block.number - blockOfLastRefresh at 6,000,000

contract xStarterGovernance is Context, Interaction {
    using SafeMath for uint256;
    using Address for address;
    
    
    address _xStarterToken;
    address _xStarterLaunchPad;
    address _xStarterNFT;
    uint _minVoteCount; // yes+no >= minVoteCount
    
    mapping (string => ILOProposal) _ILOProposals;
    mapping (address => Voter) _voters;
    
    uint _totalBalance;
    uint _totalAccumulated;
    uint _totalSpent;
    
    modifier onlyILOOpen(string memory name_) {
        require(ILOOpen(name_), "ILO has not been set up");
        _;
    }
    
    constructor(address xStarterToken_) {
        _xStarterToken = xStarterToken_;
    }
    
    function ILOOpen(string memory name_) public view returns(bool) {
        return block.number >= _ILOProposals[name_].startBlock && block.number < _ILOProposals[name_].endBlock;
    }
    function balance(address voter_) public view returns(uint availBal) {
        // voting points is accumulated by the number of blocks after deposit
        Voter memory voter = _voters[voter_];
        availBal = voter.balance - voter.lockedBalance;
        
    }
    function ILOApproved(string memory name_) public view returns(bool) {
        require(block.number > _ILOProposals[name_].endBlock, "Voting on ILO not complete");
        ILOProposal storage proposal = _ILOProposals[name_];
        return proposal.yesCount + proposal.noCount > _minVoteCount && _ILOProposals[name_].yesCount > _ILOProposals[name_].noCount;  
    }
    
    event ILOVoted(string indexed name_, address indexed voter_, VoteChoice indexed choice_, uint amount_ );
    // create a modifier that verifies that ILO can be voted on
    function voteForILO(string memory name_, uint amount_, VoteChoice choice_) external allowedToInteract onlyILOOpen(name_) returns(bool) {
        _disallowInteraction();
        require(balance(_msgSender()) > amount_, "not enough balance");
        Voter storage voter = _voters[_msgSender()];
        require(voter.votes.length < 3, "you have 3 active votes, call cleanVotes to clean ended votes");
        ILOProposal storage proposal = _ILOProposals[name_];
        voter.lockedBalance = voter.lockedBalance.add(amount_);
        if(choice_ == VoteChoice.YES) {
            proposal.yesCount = proposal.yesCount.add(amount_);
        }else {
            proposal.noCount = proposal.noCount.add(amount_);
        }
        Vote memory vote = Vote(
            ProposalType.ILO,
            name_,
            amount_,
            _msgSender(),
            choice_
            );
        proposal.votes.push(vote);
        voter.votes.push(ILOVoteInfo(name_, proposal.votes.length - 1, amount_, true, proposal.endBlock));
        emit ILOVoted(name_, _msgSender(), choice_, amount_);
        _allowInteraction();
        return true;
    }
    // cleans votes and unlocks any locked balance
    function cleanVotes(address voter_) public allowedToInteract returns (bool) {
        _disallowInteraction();
         Voter storage voter = _voters[voter_];
         for (uint i=0; i<voter.votes.length; i++) {
             ILOVoteInfo storage vote = voter.votes[i];
             if(block.number > vote.endBlock && vote.amtLocked) {
                 vote.amtLocked = false;
                 voter.lockedBalance = voter.lockedBalance.sub(vote.amount);
             }
         }
         _allowInteraction();
         return true;
        
    }
    // audit can be done off chain, by using emitted events
    function auditILOVote(string memory name_) external returns(bool) {
        
    }
    // call this function to have every vote emitted
    function auditThroughEmission(string memory name_) external {
        
    }
    
    // ILO must already be registered on Launchpad
    function addILO(string memory name_) external returns(bool) {
        
    }
    
    event Withdrawn(address indexed depositor_, uint indexed amount_);
    function withdraw(uint amount_) external allowedToInteract returns(bool success) {
        _disallowInteraction();
        _subtractFromBal(_msgSender(), amount_);
        success = IERC20(_xStarterToken).approve(_msgSender(), amount_);
        require(success, "not able to approve withdrawal amount");
        _allowInteraction();
        emit Withdrawn(_msgSender(), amount_);
    }
    
    
    event Deposited(address indexed depositor_, uint indexed amount_);
    function deposit(uint amount_) external allowedToInteract returns(bool success) {
        _disallowInteraction();
        // check for approved amount
        uint approvedAmount = IERC20(_xStarterToken).allowance(_msgSender(), address(this));
        
        // verify approved amount is equal or greater than amount looking to deposit
        require(approvedAmount >= amount_, "allowance less than amount to deposit");
        // transfer balance with transferFrom
        success = IERC20(_xStarterToken).transferFrom(_msgSender(), address(this), amount_);
        
        // make sure transaction was succesfull
        require(success, "not able to transfer approved amount");
        _voters[_msgSender()].balance =  _voters[_msgSender()].balance.add(amount_);
        _allowInteraction();
        emit Deposited(_msgSender(), amount_);

    }
    
    function _subtractFromBal(address voter_, uint amount_) internal returns(bool) {
        
        uint freeBal = _voters[voter_].balance - _voters[voter_].lockedBalance;
        require(freeBal >= amount_, "not enough free balance");
        _voters[voter_].balance = _voters[voter_].balance.sub(amount_);
        return true;
        
    }
        
    
}