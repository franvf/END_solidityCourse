//SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

interface IGeometric {

    function setBase(uint256 newBase) external returns(uint256);
    function setHeight(uint256 newHeight) external returns(uint256);
    function calculateArea() external view returns(uint256);

}

contract Rectangle is IGeometric {

    uint256 private base;
    uint256 private height;

    function setBase(uint256 newBase) external returns(uint256){
        base = newBase;
        return base;
    }

    function setHeight(uint256 newHeight) external returns(uint256){
        height = newHeight;
        return height;
    }

    function calculateArea() external view returns(uint256){
        return base * height;
    }

}

contract Triangle is IGeometric {

    uint256 private base;
    uint256 private height;

    function setBase(uint256 newBase) external returns(uint256){
        base = newBase;
        return base;
    }

    function setHeight(uint256 newHeight) external returns(uint256){
        height = newHeight;
        return height;
    }

    function calculateArea() external view returns(uint256){
        return (base * height)/2;
    }

}

abstract contract Square is IGeometric {
    
    // uint256 private base;

    // function setBase(uint256 newBase) external returns(uint256){
    //     base = newBase;
    //     return base;
    // }

    // function calculateArea() external view returns(uint256) {
    //     return base**2;
    // }
}