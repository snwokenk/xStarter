// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;



interface IUniswapRouter {
        function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    
    // add liquidity, this will automatically create a pair for WETH
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    
    // get the WETH address
    function WETH() external pure returns (address);
}

contract LPLaunch {
    uint balanceVal;
    mapping(address => uint) balances;
    address _addressOfDex = address(0xB1Ffd5BA1fdE7Abe45b0b161e491c0fA8dFEF92B);
    
    
    function getBalance() public view returns(uint balance){
        balance = balances[msg.sender];
    }
    function sendNativeToken() payable external returns(bool) {
        require(msg.value > 0, "must send value");
        balances[msg.sender] += msg.value;
        balanceVal += msg.value;
        return true;
    }
    function withdrawBalance() external returns(bool success){
        uint amount_ =  balances[msg.sender];
        require(amount_ > 0);
        balances[msg.sender] = 0;
        (success, ) = address(msg.sender).call{value: amount_}('');
        
    }
    function createLiquidityPairETH(address _projectToken) external returns(uint liquidityTokens_) {
        uint _fundingTokenAvail = address(this).balance;
        //require(address(0) == _fundingToken, "xStarterPair: FundingTokenError");
        uint amountETH = _fundingTokenAvail;
        uint amountProjectToken = 500000000 ether;
        
        // approve project token to be sent to dex. Spender is dex IUniswapRouter address (honeyswap, uniswap etc)
        //bool approved_ = _callApproveOnProjectToken(_addressOfDex, amountProjectToken);
       
        
        (uint amountTokenInPool, uint amountETHInPool, uint amountliquidityToken) = IUniswapRouter(_addressOfDex).addLiquidityETH{value: amountETH}(
            _projectToken,
            amountProjectToken,
            amountProjectToken,
            amountETH,
            address(this),
            block.timestamp + 1800
            );
        
        liquidityTokens_ = amountliquidityToken;
        
        // _fundingTokenAvail = 0;
        // // subtract amount sent to liquidity pool from this
        // _totalTokensSupplyControlled =  _totalTokensSupplyControlled.sub(amountProjectToken);
        // _tokensForLiquidity = 0;
        
        
    }
}