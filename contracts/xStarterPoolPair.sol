// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC777/IERC777Recipient.sol";
import "@openzeppelin/contracts/token/ERC777/IERC777Sender.sol";

contract xStarterPoolPair is Ownable {
    
    // stores address of the project's token
    address projectToken;
    
    // uint keeping track of total project's token supply
    uint totalTokensSupply;
    
    // uint keeping of set aside for ILO
    uint totalTokensILO;
    
    // tokens remaining for ILO
    uint availTokensILO;
    
    
    
}