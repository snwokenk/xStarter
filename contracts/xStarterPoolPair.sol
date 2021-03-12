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


interface ERC20AndOwnable {
    function totalSupply() external view returns (uint256);
    function owner() external view  returns (address);
    function allowance(address owner_, address spender) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
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
    
    event TokenCreatedByXStarterPoolPair(address indexed TokenAddr_, address indexed PoolPairAddr_, address indexed Admin_, uint timestamp_);
    
    // stores address of the project's token
    address private _projectToken;
    
    // uint keeping track of total project's token supply
    uint private _totalTokensSupply;
    
    uint private _totalTokensSupplyControlled;
    
    // this is set up by the launchpad, it enforces what the project told the community
    // if the project said 70% of tokens will be offered in the ILO. This will be set in the constructor.
    address _fundingToken; // if 0 then use nativeTokenSwap
    uint private _percentOfTotalTokensForILO;
    uint private _swapRatio;
    
    
    // uint amount of tokens  aside for ILO
    uint private _totalTokensILO;
    
    // tokens remaining for ILO
    uint private _availTokensILO;
    
    // utc timestamp
    uint48 private _startTime;
    
    // uint timestamp
    uint48 private _endTime;
    
    // bool if xStarterPoolPair is set up
    bool _isSetup;
    
    mapping(address => FunderInfo) private _funders;
    
    // step 1
    constructor(
        address adminAddress,
        uint8 percentOfTokensForILO_,
        uint24 swapRatio_,
        address fundingToken_
        ) Administration(adminAddress) {
            require(percentOfTokensForILO_ > 0 && percentOfTokensForILO_ <= 100, "percent of tokens must be between 1 and 100");
            require(swapRatio_ > 0, "swapRatio must at least 1 ");
            _percentOfTotalTokensForILO = percentOfTokensForILO_;
            _fundingToken = fundingToken_;
        }
    function isSetup() public view returns (bool) {
        return _isSetup;
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
                ERC20AndOwnable existingToken = ERC20AndOwnable(addressOfProjectToken);
                
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
        ERC20AndOwnable existingToken = ERC20AndOwnable(_projectToken);
        uint allowance = existingToken.allowance(admin(), address(this));
        require(allowance == _totalTokensSupply, "You must deposit all available tokens by calling the approve function on the token contract");
        // transfer approved tokens from admin to current ILO contract
        success = existingToken.transferFrom(_msgSender(), address(this), _totalTokensSupply);
        
        if(success) {
            _totalTokensSupplyControlled =  _totalTokensSupplyControlled.add(_totalTokensSupply);
            _setTokensForILO();
        }
        return success;
        
    }
    
    // function should be called within a function that checks proper access ie onlyAdmin or onlyOwner
    function _setTokensForILO() internal {
        // using the percent of tokens set in constructor by launchpad set total tokens for ILO 
        // formular:  (_percentOfTotalTokensForILO/100 ) * _totalTokensSupplyControlled
        _totalTokensILO = _totalTokensSupplyControlled.mul(_percentOfTotalTokensForILO.div(100));
    }
    
    
    // functions for taking part in ILO
    function nativeTokenSwap() payable external {
        require(msg.value > 0, "No value Sent");
        uint value_ = msg.value;
        uint projectTokenAmount = value_.mul(_swapRatio);
        FunderInfo storage funder = _funders[_msgSender()];
        funder.fundingTokenAmount = funder.fundingTokenAmount.add(value_);
        funder.projectTokenAmount = funder.projectTokenAmount.add(projectTokenAmount);
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
        // this contract shouldn't receive tokens
        revert();
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
        revert();
    }
    
}