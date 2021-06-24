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
import "./xStarterDeployers.sol";

// contract xStarterDeployer {
// //   address _admin;
// //   function setAdmin(address addr) external returns(bool) {
// //       _admin = addr;
// //   }
    
//     function deployILO(
//         address adminAddress_,
//         address proposalAddr_,
//         address addressOfDex_,
//         address addressOfDexFactory_
//         ) external returns(address ILO_) {
//             // require(msg.sender == _admin, "Only launchpad can deploy ILO");
            
//             address ILO = address(new xStarterPoolPairB(
//                  adminAddress_,
//                  proposalAddr_,
//                  addressOfDex_,
//                  addressOfDexFactory_
//                 ));
//             ILO_ = address(ILO);
        
//     }
// }

contract xStarterDeployer is BaseDeployer {
   
    
    function deployILO(
        address adminAddress_,
        address proposalAddr_,
        address addressOfDex_,
        address addressOfDexFactory_,
        address xStarterToken_,
        address xstarterLP_,
        address xStarterERCDeployer_,
        uint  minXSTN_,
        uint  minXSTNLP_
        ) external onlyAllowedCaller returns(address ILO_) {
            
            address ILO = address(new xStarterPoolPairB(
                adminAddress_,
                proposalAddr_,
                addressOfDex_,
                addressOfDexFactory_,
                xStarterToken_,
                xstarterLP_,
                xStarterERCDeployer_,
                minXSTN_,
                minXSTNLP_
                ));
            ILO_ = address(ILO);
        
    }
}




interface iXstarterDeployer {
    function setAllowedCaller(address allowedCaller_) external returns(bool);
    function deployILO(
        address adminAddress_,
        address proposalAddr_,
        address addressOfDex_,
        address addressOfDexFactory_,
        address xStarterToken_,
        address xstarterLP_,
        address xStarterERCDeployer_,
        uint  minXSTN_,
        uint  minXSTNLP_
        ) external returns(address ILO_);
}



// contract launches xStarterPoolPairB contracts for approved ILO proposals and enforces
contract xStarterLaunchPad is Administration, Interaction{
    using SafeMath for uint256;
    using Address for address;
    modifier onlyEnoughDeposits() {
        // must add 1, given this checks to makes sure proposer has tokens for at least 1 proposal addional proposal
        require(depositBalance(_msgSender()) >= _depositPerProposal * (_numOfProposals[_msgSender()] + 1), 'must have minimum deposit');
        _;
    }
    
    bool private _initialILODeployed;
    // xStarter's ILO address
    address private _initialILOAddr;
    address private _initialILOPropAddr;
    bool _deploying;
    // address __admin = 0xF4c8163B122fc28686990AC2777Fe090ca6b5357; // address of deployer
    
    // min amount of tokens to have deposited 
    uint _depositPerProposal;
    
    // minimum amount of xStarter tokens or xStarter lps needed to participate
    uint  _minXSTNLP;
    uint  _minXSTN;
    address  _xStarterToken;
    address _xStarterLP;
    address  _xStarterGovernance;
    address  _xStarterNFT;
    address public _addressOfDex;
    address public _addressOfDexFactory;
    address  _xStarterDeployer;
    address _xStarterERCDeployer;
    
    // todo: let mapping be string and uint in which index is the position of ILOproposal in array
    mapping(address => uint) private _ILOProposals;
    address[] private _ILOProposalArray;
    // mapping(string => DeployedILO) private _deployedILOs;
    // mapping(string => GovernanceProposal) private _govProposals;
    mapping(address => uint16) _numOfProposals;
    mapping(address => uint) private _tokenDeposits;
    mapping(address => bool) private _currentlyFunding;
    mapping(string => address) private supportedDex;
    
    

    constructor(
        address xStarterToken_, 
        address xStarterDeployer_, 
        address xStarterERCDeployer_,
        uint depositPerProposal_,
        uint  minXSTN_,
        uint  minXSTNLP_,
        address addressOfDex_,
        address addressOfDexFactory_,
        address admin_
        ) Administration(admin_) {
        
        
        _xStarterToken = xStarterToken_;
        _xStarterDeployer = xStarterDeployer_;
        _xStarterERCDeployer = xStarterERCDeployer_;
        _depositPerProposal = depositPerProposal_;
        _minXSTN = minXSTN_;
        _minXSTNLP = minXSTNLP_;
        _addressOfDex = addressOfDex_;
        _addressOfDexFactory = addressOfDexFactory_;
        
    }
    
    function changeMinTokensRequirements(
        uint  minXSTN_,
        uint  minXSTNLP_
        ) external returns(bool) {
            require(_xStarterGovernance != address(0) && _msgSender() == _xStarterGovernance, 'Not authorized' );
            _minXSTN = minXSTN_;
            _minXSTNLP = minXSTNLP_;
            return true;
        }
    function getMinTokensRequirements() public view returns(uint, uint) {
        return (_minXSTN, _minXSTNLP);
    }
    
    function addGovernance(address xStarterGovernance_) external onlyAdmin returns(bool) {
        _xStarterGovernance = xStarterGovernance_;
        return true;
    }
    
    function addNFT(address xStarterNFT_) external onlyAdmin returns(bool) {
        _xStarterNFT = xStarterNFT_;
        return true;
    }
    
    function xStarterDEXUsed() public view returns(address dexAddress, address dexFactoryAddress) {
        return (_addressOfDex, _addressOfDexFactory);
    }
    function xStarterContracts() public view returns(address[5] memory) {
        return [_xStarterGovernance, _xStarterToken, _xStarterNFT, _xStarterDeployer, _xStarterERCDeployer];
    }
    function getProposal(address proposalAddr_) public view returns(CompactInfo memory i_) {
        // uint lenOfArrayAtTimeOfAdd = _ILOProposals[proposalAddr_];
        // // proposalAddr does not exist return empty proposal
        // if(lenOfArrayAtTimeOfAdd == 0) {
        //     return proposal;
        // }
        // proposal = _ILOProposalArray[lenOfArrayAtTimeOfAdd - 1];
        require((proposalAddr_ == _initialILOAddr && _ILOProposals[proposalAddr_] == 0) || _ILOProposals[proposalAddr_] != 0, "proposal address not registered");
        i_ = iXstarterProposal(proposalAddr_).getCompactInfo();
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
        uint ind = 0;
        for (uint i=start ; i < end; i++) {
            compactInfos[ind] = iXstarterProposal(_ILOProposalArray[i]).getCompactInfo();
            ind++;
        }
        
        return (compactInfos, endOfArray);
        
    }
    function noOfProposals() public view returns(uint256) {
        return _ILOProposalArray.length;
    }
    
    
    // function IsProposerOrAdmin(address msgSender_, address proposalAddr_) public view returns(bool) {
    //     (ILOProposal memory proposal, ) = getProposal(proposalAddr_);
    //     return proposal.proposer != address(0) && (proposal.proposer == msgSender_ || proposal.admin == msgSender_);
    // }
    
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
        
        success = IERC20(_xStarterToken).approve(_msgSender(), amount_);
        _allowInteraction();
        emit TokensWithdrawn(_msgSender(), amount_);
    }
    
    
    function registerILOProposal(address proposalAddr_) public returns(bool success) {
        require(_initialILODeployed, "Initial xStarter ILO not deployed");
        success = _registerILOProposal(proposalAddr_);
        // require(success, "not able to register ILO");
        
        
    }
    
    function deployXstarterILO(address proposalAddr_) external onlyAdmin returns(address ILO){
        // require(_msgSender() == __admin, "Not authorized");
        require(!_initialILODeployed, "xStarter ILO already deployed");
        bool success = _registerILOProposal(proposalAddr_);
        require(success, 'Not able to create initial ILO proposal');
        // (success, ILO) = _deployILO(proposalAddr_, _msgSender());
        
        // deploy
        ILO = iXstarterDeployer(_xStarterDeployer).deployILO(
            _msgSender(),
            proposalAddr_,
            _addressOfDex,
            _addressOfDexFactory, // contrib lock
            address(0), // xStarter token not yet distributed so should 
            address(0),
            _xStarterERCDeployer,
            _minXSTN,
            _minXSTNLP
        );
        // allow newly created ILO pool pair to use erc20 deployer
        IXStarterERCDeployer(_xStarterERCDeployer).setAllowedCaller(ILO);
        
        // change proposal state
        success = iXstarterProposal(proposalAddr_).deploy(ILO);
        require(success, 'Not able to deploy initial ILO');
        _initialILODeployed = true;
        _initialILOAddr = ILO;
        _initialILOPropAddr = proposalAddr_;
        emit ILODeployed(proposalAddr_, _msgSender(), ILO);
        
    }
    
    function setTokenAndLPAddr() external view returns(address xStarterToken_, address xStarterLP_) {
        (xStarterToken_, xStarterLP_) = iXstarterProposal(_initialILOPropAddr).getTokenAndLPAddr();
        require(xStarterToken_ != address(0) && xStarterLP_ != address(0), "initial xStarter ILO not completed");
    }
    
    event ILODeployed(address proposalAddr_, address indexed caller_, address indexed ILO);
    function deployILOContract(address proposalAddr_, address ILOAdmin_) external allowedToInteract returns(bool success) {
        // anyone can deploy an ILO, but if ILOAdmin_ != ILO proposer then, then the msg.sender must be the ILO proposer
        // ILO proposer also gets the NFT rewards, so it makes no sense for anyone but the 
        _disallowInteraction();
        
        // initial ILO of xStarter tokens should have been completed, with liquidity pair created
        require(_xStarterToken != address(0) && _xStarterLP != address(0), "initial xStarter ILO not completed");
        // require(!iXstarterProposal(proposalAddr_).isDeployed(), "ILO already deployed or being deployed");
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
            _addressOfDexFactory, // contrib lock
            _xStarterToken,
            _xStarterLP,
            _xStarterERCDeployer,
            _minXSTN,
            _minXSTNLP
        );
        
        // change proposal state
        success = iXstarterProposal(proposalAddr_).deploy(ILO);
        // allow newly created ILO pool pair to use erc20 deployer
        IXStarterERCDeployer(_xStarterERCDeployer).setAllowedCaller(ILO);
        
        
        return (success, ILO);
        
    }
    
    event ILOProposalRegistered(address indexed proposer, address indexed proposalAddr_);
    
    function _registerILOProposal(address proposalAddr_) internal returns(bool success) {
        
        _ILOProposalArray.push(proposalAddr_);
        _ILOProposals[proposalAddr_] = _ILOProposalArray.length;
        success = iXstarterProposal(proposalAddr_).register(_xStarterGovernance);
        require(success, 'not able to register ILOProposal');
        emit ILOProposalRegistered(_msgSender(), proposalAddr_);
        
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






    
