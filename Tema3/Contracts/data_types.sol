//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.14;

contract DataTypes {

    //Enteros

    uint8 a = 100;
    // uint8 b = 1023;
    uint16 b = 1039;
    int8 c = -128;
    // int8 c = 128;

    //Booleanos
    bool d = true;
    // bool d; -> This is false

    //Address
    address e = 0xc3F064CbFDBf76673051B24f9BFB62fd211E6DCa;
    // address f = 0x00;

    //Enum -> Como crear un nuevo tipo de dato
    enum myEnum {
        Piedra, 
        Papel,
        Tijera
    }

    myEnum playerChoice;

    function setPlayerChoice(myEnum newChoice) public returns(myEnum) {
        playerChoice = newChoice;
        return playerChoice;
    }

    function setPlayerChoiceToRock() public {
        playerChoice = myEnum.Piedra;
    }

    //String

    string s = "Hola, buenos dias"; // -> Comentar que estas son variables de estado
    
    //Bytes
    bytes32 t = "Hola, buenos dias";

    function getCharacter(uint8 char) public view returns(bytes1) {
        bytes1 value = t[char]; // -> Comentar que estas son vairables locales
        return value;
    }

    // Access string character is not possible
    // function getCharacter(uint8 char) public view returns(string calldata) {
    //     string calldata value = s[char];
    //     return value;
    // }

    //Arrays
    uint8[] array; //Dynamic array

    function addElement(uint8 element) public {
        array.push(element);
    }

    // function modifySecondElement(uint8 element) public {
    //     array[2] = element;
    // }

    //Structs
    struct Empleado {
        uint8 edad;
        string nombre;
        bool activo;
    }

    Empleado myEmployee;

    function createEmployee(uint8 edad, string memory nombre, bool activo) public {
        // myEmployee.edad = edad;
        // myEmployee.nombre = nombre;
        // myEmployee.activo = activo;

        myEmployee = Empleado(edad, nombre, activo);
    }

    //Mappings
    mapping(uint256 => Empleado) listaEmpleados;

    function addEmployee(uint8 edad, string memory nombre, bool activo, uint256 clave) public {
        listaEmpleados[clave] = Empleado(edad, nombre, activo);
    }
}