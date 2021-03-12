// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";

abstract contract Administration is Context {
    event AdministrationTransferred(address indexed previousAdmin, address indexed newAdmin);

    address private _admin;

    constructor (address adminAddress)  {
        require(adminAddress != address(0), "Administration: new admin is the zero address");
        address msgSender = _msgSender();
        _admin = msgSender;
        emit AdministrationTransferred(address(0), msgSender);
    }

    function admin() public view virtual returns (address) {
        return _admin;
    }

    modifier onlyAdmin() {
        require(admin() == _msgSender(), "Administration: caller is not the admin");
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