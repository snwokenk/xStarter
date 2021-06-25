// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./xStarterStructs.sol";

interface IXstarterProposal {
    function getCompactInfo() external view returns(CompactInfo memory);
    function addMoreInfo(
        uint48 contribTimeLock_,
        uint48 liqPairLockLen_,
        uint minPerSwap_,
        uint minPerAddr_,
        uint maxPerAddr_,
        uint softcap_,
        uint hardcap_,
        uint8 percentTokensForTeam_ 
        ) external returns(bool);
}

interface IXStarterLaunchpad {
    function deployXstarterILO(address proposalAddr_) external  returns(address ILO);
    function getProposal(address proposalAddr_) external view returns(CompactInfo memory i_);
    function xStarterDEXUsed() external view returns(address dexAddress, address dexFactoryAddress);
    function xStarterContracts() external view returns(address[5] memory);
}

interface IXstarterPoolPair {
    function setUpPoolPair(
        address addressOfProjectToken,
        string memory tokenName_,
        string memory tokenSymbol_,
        uint totalTokenSupply_,
        uint48 startTime_, 
        uint48 endTime_
        ) external returns(bool);
}