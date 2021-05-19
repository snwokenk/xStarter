// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./xStarterStructs.sol";



        
        
interface iXstarterProposal {
    function getILOInfo() external view returns(ILOProposal memory, ILOAdditionalInfo memory);
    function addILOAddress(address ILOAddr) external returns(bool);
    function getLaunchpadAddress() external  view returns(address);
    function getMainInfo() external view returns(string memory tokenName, string memory tokenSymbol, string memory infoURL, uint totalSupply, uint8 percentOfTokensForILO, address fundingToken);
}

contract xStarterProposal {
    ILOProposal _i;
    ILOAdditionalInfo _a;
    bool locked;
    address _xStarterLaunchpad;
    address admin;
    mapping(address => bool) public allowedCallers;
    
    event ILOProposalCreated(address indexed proposer, address indexed proposalAddr_, string indexed infoURL_, string tokenName_, uint totalSupply_);
    constructor(
        string memory tokenName_, 
        string memory tokenSymbol_, 
        string memory infoURL_, 
        uint totalSupply_, 
        uint8 percentOfTokensForILO_, 
        address fundingToken_, 
        address xStarterLaunchpad_
        // uint48 contribTimeLock_,
        // uint minPerSwap_,
        // uint minFundPerAddr_,
        // uint maxFundPerAddr_,
        // uint minFundingTokenRequired_,
        // uint maxFundingToken_
        // address addressOfDex_,
        // address addressOfDexFactory_
    ) {
       bool success =  _createILOProposal(
           
           tokenName_, 
           tokenSymbol_, 
           infoURL_, 
           totalSupply_, 
           percentOfTokensForILO_, 
           fundingToken_
        //   contribTimeLock_,
        //   minPerSwap_,
        //   minFundPerAddr_,
        //   maxFundPerAddr_,
        //   minFundingTokenRequired_,
        //   maxFundingToken_
        //   addressOfDex_,
        //   addressOfDexFactory_
           );
       require(success, "Not able to deploy");
      _xStarterLaunchpad = xStarterLaunchpad_;
      admin = msg.sender;
      allowedCallers[msg.sender] = true;
      emit ILOProposalCreated(msg.sender, address(this), infoURL_, tokenName_, totalSupply_);
        
    }
    function isLocked() public view returns(bool) {
        return locked;
    }
    function addMoreInfo(
        uint48 contribTimeLock_,
        uint48 liqPairLockLen_,
        uint minPerSwap_,
        uint minFundPerAddr_,
        uint maxFundPerAddr_,
        uint minFundingTokenRequired_,
        uint maxFundingToken_
        ) external returns(bool) {
            require(!locked, 'additional info already set, can not change after setting');
            locked = true;
            
            _a.contribTimeLock = contribTimeLock_;
            _a.liqPairLockLen = liqPairLockLen_;
            _a.minPerSwap = minPerSwap_;
            _a.minFundPerAddr = minFundPerAddr_;
            _a.maxFundPerAddr = maxFundPerAddr_;
            _a.minFundingTokenRequired = minFundingTokenRequired_;
            _a.maxFundingToken = maxFundingToken_;
            return true;
    }
    function getLaunchpadAddress() external  view returns(address) {
        return _xStarterLaunchpad;
    }
    function getILOInfo() external view returns(ILOProposal memory, ILOAdditionalInfo memory) {
        return (_i, _a);
    }
    function getMainInfo() external view returns(string memory tokenName, string memory tokenSymbol, string memory infoURL, uint totalSupply, uint8 percentOfTokensForILO, address fundingToken){
        
        tokenName = _i.tokenName;
        tokenSymbol = _i.tokenSymbol;
        infoURL = _i.infoURL;
        totalSupply = _i.totalSupply;
        percentOfTokensForILO = _i.percentOfTokensForILO;
        fundingToken = _i.fundingToken;
        
    }
    function addCallers(address caller_) external returns(bool) {
        require(msg.sender == admin || allowedCallers[msg.sender], "not authorized");
        allowedCallers[caller_] = true;
        return true;
        
    }
    
    function addILOAddress(address ILOAddr_) external returns(bool) {
        require(msg.sender == _xStarterLaunchpad, 'not authorized');
        _i.ILOAddress = ILOAddr_;
        _i.deployedBlockNumber = block.number;
        _i.deployedTimestamp = block.timestamp;
        _i.isDeployed = true;
        _i.isApproved = true;
        _i.isOpen = false;
        return true;
    }
    
    function _createILOProposal(
        string memory tokenName_, 
        string memory tokenSymbol_,
        string memory infoURL_, 
        uint totalSupply_, 
        uint8 percentOfTokensForILO_, 
        address fundingToken_
        // uint48 contribTimeLock_,
        // uint minPerSwap_,
        // uint minFundPerAddr_,
        // uint maxFundPerAddr_,
        // uint minFundingTokenRequired_,
        // uint maxFundingToken_
        // address addressOfDex_,
        // address addressOfDexFactory_
        ) internal returns(bool) {
        
        
        // bytes32 memory proposalHash = keccak256(abi.encode(tokenName_, tokenSymbol_, totalSupply_, percentOfTokensForILO_, _msgSender()));
        _i = ILOProposal(
            msg.sender,
            msg.sender,
            fundingToken_,
            tokenName_, 
            tokenSymbol_, 
            infoURL_,
            totalSupply_, 
            18, 
            percentOfTokensForILO_, 
            block.number, 
            block.timestamp, 
            false, 
            true,
            0,
            0,
            false,
            address(0)
            // contribTimeLock_,
            // minPerSwap_,
            // minFundPerAddr_,
            // maxFundPerAddr_,
            // minFundingTokenRequired_,
            // maxFundingToken_
            // addressOfDex_,
            // addressOfDexFactory_
        );
        
        return true;
        
    }
}