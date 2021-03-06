// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC777ReceiveSend.sol";
import "@openzeppelin/contracts/token/ERC777/ERC777.sol";
import "@openzeppelin/contracts/access/Ownable.sol";



contract xStarterToken is Ownable, ERC777, ERC777NoReceiveRecipient, ERC777NoSendSender {
    constructor(
        uint256 initialSupply,
        address[] memory defaultOperators
    )
        ERC777("xStarterToken", "XSTN", defaultOperators)
    {
        _mint(msg.sender, initialSupply * 10 ** decimals(), "", "");
    }
}
