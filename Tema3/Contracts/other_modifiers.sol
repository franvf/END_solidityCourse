//SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

contract A {
    uint256 value = 10;

    //Explicar errores 
    function setValue(uint256 newValue) public pure returns(uint256) {
        value = newValue;
        return value;
    }

    //Explicar warning
    function getValue() public returns(uint256) {
        return value;
    }

    //Explicar warning
    function add(uint a, uint b) public returns(uint256) {
        return a + b;
    }

    function doSomething(uint a, uint b) external pure virtual returns(uint256) {
        return a * b;
    }

    //Modificador
    address admin = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
    modifier onlyAdmin()  {
        require(msg.sender == admin);
        _;
    }

    //Comentar error
    function subtract(int a, int b) external pure onlyAdmin returns(int256){
        return a - b;
    }

}


contract B is A {
    //Comentar qué pasa si quitamos override 
    //Comentar qué pasa si cambiamos visibilidad a public
    //Comentar qué pasa si cambiamos visibilidad a internal/private
    function doSomething(uint a, uint b) external pure override returns(uint256){
        return a / b;
    }
}

contract C {
    //Comentar error y luego dar un valor
    uint256 private constant a = 5;

    uint256 private immutable b; //Si no le damos un valor necesitamos un constructor

    //mostrar que el valor puede pasarse como argumento y que a no puede inicializarse
    constructor() {
        // a = 5;
        b = 10;
    }
}