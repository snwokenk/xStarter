// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";

contract xStarterNFT is Context {
    
    address public _xStarterLaunchPad;
    address public _xStarterGovernance;
    bool _isProd;
    bool _initialized;
    address _allowedCaller = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266; // address of deployer
    
    function initialize(address xStarterGovernance_, address xStarterLaunchPad_, bool isProd_) external returns(bool) {
        require(!_initialized, "contract has already been initialized");
        require(_allowedCaller != address(0) && _msgSender() == _allowedCaller, 'Not authorized');
        _initialized = true;
        _allowedCaller = address(0);
        _isProd = isProd_;
        _xStarterGovernance = xStarterGovernance_;
        _xStarterLaunchPad = xStarterLaunchPad_;
        
        return true;
    }
}