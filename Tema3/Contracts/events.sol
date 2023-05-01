//SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

contract Events {

    uint256 private x;

    event newXValue(uint256 newValue);
    // event newXValue(address indexed eoa, uint256 newXValue); 

    function setX(uint256 newX) external returns(uint256){
        x = newX;

        emit newXValue(x); //Se notifica a la blockchain cada vez que X cambia
        return x;
    }

}