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
struct ILOAdditionalInfo {
    uint48 contribTimeLock;
    uint minPerSwap;
    uint minFundPerAddr;
    uint maxFundPerAddr;
    uint minFundingTokenRequired;
    uint maxFundingToken;
}