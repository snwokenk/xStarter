// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC777/IERC777Recipient.sol";
import "@openzeppelin/contracts/token/ERC777/IERC777Sender.sol";
import "@openzeppelin/contracts/token/ERC777/ERC777.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "./Administration.sol";


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
    
    event TokenCreatedByStarterPool();
    
    // stores address of the project's token
    address private _projectToken;
    
    // uint keeping track of total project's token supply
    uint private _totalTokensSupply;
    
    // uint keeping of set aside for ILO
    uint private _totalTokensILO;
    
    // tokens remaining for ILO
    uint private _availTokensILO;
    
    // utc timestamp
    uint48 private _startTime;
    
    // uint timestamp
    uint48 private _endTime;
    
    constructor(
        address admin, 
        address addressOfProjectToken,
        string memory tokenName_,
        string memory tokenSymbol_,
        uint totalTokenSupply_,
        uint48 startTimeTimestamp, 
        uint48 endTimeTimestamp
        ) Administration(admin) {
            
            if(address(0) == addressOfProjectToken) {
                address[] memory defaultOperators_;
                _deployToken(tokenName_, tokenSymbol_, totalTokenSupply_, defaultOperators_);
            } else {
                
            }
            _startTime = startTimeTimestamp;
            _endTime = endTimeTimestamp;
        }
    
    function _deployToken(
        string memory name_,
        string memory symbol_,
        uint totalTokenSupply_,
        address[] memory defaultOperators_
    ) internal onlyAdmin returns(bool){
        ProjectBaseToken newToken = new ProjectBaseToken(name_,symbol_, totalTokenSupply_, defaultOperators_);

        _projectToken = address(newToken);
        _totalTokensSupply = totalTokenSupply_;
        
        return true;
        
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