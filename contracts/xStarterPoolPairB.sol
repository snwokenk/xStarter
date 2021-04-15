// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC777/IERC777Recipient.sol";
import "@openzeppelin/contracts/token/ERC777/IERC777Sender.sol";
import "@openzeppelin/contracts/token/ERC777/ERC777.sol";
import "@openzeppelin/contracts/token/ERC777/ERC777.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/introspection/IERC1820Registry.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "./Administration.sol";
import "./ERC777ReceiveSend.sol";
//import "./UniswapInterface.sol";



// https://ropsten.etherscan.io/tx/0xd0fd6a146eca2faff282a10e7604fa1c0c334d6a8a6361e4694a743154b2798f
// must first approve amount


// https://ropsten.etherscan.io/tx/0x2f39644b43bb8f1407e4bb8bf9c1f6ceb116633be8be7c8fa2980235fa088c51
// transaction showing how to add liquidity for ETH to token pair

// xStarterPoolPairB: project tokens are swapped after total funding is raised. As Long as a Minimum funding amount is reached.

interface IERC20AndOwnable {
    function totalSupply() external view returns (uint256);
    function owner() external view  returns (address);
    function allowance(address owner_, address spender) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function decimals() external view returns (uint8);
}

interface IERC20Uni {
    function approve(address spender, uint256 amount) external returns (bool);
}
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

interface IUniswapFactory {
  function getPair(address tokenA, address tokenB) external view returns (address pair);
}




contract ProjectBaseToken is Context, ERC777, ERC777NoReceiveRecipient, ERC777NoSendSender {
    using SafeMath for uint256;
    using Address for address;

    constructor(
        string memory name_,
        string memory symbol_,
        uint totalSupply_,
        address creatorAddr,
        address[] memory defaultOperators_
    ) ERC777(name_, symbol_, defaultOperators_) {

        // this will mint total supply 
        _mint(creatorAddr, totalSupply_, "", "");
        //  _mint(_msgSender(), totalSupply_, "", "");

    }
    
    
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
        
         _setupDecimals(decimals_);
        // this will mint total supply 
        _mint(creatorAddr, totalSupply_);
        //  _mint(_msgSender(), totalSupply_, "", "");

    }
    
    
}



contract xStarterPoolPairB is Ownable, Administration, IERC777Recipient, IERC777Sender {
    using SafeMath for uint256;
    using Address for address;
    
    // this is for xDai chain. if deploying to other chains check the length of block creation, some are faster
    uint constant MINE_LEN = 5 seconds;
    
    struct FunderInfo {
    uint fundingTokenAmount;
    uint projectTokenAmount;
        
    }
    struct SwapInfo {
    uint24 fundTokenReceive;
    uint24 projectTokenGive;
        
    }
    
    modifier onlySetup() {
        require(_isSetup, "ILO has not been set up");
        _;
    }
    
    modifier onlyOpen() {
        require(isEventOpen(), "ILO event not open");
        _;
    }
    
    modifier notCurrentlyFunding() {
        require(!_currentlyFunding[_msgSender()], "Locked From Funding, A transaction you initiated has not been completed");
        _;
    }
    modifier allowedToWithdraw() {
        require(!_currentlyWithdrawing[_msgSender()], "Locked From Funding, A transaction you initiated has not been completed");
        _;
    }
    
    event TokenCreatedByXStarterPoolPair(address indexed TokenAddr_, address indexed PoolPairAddr_, address indexed Admin_, uint timestamp_);
    event TokenSwapped(address indexed funder_, uint indexed tokensDesired, uint indexed tokensReceived_, uint tokensForLiq_);
    address private _addressOfDex;
    address private _addressOfDexFactory;
    uint24 private _dexDeadlineLength;
    
    // stores address of the project's token
    address private _projectToken;
    uint8 private _projectTokenDecimals;
    
    // uint keeping track of total project's token supply. 
    //for record. this is used to make sure total token is the same as voted for by the community
    uint private _totalTokensSupply;
    
    // added to when token is transferred from admin address to contract.
    // subtracted from when token is transfered to dex
    // subtracted from when token can be withdrawn by participants and admin
    uint private _totalTokensSupplyControlled;
    
    // this is set up by the launchpad, it enforces what the project told the community
    // if the project said 70% of tokens will be offered in the ILO. This will be set in the constructor.
    address _fundingToken; // if 0 then use nativeTokenSwap
    uint8 _fundingTokenDecimals; 
    // address of  dex liquidity token pair, this is the pair that issues liquidity tokens from uniswap or deriivatives
    address _liquidityPairAddress; 
    uint private _totalLPTokens; // amount of liquidity
     uint private _availLPTokens; // amount of liquidity
    // timestamp when contributors can start withdrawing their their Liquidity pool tokens
    uint private _liqPairTimeLock;
    uint private _liqPairBlockLock;
    // length of lock for Liquidity tokens Minimum 365.25 days or 31557600 seconds
    uint private _liqPairLockLen;
    
    uint8 private _percentOfTotalTokensForILO;
    uint8 private _percentOfILOTokensForLiquidity = 50;
    // timestamp of when contributors tokens will be free to withdraw
    uint private _contribTimeStampLock;
    // time stamp until project owner tokens are free usually double the length of contributor time
    uint private _projTimeLock;
    // block lock, use both timesamp and block number to add time lock
    uint private _projBlockLock;
    
    
    // the length in seconds of between block timestamp till timestamp when contributors can receive their tokens 
    //Minimum is 14 days equivalent or 1,209,600 seconds
    // also project owners tokens are timelocked for either double the timelock of contributors or an additional 2 months
    uint private _contribTimeLock;
    uint private _contribBlockLock;
    
    
    uint private _minFundingTokenRequired;
    uint private _maxFundingToken;
    uint private _minFundPerAddr = 1000000000000 wei;
    uint private _maxFundPerAddr;
    // Minimum is 1 gwei, this is a really small amount and should only be overriden by a larger amount
    uint private _minPerSwap = 1000000000 wei;
    SwapInfo private _swapRatio;
    
    
    

    // uint amount of tokens  aside for ILO.
    uint private _totalTokensILO;
    // tokens remaining for ILO
    uint private _availTokensILO;
    
    
    // tokens for liquidity
    uint private _tokensForLiquidity;
    
    
    
    // total funding tokens
    uint _fundingTokenTotal;
    // total funding tokens available. For non capital raising will be the same as _fundingTokenTotal until liquidity pool is created
    uint _fundingTokenAvail;
    
    // utc timestamp
    uint48 private _startTime;
    
    // uint timestamp
    uint48 private _endTime;
    
    // bool if xStarterPoolPair is set up
    bool _isSetup;
    // 
    bool _ILOValidated;
    bool _ILOSuccess;
    bool _approvedForLP;
    
    bool _liquidityPairCreated;
    
    uint private _adminBalance;
    mapping(address => FunderInfo) private _funders;
    mapping(address => bool) private liqTokensWithdrawn;
    mapping(address => bool) private _projTokensWithdrawn;
    mapping(address => bool) private _currentlyFunding;
     mapping(address => bool) private _currentlyWithdrawing;
    
    // step 1
    constructor(
        address adminAddress,
        uint8 percentOfTokensForILO_,
        uint24 fundTokenReceive_,
        uint24 projectTokenGive_,
        uint24 dexDeadlineLength_,
        uint48 contribTimeLock_,
        uint minPerSwap_,
        uint minFundPerAddr_,
        uint maxFundPerAddr_,
        uint minFundingTokenRequired_,
        uint maxFundingToken_,
        address fundingToken_,
        address addressOfDex_,
        address addressOfDexFactory_
        
        ) Administration(adminAddress) {
            // require(percentOfTokensForILO_ > 0 && percentOfTokensForILO_ <= 100, "percent of tokens must be between 1 and 100");
            // require(projectTokenGive_ > 0 && fundTokenReceive_ > 0, "swap ratio is zero ");
            // require(minFundingTokenRequired_ > 0, "No softcap set");
            _percentOfTotalTokensForILO = percentOfTokensForILO_;
            _fundingToken = fundingToken_;
            _dexDeadlineLength = dexDeadlineLength_;
            _contribTimeLock = contribTimeLock_ < 60 ? 60 : contribTimeLock_;
            _swapRatio.fundTokenReceive = fundTokenReceive_;
            _swapRatio.projectTokenGive = projectTokenGive_;
            _addressOfDex = addressOfDex_;
            _addressOfDexFactory = addressOfDexFactory_;
            // if provided is less than default take default
            _minPerSwap = _minPerSwap > minPerSwap_ ? _minPerSwap : minPerSwap_;
            // todo require a minimum fund per address possible 1000 gwei or 1000000000000 wei
            _minFundPerAddr = minFundPerAddr_ < _minFundPerAddr ? _minFundPerAddr : minFundPerAddr_;
            // 0 means not max set
            _maxFundPerAddr = maxFundPerAddr_ < _minFundPerAddr ? 0 : maxFundPerAddr_;
            //_contribTimeLock = contribTimeLock_ < 1209600 ? 1209600 : contribTimeLock_;
            
            _minFundingTokenRequired = minFundingTokenRequired_;
            _maxFundingToken = maxFundingToken_;
            
        }
    function addressOfDex() public view returns(address) {
        return _addressOfDex;
    }
    function addressOfDexFactory() public view returns(address) {
        return _addressOfDexFactory;
    }
    function amountRaised() public view returns(uint) {
        return _fundingTokenTotal;
    }
    function availLPTokens() public view returns(uint) {
        return _availLPTokens;
    }
    function balanceOfFunder(address funder_) public view returns(uint, uint) {
        return (_funders[funder_].fundingTokenAmount, _funders[funder_].projectTokenAmount);
    }
    function swapRatio() public view returns(uint24, uint24) {
        return (_swapRatio.fundTokenReceive, _swapRatio.projectTokenGive);
    }
    
    function adminBalance() public view returns(uint balance_) {
        return _adminBalance;
    }
    function isSetup() public view returns (bool) {
        return _isSetup;
    }
    
    function isTimeLockSet() public view returns (bool) {
        return _projTimeLock != 0 && _contribTimeStampLock != 0 && _liqPairTimeLock != 0;
    }
    
    // return true if ILO is complete, Validated and ILO did not reach threshold ie _ILOSuccess == false
    function ILOFailed() public view returns (bool) {
        return isEventDone() && _ILOValidated && !_ILOSuccess;
    }
    
    function isContribTokenLocked() public view returns (bool) {
        require(isTimeLockSet(), "Time locked not set");
        return block.timestamp < _contribTimeStampLock || block.number < _contribBlockLock;
    }
    
    function isProjTokenLocked() public view returns (bool) {
        require(isTimeLockSet(), "Time locked not set");
        return block.timestamp < _projTimeLock || block.number < _projBlockLock;
    }
    
    function isLiqTokenLocked() public view returns (bool) {
        require(isTimeLockSet(), "Time locked not set");
        return block.timestamp < _liqPairTimeLock || block.number < _liqPairBlockLock;
    }
    
    function endTime() public view returns (uint48) {
        return _endTime;
    }
    function startTime() public view returns (uint48) {
        return _startTime;
    }

    function availTokensILO() public view returns (uint) {
        return _availTokensILO;
    }
    
    function totalTokensILO() public view returns (uint) {
        return _totalTokensILO;
    }
    function percentOfTotalTokensForILO() public view returns (uint) {
        return _percentOfTotalTokensForILO;
    }
    function totalTokensSupplyControlled() public view returns (uint) {
        return _totalTokensSupplyControlled;
    }
    
    function totalTokensSupply() public view returns (uint) {
        return _totalTokensSupply;
    }
    
    function projectToken() public view returns (address) {
        return _projectToken;
    }
    
    // different
    function isEventOpen() public view returns (bool isOpen_) {
        uint48 currentTime = uint48(block.timestamp);
        
        if(currentTime >= startTime() && currentTime < endTime() && amountRaised() < _maxFundingToken && _isSetup) {
            isOpen_ = true;
        }
        
    }
    
    //different
    function isEventDone() public view returns (bool isOpen_) {
        uint48 currentTime = uint48(block.timestamp);
        
        if(_isSetup && ( currentTime >= endTime() )|| ( _maxFundingToken > 0 && amountRaised() == _maxFundingToken )) {
            isOpen_ = true;
        }
        
    }
    
    // Step 2
    function setUpPoolPair(
        address addressOfProjectToken,
        string memory tokenName_,
        string memory tokenSymbol_,
        uint8  decimals_,
        uint totalTokenSupply_,
        uint48 startTime_, 
        uint48 endTime_
        ) public onlyAdmin returns(bool)  {
            
            require(admin() == msg.sender, "Administration: caller is not the admin");
            require(!_isSetup,"initial setup already done");
            require(startTime_ > block.timestamp && endTime_ > startTime_, "ILO dates not correct");
            decimals_ = decimals_ > 18 ? 18 : decimals_;
            totalTokenSupply_ =  totalTokenSupply_ * 10 ** decimals_;
            
            // if address of project token is 0 address deploy token for it
            if(address(0) == addressOfProjectToken) {
                    address[] memory defaultOperators_;
                    _deployToken(tokenName_, tokenSymbol_, decimals_, totalTokenSupply_, defaultOperators_);
            } 
            else {
                IERC20AndOwnable existingToken = IERC20AndOwnable(addressOfProjectToken);
                
                address existingTokenOwner = existingToken.owner();
                uint existingTokenSupply = existingToken.totalSupply();
                uint8 expDecimals = existingToken.decimals();
                
                require(existingTokenOwner == admin(),"Admin of pool pair must be owner of token contract");
                require(existingTokenSupply == totalTokenSupply_, "All tokens from contract must be transferred");
                require(expDecimals == decimals_, "decimals do not match");
                
                _projectToken = addressOfProjectToken;
                _totalTokensSupply = _totalTokensSupply.add(totalTokenSupply_);
                _totalTokensSupplyControlled = _totalTokensSupplyControlled.add(totalTokenSupply_);
                
            }
            _startTime = startTime_;
            
            _endTime = endTime_;
            _isSetup = true;
            return _isSetup;
    }
    
    // function should be called within a function that checks proper access
    function _deployToken(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint totalTokenSupply_,
        address[] memory defaultOperators_
    ) internal returns(bool){
        //ProjectBaseToken newToken = new ProjectBaseToken(name_,symbol_, totalTokenSupply_, address(this), defaultOperators_);
        ProjectBaseTokenERC20 newToken = new ProjectBaseTokenERC20(name_,symbol_, decimals_, totalTokenSupply_, address(this));

        _projectToken = address(newToken);
        _totalTokensSupply = totalTokenSupply_;
        _totalTokensSupplyControlled = _totalTokensSupplyControlled.add(totalTokenSupply_);
        
        //_totalTokensILO = _totalTokensSupplyControlled.mul(_percentOfTotalTokensForILO.div(100));
        _setTokensForILO();
        
        emit TokenCreatedByXStarterPoolPair(_projectToken, address(this), _msgSender(), block.timestamp);
        
        return true;
        
    }
    
    
    // step 3 if PoolPair has not been funded, if token was created by poolpair contract it is automatically funded, also sets ILO tokens
    function depositAllTokenSupply() public onlyAdmin onlySetup returns(bool success) {
        require(_totalTokensSupplyControlled != _totalTokensSupply, "already deposited");
        // if(_totalTokensSupplyControlled == _totalTokensSupply) { 
        //     return true;
            
        // }
        IERC20AndOwnable existingToken = IERC20AndOwnable(_projectToken);
        uint allowance = existingToken.allowance(admin(), address(this));
        require(allowance == _totalTokensSupply, "You must deposit all available tokens by calling the approve function on the token contract");
        // transfer approved tokens from admin to current ILO contract
        success = existingToken.transferFrom(_msgSender(), address(this), _totalTokensSupply);
        
        if(success) {
            _totalTokensSupplyControlled =  _totalTokensSupplyControlled.add(_totalTokensSupply);
            _setTokensForILO();
        }else {
            revert('could not transfer project tokens to pool pair contract');
        }
        return success;
        
    }
    
    // function should be called within a function that checks proper access ie onlyAdmin or onlyOwner
    function _setTokensForILO() internal {
        // using the percent of tokens set in constructor by launchpad set total tokens for ILO 
        // formular:  (_percentOfTotalTokensForILO/100 ) * _totalTokensSupplyControlled
        //uint amount = _totalTokensSupplyControlled.mul(_percentOfTotalTokensForILO/100);
        uint amount = _totalTokensSupplyControlled * _percentOfTotalTokensForILO/100;
        _totalTokensILO = amount;
        _availTokensILO = amount;
        _adminBalance = _totalTokensSupplyControlled.sub(amount);
    }
    
    
    // functions for taking part in ILO
    function contributeNativeToken() payable notCurrentlyFunding onlyOpen external returns(bool){
        require(msg.value > _minPerSwap, "No value Sent");
        _disallowFunding();
        _contribute(msg.value, _msgSender());
        _allowFunding();
        return true;
        
    }
    
    
    // should be called after approving amount of token
    function contributeFundingToken() notCurrentlyFunding  onlyOpen external returns(bool) {
        require(_fundingToken != address(0), "please use nativeTokenSwap. Only native token allowed. xDai token for xDai side chain etc");
        _disallowFunding();
        uint amount_ = _retrieveApprovedToken();
        _contribute(amount_, _msgSender());
        _allowFunding();
        
        return true;
    }
    
    function _contribute(uint fundingTokenAmount_, address funder_) internal {
        _fundingTokenTotal = _fundingTokenTotal.add(fundingTokenAmount_);
        _fundingTokenAvail = _fundingTokenAvail.add(fundingTokenAmount_);
        require(_fundingTokenTotal <= _maxFundingToken, "exceeds hard carp");
         // add to msg.sender token funder balance
        FunderInfo storage funder = _funders[funder_];
        funder.fundingTokenAmount = funder.fundingTokenAmount.add(fundingTokenAmount_);
        
        // funding can be less than Minimum if max - total < minimum
        uint amountLeft = _maxFundingToken - _fundingTokenTotal;
        
        // funding amount should be greater or equal to Minimum OR if not then available amount should be less than Minimum and fundingTokenAmount equals to amount left
        require((funder.fundingTokenAmount >= _minFundPerAddr) || (amountLeft < _minFundPerAddr && fundingTokenAmount_ == amountLeft ) , "Minimum amount not met");
        // if max is set then make sure not contributing max
        require(funder.fundingTokenAmount <= _maxFundPerAddr || _maxFundPerAddr == 0, "maximum exceeded");
    }
    
    
    function _retrieveApprovedToken() internal returns(uint allowedAmount_) {
        address ownAddress = address(this);
        IERC20AndOwnable existingToken = IERC20AndOwnable(_fundingToken);
        allowedAmount_ = existingToken.allowance(_msgSender(), ownAddress);
        require(allowedAmount_ > _minPerSwap, "Amount must be greater than 0");
        bool success = existingToken.transferFrom(_msgSender(), ownAddress, allowedAmount_);
        require(success, "not able to retrieve approved tokens of funding token");
        return allowedAmount_;
    }
    
    function _allowFunding() internal {
        _currentlyFunding[_msgSender()] = true;
    }
    function _disallowFunding() internal {
        _currentlyFunding[_msgSender()] = false;
    }
    
    function _allowWithdraw() internal {
        _currentlyWithdrawing[_msgSender()] = true;
    }
    function _disallowWithdraw() internal {
        _currentlyWithdrawing[_msgSender()] = false;
    }
    
    event ILOValidated(address indexed caller_, uint indexed amountRaised_, bool success_,  uint indexed swappedTokens_);
    
    // step 4 validate after ILO
    // validate checks to make sure mini amount of project tokens raised
    // different
    function validateILO() external returns(bool) {
        require(isEventDone() && !_ILOValidated, "ILO not yet done OR already validated");
        // uint minNeeded = uint(_totalTokensILO * _percentRequiredTokenPurchase / 100);
        _ILOSuccess = amountRaised() >= _minFundingTokenRequired;
        _ILOValidated = true;
        emit ILOValidated(_msgSender(), amountRaised(),  _ILOSuccess,  _totalTokensILO);
        
        if(_ILOSuccess) {
            _tokensForLiquidity = uint(_totalTokensILO * _percentOfILOTokensForLiquidity / 100);
        }
        
        return true;
    }
    
    // step 5
    function approveTokensForLiquidityPair() external returns(bool) {
        
        require(_ILOValidated && !ILOFailed(), "You must first validate ILO"); 
        require(address(0) != _addressOfDex, "dex zero addr");
        uint amountProjectToken = _tokensForLiquidity;
        
        if(address(0) == _fundingToken) {
            _approvedForLP = _callApproveOnProjectToken(_addressOfDex, amountProjectToken);
        } else {
            uint amountERC20 = _fundingTokenAvail;
            _approvedForLP =  _callApproveOnProjectToken(_addressOfDex, amountProjectToken) && _callApproveOnFundingToken(_addressOfDex, amountERC20);
        }
        
        // approve project token to be sent to dex. Spender is dex IUniswapRouter address (honeyswap, uniswap etc)
        require(_approvedForLP, "xStarterPair: TokenApprovalFail");
       
        return _approvedForLP;
    }
    
    
    // step 6
    // todo: find out why this function fails, probably create a separate test contract and try
    function createLiquidityPool() external returns(bool success) {
        // liquidity will be _fundingTokenAvail to _tokensForLiquidity ratio
        require(_ILOValidated && !ILOFailed(), "You must first validate ILO");
        require(_approvedForLP, "xStarterPair: TokenApprovalFail");
        require(!_liquidityPairCreated, "Liquidity pair already created");
        _liquidityPairCreated = true;
    
        uint liquidityAmount;
        if(address(0) == _fundingToken) {
            liquidityAmount = _createLiquidityPairETH();
        } else {
            liquidityAmount = _createLiquidityPairERC20();
        }
        _totalLPTokens = liquidityAmount;
        _availLPTokens = liquidityAmount;
        
        return true;
        
    }
    
    // step 7
    function finalizeILO() external returns(bool success) {
        require(_liquidityPairCreated, "liquidity pair must be created first");
        // set liquidity pair address 
        _liquidityPairAddress = _setLiquidityPairAddress();
        success = _setTimeLocks();
    }
    
    
    
    function withdraw() external allowedToWithdraw returns(bool success) {
         _disallowWithdraw();
        require(!isContribTokenLocked(), "withdrawal locked");
        require(!_projTokensWithdrawn[_msgSender()], "project tokens already withdrawn");
        FunderInfo storage funder = _funders[_msgSender()];
        require(funder.fundingTokenAmount > 0, "Did Not Contribute");
        _projTokensWithdrawn[_msgSender()] = true;
        
        uint amount_ = _getProjTknBal(_msgSender(), funder.fundingTokenAmount);
        //funder.projectTokenAmount = funder.projectTokenAmount.sub(amount_);
        _totalTokensSupplyControlled = _totalTokensSupplyControlled.sub(amount_);
        success = IERC20AndOwnable(_projectToken).approve(_msgSender(), amount_);
        
        _allowWithdraw();
    }
    
    // todo: verify the balance is right
    function _getProjTknBal(address funder_, uint funderContAmt_) internal view returns(uint balance) {
        // *** CHECK TO MAKE SURE PROJECT TOKENS ARE NOT WITHDRAWN BEFORE CALLING THIS FUNCTION ***
        
        uint tokensForContributors = _totalTokensILO - _tokensForLiquidity;
        
        uint amtPer = _fundingTokenTotal.div(10 ** 18);
        amtPer = tokensForContributors.div(amtPer);
        // lpPer * fundingTokenAmount to get lp tokens to send
        balance  = _funders[_msgSender()].fundingTokenAmount * amtPer;
        
    }
    // TODO: verify this function is safe, since it requires sending back ether/xDai/native token
    function withdrawOnFailure() external allowedToWithdraw returns(bool success) {
        require(ILOFailed(), "ILO not failed");
        _disallowWithdraw();
        
        
        if(_msgSender() == _admin) {
            // if admin withdraw all project tokens
            require(_adminBalance != 0, "already withdrawn");
            _adminBalance = 0;
            uint amount_ = _totalTokensSupplyControlled;
            _totalTokensSupplyControlled = 0;
            success = IERC20AndOwnable(_projectToken).approve(_msgSender(), amount_);
            
        }else{
            // if not admin send back funding token (nativ token like eth or ERC20 token)
            FunderInfo storage funder = _funders[_msgSender()];
            uint amount_ = funder.fundingTokenAmount;
            require(amount_ > 0, "no balance");
            // uint amount2_ = funder.projectTokenAmount;
            funder.fundingTokenAmount = 0;
            funder.projectTokenAmount = 0;
            _fundingTokenAvail = _fundingTokenAvail.sub(amount_);
            if(_fundingToken == address(0)) {
                // send native token to funder
                (success, ) = _msgSender().call{value: amount_}('');
                
            }else {
                // or if funding token wasn't native, send ERC20 token
                success = IERC20AndOwnable(_fundingToken).approve(_msgSender(), amount_);
            }
        }
        
        
        _allowWithdraw();
    }
    
    // withraws all the liquidity token of the user
    // todo: figure a way to make this efficient
    function withdrawLiquidityTokens() external allowedToWithdraw returns(bool success) {
        require(!isLiqTokenLocked(), "withdrawal locked ");
        _disallowWithdraw();
        require(!liqTokensWithdrawn[_msgSender()], "No tokens");
        liqTokensWithdrawn[_msgSender()] = true;
        
        // get lp tokens per 1 funding token offerrd
        //reduce to regular size
        // todo put this step in a library
        uint lpPer = _fundingTokenTotal.div(10 ** 18);
        lpPer = _totalLPTokens.div(lpPer);
        // lpPer * fundingTokenAmount to get lp tokens to send
        uint LPAmount_ = _funders[_msgSender()].fundingTokenAmount * lpPer;
        require(LPAmount_ > 0 && LPAmount_ <= _availLPTokens, "not enough lp tokens");
        _availLPTokens = _availLPTokens.sub(LPAmount_);
        success = IERC20Uni(_projectToken).approve(_msgSender(), LPAmount_);
        _allowWithdraw();
        
    }
    
    function withdrawAdmin() external onlyAdmin returns (bool success) {
        require(!isProjTokenLocked(), "withdrawal locked");
        _disallowWithdraw();
        // admin
        uint amount_ = _adminBalance;
        _adminBalance = 0;
        _totalTokensSupplyControlled = _totalTokensSupplyControlled.sub(amount_);
        success = IERC20AndOwnable(_projectToken).approve(_admin, amount_);
        _allowWithdraw();
    }
    
    function _setLiquidityPairAddress() internal view returns(address liquidPair_) {
        
        if(address(0) == _fundingToken) {
            address WETH_ = IUniswapRouter(_addressOfDex).WETH();
            liquidPair_ = IUniswapFactory(_addressOfDexFactory).getPair(WETH_, _projectToken);
            require(address(0) != liquidPair_, "Liquidity Pair Should Be Created But Hasn't");
        } else {
            liquidPair_ = IUniswapFactory(_addressOfDexFactory).getPair(_fundingToken, _projectToken);
            require(address(0) != liquidPair_, "Liquidity Pair Should Be Created But Not Created");
        }
    }
    
    function _setTimeLocks() internal returns(bool)  {
        require(!isTimeLockSet(), "Time lock already set");
        uint timeLockLengthX2 = _contribTimeLock * 2;
        // if timelock greater than 60 days in seconds, set to length of contributor timelock + 30 days
        uint timeLen = timeLockLengthX2 > 5184000 ? _contribTimeLock + 2592000 : timeLockLengthX2;
        
        _projTimeLock = block.timestamp + timeLen;
        _projBlockLock = block.number + uint(timeLen / MINE_LEN);
        _contribTimeStampLock = block.timestamp + _contribTimeLock;
        _contribBlockLock = block.number + uint(_contribTimeLock / MINE_LEN);
        _liqPairTimeLock = block.timestamp + _liqPairLockLen;
        _liqPairBlockLock = block.number + uint(_liqPairLockLen / MINE_LEN);
        
        return true;
    
    }
    
    // this can be called by anyone. but should be called AFTER the ILO
    // on xDai chain ETH would be xDai, on BSC it would be BNB 
    // step 6a
    function _createLiquidityPairETH() internal returns(uint liquidityTokens_) {
        
        //require(address(0) == _fundingToken, "xStarterPair: FundingTokenError");
        uint amountETH = _fundingTokenAvail;
        uint amountProjectToken = _tokensForLiquidity;
        
        
        // approve project token to be sent to dex. Spender is dex IUniswapRouter address (honeyswap, uniswap etc)
        //bool approved_ = _callApproveOnProjectToken(_addressOfDex, amountProjectToken);
       
        
        (uint amountTokenInPool, uint amountETHInPool, uint amountliquidityToken) = IUniswapRouter(_addressOfDex).addLiquidityETH{value: amountETH}(
            _projectToken,
            amountProjectToken,
            amountProjectToken,
            amountETH,
            address(this),
            block.timestamp + _dexDeadlineLength
            );
        
        liquidityTokens_ = amountliquidityToken;
        
        _fundingTokenAvail = 0;
        // subtract amount sent to liquidity pool from this
        _totalTokensSupplyControlled =  _totalTokensSupplyControlled.sub(amountProjectToken);
        _tokensForLiquidity = 0;
        
        
    }
    
    // step 6b
    function _createLiquidityPairERC20() internal returns(uint liquidityTokens_) {
        
        require(address(0) != _fundingToken, "xStarterPair: FundingTokenError");
        //require(_approvedForLP, "xStarterPair: TokenApprovalFail, call syncBalances before calling again");
        
        uint amountERC20 = _fundingTokenAvail;
        uint amountProjectToken = _totalTokensSupplyControlled;
        
        
        // approve project token to be sent to dex. Spender is dex IUniswapRouter address (honeyswap, uniswap etc)
        // bool approvedA_ = _callApproveOnProjectToken(_addressOfDex, amountProjectToken);
        // bool approvedB_ = _callApproveOnFundingToken(_addressOfDex, amountERC20);
        
        
        //require(approvedA_ && approvedB_, "xStarterPair: TokenApprovalFail, call syncBalances before calling again");
        
        (uint amountTokenInPool, uint amountETHInPool, uint amountliquidityToken) = IUniswapRouter(_addressOfDex).addLiquidity(
            _projectToken,
            _fundingToken,
            amountProjectToken,
            amountERC20,
            amountProjectToken,
            amountERC20,
            address(this),
            block.timestamp + _dexDeadlineLength
            );
        
        _fundingTokenAvail = 0;
        // subtract amount sent to liquidity pool from this
        _totalTokensSupplyControlled =  _totalTokensSupplyControlled.sub(amountProjectToken);
        _tokensForLiquidity = 0;
        
        liquidityTokens_ = amountliquidityToken;
        
        
    }
    
    
    function _callApproveOnProjectToken(address spender_, uint amount_) internal returns(bool success) {
        success = IERC20(_projectToken).approve(spender_, amount_);
        
    }
    
    function _callApproveOnFundingToken(address spender_, uint amount_) internal returns(bool success) {
        success = IERC20(_fundingToken).approve(spender_, amount_);
        
    }
    // IERC777Recipient implementation
    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external view  override{
        // this contract should receive token using approve on ERC20/ and then fundingTokenSwap function on this contract
        require(from == address(this), "approve then call fundingTokenSwap");
    }
    
    // IERC777Sender implementation called before tokenis
    function tokensToSend(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external view  override {
         require(from == address(this), "approve then call fundingTokenSwap");
    }
    
}