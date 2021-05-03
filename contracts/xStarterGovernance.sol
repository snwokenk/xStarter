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
    // available balance is balance - lockedBalance
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
    address _xStarterNFT;
    
    mapping (string => ILOProposal) _ILOProposals;
    mapping (address => Voter) _voters;
    
    uint totalBalance;
    uint totalAccumulated;
    uint totalSpent;
    
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
    function ILOApproved(string memory tokenSymbol_) public returns(bool) {
        return true;
    }
    
    // create a modifier that verifies that ILO can be voted on
    function voteForILO(string memory name_, uint amount_, VoteChoice choice_) external allowedToInteract onlyILOOpen(name_) returns(bool) {
        _disallowInteraction();
        require(balance(_msgSender()) > amount_, "not enough balance");
        Voter storage voter = _voters[_msgSender()];
        ILOProposal storage proposal = _ILOProposals[name_];
        voter.lockedBalance = voter.lockedBalance.add(amount_);
        proposal.votes.push(Vote(
            ProposalType.ILO,
            name_,
            amount_,
            _msgSender(),
            choice_
            )
        );
        _allowInteraction();
        return true;
    }
    
    function validateILO(string memory name_) external returns(bool) {}
    
    
    function addILO(string memory name_) external returns(bool) {}
    
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