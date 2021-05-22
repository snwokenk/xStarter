// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC777/IERC777Recipient.sol";
import "@openzeppelin/contracts/token/ERC777/IERC777Sender.sol";
import "@openzeppelin/contracts/token/ERC777/ERC777.sol";
import "@openzeppelin/contracts/token/ERC777/ERC777.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/introspection/IERC1820Registry.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./Administration.sol";
import "./ERC777ReceiveSend.sol";
import "./xStarterInterfaces.sol";
//import "./UniswapInterface.sol";



// https://ropsten.etherscan.io/tx/0xd0fd6a146eca2faff282a10e7604fa1c0c334d6a8a6361e4694a743154b2798f
// must first approve amount


// https://ropsten.etherscan.io/tx/0x2f39644b43bb8f1407e4bb8bf9c1f6ceb116633be8be7c8fa2980235fa088c51
// transaction showing how to add liquidity for ETH to token pair

// xStarterPoolPairB: project tokens are swapped after total funding is raised. As Long as a Minimum funding amount is reached.

interface IERC20AndOwnable {
    function totalSupply() external view returns (uint256);
    // function owner() external view  returns (address);
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

struct Info {
        uint8 _percentOfTokensForILO;
        uint24 _dexDeadlineLength;
        uint48 _contribTimeLock;
        
        // length of lock for Liquidity tokens Minimum 365.25 days or 31557600 seconds
        uint48 _liqPairLockLen;
        uint _minPerSwap;
        
        uint _minPerAddr;
        uint _maxPerAddr;
        uint _softcap;
        uint _hardcap;
        address _fundingToken;
        address _addressOfDex;
        address _addressOfDexFactory;
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
        uint totalSupply_,
        address creatorAddr
    ) ERC20(name_, symbol_) {
        
        //  _setupDecimals(decimals_);
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
        require(!_currentlyWithdrawing[_msgSender()], "Locked From Withdrawing, A transaction you initiated has not been completed");
        _;
    }
    
    event TokenCreatedByXStarterPoolPair(address indexed TokenAddr_, address indexed PoolPairAddr_, address indexed Admin_, uint timestamp_);
    event TokenSwapped(address indexed funder_, uint indexed tokensDesired, uint indexed tokensReceived_, uint tokensForLiq_);
    Info private i;
    // address private _addressOfDex;
    // address private _addressOfDexFactory;
    uint _decimals = 18;
    
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
    // address _fundingToken; // if 0 then use nativeTokenSwap
    // uint8 _fundingTokenDecimals; 
    // address of  dex liquidity token pair, this is the pair that issues liquidity tokens from uniswap or deriivatives
    address _liquidityPairAddress; 
    uint private _totalLPTokens; // amount of liquidity
     uint private _availLPTokens; // amount of liquidity
    // timestamp when contributors can start withdrawing their their Liquidity pool tokens
    uint private _liqPairTimeLock;
    uint private _liqPairBlockLock;
    
    
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
    uint private _contribBlockLock;
    
    
    // uint private _softcap;
    // uint private _hardcap;
    // uint private _minPerAddr = 1000000000000 wei;
    // uint private _maxPerAddr;
    // Minimum is 1 gwei, this is a really small amount and should only be overriden by a larger amount
    SwapInfo private _swapRatio;
    
    
    

    // uint amount of tokens  aside for ILO.
    uint private _totalTokensILO;
    // tokens remaining for ILO
    uint private _availTokensILO;
    
    
    // tokens for liquidity
    uint private _tokensForLiquidity;
    // stores value of tokens for liquidity and  is used to calculate contributors share
    uint private _amountForProjTokenCalc;
    
    
    
    // total funding tokens
    uint _fundingTokenTotal;
    // total funding tokens available. For non capital raising will be the same as i._fundingTokenTotal until liquidity pool is created
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
    mapping(address => bool) private _liqTokensWithdrawn;
    mapping(address => bool) private _projTokensWithdrawn;
    mapping(address => bool) private _currentlyFunding;
    mapping(address => bool) private _currentlyWithdrawing;
    
    // step 1
    // todo: remove some of the unused parameters on the constructor 
    constructor(
        address adminAddress,
        address proposalAddr_,
        address addressOfDex_,
        address addressOfDexFactory_
        
        ) Administration(adminAddress) {
            // require(percentOfTokensForILO_ > 0 && percentOfTokensForILO_ <= 100, "percent of tokens must be between 1 and 100");
            // require(projectTokenGive_ > 0 && fundTokenReceive_ > 0, "swap ratio is zero ");
            // require(softcap_ > 0, "No softcap set");
            
            (ILOProposal memory i_, ILOAdditionalInfo memory a_) = iXstarterProposal(proposalAddr_).getILOInfo();
            
            
            i._minPerSwap = a_.minPerSwap;
            i._minPerAddr = a_.minPerAddr;
            _percentOfTotalTokensForILO = i_.percentOfTokensForILO;
            i._fundingToken = i_.fundingToken;
            i._dexDeadlineLength = 1800;
            // todo; in final production contract should be not less than 1209600 seconds or 14 days
            i._contribTimeLock = a_.contribTimeLock;
            i._liqPairLockLen = a_.liqPairLockLen;
            // i._addressOfDex = addressOfDex_;
            i._addressOfDex = addressOfDex_;
            i._addressOfDexFactory = addressOfDexFactory_;
            // if provided is less than default take default
            // todo require a minimum fund per address possible 1000 gwei or 1000000000000 wei
            i._minPerAddr = a_.minPerAddr;
            // 0 means not max set
            i._maxPerAddr = a_.maxPerAddr;
            
            i._softcap = a_.softcap;
            i._hardcap = a_.hardcap;
            _totalTokensSupply = i_.totalSupply;
            
        }
    
    function getFullInfo() external view returns(Info memory) {
        return i;
    }
    function addressOfDex() public view returns(address) {
        return i._addressOfDex;
    }
    function addressOfDexFactory() public view returns(address) {
        return i._addressOfDexFactory;
    }
    function amountRaised() public view returns(uint) {
        return _fundingTokenTotal;
    }
    function availLPTokens() public view returns(uint) {
        return _availLPTokens;
    }
    function softcap() public view returns(uint) {
        return i._softcap;
    }
    function hardcap() public view returns(uint) {
        return i._hardcap;
    }
    function minSpend() public view returns(uint) {
        return i._minPerAddr;
    }
    function maxSpend() public view returns(uint) {
        return i._maxPerAddr;
    }
    function liquidityPairAddress() public view returns(address) {
        return _liquidityPairAddress;
    }
    
    function tokensForLiquidity() public view returns(uint) {
        return _tokensForLiquidity;
    }
    function amountForProjTokenCalc() public view returns(uint) {
        return _amountForProjTokenCalc;
    }
    function fundingTokenBalanceOfFunder(address funder_) public view returns(uint) {
        return _funders[funder_].fundingTokenAmount;
    }
    function projectTokenBalanceOfFunder(address funder_) public view returns(uint) {
        require(_ILOValidated, "project balance not available till ILO validated");
        return _getProjTknBal(funder_);
    }
    function projectLPTokenBalanceOfFunder(address funder_) public view returns(uint) {
        require(_availLPTokens > 0, "LP tokens not yet set");
        return _getLiqTknBal(funder_);
    }
    //todo: swapRatio should be called after ILO, which would allow individuals to see how much tokens they're receiving per funding token
    function swapRatio() public view returns(uint24, uint24) {
        return (_swapRatio.fundTokenReceive, _swapRatio.projectTokenGive);
    }
    
    function adminBalance() public view returns(uint balance_) {
        return _adminBalance;
    }
    function isWithdrawing(address addr_) public view returns(bool) {
        return _currentlyWithdrawing[addr_ ];
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
    
    function fundingToken() public view returns (address) {
        return i._fundingToken;
    }
    
    // different
    function isEventOpen() public view returns (bool isOpen_) {
        uint48 currentTime = uint48(block.timestamp);
        
        if(currentTime >= startTime() && currentTime < endTime() && amountRaised() < i._hardcap && _isSetup) {
            isOpen_ = true;
        }
        
    }
    
    //different
    function isEventDone() public view returns (bool isOpen_) {
        uint48 currentTime = uint48(block.timestamp);
        
        if(_isSetup && ( currentTime >= endTime() )|| ( i._hardcap > 0 && amountRaised() == i._hardcap )) {
            isOpen_ = true;
        }
        
    }
    
    // Step 2
    function setUpPoolPair(
        address addressOfProjectToken,
        string memory tokenName_,
        string memory tokenSymbol_,
        uint totalTokenSupply_,
        uint48 startTime_, 
        uint48 endTime_
        ) public onlyAdmin returns(bool)  {
            
            require(admin() == msg.sender, "Administration: caller is not the admin");
            require(!_isSetup,"initial setup already done");
            require(startTime_ > block.timestamp && endTime_ > startTime_, "ILO dates not correct");
            totalTokenSupply_ =  totalTokenSupply_ * 10 ** _decimals;
            require(_totalTokensSupply == totalTokenSupply_, "Total token supply not equal to provided information");
            
            // if address of project token is 0 address deploy token for it
            if(address(0) == addressOfProjectToken) {
                    address[] memory defaultOperators_;
                    _deployToken(tokenName_, tokenSymbol_, totalTokenSupply_, defaultOperators_);
            } 
            else {
                IERC20AndOwnable existingToken = IERC20AndOwnable(addressOfProjectToken);
                
                // address existingTokenOwner = existingToken.owner();
                uint existingTokenSupply = existingToken.totalSupply();
                uint8 expDecimals = existingToken.decimals();
                
                // require(existingTokenOwner == admin(),"Admin of pool pair must be owner of token contract");
                require(existingTokenSupply == totalTokenSupply_, "All tokens from contract must be transferred");
                require(expDecimals == _decimals, "decimals do not match");
                
                _projectToken = addressOfProjectToken;
                // _totalTokensSupply = _totalTokensSupply.add(totalTokenSupply_);
                // _totalTokensSupplyControlled = _totalTokensSupplyControlled.add(totalTokenSupply_);
                
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
        uint totalTokenSupply_,
        address[] memory defaultOperators_
    ) internal returns(bool){
        //ProjectBaseToken newToken = new ProjectBaseToken(name_,symbol_, totalTokenSupply_, address(this), defaultOperators_);
        ProjectBaseTokenERC20 newToken = new ProjectBaseTokenERC20(name_,symbol_, totalTokenSupply_, address(this));

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
        
        require(success,'could not transfer project tokens to pool pair contract');

        _totalTokensSupplyControlled =  _totalTokensSupplyControlled.add(_totalTokensSupply);
        _setTokensForILO();

        
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
        require(i._fundingToken == address(0), "please use contributeFundingToken");
        require(msg.value > i._minPerSwap, "No value Sent");
        _disallowFunding();
        _contribute(msg.value, _msgSender());
        _allowFunding();
        return true;
        
    }
    
    
    // should be called after approving amount of token
    function contributeFundingToken() notCurrentlyFunding  onlyOpen external returns(bool) {
        require(i._fundingToken != address(0), "please use nativeTokenSwap.");
        _disallowFunding();
        uint amount_ = _retrieveApprovedToken();
        _contribute(amount_, _msgSender());
        _allowFunding();
        
        return true;
    }
    
    function _contribute(uint fundingTokenAmount_, address funder_) internal {
        _fundingTokenTotal = _fundingTokenTotal.add(fundingTokenAmount_);
        _fundingTokenAvail = _fundingTokenAvail.add(fundingTokenAmount_);
        require(_fundingTokenTotal <= i._hardcap, "exceeds hard carp");
         // add to msg.sender token funder balance
        FunderInfo storage funder = _funders[funder_];
        funder.fundingTokenAmount = funder.fundingTokenAmount.add(fundingTokenAmount_);
        
        // funding can be less than Minimum if max - total < minimum
        uint amountLeft = i._hardcap - _fundingTokenTotal;
        
        // funding amount should be greater or equal to Minimum OR if not then available amount should be less than Minimum and fundingTokenAmount equals to amount left
        require((funder.fundingTokenAmount >= i._minPerAddr) || (amountLeft < i._minPerAddr && fundingTokenAmount_ == amountLeft ) , "Minimum amount not met");
        // if max is set then make sure not contributing max
        require(funder.fundingTokenAmount <= i._maxPerAddr || i._maxPerAddr == 0, "maximum exceeded");
    }
    
    
    function _retrieveApprovedToken() internal returns(uint allowedAmount_) {
        address ownAddress = address(this);
        IERC20AndOwnable existingToken = IERC20AndOwnable(i._fundingToken);
        allowedAmount_ = existingToken.allowance(_msgSender(), ownAddress);
        require(allowedAmount_ > i._minPerSwap, "Amount must be greater than 0");
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
        _currentlyWithdrawing[_msgSender()] = false;
    }
    function _disallowWithdraw() internal {
        _currentlyWithdrawing[_msgSender()] = true;
    }
    
    event ILOValidated(address indexed caller_, uint indexed amountRaised_, bool success_,  uint indexed swappedTokens_);
    
    // step 4 validate after ILO
    // validate checks to make sure mini amount of project tokens raised
    // different
    function validateILO() external returns(bool) {
        require(isEventDone() && !_ILOValidated, "ILO not yet done OR already validated");
        // uint minNeeded = uint(_totalTokensILO * _percentRequiredTokenPurchase / 100);
        _ILOSuccess = amountRaised() >= i._softcap;
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
        require(address(0) != i._addressOfDex, "dex zero addr");
        require(!_approvedForLP, "approved tokens for liquidity already called");
        uint amountProjectToken = _tokensForLiquidity;
        
        if(address(0) == i._fundingToken) {
            _approvedForLP = _callApproveOnProjectToken(i._addressOfDex, amountProjectToken);
        } else {
            uint amountERC20 = _fundingTokenAvail;
            _approvedForLP =  _callApproveOnProjectToken(i._addressOfDex, amountProjectToken) && _callApproveOnFundingToken(i._addressOfDex, amountERC20);
        }
        
        // approve project token to be sent to dex. Spender is dex IUniswapRouter address (honeyswap, uniswap etc)
        require(_approvedForLP, "xStarterPair: TokenApprovalFail");
       
        return _approvedForLP;
    }
    
    event liquidityPairCreated(address indexed lpAddress_, address dexAddress_, uint lpTokenAmount_);
    // step 6
    function createLiquidityPool() external returns(bool success) {
        // liquidity will be i._fundingTokenAvail to _tokensForLiquidity ratio
        require(_ILOValidated && !ILOFailed(), "You must first validate ILO");
        require(_approvedForLP, "xStarterPair: TokenApprovalFail");
        require(!_liquidityPairCreated, "Liquidity pair already created");
        _liquidityPairCreated = true;
    
        uint liquidityAmount;
        // save current amount to be used later to calculate each individual contributors share of project tokens
        _amountForProjTokenCalc = _tokensForLiquidity;
        if(address(0) == i._fundingToken) {
            liquidityAmount = _createLiquidityPairETH();
        } else {
            liquidityAmount = _createLiquidityPairERC20();
        }
        _totalLPTokens = liquidityAmount;
        _availLPTokens = liquidityAmount;
        _liquidityPairAddress = _getLiquidityPairAddress();
        
        emit liquidityPairCreated(_liquidityPairAddress, addressOfDex(), liquidityAmount);
        
        return true;
        
    }
    
    event ILOFinalized(address caller_);
    // step 7
    function finalizeILO() external returns(bool success) {
        require(_liquidityPairCreated, "liquidity pair must be created first");
        // set liquidity pair address 
        success = _setTimeLocks();
        emit ILOFinalized(_msgSender());
    }
    
    
    event WithdrawnProjectToken(address indexed funder_, uint indexed amount_);
    
    function withdraw() external allowedToWithdraw returns(bool success) {
         _disallowWithdraw();
        require(!isContribTokenLocked(), "withdrawal locked");
        require(!_projTokensWithdrawn[_msgSender()], "project tokens already withdrawn");
        uint amount_ = projectTokenBalanceOfFunder(_msgSender());
        _projTokensWithdrawn[_msgSender()] = true;
        // FunderInfo storage funder = _funders[_msgSender()];
        // require(funder.fundingTokenAmount > 0, "Did Not Contribute");
        require(amount_ > 0, 'amount must be greater than 0');
        //funder.projectTokenAmount = funder.projectTokenAmount.sub(amount_);
        success = IERC20AndOwnable(_projectToken).approve(_msgSender(), amount_);
         _totalTokensSupplyControlled = _totalTokensSupplyControlled.sub(amount_);
        
        _allowWithdraw();
        emit WithdrawnProjectToken(_msgSender(), amount_);
    }
    
    // todo: verify the balance is right
    function _getProjTknBal(address funder_) internal view returns(uint balance) {
        if(_projTokensWithdrawn[funder_] == true) {
            return 0;
        }
        uint tokensForContributors = _totalTokensILO - _amountForProjTokenCalc;
        balance = _getProportionAmt(tokensForContributors, _fundingTokenTotal, _funders[funder_].fundingTokenAmount);
        // avoid solidity rounding fractions to 0
        // if(tokensForContributors > i._fundingTokenTotal) {
            
        //     amtPer = tokensForContributors / i._fundingTokenTotal;
        //     balance  = _funders[funder_].fundingTokenAmount * amtPer;
        // }else {
        //     amtPer = i._fundingTokenTotal / tokensForContributors;
        //     balance  = _funders[funder_].fundingTokenAmount / amtPer;
        // }
        // uint amtPer = i._fundingTokenTotal.div(10 ** 18);
       
        // lpPer * fundingTokenAmount to get lp tokens to send
       
    }
    
    function _getLiqTknBal(address funder_) internal view returns(uint balance) {
        if(_liqTokensWithdrawn[funder_] == true) {
            return 0;
        }
        
        balance = _getProportionAmt(_totalLPTokens, _fundingTokenTotal, _funders[funder_].fundingTokenAmount);
        // uint amtPer;
        // // avoid solidity rounding fractions to 0
        // if(_totalLPTokens > i._fundingTokenTotal) {
        //     amtPer = _totalLPTokens / i._fundingTokenTotal;
        //     balance  = _funders[funder_].fundingTokenAmount * amtPer;
        // }else {
        //     amtPer = i._fundingTokenTotal / _totalLPTokens;
        //     balance  = _funders[funder_].fundingTokenAmount / amtPer;
        // }
        
        
    }
    
    function _getProportionAmt(uint totalRewardTokens, uint totalFundingTokens, uint funderFundingAmount) internal pure returns (uint proportionalRewardTokens) {
        // assumes each both tokens a decimals = 18, while precision is lost, reducing this blunts the loss of precision
        uint reducedTotalFundingTokens = totalFundingTokens / (10 ** 12);
        uint reducedFunderFundingAmount = funderFundingAmount / (10 ** 12);
        uint amtPer = totalRewardTokens / reducedTotalFundingTokens;
        
        proportionalRewardTokens = amtPer * reducedFunderFundingAmount;
    }
    
    event WithdrawnOnFailure(address indexed funder_, address indexed TokenAddr_, uint indexed amount_,  bool isAdmin);
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
            emit WithdrawnOnFailure(_msgSender(), _projectToken, amount_, true);
            
        }else{
            // if not admin send back funding token (nativ token like eth or ERC20 token)
            FunderInfo storage funder = _funders[_msgSender()];
            uint amount_ = funder.fundingTokenAmount;
            require(amount_ > 0, "no balance");
            // uint amount2_ = funder.projectTokenAmount;
            funder.fundingTokenAmount = 0;
            funder.projectTokenAmount = 0;
            _fundingTokenAvail = _fundingTokenAvail.sub(amount_);
            if(i._fundingToken == address(0)) {
                // send native token to funder
                (success, ) = _msgSender().call{value: amount_}('');
                emit WithdrawnOnFailure(_msgSender(), address(0), amount_, false);
                
            }else {
                // or if funding token wasn't native, send ERC20 token
                success = IERC20AndOwnable(i._fundingToken).approve(_msgSender(), amount_);
                emit WithdrawnOnFailure(_msgSender(), i._fundingToken, amount_, false);
            }
        }
        
        
        _allowWithdraw();
    }
    
    event WithdrawnLiquidityToken(address funder_, uint amount_);
    
    // withraws all the liquidity token of the user
    function withdrawLiquidityTokens() external allowedToWithdraw returns(bool success) {
        require(!isLiqTokenLocked(), "withdrawal locked ");
        _disallowWithdraw();
        require(!_liqTokensWithdrawn[_msgSender()], "No tokens");
        uint LPAmount_ = _getLiqTknBal(_msgSender());
        _liqTokensWithdrawn[_msgSender()] = true;
        
        require(LPAmount_ > 0 && LPAmount_ <= _availLPTokens, "not enough lp tokens");
        _availLPTokens = _availLPTokens.sub(LPAmount_);
        success = IERC20Uni(_liquidityPairAddress).approve(_msgSender(), LPAmount_);
        _allowWithdraw();
        emit WithdrawnLiquidityToken(_msgSender(), LPAmount_);
        
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
    
    function _getLiquidityPairAddress() internal view returns(address liquidPair_) {
        
        if(address(0) == i._fundingToken) {
            address WETH_ = IUniswapRouter(i._addressOfDex).WETH();
            liquidPair_ = IUniswapFactory(i._addressOfDexFactory).getPair(WETH_, _projectToken);
            require(address(0) != liquidPair_, "Liquidity Pair Should Be Created But Hasn't");
        } else {
            liquidPair_ = IUniswapFactory(i._addressOfDexFactory).getPair(i._fundingToken, _projectToken);
            require(address(0) != liquidPair_, "Liquidity Pair Should Be Created But Not Created");
        }
    }
    
    event TimeLockSet(uint indexed projTokenLock_, uint indexed contribTokenLock_, uint indexed liquidityTokenLock_);
    function _setTimeLocks() internal returns(bool)  {
        require(!isTimeLockSet(), "Time lock already set");
        uint timeLockLengthX2 = i._contribTimeLock * 2;
        // if timelock greater than 60 days in seconds, set to length of contributor timelock + 30 days
        uint timeLen = timeLockLengthX2 > 5184000 ? i._contribTimeLock + 2592000 : timeLockLengthX2;
        
        _projTimeLock = block.timestamp + timeLen;
        _projBlockLock = block.number + uint(timeLen / MINE_LEN);
        _contribTimeStampLock = block.timestamp + i._contribTimeLock;
        _contribBlockLock = block.number + uint(i._contribTimeLock / MINE_LEN);
        _liqPairTimeLock = block.timestamp + i._liqPairLockLen;
        _liqPairBlockLock = block.number + uint(i._liqPairLockLen / MINE_LEN);
        
        emit TimeLockSet(_projBlockLock, _contribBlockLock, _liqPairBlockLock);
        
        return true;
    
    }
    
    // this can be called by anyone. but should be called AFTER the ILO
    // on xDai chain ETH would be xDai, on BSC it would be BNB 
    // step 6a
    function _createLiquidityPairETH() internal returns(uint liquidityTokens_) {
        
        //require(address(0) == i._fundingToken, "xStarterPair: FundingTokenError");
        uint amountETH = _fundingTokenAvail;
        uint amountProjectToken = _tokensForLiquidity;
        
        
        // approve project token to be sent to dex. Spender is dex IUniswapRouter address (honeyswap, uniswap etc)
        //bool approved_ = _callApproveOnProjectToken(i._addressOfDex, amountProjectToken);
       
        
        (uint amountTokenInPool, uint amountETHInPool, uint amountliquidityToken) = IUniswapRouter(i._addressOfDex).addLiquidityETH{value: amountETH}(
            _projectToken,
            amountProjectToken,
            amountProjectToken,
            amountETH,
            address(this),
            block.timestamp + i._dexDeadlineLength
            );
        
        liquidityTokens_ = amountliquidityToken;
        
        _fundingTokenAvail = 0;
        // subtract amount sent to liquidity pool from this
        _totalTokensSupplyControlled =  _totalTokensSupplyControlled.sub(amountProjectToken);
        _tokensForLiquidity = 0;
        
        
    }
    
    // step 6b
    function _createLiquidityPairERC20() internal returns(uint liquidityTokens_) {
        
        require(address(0) != i._fundingToken, "xStarterPair: FundingTokenError");
        //require(_approvedForLP, "xStarterPair: TokenApprovalFail, call syncBalances before calling again");
        
        uint amountERC20 = _fundingTokenAvail;
        uint amountProjectToken = _tokensForLiquidity;
        
        
        // approve project token to be sent to dex. Spender is dex IUniswapRouter address (honeyswap, uniswap etc)
        // bool approvedA_ = _callApproveOnProjectToken(i._addressOfDex, amountProjectToken);
        // bool approvedB_ = _callApproveOnFundingToken(i._addressOfDex, amountERC20);
        
        
        //require(approvedA_ && approvedB_, "xStarterPair: TokenApprovalFail, call syncBalances before calling again");
        
        (uint amountTokenInPool, uint amountETHInPool, uint amountliquidityToken) = IUniswapRouter(i._addressOfDex).addLiquidity(
            _projectToken,
            i._fundingToken,
            amountProjectToken,
            amountERC20,
            amountProjectToken,
            amountERC20,
            address(this),
            block.timestamp + i._dexDeadlineLength
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
        success = IERC20(i._fundingToken).approve(spender_, amount_);
        
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