// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./xStarterStructs.sol";


contract xStarterProposal {
    ILOProposal _i;
    ILOAdditionalInfo _a;
    bool locked;
    address _xStarterLaunchpad;
    address _xStarterGov;
    // address _ILOAddress;
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
        // uint minPerAddr_,
        // uint maxPerAddr_,
        // uint softcap_,
        // uint hardcap_
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
           );
       require(success, "Not able to deploy");
      _xStarterLaunchpad = xStarterLaunchpad_;
      admin = msg.sender;
      allowedCallers[msg.sender] = true;
      emit ILOProposalCreated(msg.sender, address(this), infoURL_, tokenName_, totalSupply_);
        
    }
    
    function isAllowedCaller(address caller_) public view returns(bool) {
        return allowedCallers[caller_];
    }
    function isLocked() public view returns(bool) {
        return locked;
    }
    function addMoreInfo(
        uint48 contribTimeLock_,
        uint48 liqPairLockLen_,
        uint minPerSwap_,
        uint minPerAddr_,
        uint maxPerAddr_,
        uint softcap_,
        uint hardcap_,
        uint8 percentTokensForTeam_ 
        ) external returns(bool) {
            require(!locked, 'additional info already set, can not change after setting');
            locked = true;
            
            _a.contribTimeLock = contribTimeLock_;
            _a.liqPairLockLen = liqPairLockLen_;
            _a.minPerSwap = minPerSwap_;
            _a.minPerAddr = minPerAddr_;
            _a.maxPerAddr = maxPerAddr_;
            _a.softcap = softcap_;
            _a.hardcap = hardcap_;
            _a.percentTokensForTeam = percentTokensForTeam_;
            return true;
    }
    function getLaunchpadAddress() external  view returns(address) {
        return _xStarterLaunchpad;
    }
    function getILOInfo1() external view returns(ILOProposal memory) {
        return _i;
    }
    function getILOInfo2() external view returns(ILOAdditionalInfo memory) {
        return _a;
    }
    function getILOInfo() external view returns(ILOProposal memory, ILOAdditionalInfo memory) {
        return (_i, _a);
    }
    function getCompactInfo() external view returns(CompactInfo memory) {
        return CompactInfo(address(this), _i, _a);
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
    function isDeployed() public view returns(bool) {
        
        return _i.isDeployed;
        
    }
    
    function deploy(address ILOAddr_) external returns(bool) {
        require(msg.sender == _xStarterLaunchpad, 'not authorized');
        _i.ILOAddress = ILOAddr_;
        _i.deployedBlockNumber = block.number;
        _i.deployedTimestamp = block.timestamp;
        _i.isDeployed = true;
        _i.isOpen = false;
        _i.ILOAddress = ILOAddr_;
        return true;
        
    }
    
    function register(address xStarterGov_) external returns(bool) {
        require(msg.sender == _xStarterLaunchpad, 'not authorized');
        _xStarterGov = xStarterGov_;
        _i.isRegistered = true;
        return true;
    }
    
    function setTokenAndLPAddr(address projectToken_, address liqPairAddr_) external returns(bool) {
        _a.liqPairAddr = liqPairAddr_;
        _a.projectToken = projectToken_;
        return true;
    }
    
    function getTokenAndLPAddr() external view returns(address, address) {
        return (_a.liqPairAddr, _a.projectToken);
    }
    
    
    function setILOTimes(uint48 startTime_, uint48 endTime_, address projectToken_) external returns(bool) {
        require(_i.ILOAddress != address(0) && msg.sender == _i.ILOAddress, 'not authorized');
        _a.startTime = startTime_;
        _a.endTime = endTime_;
        _a.projectToken = projectToken_;
        return true;
    }
    function setStatus(uint8 status_) public returns(bool) {
        require(_i.ILOAddress != address(0) && msg.sender == _i.ILOAddress, 'not authorized');
        require(status_ > _a.ILOStatus);
        _a.ILOStatus = status_;
        return true;
    }
    function getStatus() public view returns(uint8) {
        return _a.ILOStatus;
    }
    function setAmountRaised(uint amountRaised_) external returns(bool) {
        require(_i.ILOAddress != address(0) && msg.sender == _i.ILOAddress, 'not authorized');
        _a.amountRaised = amountRaised_;
        return true;
        
    }
    function approved() external view returns(bool) {
        return _i.isApproved;
    }
    
    function approve() external returns(bool) {
        require(msg.sender == _xStarterGov, 'not authorized');
        _i.isApproved = true;
        return true;
    }
    
    function _createILOProposal(
        string memory tokenName_, 
        string memory tokenSymbol_,
        string memory infoURL_, 
        uint totalSupply_, 
        uint8 percentOfTokensForILO_, 
        address fundingToken_
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
            false,
            true,
            0,
            0,
            false,
            address(0)
        );
        
        return true;
        
    }
}