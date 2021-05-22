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
// import "./xStarterStructs.sol";





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
    
    function deployILO(
        address adminAddress_,
        address proposalAddr_,
        address addressOfDex_,
        address addressOfDexFactory_
        ) external returns(address ILO_) {
            require(msg.sender == allowedCaller, "Only launchpad can deploy ILO");
            
            xStarterPoolPairB ILO = new xStarterPoolPairB(
                 adminAddress_,
                 proposalAddr_,
                 addressOfDex_,
                 addressOfDexFactory_
                );
            ILO_ = address(ILO);
        
    }
}

interface iXstarterDeployer {
    function deployILO(
        address adminAddress_,
        address proposalAddr_,
        address addressOfDex_,
        address addressOfDexFactory_
        ) external returns(address ILO_);
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
    
    bool private _initialILODeployed;
    bool _initialized;
    bool _deploying;
    address _allowedCaller = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266; // address of deployer
    
    // min amount of tokens to have deposited 
    uint _depositPerProposal;
    address  _xStarterToken;
    address  _xStarterGovernance;
    address  _xStarterNFT;
    address public _addressOfDex;
    address public _addressOfDexFactory;
    address  _xStarterDeployer;
    
    // todo: let mapping be string and uint in which index is the position of ILOproposal in array
    mapping(address => uint) private _ILOProposals;
    address[] private _ILOProposalArray;
    // mapping(string => DeployedILO) private _deployedILOs;
    // mapping(string => GovernanceProposal) private _govProposals;
    mapping(address => uint16) _numOfProposals;
    mapping(address => uint) private _tokenDeposits;
    mapping(address => bool) private _currentlyFunding;
    mapping(string => address) private supportedDex;
    
    

    function initialize(
        address xStarterGovernance_, 
        address xStarterToken_, 
        address xStarterNFT_, 
        address xStarterDeployer_, 
        uint depositPerProposal_,
        address addressOfDex_,
        address addressOfDexFactory_
        ) external returns(bool) {
        require(!_initialized, "contract has already been initialized");
        require(_allowedCaller != address(0) && _msgSender() == _allowedCaller, 'Not authorized');
        _initialized = true;
        // _initialILODeployed = initialILODeployed_;
        
        
        _xStarterToken = xStarterToken_;
        _xStarterGovernance = xStarterGovernance_;
        _xStarterNFT = xStarterNFT_;
        _xStarterDeployer = xStarterDeployer_;
        _depositPerProposal = depositPerProposal_;
        _addressOfDex = addressOfDex_;
        _addressOfDexFactory = addressOfDexFactory_;
        return true;
        
    }
    function xStarterDEXUsed() public view returns(address dexAddress, address dexFactoryAddress) {
        return (_addressOfDex, _addressOfDexFactory);
    }
    function xStarterContracts() public view returns(address[4] memory) {
        return [_xStarterGovernance, _xStarterToken, _xStarterNFT, _xStarterDeployer];
    }
    function getProposal(address proposalAddr_) public view returns(ILOProposal memory i_, ILOAdditionalInfo memory a_) {
        // uint lenOfArrayAtTimeOfAdd = _ILOProposals[proposalAddr_];
        // // proposalAddr does not exist return empty proposal
        // if(lenOfArrayAtTimeOfAdd == 0) {
        //     return proposal;
        // }
        // proposal = _ILOProposalArray[lenOfArrayAtTimeOfAdd - 1];
        (i_, a_) = iXstarterProposal(proposalAddr_).getILOInfo();
        return (i_, a_);
    }
    
    // gets ILOProposals 5 at a time
    // function getProposals(uint round_) public view returns(ILOProposal[] memory, bool ) {
    //     uint len = _ILOProposalArray.length;
    //     require(len > 0, "No Proposals Yet");
    //     // uint start = round_ * 5
    //     uint end = (round_ * 5) + 5;
    //     bool endOfArray =  end >= len;
    //     end = endOfArray ? len : end;
    //     uint start = end <= 5 ? 0 : end - 5;
    //     ILOProposal[] memory proposals = new ILOProposal[](end - start);
        
    //     for (uint i=start ; i < end; i++) {
    //         proposals[i] = _ILOProposalArray[i];
    //     }
        
    //     return (proposals, endOfArray);
        
    // }
    
    function getProposals(uint round_) public view returns(CompactInfo[] memory, bool ) {
        uint len = _ILOProposalArray.length;
        require(len > 0, "No Proposals Yet");
        // uint start = round_ * 5
        uint end = (round_ * 5) + 5;
        bool endOfArray =  end >= len;
        end = endOfArray ? len : end;
        uint start = end <= 5 ? 0 : end - 5;
        CompactInfo[] memory compactInfos = new CompactInfo[](end - start);
        
        for (uint i=start ; i < end; i++) {
            compactInfos[i] = iXstarterProposal(_ILOProposalArray[i]).getCompactInfo();
        }
        
        return (compactInfos, endOfArray);
        
    }
    
    
    function IsProposerOrAdmin(address msgSender_, address proposalAddr_) public view returns(bool) {
        (ILOProposal memory proposal, ) = getProposal(proposalAddr_);
        return proposal.proposer != address(0) && (proposal.proposer == msgSender_ || proposal.admin == msgSender_);
    }
    
    function depositBalance(address addr_) public view returns(uint) {
        return _tokenDeposits[addr_];
    }
    function isDeployed(address proposalAddr_) public view returns(bool) {
        
        return iXstarterProposal(proposalAddr_).isDeployed();
        
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
    
    
    event ILOProposalRegistered(address indexed proposer, address indexed proposalAddr_);
    
     function registerILOProposal(address proposalAddr_) public returns(bool success) {
        require(_initialILODeployed, "Initial xStarter ILO not deployed");
        success = _registerILOProposal(proposalAddr_);
        require(success, "not able to register ILO");
        emit ILOProposalRegistered(_msgSender(), proposalAddr_);
        
    }
    
    function deployXstarterILO(address proposalAddr_) external returns(address ILO){
        require(_msgSender() == _allowedCaller, "Not authorized");
        require(!_initialILODeployed, "xStarter ILO already deployed");
        _allowedCaller = address(0);
        _initialILODeployed = true;
        bool success = registerILOProposal(proposalAddr_);
        require(success, 'Not able to create initial ILO proposal');
        (success, ILO) = _deployILO(proposalAddr_, _msgSender());
        require(success, 'Not able to deploy initial ILO');
        _allowedCaller = address(0);
        emit ILODeployed(proposalAddr_, _msgSender(), ILO);
        
    }
    
    event ILODeployed(address proposalAddr_, address indexed caller_, address indexed ILO);
    function deployILOContract(address proposalAddr_, address ILOAdmin_) external allowedToInteract returns(bool success) {
        // anyone can deploy an ILO, but if ILOAdmin_ != ILO proposer then, then the msg.sender must be the ILO proposer
        // ILO proposer also gets the NFT rewards, so it makes no sense for anyone but the 
        _disallowInteraction();
        require(_initialILODeployed, "initial xStarter ILO not deployed");
        require(!iXstarterProposal(proposalAddr_).isDeployed(), "ILO already deployed or being deployed");
        address ILO;
        (success, ILO) = _deployILO(proposalAddr_, ILOAdmin_);
        require(success, "Not able to deploy ILO");
        _allowInteraction();
        emit ILODeployed(proposalAddr_, _msgSender(), ILO);
        
    }
    
    
    function _canWithdraw(uint amount_) internal view returns(bool) {
        if(_numOfProposals[_msgSender()] == 0) { return true; }
        
        return _tokenDeposits[_msgSender()].sub(amount_) >= _depositPerProposal * _numOfProposals[_msgSender()];
    }
    
    function _deployILO(address proposalAddr_, address ILOAdmin_) internal returns (bool success, address ILO){
        
        // check if its approved
        // bool approved = iXstarterProposal(proposalAddr_).approved();
        bool approved = iXstarterGovernance(_xStarterGovernance).ILOApproved(proposalAddr_);
        require(approved, "proposal has not been approved");
        
        // deploy
        ILO = iXstarterDeployer(_xStarterDeployer).deployILO(
            ILOAdmin_,
            proposalAddr_,
            _addressOfDex,
            _addressOfDexFactory // contrib lock
        );
        
        // change proposal state
        success = iXstarterProposal(proposalAddr_).deploy(ILO);
        
        
        return (success, ILO);
        
    }
    
    
    function _registerILOProposal(address proposalAddr_) internal returns(bool success) {
        
        _ILOProposalArray.push(proposalAddr_);
        _ILOProposals[proposalAddr_] = _ILOProposalArray.length;
        success = iXstarterProposal(proposalAddr_).register(_xStarterGovernance);
        require(success, 'not able to register ILOProposal');
        
        return success;
        
    }
    
    // function _verifyILO(address proposalAddr_, string memory tokenName_, string memory tokenSymbol_, string memory infoURL_, uint totalSupply_, uint8 percentOfTokensForILO_, address fundingToken_) internal view returns(bool) {
    //     (ILOProposal memory proposal, ) = getProposal(proposalAddr_);
    //     require(!proposal.isOpen && !proposal.isApproved, "proposal with token symbol is either in the process of voting or already approved");
    //     (string memory tokenName, string memory tokenSymbol, string memory infoURL, uint totalSupply, uint8 percentOfTokensForILO, address fundingToken) = iXstarterProposal(proposalAddr_).getMainInfo();
        
    //     require(
            
    //         (
    //         keccak256(abi.encodePacked(tokenName_)) == keccak256(abi.encodePacked(tokenName)) &&
    //         keccak256(abi.encodePacked(tokenSymbol_)) == keccak256(abi.encodePacked(tokenSymbol)) &&
    //         keccak256(abi.encodePacked(infoURL_)) == keccak256(abi.encodePacked(infoURL)) &&
    //         totalSupply_ == totalSupply &&
    //         percentOfTokensForILO_ == percentOfTokensForILO &&
    //         fundingToken_ == fundingToken),
    //         "ILOProposal Info Error"
    //     );
    //     return true;
    // }
}






    
