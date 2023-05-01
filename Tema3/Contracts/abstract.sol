//SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

abstract contract Geometric {
    
    uint256 private base;
    uint256 private height;

    constructor(uint256 newBase, uint256 newHeight){
        base = newBase;
        height = newHeight;
    }

    function setBase(uint256 newBase) external returns(uint256){
        base = newBase;
        return base;
    }

    function setHeight(uint256 newHeight) external returns(uint256){
        height = newHeight;
        return height;
    }

    function getBase() public view returns(uint256){
        return base;
    }

    function getHeight() public view returns(uint256){
        return height;
    }

    function calculateArea() external view virtual returns(uint256);
}

contract Rectangle is Geometric {

    constructor(uint256 newBase, uint256 newHeight) Geometric(newBase, newHeight){}

    function calculateArea() external view override returns(uint256){
        uint256 base = getBase();
        uint256 height = getHeight();
        return base * height;
    }

}