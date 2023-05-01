//SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;
// pragma solidity >0.8.0 <0.9.0;
// pragma solidity 0.8.14;

contract Test {

    uint256 x = 0;


    function setX(uint256 newX) public {
        x = newX;
    }

    function getX() public view returns(uint256) {
        return x;
    }

    function sum(uint256 a, uint256 b) public returns(uint256 total) {
        x = a;
        total = x + b;
        return total;
    }

}