// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./xStarterStructs.sol";

interface iXstarterProposal {
    function setILOTimes(uint48 startTime_, uint48 endTime_, address projectToken_) external returns(bool);
    function setStatus(uint8 status_) external returns(bool);
    function getStatus() external view returns(uint8);
    function setTokenAndLPAddr(address projectToken_, address liqPairAddr_) external returns(bool);
     function getTokenAndLPAddr() external view returns(address, address);
    function setAmountRaised(uint amountRaised_) external returns(bool);
    function getILOInfo1() external view returns(ILOProposal memory);
    function getILOInfo2() external view returns(ILOAdditionalInfo memory);
    function getILOInfo() external view returns(ILOProposal memory, ILOAdditionalInfo memory);
    function getCompactInfo() external view returns(CompactInfo memory);
    function isDeployed() external view returns(bool);
    function isALlowedCaller(address caller_) external view returns(bool);
    function deploy(address ILOAddr) external returns(bool);
    function register(address xStarterGov_) external returns(bool);
    function approve() external returns(bool);
    function approved() external view returns(bool);
    function getLaunchpadAddress() external  view returns(address);
    function getMainInfo() external view returns(string memory tokenName, string memory tokenSymbol, string memory infoURL, uint totalSupply, uint8 percentOfTokensForILO, address fundingToken);
}

interface iXstarterGovernance {
    function ILOApproved(address proposalAddr_) external view returns(bool);
    function isILOVoter(address proposalAddr_, address voter_) external view returns(bool);
    function isGOVVoter(string memory proposalName_, address voter_) external view returns(bool);
    function validateILOVotes(address proposalAddr_) external returns(bool results);
    function getILOPoll(address proposalAddr_) external view returns (ILOPoll memory poll_);
}