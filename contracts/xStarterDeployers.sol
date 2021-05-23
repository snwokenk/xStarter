// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


// launched by user, directly deploying from launchpad increases the code size
contract BaseDeployer {
     address public _admin; // address of deployer
    
     constructor() {
        require(msg.sender == _admin, 'Not authorized');
        _admin = msg.sender;
    }
    function setLaunchPad(address launchPad_) external returns(bool) {
        require(msg.sender == _admin, 'not authorized');
        _admin = launchPad_;
        return true;
    }
}


