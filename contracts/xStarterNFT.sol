// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";

contract xStarterNFT is Context {
    
    address public _xStarterLaunchPad;
    address public _xStarterToken;
    address public _xStarterGovernance;
    bool _isProd;
    bool _initialized;
    address _allowedCaller = 0xF4c8163B122fc28686990AC2777Fe090ca6b5357; // address of deployer
    
    function initialize(address xStarterGovernance_, address xStarterToken_, address xStarterLaunchPad_, bool isProd_) external returns(bool) {
        require(!_initialized, "contract has already been initialized");
        require(_allowedCaller != address(0) && _msgSender() == _allowedCaller, 'Not authorized');
        _initialized = true;
        _allowedCaller = address(0);
        _isProd = isProd_;
        _xStarterGovernance = xStarterGovernance_;
        _xStarterLaunchPad = xStarterLaunchPad_;
        _xStarterToken = xStarterToken_;
        
        return true;
    }
    
    function xStarterContracts() public view returns(address[3] memory) {
        return [_xStarterToken, _xStarterGovernance, _xStarterLaunchPad];
    }
    
    
}