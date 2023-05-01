// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

library Math {
    uint8 constant value = 5;

    function add(uint256 a, uint256 b) internal pure returns(uint256){
        return a+b;
    }

    function addFive(uint256 a) internal pure returns(uint256){
        return a+value;
    }
}

library advancedMath {
    function square(uint256 a) internal pure returns(uint256){
        return a**2;
    }
}

contract Calculator {
    using Math for uint256;
    // using Math, advancedMath for uint256;
    // using Math for *;

    function sum(uint256 a, uint256 b) external  pure returns(uint256){
        return a.add(b);
    }
}