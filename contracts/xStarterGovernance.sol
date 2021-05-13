// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Interaction.sol";

// available voting points = (balance * (block.number - blockOfLastRefresh)) + accumulatedVP - spentVP
interface iXstarterLaunchPad {
    function ILOProposalExist(string memory tokenSymbol_) external view returns(bool);
    function IsProposerOrAdmin(address msgSender_, string memory tokenSymbol_) external view returns(bool);
}
enum ProposalType{ ILO, GOV }
enum VoteChoice{ YES, NO }

struct Voter {
    uint balance; // token balance
    uint lockedBalance; // balance locked in
    ILOVoteInfo[] votes; // only allowed to have 3 active votes
    GOVVoteInfo[] gVotes;
    bool isVoter;
    // available balance is balance - lockedBalance
}

struct ILOVoteInfo {
    string symbol; // symbol of ILO proposal
    uint index; 
    uint amount;
    bool amtLocked; // if amount is part of locked balance, cleanVotes, should unlock any amount that current block > endBlock
    uint endBlock;
}

struct GOVVoteInfo {
    string name; // symbol of ILO proposal
    uint index; 
    uint amount;
    bool amtLocked; // if amount is part of locked balance, cleanVotes, should unlock any amount that current block > endBlock
    uint endBlock;
}
struct Vote {
    ProposalType proposalType;
    string symbol;
    uint amount; // amount stake
    address voter;
    VoteChoice choice;
    
}

struct ILOProposal {
    uint yesCount;
    uint noCount;
    Vote[] votes;
    bool isValidated; // vote was individually validated onchain, this is not necessary, unless someone decides to validate, proposal votes 
    // bool isApproved;
    uint startBlock;
    uint endBlock;
    address validator; // who validated the ILO,
    string queryString; // could be a query string or an ipfs string address
    
}

struct GOVProposal {
    uint yesCount;
    uint noCount;
    Vote[] votes;
    bool isValidated; // validating 
    bool isApproved;
    uint startBlock;
    uint endBlock;
    address validator; // who validated the ILO,
    string queryString;
    
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
    mapping (string => GOVProposal) _GOVProposals;
    mapping (address => Voter) _voters;
    
    uint _totalBalance;
    uint _totalAccumulated;
    uint _totalSpent;
    
    modifier onlyILOVoteOpen(string memory symbol_) {
        require(ILOVoteOpen(symbol_), "ILO has not been set up");
        _;
    }
    modifier onlyGOVVoteOpen(string memory name_) {
        require(GOVVoteOpen(name_), "ILO has not been set up");
        _;
    }
    
    constructor(address xStarterToken_) {
        _xStarterToken = xStarterToken_;
    }
    
    function ILOVoteOpen(string memory symbol_) public view returns(bool) {
        return block.number >= _ILOProposals[symbol_].startBlock && block.number < _ILOProposals[symbol_].endBlock;
    }
    function GOVVoteOpen(string memory name_) public view returns(bool) {
        return block.number >= _GOVProposals[name_].startBlock && block.number < _GOVProposals[name_].endBlock;
    }
    
    function balance(address voter_) public view returns(uint availBal) {
        // voting points is accumulated by the number of blocks after deposit
        Voter memory voter = _voters[voter_];
        availBal = voter.balance - voter.lockedBalance;
        
    }
    function ILOApproved(string memory symbol_) public view returns(bool) {
        require(block.number > _ILOProposals[symbol_].endBlock, "Voting on ILO not complete");
        ILOProposal storage proposal = _ILOProposals[symbol_];
        return proposal.yesCount + proposal.noCount > _minVoteCount && _ILOProposals[symbol_].yesCount > _ILOProposals[symbol_].noCount;  
    }
    
    function GOVApproved(string memory name_) public view returns(bool) {
        require(block.number > _GOVProposals[name_].endBlock, "Voting on ILO not complete");
        GOVProposal storage proposal = _GOVProposals[name_];
        return proposal.yesCount + proposal.noCount > _minVoteCount && _GOVProposals[name_].yesCount > _GOVProposals[name_].noCount;  
    }
    
    event ILOVoted(string indexed symbol_, address indexed voter_, VoteChoice indexed choice_, uint amount_ );
    // create a modifier that verifies that ILO can be voted on
    function voteForILO(string memory symbol_, uint amount_, VoteChoice choice_) external allowedToInteract onlyILOVoteOpen(symbol_) returns(bool) {
        _disallowInteraction();
        require(balance(_msgSender()) > amount_, "not enough balance");
        Voter storage voter = _voters[_msgSender()];
        require(voter.votes.length < 3, "you have 3 active votes, call cleanVotes to clean ended votes");
        ILOProposal storage proposal = _ILOProposals[symbol_];
        voter.lockedBalance = voter.lockedBalance.add(amount_);
        if(choice_ == VoteChoice.YES) {
            proposal.yesCount = proposal.yesCount.add(amount_);
        }else {
            proposal.noCount = proposal.noCount.add(amount_);
        }
        Vote memory vote = Vote(
            ProposalType.ILO,
            symbol_,
            amount_,
            _msgSender(),
            choice_
            );
        proposal.votes.push(vote);
        voter.votes.push(ILOVoteInfo(symbol_, proposal.votes.length - 1, amount_, true, proposal.endBlock));
        emit ILOVoted(symbol_, _msgSender(), choice_, amount_);
        _allowInteraction();
        return true;
    }
    
    event GOVVoted(string indexed name_, address indexed voter_, VoteChoice indexed choice_, uint amount_ );
    // create a modifier that verifies that ILO can be voted on
    function voteForGOV(string memory name_, uint amount_, VoteChoice choice_) external allowedToInteract onlyGOVVoteOpen(name_) returns(bool) {
        _disallowInteraction();
        require(balance(_msgSender()) > amount_, "not enough balance");
        Voter storage voter = _voters[_msgSender()];
        require(voter.votes.length < 3, "you have 3 active votes, call cleanVotes to clean ended votes");
        GOVProposal storage proposal = _GOVProposals[name_];
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
        voter.gVotes.push(GOVVoteInfo(name_, proposal.votes.length - 1, amount_, true, proposal.endBlock));
        emit GOVVoted(name_, _msgSender(), choice_, amount_);
        _allowInteraction();
        return true;
    }
    
    event VoteCleaned(address indexed voter_)
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
         for (uint i=0; i<voter.gVotes.length; i++) {
             GOVVoteInfo storage vote = voter.gVotes[i];
             if(block.number > vote.endBlock && vote.amtLocked) {
                 vote.amtLocked = false;
                 voter.lockedBalance = voter.lockedBalance.sub(vote.amount);
             }
         }
         _allowInteraction();
         emit VoteCleaned(voter_);
         return true;
        
    }
    // audit can be done off chain, by using emitted events
    function auditILOVote(string memory symbol_) external returns(bool) {
        
    }
    // call this function to have every vote emitted
    function auditThroughEmission(string memory symbol_) external {
        
    }
    
    event ILOProposalAdded(address indexed msgSender_, string indexed symbol_, uint indexed startBlock_, uint endBlock_);
    // ILO must already be registered on Launchpad
    function addILO(string memory symbol_) external allowedToInteract returns(bool) {
        _disallowInteraction();
        bool authorized = iXstarterLaunchPad(_xStarterLaunchPad).IsProposerOrAdmin(_msgSender(), symbol_);
        require(authorized, "must be admin or proposer of ILO on Launchpad contract");
        require(_ILOProposals[symbol_].startBlock == 0, 'IlO proposal already exist');
        // 86400 / 5 = 17280 blocks assuming 5 sec blocks
        uint sBlock = block.number + 17280;
        _ILOProposals[symbol_].startBlock = sBlock;
        _ILOProposals[symbol_].endBlock = sBlock + 17280;
        emit ILOProposalAdded(_msgSender(), symbol_, sBlock, sBlock + 17280);
        _allowInteraction();
        
        return true;
        
    }
    
    event GOVProposalAdded(address indexed msgSender_, string indexed name_, uint indexed startBlock_, uint endBlock_);
    // ILO must already be registered on Launchpad
    // todo: add query string (aim is to use ipfs and access ipfs through ipfs.io for browsers that do not have the ipfs extension or support ipfs natively)
    function addGOV(string memory name_) external allowedToInteract returns(bool) {
        _disallowInteraction();
        // bool authorized = iXstarterLaunchPad(_xStarterLaunchPad).IsProposerOrAdmin(_msgSender(), symbol_);
        // require(authorized, "must be admin or proposer of ILO on Launchpad contract");
        require(_GOVProposals[name_].startBlock == 0, 'Gov proposal already exist');
        // 86400 / 5 = 17280 blocks assuming 5 sec blocks
        uint sBlock = block.number + 17280;
        _GOVProposals[name_].startBlock = sBlock;
        _GOVProposals[name_].endBlock = sBlock + 17280;
        emit ILOProposalAdded(_msgSender(), name_, sBlock, sBlock + 17280);
        _allowInteraction();
        
        return true;
        
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
        
        uint bal = balance(voter_);
        
        require(bal >= amount_, "not enough free balance");
        _voters[voter_].balance = _voters[voter_].balance.sub(amount_);
        return true;
        
    }
        
    
}