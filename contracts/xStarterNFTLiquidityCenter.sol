// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import "./ERC777ReceiveSend.sol";
import "@openzeppelin/contracts/token/ERC777/IERC777Recipient.sol";
import "@openzeppelin/contracts/token/ERC777/IERC777Sender.sol";
import "@openzeppelin/contracts/token/ERC777/IERC777.sol";
import "@openzeppelin/contracts/utils/introspection/ERC1820Implementer.sol";
import "@openzeppelin/contracts/utils/introspection/IERC1820Registry.sol";
import "@openzeppelin/contracts/access/Ownable.sol";



contract xStarterNFTLiquidityCenter is Ownable, ERC1820Implementer, IERC777Sender, IERC777Recipient{
    
    IERC1820Registry constant internal _ERC1820_REGISTRY = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);
    string NFTName;
    string NFTSymbol;
    address ERCToken; // erc20 token for conversion to NFT
    address NFT;
    uint rate;
    uint maxNFTSupply;
    mapping(address => uint) balances;
    
    function balanceOf(address _holder) public view returns(uint) {
        return balances[_holder];
    }
    
    constructor(
        string memory _NFTName,
        string  memory _NFTSymbol,
        address _ERC777Token,
        uint _ERC20ToERC77Rate,
        uint _maxNFTSupply
    )
    {
        NFTName = _NFTName;
        NFTSymbol = _NFTSymbol;
        ERCToken = _ERC777Token;
        rate = _ERC20ToERC77Rate;
        maxNFTSupply = _maxNFTSupply;
        bytes32  _interfaceHashSender = _ERC1820_REGISTRY.interfaceHash("ERC777TokensSender");
        bytes32  _interfaceHashReceiver = _ERC1820_REGISTRY.interfaceHash("ERC777TokensRecipient");
        _registerInterfaceForAddress(_interfaceHashSender, address(this));
        _ERC1820_REGISTRY.setInterfaceImplementer(address(0), _interfaceHashSender, address(this));
        _registerInterfaceForAddress(_interfaceHashReceiver, address(this));
        _ERC1820_REGISTRY.setInterfaceImplementer(address(0), _interfaceHashReceiver, address(this));
    }
    
    // called when an ERC777 token is about to be sent to contract
    function tokensToSend(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external view  override {
        // check to see if NFTs available
        // check balance of this address
        revert('not token sender');
        // require(msg.sender == ERCToken, 'not associated token');
    }
    
    function setNFTAddress(address _NFT) public onlyOwner returns(bool) {
        NFT = _NFT;
        return true;
    }
    
     // called when an ERC777 token is about to be sent to contract
    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external  override{
        require(msg.sender == ERCToken, 'not associated token');
        // verify balance of using msg.sender, then credit
        balances[from] = balances[from] + amount;
    }
    
    function sendToken(address _addr, uint _amount) public {
        IERC777(ERCToken).send(_addr, _amount, "");
    }
}