// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;


import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC777/IERC777Recipient.sol";
import "@openzeppelin/contracts/token/ERC777/IERC777Sender.sol";
import "@openzeppelin/contracts/token/ERC777/ERC777.sol";
import "@openzeppelin/contracts/token/ERC777/ERC777.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "./Administration.sol";
import "./xStarterPoolPair.sol";

struct ILOProposal {
    string tokenName;
    string tokenSymbol;
    uint totalSupply;
    uint8 decimals;
    uint8 percentOfTokensForILO;
    address tokenAddress;
    uint blockNumber;
    
}

struct GovernanceProposal {
    address proposer;
    string proposalHash;
}

contract xStarterLaunchPad is Ownable{
    using SafeMath for uint256;
    using Address for address;
    
    mapping(string => ILOProposal) ILOProposals;
    mapping(string => GovernanceProposal) govProposals;
    
    
}