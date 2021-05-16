// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

struct ILOProposal {
    address proposer;
    address admin;
    address fundingToken;
    string tokenName;
    string tokenSymbol;
    string infoURL;
    uint totalSupply;
    uint8 decimals; // set at 18
    uint8 percentOfTokensForILO; // (minimum 50%)
    uint blockNumber;
    uint timestamp;
    bool isApproved;
    bool isOpen;
    uint deployedBlockNumber;
    uint deployedTimestamp;
    bool isDeployed;
    address ILOAddress;
}
interface iXstarterProposal {
    function getILOInfo() external view returns(ILOProposal memory);
    function addILOAddress(address ILOAddr) external returns(bool);
    function getLaunchpadAddress() external  view returns(address);
    function getMainInfo() external view returns(string memory tokenName, string memory tokenSymbol, string memory infoURL, uint totalSupply, uint8 percentOfTokensForILO, address fundingToken);
}

contract xStarterProposal {
    ILOProposal _i;
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
    ) {
       bool success =  _createILOProposal(tokenName_, tokenSymbol_, infoURL_, totalSupply_, percentOfTokensForILO_, fundingToken_);
       require(success, "Not able to deploy");
       _xStarterLaunchpad = xStarterLaunchpad_;
       admin = msg.sender;
       allowedCallers[msg.sender] = true;
       emit ILOProposalCreated(msg.sender, address(this), infoURL_, tokenName_, totalSupply_);
        
    }
    function getLaunchpadAddress() external  view returns(address) {
        return _xStarterLaunchpad;
    }
    function getILOInfo() external view returns(ILOProposal memory) {
        return _i;
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
        return true;
    }
    
    function _createILOProposal(string memory tokenName_, string memory tokenSymbol_, string memory infoURL_, uint totalSupply_, uint8 percentOfTokensForILO_, address fundingToken_) internal returns(bool) {
        
        
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
        );
        
        return true;
        
    }
}