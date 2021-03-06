// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";

abstract contract Administration is Context {
    event AdministrationTransferred(address indexed previousAdmin, address indexed newAdmin);

    address internal _admin;

    constructor (address adminAddress)  {
        require(adminAddress != address(0), "Administration: new admin is the zero address");
        // address msgSender = _msgSender();
        _admin = adminAddress;
        emit AdministrationTransferred(address(0), adminAddress);
    }

    function admin() public view virtual returns (address) {
        return _admin;
    }

    modifier onlyAdmin() {
        require(admin() == _msgSender(), "Not authorized");
        _;
    }

    function renounceAdministration() public virtual onlyAdmin {
        emit AdministrationTransferred(_admin, address(0));
        _admin = address(0);
    }

    function transferAdministration(address newAdmin) public virtual onlyAdmin {
        require(admin() != address(0), "Administration: new admin is the zero address");
        emit AdministrationTransferred(_admin, newAdmin);
        _admin = newAdmin;
    }
}