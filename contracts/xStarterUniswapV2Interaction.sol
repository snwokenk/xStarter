// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

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
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

//  interface for router
interface IRouter02 is IRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

// interface for a uniswap or uniswap fork LP pair
interface IPair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// erc20 interface
interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

interface IFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;

    function INIT_CODE_PAIR_HASH() external view returns (bytes32);
}


struct TokenInfo {
    string name;
    string symbol;
    uint8 decimals;
    uint addrBalance;
    
}

import "@openzeppelin/contracts/access/Ownable.sol";
contract xStarterUniswapV2Interaction is Ownable  {
    // change these constants when deploying to other chains

    address public router;
    address public factory;
    address public WETH;
    address public USD;
        // if using other blockchain might be different. ETH's USDT uses 6 decimals, BUSD uses 18. initially deploying fo BUSD
    // todo: create a way to dynamically 
    uint8 public USDDecimal = 18;

    constructor(address _WETH, address _USD, address _router, address _factory) {
        // ensure that USD pair meant to represent USD has a pair with WETH and is liquid, for example on BSC the representation should be BUSD
        WETH = _WETH;
        USD = _USD;
        router = _router;
        factory = _factory;
    }
    function getUSDAmountOfWETH(uint WETHAmount) public view returns(uint256 USDEquivAmount) {
        address[] memory paths = new address[](2);
        paths[0] = WETH;
        paths[1] = USD;
        uint[] memory amounts = IRouter02(router).getAmountsOut(WETHAmount, paths);
        USDEquivAmount = amounts[1];
        
    }

    function getTokenInfoAndUSDEquivalent(uint256 WETHAmount, address outToken, address addressToFindBalance) public view returns(TokenInfo memory outTokenInfo, uint256 USDEquivAmount) {
        USDEquivAmount = getUSDAmountOfWETH(WETHAmount);
        outTokenInfo.name = IERC20(outToken).name();
        outTokenInfo.symbol = IERC20(outToken).symbol();
        outTokenInfo.decimals = IERC20(outToken).decimals();
        if(addressToFindBalance != address(0)) {
            outTokenInfo.addrBalance = IERC20(outToken).balanceOf(addressToFindBalance);
        }
    }
    function getBestQuote(uint256 inTokenAmount, address inToken, address otherToken, address outToken) public view returns(address[] memory route, uint256 quote) {
        
        address inTokenPair = IFactory(factory).getPair(inToken, outToken);
        address otherTokenPair = IFactory(factory).getPair(otherToken, outToken);
        require(inTokenPair != address(0) || otherTokenPair != address(0), "No Pairs" );
        
        // first get rate of inToken to other Token
        address[] memory paths = new address[](2);
        paths[0] = inToken;
        paths[1] = otherToken;
        // amounts[1] is the otherTokenAmount equivalent ie if inTokenAmount was 1 bnb and otherToken was BUSD this returns 559, then that's the otherTokenAmount
        uint[] memory amounts;
        uint otherTokenAmount;
        if(otherTokenPair != address(0)) {
            amounts = IRouter02(router).getAmountsOut(inTokenAmount, paths);
            otherTokenAmount = amounts[1];
        }else {
            otherTokenAmount = 0;
        }


        // get quote for inToken
        paths[1] = outToken;
        amounts = IRouter02(router).getAmountsOut(inTokenAmount, paths);
        uint quoteForIntoken;
        if(inTokenPair != address(0)) {
            amounts = IRouter02(router).getAmountsOut(inTokenAmount, paths);
            quoteForIntoken = amounts[1];
        }else {
            quoteForIntoken = uint256(0);
        }

        // get quote for otherToken
        paths[0] = otherToken;
        uint quoteForOtherToken;
        if(otherTokenPair != address(0)) {
            amounts = IRouter02(router).getAmountsOut(otherTokenAmount, paths);
            quoteForOtherToken = amounts[1];
        }else {
            quoteForOtherToken = 0;
        }

        // intoken (direct purchase is the best) 
        if(quoteForIntoken >= quoteForOtherToken) {
            route = new address[](2);
            route[0] = inToken;
            route[1] = outToken;
            quote = quoteForIntoken;
        }else {
            // purchasing outToken by first purchasing the 3rd party token is best
            route = new address[](3);
            route[0] = inToken;
            route[1] = otherToken;
            route[2] = outToken;
            quote = quoteForOtherToken;
        }
    }

    // use this to get quote for crypto when using native token (BNB, ETH, AVAX, MATIC) etc
    // this checks to see if a direct purchase or a purchase using a USD equivalent is better
    // this also returns the USD equivalent of the WETHAmount, allowing for a easy calculations of desired token amount in $
    function getBestQuoteUsingWETH(uint256 WETHAmount, address outToken) public view returns(address[] memory route, uint256 quote, uint256 USDEquivAmount) {
        
        address WETHPair = IFactory(factory).getPair(WETH, outToken);
        address USDPair = IFactory(factory).getPair(USD, outToken);
        require(WETHPair != address(0) || USDPair != address(0), "No Pairs" );
        
        // first get rate of WETH/WBNB/WAVAX etc to USD Token (BUSD, USDT) depending on chain
        address[] memory paths = new address[](2);
        paths[0] = WETH;
        paths[1] = USD;
        uint[] memory amounts;
        amounts = IRouter02(router).getAmountsOut(WETHAmount, paths);
        USDEquivAmount = amounts[1];
        //amounts[1] is WETH/USD rate, check to see if desired token has a USD pair before making function call
        // if(USDPair != address(0)) {
        //     amounts = IRouter02(router).getAmountsOut(WETHAmount, paths);
        //     USDEquivAmount = amounts[1];
        // }else {
        //     USDEquivAmount = 0;
        // }


        // get amount of desired token for WETH amount
        paths[1] = outToken;
        uint amountForWETH;

        // if desired token has a WETH pair
        if(WETHPair != address(0) && IPair(WETHPair).totalSupply() > 0) {
            amounts = IRouter02(router).getAmountsOut(WETHAmount, paths);
            amountForWETH = amounts[1];
        }else {
            amountForWETH = 0;
        }

        // get amount of desired token for USD amount equivalent
        paths[0] = USD;
        uint amountForUSD;
        if(USDPair != address(0) && IPair(USDPair).totalSupply() > 0) {
            amounts = IRouter02(router).getAmountsOut(USDEquivAmount, paths);
            amountForUSD = amounts[1];
        }else {
            amountForUSD = 0;
        }

        // intoken (direct purchase is the best) 
        if(amountForWETH >= amountForUSD) {
            route = new address[](2);
            route[0] = WETH;
            route[1] = outToken;
            quote = amountForWETH;
        }else {
            // purchasing outToken by first purchasing the 3rd party token is best
            route = new address[](3);
            route[0] = WETH;
            route[1] = USD;
            route[2] = outToken;
            quote = amountForUSD;
        }
    
    
    
    }
    function getBestQuoteUsingTokenToWETH(address inToken, uint256 tokenAmount) public view returns(address[] memory route, uint256 quote) {
        
        address WETHPair = IFactory(factory).getPair(WETH, inToken);
        address USDPair = IFactory(factory).getPair(USD, inToken);
        require(WETHPair != address(0) || USDPair != address(0), "No Pairs" );

        
        // first get rate of Token to WETH/WBNB/WAVAX route
        address[] memory paths = new address[](2);
        paths[0] = inToken;
        paths[1] = WETH;
        uint[] memory amounts;
        uint tokenToETHAmt;
        //amounts[1] is WETH/USD rate, check to see if desired token has a USD pair before making function call
        if(WETHPair != address(0) && IPair(WETHPair).totalSupply() > 0) {
            amounts = IRouter02(router).getAmountsOut(tokenAmount, paths);
            tokenToETHAmt = amounts[1];
        }else {
            tokenToETHAmt = 0;
        }

        // then get rate of Token to USD pair to WBNB
        paths = new address[](3);
        paths[0] = inToken;
        paths[1] = USD;
        paths[2] = WETH;
        uint tokenToUSDToETHAmt;
        // if desired token has a WETH pair
        if(USDPair != address(0) && IPair(USDPair).totalSupply() > 0) {
            amounts = IRouter02(router).getAmountsOut(tokenAmount, paths);
            tokenToUSDToETHAmt = amounts[2];
        }else {
            tokenToUSDToETHAmt = 0;
        }

        // intoken (direct purchase is the best) 
        if(tokenToETHAmt >= tokenToUSDToETHAmt) {
            route = new address[](2);
            route[0] = inToken;
            route[1] = WETH;
            quote = tokenToETHAmt;
        }else {
            // purchasing outToken by first purchasing the 3rd party token is best
            route = new address[](3);
            route[0] = inToken;
            route[1] = USD;
            route[2] = WETH;
            quote = tokenToUSDToETHAmt;
        }
    
    
    
    }

    function getBestQuoteAndSymbolUsingWETH(uint256 WETHAmount, address outToken, address addressToFindBalance) public view returns(address[] memory route, TokenInfo memory outTokenInfo, uint256 quote, uint256 USDEquivAmount) {
        (route, quote, USDEquivAmount) = getBestQuoteUsingWETH(WETHAmount, outToken);
        outTokenInfo.name = IERC20(outToken).name();
        outTokenInfo.symbol = IERC20(outToken).symbol();
        outTokenInfo.decimals = IERC20(outToken).decimals();
        if(addressToFindBalance != address(0)) {
            outTokenInfo.addrBalance = IERC20(outToken).balanceOf(addressToFindBalance);
        }
    }

    function checkSwapETHForTokensUsingDataFromBlockchain(address outToken, uint minOutTokens, uint slippage, uint msgVal) public view returns(address[] memory route, uint256 quote, uint minQuote, bool enoughTokens) {
        require(slippage >= 10 && slippage < 10000, "percentage must be between 10 and 9999 inclusively");
        // uint256 USDEquivAmount;
        // slippage of 100 === 1% slippage
        (route, quote, ) = getBestQuoteUsingWETH(msgVal, outToken);
        minQuote = (quote * slippage) / 10000; // 0.5% slippage
        enoughTokens = minQuote >= minOutTokens;
        require(minQuote >= minOutTokens, "Tokens to receive less than minimum");

    }

    // minOutTokens could be considered used as slippage or as a price point
    // for example, imagine a token is about to be added to a DEX at a rate of $0.10 
    function swapETHForTokensUsingDataFromBlockchain(address outToken, uint minOutTokens, uint slippage) public payable returns(address[] memory route, uint256 quote, uint minQuote) {
        require(slippage >= 10 && slippage < 10000, "percentage must be between 10 and 9999 inclusively");

        // uint256 USDEquivAmount;
        (route, quote, ) = getBestQuoteUsingWETH(msg.value, outToken);
        minQuote = (quote * slippage) / 10000; // 0.5% slippage
        require(minQuote >= minOutTokens, "Tokens to receive less than minimum");
        IRouter02(router).swapExactETHForTokensSupportingFeeOnTransferTokens{value:msg.value}(minQuote, route, msg.sender, block.timestamp + 7);
        // actualAmount = amounts[amounts.length - 1];


    }

    function checkSwapPercentOfApprovedBalance(address tokenAddr, uint8 percentage, uint minETHAmt) public view returns (address[] memory route, uint256 quote, uint minQuote) {
        require(percentage >= 1 && percentage <= 100, "percentage must be between 1 and 100 inclusively");

        // verify approval greater than zero
        uint approvalAmt = IERC20(tokenAddr).allowance(msg.sender, address(this));
        uint sellingAmt = (approvalAmt * percentage)/ 100;
        require(sellingAmt > 0, "not enough to sell, check approved amounts");
        uint senderBalance = IERC20(tokenAddr).balanceOf(msg.sender);
        require(senderBalance >= sellingAmt, "Not enough tokens to swap");

        // check current rate
        (route, quote) = getBestQuoteUsingTokenToWETH(tokenAddr, sellingAmt);
        minQuote = (quote * 9800) / 10000; // 0.5% slippage
        require(minQuote >= minETHAmt, "ETH to receive less than minimum");

    }

    // // before calling this make sure to approve tokens on this address (not the dex)
    // // this will sell the percentage of all approved tokens, so if you have 500 approved tokens and percentage is 50, it will swap  250 tokens
    // function swapPercentOfApprovedBalance(address tokenAddr, uint8 percentage, uint minETHAmt) public returns (address[] memory route, uint256 quote, uint minQuote) {
    //     require(percentage >= 1 && percentage <= 100, "percentage must be between 1 and 100 inclusively");

    //     // verify approval greater than zero
    //     uint approvalAmt = IERC20(tokenAddr).allowance(msg.sender, address(this));
    //     uint sellingAmt = (approvalAmt * percentage)/ 100;
    //     require(sellingAmt > 0, "not enough to sell, check approved amounts");
    //     uint senderBalance = IERC20(tokenAddr).balanceOf(msg.sender);
    //     require(senderBalance >= sellingAmt, "Not enough tokens to swap");

    //     // check current rate
    //     (route, quote) = getBestQuoteUsingTokenToWETH(tokenAddr, sellingAmt);
    //     minQuote = (quote * 9800) / 10000; // 0.5% slippage
    //     require(minQuote >= minETHAmt, "ETH to receive less than minimum");

    //     // send token to address
    //     IERC20(tokenAddr).transferFrom(msg.sender, address(this), sellingAmt);
    //     // approve router
    //     IERC20(tokenAddr).approve(router, sellingAmt);
    //     IRouter02(router).swapExactTokensForETHSupportingFeeOnTransferTokens(sellingAmt, minQuote, route, msg.sender, block.timestamp + 7);

    // }

    // before calling this make sure to approve tokens on this address (not the dex)
    // this will sell the percentage of all approved tokens, so if you have 500 approved tokens and percentage is 50, it will swap  250 tokens
    function swapPercentOfApprovedBalanceWithSlippage(address tokenAddr, uint8 percentage, uint minETHAmt, uint slippage) public returns (address[] memory route, uint256 quote, uint minQuote) {
        require(percentage >= 1 && percentage <= 100, "percentage must be between 1 and 100 inclusively");
        require(slippage >= 1 && slippage < 100, "percentage must be between 1 and 99 inclusively");

        // verify approval greater than zero
        uint approvalAmt = IERC20(tokenAddr).allowance(msg.sender, address(this));
        uint sellingAmt = (approvalAmt * percentage)/ 100;
        require(sellingAmt > 0, "not enough to sell, check approved amounts");
        uint senderBalance = IERC20(tokenAddr).balanceOf(msg.sender);
        require(senderBalance >= sellingAmt, "Not enough tokens to swap");

        // check current rate
        uint slippageAdj = 10000 - (slippage * 100);
        (route, quote) = getBestQuoteUsingTokenToWETH(tokenAddr, sellingAmt);
        minQuote = (quote * slippageAdj) / 10000; // 0.5% slippage
        require(minQuote >= minETHAmt, "ETH to receive less than minimum");

        // send token to address
        IERC20(tokenAddr).transferFrom(msg.sender, address(this), sellingAmt);
        // approve router
        IERC20(tokenAddr).approve(router, sellingAmt);
        IRouter02(router).swapExactTokensForETHSupportingFeeOnTransferTokens(sellingAmt, minQuote, route, msg.sender, block.timestamp + 7);




    }

}