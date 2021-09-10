// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC777ReceiveSend.sol";
import "@openzeppelin/contracts/token/ERC721/presets/ERC721PresetMinterPauserAutoId.sol";
// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";



contract xStarterConvertibleNFT is Ownable, ERC721PresetMinterPauserAutoId, ERC777NoReceiveRecipient, ERC777NoSendSender {
    using Counters for Counters.Counter;
    uint public maxSupply;
    uint public supplyReserved;
    uint public maxPerTx;
    uint public maxPerAddr;
    uint public mintPrice;
    
    
    uint contractBalance;
    Counters.Counter internal _tokenIdTracker;
    constructor(
        string memory _name,
        string  memory _symbol,
        string memory _baseNFTURI,
        uint _maxSupply,
        uint _maxPerTx,
        uint _maxPerAddr,
        uint _mintPrice,
        uint _supplyReserved
    )
        ERC721PresetMinterPauserAutoId(_name, _symbol, _baseNFTURI)
    {
       maxSupply = _maxSupply;
       maxPerTx = _maxPerTx;
       maxPerAddr = _maxPerAddr;
       mintPrice = _mintPrice;
       supplyReserved = _supplyReserved;
    }
    
    // edit 
    // function _baseURI() internal pure override returns (string memory) {
    //     return "";
    // }
    
     function withdraw() public onlyRole(getRoleAdmin(DEFAULT_ADMIN_ROLE)) returns(bool success) {
         require(contractBalance > 0, 'zero balance');
         uint amount_ = contractBalance;
         contractBalance = 0;
         (success, ) = msg.sender.call{value: amount_}('');
     }
    
    function mintBirds(uint noOfBirds) public payable {
        require(balanceOf(msg.sender) + noOfBirds <= maxPerAddr, 'max per address reached');
        require(noOfBirds > 0 && noOfBirds <= maxPerTx, 'number of birds to mint not valid');
        require(totalSupply() + noOfBirds <= maxSupply - supplyReserved, 'no more NFTs to mint');
        require(noOfBirds * mintPrice == msg.value, 'correct payment not sent');
        contractBalance += msg.value;
        for(uint i=0; i<noOfBirds; i++) {
            _mint(msg.sender, _tokenIdTracker.current());
            _tokenIdTracker.increment();
        }
        
    }
    
    
    // used to grand minter role to management contract and renounce all roles from contract
    function grantAndRenounceMinterAdminRole(address account) public onlyRole(getRoleAdmin(DEFAULT_ADMIN_ROLE)) {
        require(contractBalance == 0, 'contract must have a zero balance, call withdraw');
        grantRole(MINTER_ROLE, account);
         grantRole(PAUSER_ROLE, account);
        renounceRole(MINTER_ROLE, msg.sender);
        renounceRole(PAUSER_ROLE, msg.sender);
        renounceRole(DEFAULT_ADMIN_ROLE, msg.sender);
        // require(getRoleMemberCount(MINTER_ROLE) == 1 && getRoleMemberCount(PAUSER_ROLE) == 1)
        
    }
    
    
}