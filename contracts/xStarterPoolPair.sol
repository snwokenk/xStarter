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
//import "./UniswapInterface.sol";



// https://ropsten.etherscan.io/tx/0xd0fd6a146eca2faff282a10e7604fa1c0c334d6a8a6361e4694a743154b2798f
// must first approve amount


// https://ropsten.etherscan.io/tx/0x2f39644b43bb8f1407e4bb8bf9c1f6ceb116633be8be7c8fa2980235fa088c51
// transaction showing how to add liquidity for ETH to token pair


interface IERC20AndOwnable {
    function totalSupply() external view returns (uint256);
    function owner() external view  returns (address);
    function allowance(address owner_, address spender) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
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
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}




contract ProjectBaseToken is Context, ERC777 {
    using SafeMath for uint256;
    using Address for address;

    constructor(
        string memory name_,
        string memory symbol_,
        uint totalSupply_,
        address[] memory defaultOperators_
    ) ERC777(name_, symbol_, defaultOperators_) {

        // this will mint total supply 
        _mint(_msgSender(), totalSupply_, "", "");

    }
}



contract xStarterPoolPair is Ownable, Administration, IERC777Recipient, IERC777Sender {
    using SafeMath for uint256;
    using Address for address;
    
    struct FunderInfo {
    uint fundingTokenAmount;
    uint projectTokenAmount;
        
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
    
    event TokenCreatedByXStarterPoolPair(address indexed TokenAddr_, address indexed PoolPairAddr_, address indexed Admin_, uint timestamp_);
    
    address private _addressOfDex;
    uint24 private _dexDeadlineLength;
    
    // stores address of the project's token
    address private _projectToken;
    
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
    // address of  dex liquidity token pair, this is the pair that issues liquidity tokens from uniswap or deriivatives
    address _liquidityPairAddress; 
    uint private _liquidityPairAmount; // amount of liquidity
    uint8 private _percentOfTotalTokensForILO;
    uint8 private _percentOfILOTokensForLiquidity = 50;
    // timestamp of when contributors tokens will be free to withdraw
    uint private _contributorsTimeStampLock;
    // time stamp until project tokens are free usually double the length of contributor time
    uint private _projectOwnerTimestampLock;
    
    // the length in seconds of timelock Minimum is 14 days equivalent or 1,209,600 seconds
    // also project owners tokens are timelocked for either double the timelock of contributors or an additional 2 months
    uint private _contributorTimeLockLength;
    
    // the number of tokens to sell to be considered a success ie:  1 - (_availTokensILO / _totalTokensILO) >= _percentRequiredTokenPurchase
    uint8 private _percentRequiredTokenPurchase = 50;
    uint40 private _minFundingTokenPerAddress;
    uint40 private _maxFundingTokenPerAddress;
    uint private _swapRatio;
    
    

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
    
    bool _ILOValidated;
    
    mapping(address => FunderInfo) private _funders;
    mapping(address => bool) private _currentlyFunding;
    
    // step 1
    constructor(
        address adminAddress,
        uint8 percentOfTokensForILO_,
        uint24 swapRatio_,
        uint24 dexDeadlineLength_,
        address fundingToken_
        ) Administration(adminAddress) {
            require(percentOfTokensForILO_ > 0 && percentOfTokensForILO_ <= 100, "percent of tokens must be between 1 and 100");
            require(swapRatio_ > 0, "swapRatio must at least 1 ");
            _percentOfTotalTokensForILO = percentOfTokensForILO_;
            _fundingToken = fundingToken_;
            _dexDeadlineLength = dexDeadlineLength_;
            
        }
    function funders(address funder_) public view returns(uint, uint) {
        return (_funders[funder_].fundingTokenAmount, _funders[funder_].projectTokenAmount);
    }
    function isSetup() public view returns (bool) {
        return _isSetup;
    }
    
    function isTimeLockSet() public view returns (bool) {
        return _projectOwnerTimestampLock == 0 && _contributorsTimeStampLock == 0;
    }
    
    
    function isContributorTimeLocked() public view returns (bool) {
        require(isTimeLockSet, "Time locked not set");
        return block.timestamp > _contributorsTimeStampLock;
    }
    
    function isProjectOwnerTimeLocked() public view returns (bool) {
        require(isTimeLockSet, "Time locked not set");
        return block.timestamp > _projectOwnerTimestampLock;
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
    
    function isEventOpen() public view returns (bool isOpen_) {
        uint48 currentTime = uint48(block.timestamp);
        
        if(currentTime >= startTime() && currentTime < endTime() && availTokensILO() > 0 ) {
            isOpen_ = true;
        }
        
    }
    
    function isEventDone() public view returns (bool isOpen_) {
        uint48 currentTime = uint48(block.timestamp);
        
        if(currentTime > endTime() || availTokensILO() == 0 ) {
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
            
            
            require(!_isSetup,"initial setup already done");
            
            // if address of project token is 0 address deploy token for it
            if(address(0) == addressOfProjectToken) {
                    address[] memory defaultOperators_;
                    _deployToken(tokenName_, tokenSymbol_, totalTokenSupply_, defaultOperators_);
            } 
            else {
                IERC20AndOwnable existingToken = IERC20AndOwnable(addressOfProjectToken);
                
                address existingTokenOwner = existingToken.owner();
                uint existingTokenSupply = existingToken.totalSupply();
                
                require(existingTokenOwner == admin(),"Admin of pool pair must be owner of token contract");
                require(existingTokenSupply == totalTokenSupply_);
                
                _projectToken = addressOfProjectToken;
                _totalTokensSupply = _totalTokensSupply.add(totalTokenSupply_);
                
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
        ProjectBaseToken newToken = new ProjectBaseToken(name_,symbol_, totalTokenSupply_, defaultOperators_);

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
        
        if(_totalTokensSupplyControlled == _totalTokensSupply) { 
            return true;
            
        }
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
        uint amount = _totalTokensSupplyControlled.mul(_percentOfTotalTokensForILO/100);
        _totalTokensILO = amount;
        _availTokensILO = amount;
    }
    
    
    // functions for taking part in ILO
    function nativeTokenSwap() payable notCurrentlyFunding onlyOpen external returns(bool){
        require(msg.value > 0, "No value Sent");
        _disallowFunding();
        _performSwap(msg.value, _msgSender());
        _allowFunding();
        return true;
        
    }
    
    // should be called after approving amount of token
    function fundingTokenSwap() notCurrentlyFunding  onlyOpen external returns(bool) {
        require(_fundingToken != address(0), "please use nativeTokenSwap. Only native token allowed. xDai token for xDai side chain etc");
        _disallowFunding();
        uint amount_ = _retrieveApprovedToken();
        _performSwap(amount_, _msgSender());
        _allowFunding();
        
        return true;
    }
    
    // a lock on a specific address can be added so address not calling function to fast
    function _performSwap(uint fundingTokenAmount_, address funder_) internal {
        
        // calculate project tokens based on _swapRatio
        uint projectTokenDesired = fundingTokenAmount_.mul(_swapRatio);
        uint projectTokenReceived = projectTokenDesired * (_percentOfILOTokensForLiquidity/100);
        
        // add to msg.sender token funder balance
        FunderInfo storage funder = _funders[funder_];
        funder.fundingTokenAmount = funder.fundingTokenAmount.add(fundingTokenAmount_);
        require(funder.fundingTokenAmount >= _minFundingTokenPerAddress , "Minimum not met");
        // if max is set then make sure not contributing max
        require(funder.fundingTokenAmount <= _maxFundingTokenPerAddress || _maxFundingTokenPerAddress == 0, "maximum exceeded");
        funder.projectTokenAmount = funder.projectTokenAmount.add(projectTokenReceived);
        
        // make state changes
        
        // add to funding token total (funding can be eth, xDai or other native tokens, OR an ERC20 token)
        _fundingTokenTotal = _fundingTokenTotal.add(fundingTokenAmount_);
        _fundingTokenAvail = _fundingTokenAvail.add(fundingTokenAmount_);
        // subtract from availTokensILO
        _availTokensILO = _availTokensILO.sub(projectTokenDesired, "not enough project tokens");
        // the difference between what is desired vs what is received is the amount for the tokens for liquidity.
        // ideally should 50 50
        _tokensForLiquidity = projectTokenDesired - projectTokenReceived;
        
        
    }
    
    function _retrieveApprovedToken() internal returns(uint allowedAmount_) {
        address ownAddress = address(this);
        IERC20AndOwnable existingToken = IERC20AndOwnable(_fundingToken);
        allowedAmount_ = existingToken.allowance(_msgSender(), ownAddress);
        require(allowedAmount_ > 0, "Amount must be greater than 0");
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
    
    // step 4 validate after ILO
    function validateILO() external returns(bool) {
        require(isEventDone(), "ILO not yet done");
        uint8 availRatio = uint8(_availTokensILO / _totalTokensILO);
        uint8 percentRatio = (1 - availRatio) * 100;
        require( percentRatio >= _percentRequiredTokenPurchase);
        
        _ILOValidated = true;
        return true;
    }
    
    // step 5
    function createLiquidityPool() external returns(address pairAddress) {
        // liquidity will be _fundingTokenAvail to _tokensForLiquidity ratio
        require(_ILOValidated, "You must first validate ILO");
        uint liquidityAmount;
        if(address(0) == _fundingToken) {
            liquidityAmount = _createLiquidityPairETH();
        } else {
            liquidityAmount = _createLiquidityPairERC20();
        }
        
        _liquidityPairAmount = liquidityAmount;
        // todo after creating liquidity pool set the locks timestamp
        
        
        
    }
    
    
    
    function _setTimeLocks() {
        require(!isTimeLockSet, "Time lock already set");
        
    }
    
    // this can be called by anyone. but should be called AFTER the ILO
    // on xDai chain ETH would be xDai, on BSC it would be BNB 
    // step 5a
    function _createLiquidityPairETH() internal returns(uint liquidityTokens_) {
        
        //require(address(0) == _fundingToken, "xStarterPair: FundingTokenError");
        uint amountETH = _fundingTokenAvail;
        uint amountProjectToken = _tokensForLiquidity;
        
        // approve project token to be sent to dex. Spender is dex IUniswapRouter address (honeyswap, uniswap etc)
        bool approved_ = _callApproveOnProjectToken(_addressOfDex, amountProjectToken);
        require(approved_, "xStarterPair: TokenApprovalFail");
        
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
    
    // step 5b
    function _createLiquidityPairERC20() internal returns(uint liquidityTokens_) {
        
        require(address(0) != _fundingToken, "xStarterPair: FundingTokenError");
        
        uint amountERC20 = _fundingTokenTotal;
        uint amountProjectToken = _totalTokensSupplyControlled;
        
        
        // approve project token to be sent to dex. Spender is dex IUniswapRouter address (honeyswap, uniswap etc)
        bool approvedA_ = _callApproveOnProjectToken(_addressOfDex, amountProjectToken);
        bool approvedB_ = _callApproveOnFundingToken(_addressOfDex, amountERC20);
        
        require(approvedA_ && approvedB_, "xStarterPair: TokenApprovalFail, call syncBalances before calling again");
        
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
        IERC20AndOwnable existingToken = IERC20AndOwnable(_projectToken);
        bool success = existingToken.approve(spender_, amount_);
        
    }
    
    function _callApproveOnFundingToken(address spender_, uint amount_) internal returns(bool success) {
        IERC20AndOwnable existingToken = IERC20AndOwnable(_fundingToken);
        bool success = existingToken.approve(spender_, amount_);
        
    }
    // IERC777Recipient implementation
    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external pure override{
        // this contract should receive token using approve on ERC20/ and then fundingTokenSwap function on this contract
        revert("send tokens using approve on ERC20 and then calling fundingTokenSwap");
    }
    
    // IERC777Sender implementation called before tokenis
    function tokensToSend(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external pure override {
        revert("send tokens using approve on ERC20 and then calling fundingTokenSwap");
    }
    
}