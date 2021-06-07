// SPDX-License-Identifier: GPL-3.0
    
pragma solidity ^0.7.6;
import "remix_tests.sol"; // this import is automatically injected by Remix.
import "remix_accounts.sol";
import "../contracts/xStarterPoolPairB.sol";

// File name has to end with '_test.sol', this file can contain more than one testSuite contracts
contract testSuite {
    
    xStarterPoolPairB foo;
    
    /// 'beforeAll' runs before all other tests
    /// More special functions are: 'beforeEach', 'beforeAll', 'afterEach' & 'afterAll'
    function beforeAll() public {
        // Here should instantiate tested contract
        foo = new xStarterPoolPairB(
            "0xF4c8163B122fc28686990AC2777Fe090ca6b5357",
            70,1,15500000,1800,60,10000000000000000,10000000000000000,1000000000000000000,0x0000000000000000000000000000000000000000,
            "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D","0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f");
        Assert.equal(uint(1), uint(1), "1 should be equal to 1");
    }

    function checkSuccess() public {
        // Use 'Assert' to test the contract, 
        // See documentation: https://remix-ide.readthedocs.io/en/latest/assert_library.html
        Assert.equal(foo.admin(), "0xF4c8163B122fc28686990AC2777Fe090ca6b5357", "value of address not the same");
        Assert.equal(uint(2), uint(2), "2 should be equal to 2");
        Assert.notEqual(uint(2), uint(3), "2 should not be equal to 3");
    }

    function checkSuccess2() public pure returns (bool) {
        // Use the return value (true or false) to test the contract
        return true;
    }
    
    function checkFailure() public {
        Assert.equal(uint(1), uint(2), "1 is not equal to 2");
    }

    /// Custom Transaction Context
    /// See more: https://remix-ide.readthedocs.io/en/latest/unittesting.html#customization
    /// #sender: account-1
    /// #value: 100
    function checkSenderAndValue() public payable {
        // account index varies 0-9, value is in wei
        Assert.equal(msg.sender, TestsAccounts.getAccount(1), "Invalid sender");
        Assert.equal(msg.value, 100, "Invalid value");
    }
}
