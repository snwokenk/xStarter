// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Interaction.sol";
import "./xStarterInterfaces.sol";

// available voting points = (balance * (block.number - blockOfLastRefresh)) + accumulatedVP - spentVP

// todo: voting point calculation might cause an overflow issue
// todo: one solution is to refresh the Voter struct aat deposit or if refreshVoter is called (takes gas)
// todo: another solution is to cap block.number - blockOfLastRefresh at 6,000,000 fixed by using tokens vote with no time accumulation

contract xStarterGovernance is Context, Interaction {
    using SafeMath for uint256;
    using Address for address;
    
    bool private _isProd;
    bool _initialized;
    // todo: change in prod
    address _allowedCaller = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266; // address of deployer
    address public _xStarterToken;
    address public _xStarterLaunchPad;
    address public _xStarterNFT;
    uint _minVoteCount; // yes+no >= minVoteCount minVoteCount == minimum number of tokens use to vote on the proposal
    mapping(address => uint) private _ILOPolls;
    ILOPoll[] private _ILOPollArray;
    // mapping (address => ILOPoll) _ILOPolls;
    mapping (address => GovPoll) _GovPolls;
    mapping (address => Voter) _voters;
    
    uint _totalBalance;
    uint _totalAccumulated;
    uint _totalSpent;
    
    modifier onlyILOVoteOpen(address proposalAddr_) {
        require(ILOVoteOpen(proposalAddr_), "ILO has not been set up");
        _;
    }
    modifier onlyGOVVoteOpen(address proposalAddr_) {
        require(GOVVoteOpen(proposalAddr_), "ILO has not been set up");
        _;
    }
    
    function initialize(address xStarterToken_, address xStarterLaunchPad_, address xStarterNFT_, bool isProd_) external returns(bool) {
        require(!_initialized, "contract has already been initialized");
        require(_allowedCaller != address(0) && _msgSender() == _allowedCaller, 'Not authorized');
        _initialized = true;
        _allowedCaller = address(0);
        _isProd = isProd_;
        
        
        _xStarterToken = xStarterToken_;
        _xStarterNFT = xStarterNFT_;
        _xStarterLaunchPad = xStarterLaunchPad_;
        return true;
        
    }
    function xStarterContracts() public view returns(address[3] memory) {
        return [_xStarterToken, _xStarterLaunchPad, _xStarterNFT];
    }
    function getILOPoll(address proposalAddr_) public view returns (ILOPoll memory poll_) {
        // get index
        uint ind = _ILOPolls[proposalAddr_];
        // if 0 then proposal poll does not exist on governance, 0 is xStarter's ILO
        if(ind == 0) {
            return poll_;
        }
        poll_ = _ILOPollArray[ind - 1];
    }
    
    function getILOPolls(uint round_) public view returns(ILOPoll[] memory, bool ) {
        uint len = _ILOPollArray.length;
        require(len > 0, "No Proposals Yet");
        // uint start = round_ * 5
        uint end = (round_ * 5) + 5;
        bool endOfArray =  end >= len;
        end = endOfArray ? len : end;
        uint start = end <= 5 ? 0 : end - 5;
        ILOPoll[] memory polls_ = new ILOPoll[](end - start);
        uint ind = 0;
        for (uint i=start ; i < end; i++) {
            polls_[i] = _ILOPollArray[i];
            ind++;
        }
        
        return (polls_, endOfArray);
        
    }
    
    function ILOVoteOpen(address proposalAddr_) public view returns(bool) {
        return block.number >= getILOPoll(proposalAddr_).startBlock && block.number < getILOPoll(proposalAddr_).endBlock;
    }
    function ILOApproved(address proposalAddr_) public view returns(bool) {
        ILOPoll memory proposal = getILOPoll(proposalAddr_);
        return proposal.validated && proposal.approved; 
    }
    function ILOVoteDone(address proposalAddr_) public view returns(bool) {
        return block.number > getILOPoll(proposalAddr_).endBlock;
    }
    function GOVVoteOpen(address proposalAddr_) public view returns(bool) {
        return block.number >= _GovPolls[proposalAddr_].startBlock && block.number < _GovPolls[proposalAddr_].endBlock;
    }
    
    function balance(address voter_) public view returns(uint availBal) {
        // voting points is accumulated by the number of blocks after deposit
        Voter memory voter = _voters[voter_];
        availBal = voter.balance - voter.lockedBalance;
        
    }
    
    
    function GOVApproved(address proposalAddr_) public view returns(bool) {
        require(block.number > _GovPolls[proposalAddr_].endBlock, "Voting on ILO not complete");
        GovPoll storage proposal = _GovPolls[proposalAddr_];
        return proposal.yesCount + proposal.noCount > _minVoteCount && _GovPolls[proposalAddr_].yesCount > _GovPolls[proposalAddr_].noCount;  
    }
    
    event ILOVoted(address proposalAddr_, address indexed voter_, VoteChoice indexed choice_, uint amount_ );
    // create a modifier that verifies that ILO can be voted on
    function voteForILO(address proposalAddr_, uint amount_, VoteChoice choice_) external allowedToInteract onlyILOVoteOpen(proposalAddr_) returns(bool) {
        _disallowInteraction();
        require(balance(_msgSender()) > amount_, "not enough balance");
        Voter storage voter = _voters[_msgSender()];
        require(voter.votes.length < 3, "you have 3 active votes, call cleanVotes to clean ended votes");
        
        uint ind = _ILOPolls[proposalAddr_];
        // if 0 then proposal poll does not exist on governance, 0 is xStarter's ILO
        require(ind != 0, "ILO not registered on governance");
 
        ILOPoll storage proposal = _ILOPollArray[ind];
        voter.lockedBalance = voter.lockedBalance.add(amount_);
        if(choice_ == VoteChoice.YES) {
            proposal.yesCount = proposal.yesCount.add(amount_);
        }else {
            proposal.noCount = proposal.noCount.add(amount_);
        }
        Vote memory vote = Vote(
            ProposalType.ILO,
            proposalAddr_,
            amount_,
            _msgSender(),
            choice_
            );
        proposal.votes.push(vote);
        voter.votes.push(ILOVoteInfo(proposalAddr_, proposal.votes.length - 1, amount_, true, proposal.endBlock));
        emit ILOVoted(proposalAddr_, _msgSender(), choice_, amount_);
        _allowInteraction();
        return true;
    }
    
    event GOVVoted(address proposalAddr_, address indexed voter_, VoteChoice indexed choice_, uint amount_ );
    // create a modifier that verifies that ILO can be voted on
    function voteForGOV(address proposalAddr_, uint amount_, VoteChoice choice_) external allowedToInteract onlyGOVVoteOpen(proposalAddr_) returns(bool) {
        _disallowInteraction();
        require(balance(_msgSender()) > amount_, "not enough balance");
        Voter storage voter = _voters[_msgSender()];
        require(voter.votes.length < 3, "you have 3 active votes, call cleanVotes to clean ended votes");
        GovPoll storage proposal = _GovPolls[proposalAddr_];
        voter.lockedBalance = voter.lockedBalance.add(amount_);
        if(choice_ == VoteChoice.YES) {
            proposal.yesCount = proposal.yesCount.add(amount_);
        }else {
            proposal.noCount = proposal.noCount.add(amount_);
        }
        Vote memory vote = Vote(
            ProposalType.ILO,
            proposalAddr_,
            amount_,
            _msgSender(),
            choice_
            );
        proposal.votes.push(vote);
        voter.gVotes.push(GOVVoteInfo(proposalAddr_, proposal.votes.length - 1, amount_, true, proposal.endBlock));
        emit GOVVoted(proposalAddr_, _msgSender(), choice_, amount_);
        _allowInteraction();
        return true;
    }
    
    event VoteCleaned(address indexed voter_);
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
    // function auditILOVote(string memory symbol_) external returns(bool) {
        
    // }
    function validateILOVotes(address proposalAddr_) public returns(bool results) {
        uint ind = _ILOPolls[proposalAddr_]; // get index
        ILOPoll storage poll_ = _ILOPollArray[ind - 1];
        require(!poll_.validated && block.number > getILOPoll(proposalAddr_).endBlock, "Voting on ILO not complete");
        poll_.validated = true;
        poll_.validator = _msgSender();
        results = poll_.yesCount + poll_.noCount > _minVoteCount && poll_.yesCount > poll_.noCount; 
        poll_.approved =  results;
        bool success = iXstarterProposal(proposalAddr_).approve();
        require(success, 'not able to change state on proposal contract');
        
    }
    
    // call this function to have every vote emitted
    // function auditThroughEmission(string memory symbol_) external {
        
    // }
    
    event ILOPollAdded(address indexed msgSender_, address proposalAddr_, uint indexed startBlock_, uint endBlock_);
    // ILO must already be registered on Launchpad
    function addILO(address proposalAddr_) external allowedToInteract returns(bool) {
        _disallowInteraction();
        bool authorized = iXstarterProposal(proposalAddr_).isALlowedCaller(_msgSender());
        require(authorized, "must be an allowed caller on proposal");
        require(getILOPoll(proposalAddr_).startBlock == 0, 'IlO proposal already exist');
        // 86400 / 5 = 17280 blocks assuming 5 sec blocks
        uint sBlock = block.number + 17280;
        
        ILOPoll storage t = _ILOPollArray.push();
        _ILOPolls[proposalAddr_] = _ILOPollArray.length;
        t.startBlock = sBlock;
        t.endBlock = sBlock + 17280;
        emit ILOPollAdded(_msgSender(), proposalAddr_, sBlock, sBlock + 17280);
        _allowInteraction();
        return true;
        
    }
    
    event GovPollAdded(address indexed msgSender_, address proposalAddr_, uint indexed startBlock_, uint endBlock_);
    // ILO must already be registered on Launchpad
    // todo: add query string (aim is to use ipfs and access ipfs through ipfs.io for browsers that do not have the ipfs extension or support ipfs natively)
    function addGOV(address proposalAddr_) external allowedToInteract returns(bool) {
        _disallowInteraction();
        // require(authorized, "must be admin or proposer of ILO on Launchpad contract");
        require(_GovPolls[proposalAddr_].startBlock == 0, 'Gov proposal already exist');
        // 86400 / 5 = 17280 blocks assuming 5 sec blocks
        uint sBlock = block.number + 17280;
        _GovPolls[proposalAddr_].startBlock = sBlock;
        _GovPolls[proposalAddr_].endBlock = sBlock + 17280;
        emit GovPollAdded(_msgSender(), proposalAddr_, sBlock, sBlock + 17280);
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