// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/presets/ERC721PresetMinterPauserAutoId.sol";
// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract xStarterNFTDeployTemplate is Ownable, ERC721PresetMinterPauserAutoId {
    
    using Counters for Counters.Counter;
    uint public maxSupply;
    uint public supplyReserved;
    uint public maxPerTx;
    uint public maxPerAddr;
    uint public mintPrice;
    bool public mintingAllowed;
    
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
    
    function withdraw() public onlyRole(getRoleAdmin(DEFAULT_ADMIN_ROLE)) returns(bool success) {
         require(address(this).balance > 0, "zero balance");
         (success, ) = msg.sender.call{value: address(this).balance}("");
     }
     
    function setMintAllowed(bool _mintAllow) public onlyRole(getRoleAdmin(DEFAULT_ADMIN_ROLE)) {
        mintingAllowed = _mintAllow;
    }
    
    function mint(address to) public  override virtual {
        require(hasRole(MINTER_ROLE, _msgSender()), "ERC721PresetMinterPauserAutoId: must have minter role to mint");

        // We cannot just use balanceOf to create the new tokenId because tokens
        // can be burned (destroyed), so we need a separate counter.
        _mint(to, _tokenIdTracker.current());
        _tokenIdTracker.increment();
    }
    
    function mintNFTs(uint noOfNFTs) public payable {
        require(mintingAllowed, "minting not allowed");
        require(balanceOf(msg.sender) + noOfNFTs <= maxPerAddr, "max per address reached");
        require(noOfNFTs > 0 && noOfNFTs <= maxPerTx, "number of birds to mint not valid");
        require(totalSupply() + noOfNFTs <= maxSupply - supplyReserved, "no more NFTs to mint");
        require(noOfNFTs * mintPrice == msg.value, "correct payment not sent");

        for(uint i=0; i<noOfNFTs; i++) {
            _mint(msg.sender, _tokenIdTracker.current());
            _tokenIdTracker.increment();
        }
        
    }
    function mintReservedNFTS(address[] memory _addrs) public onlyRole(getRoleAdmin(DEFAULT_ADMIN_ROLE)) {
        require(_addrs.length > 0, "no addresses");
        require(_addrs.length <= supplyReserved, 'not enough reserved NFTs');
        supplyReserved -= _addrs.length;
        for(uint i=0; i<_addrs.length; i++) {
            _mint(_addrs[i], _tokenIdTracker.current());
            _tokenIdTracker.increment();
        }
    }
    
    
}