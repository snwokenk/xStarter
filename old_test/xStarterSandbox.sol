// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;



contract Sandbox {
    uint8 public _percentOfILOTokensForLiquidity = 50;
    uint public _totalTokensILO = 350000000 ether;
    uint public _amountForProjTokenCalc = 0;
    uint public _fundingTokenTotal = 2 ether;
    uint public fundersAmount = 1 ether;
    
    function _getProjTknBal() external view returns(uint balance) {
        // *** CHECK TO MAKE SURE PROJECT TOKENS ARE NOT WITHDRAWN BEFORE CALLING THIS FUNCTION ***
        
        uint tokensForContributors = _totalTokensILO - _amountForProjTokenCalc;
        
        // uint amtPer = _fundingTokenTotal / (10 ** 18);
        uint amtPer = tokensForContributors / _fundingTokenTotal;
        // lpPer * fundingTokenAmount to get lp tokens to send
        balance  = fundersAmount * amtPer;
        
    }
}