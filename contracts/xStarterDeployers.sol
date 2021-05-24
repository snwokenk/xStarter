// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;



// launched by user, directly deploying from launchpad increases the code size
contract BaseDeployer {
     address public admin; // address of deployer
     mapping(address => bool) _allowedCallers;
     
     modifier onlyAdmin() {
        require(admin == msg.sender, "Not authorized");
        _;
    }
    modifier onlyAllowedCaller() {
        require(_allowedCallers[msg.sender] || admin == msg.sender, "Not an Allowed Caller");
        _;
    }
    
    constructor() {
        admin = msg.sender;
    }
    function setAdmin(address newAdmin_) external onlyAdmin returns(bool) {
        admin = newAdmin_;
        return true;
    }
    function setAllowedCaller(address allowedCaller_) external onlyAdmin returns(bool) {
        require(!_allowedCallers[allowedCaller_], 'msg.sender already allowed');
        _allowedCallers[allowedCaller_] = true;
        return true;
    }
}


