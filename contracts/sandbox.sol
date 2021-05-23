// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract sandbox {
    
    uint[5] numberArray;
    uint[] dyna;
    
    function getLen() external view returns(uint) {
        return dyna.length;
    }
    function pushIt() external returns(uint) {
        dyna.push(uint(10));
        return dyna.length;
    }
    
    function getIt(uint index) external view returns(uint) {
        
        return dyna[index];
    }
}

contract getSandboxCode {
    
    uint version;
    
    function getCode(address _addr) external returns(bytes memory o_code, bytes memory b_code, address newCode) {
        
        uint oldVersion = version;
        uint newVersion = version + 1;
        bytes32 salt = keccak256(abi.encodePacked(oldVersion, newVersion));
        b_code = type(sandbox).creationCode;
        
        assembly {
            // retrieve the size of the code, this needs assembly
            let size := extcodesize(_addr)
            // allocate output byte array - this could also be done without assembly
            // by using o_code = new bytes(size)
            o_code := mload(0x40)
            // new "memory end" including padding
            mstore(0x40, add(o_code, and(add(add(size, 0x20), 0x1f), not(0x1f))))
            // store length in memory
            mstore(o_code, size)
            // actually retrieve the code, this needs assembly
            extcodecopy(_addr, add(o_code, 0x20), 0, size)
            
            
        }
        
        assembly {
            newCode := create2(0,add(o_code, 32), mload(o_code), salt)
        }
        
        
    }
}