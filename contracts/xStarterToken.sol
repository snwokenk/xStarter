// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/token/ERC777/ERC777.sol";
import "@openzeppelin/contracts/token/ERC777/IERC777Recipient.sol";
import "@openzeppelin/contracts/token/ERC777/IERC777Sender.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


abstract contract ERC777Recipient is IERC777Recipient {
    
    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external pure override{
        // this contract shouldn't receive tokens
        revert();
    }

}
abstract contract ERC777Sender is IERC777Sender {
    function tokensToSend(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external pure override {
        revert();
    }
}
contract XStarterToken is Ownable, ERC777, ERC777Recipient, ERC777Sender {
    constructor(
        uint256 initialSupply,
        address[] memory defaultOperators
    )
        ERC777("xStarterToken", "XSTN", defaultOperators)
        public
    {
        _mint(msg.sender, initialSupply * 10 ** 18, "", "");
    }
}
