// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;


import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Address.sol";

// import "https://github.com/openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "https://github.com/openzeppelin/contracts/token/ERC20/ERC20.sol";
// import "https://github.com/openzeppelin/contracts/utils/Context.sol";
// import "https://github.com/openzeppelin/contracts/utils/Address.sol";

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

contract ProjectBaseTokenERC20 is Context, ERC20{
    using SafeMath for uint256;
    using Address for address;

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint totalSupply_,
        address creatorAddr
    ) ERC20(name_, symbol_) {
        totalSupply_ =  totalSupply_ * 10 ** decimals_;
         _setupDecimals(decimals_);
        // this will mint total supply 
        _mint(creatorAddr, totalSupply_);
        //  _mint(_msgSender(), totalSupply_, "", "");

    }
    
    
}

contract LPLaunch {
    uint balanceVal;
    mapping(address => uint) balances;
    address _addressOfDex = address(0xB1Ffd5BA1fdE7Abe45b0b161e491c0fA8dFEF92B);
    
    function getBlockNumber() public view returns(uint) {
        return block.number;
    }
    function getBlockTime() public view returns(uint) {
        return block.timestamp;
    }
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
    
    function getBackProjectTokens(address addr) external {
        uint tBalance =  IERC20(addr).balanceOf(address(this));
        IERC20(addr).transfer(msg.sender, tBalance);
        
    }
    
    function _callApproveOnProjectToken(address _projectToken, address spender_, uint amount_) internal returns(bool success) {
        success = IERC20(_projectToken).approve(spender_, amount_);
        
    }
    event LPCreated(uint indexed ETHAMOUNT, uint indexed TOKENAMOUNT);
    function createLiquidityPairETH(address _projectToken) external returns(uint liquidityTokens_) {
        uint _fundingTokenAvail = address(this).balance;
        //require(address(0) == _fundingToken, "xStarterPair: FundingTokenError");
        uint amountETH = _fundingTokenAvail;
        uint amountProjectToken = IERC20(_projectToken).balanceOf(address(this));
        uint deadline = block.timestamp + 6000;
        
        emit LPCreated(amountETH, amountProjectToken);
        
        
        
        _callApproveOnProjectToken(_projectToken, _addressOfDex, amountProjectToken);
        
        // approve project token to be sent to dex. Spender is dex IUniswapRouter address (honeyswap, uniswap etc)
        //bool approved_ = _callApproveOnProjectToken(_addressOfDex, amountProjectToken);
        
        
       
        
        (uint amountTokenInPool, uint amountETHInPool, uint amountliquidityToken) = IUniswapRouter(_addressOfDex).addLiquidityETH{value: amountETH}(
            _projectToken,
            amountProjectToken,
            amountProjectToken,
            amountETH,
            address(this),
            deadline
            );
        
        liquidityTokens_ = amountliquidityToken;
        
        // _fundingTokenAvail = 0;
        // // subtract amount sent to liquidity pool from this
        // _totalTokensSupplyControlled =  _totalTokensSupplyControlled.sub(amountProjectToken);
        // _tokensForLiquidity = 0;
        
        
    }
}