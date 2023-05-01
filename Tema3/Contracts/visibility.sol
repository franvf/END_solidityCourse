//SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

contract A {
    uint256 private value; //Always private. If it is public getter is created automatically

    function setValue(uint256 newValue) public returns(uint256) { 
        value = newValue;
        return value;
    }

    function multiplyValue(uint256 multiplier) external {
        uint256 newValue = value * multiplier;
        setValue(newValue); //Cambiar setvalue() a external-private, internal para el ejemplo
    }

    function getValue() public view returns(uint256){
        return value;
    }
}

contract B is A { //Decir que esto es herencia -> Todas las funciones que no sean privadas/externas se van a poder llamar

    function addValue(uint256 addend) public returns(uint256) {
        //No podemos hacer esto porque value es privada. (Modificar a internal y public para demostrar)
        // value = value + addend;
        // return value;

        uint256 value = getValue(); //Cambiar getValue a external/public/private
        value = value + addend;
        setValue(value);
        return value;
    }

}