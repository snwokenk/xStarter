// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

import "@openzeppelin/contracts/utils/Context.sol";

abstract contract Interaction is Context {
    
    modifier allowedToInteract() {
        require(!_currentlyInteracting[_msgSender()], "Locked From Interaction, A transaction you initiated has not been completed");
        _;
    }
    
    mapping(address => bool) private _currentlyInteracting;
    
    function _allowInteraction() internal {
        _currentlyInteracting[_msgSender()] = false;
    }
    function _disallowInteraction() internal {
        _currentlyInteracting[_msgSender()] = true;
    }
}