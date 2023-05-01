//SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

contract A {
    uint8 private value;
    uint256[] historicValues;

    error BigNumber(string);

    function setValue(uint8 newValue) public returns(uint8) {
        // require(newValue <= 20, "El valor introducido debe ser menor o igual a 20"); 
        // assert(newValue <= 20);
        // if(newValue > 20) revert BigNumber("El valor introducido debe ser menor o igual a 20");
        // if(newValue > 20) revert();
        // if(newValue > 20) revert("El valor introducido debe ser menor o igual a 20");
        
        value = newValue;
        historicValues.push(value); //Añadir el valor al array al final
        return value;
    }

    function getValue() public view returns(uint8){
        return value;
    }

    //Obtener los valores historicos hasta cierto punto y devolver cuáles son pares
    function getSomeValues(uint256 limit) public view returns(uint256[] memory){
        require(limit <= historicValues.length, "limit sobrepasa la cantidad de elementos en el array");
        
        uint256[] memory someValues = new uint256[](limit);

        for(uint i; i < someValues.length; i++){
            if(historicValues[i] % 5 == 0){ //Si los valores son múltiplos de 5
                someValues[i] = 5;
            } else if(historicValues[i] % 2 == 0) { //Si es múltiplo de 2 (par)
                someValues[i] = 2;
            } else {
                someValues[i] = 1;
            }
        }

        // uint256 counter = 0;
        // while(counter < limit){
        //     someValues[counter] = historicValues[counter];
        //     counter += 1;
        // }

        // do {
        //     someValues[counter] = historicValues[counter];
        //     counter += 1;
        // } while(counter < limit);

        return someValues;
    }


}

contract B { 
    A sc; //Esto no es herencia es llamar a un contrato externo. Tiene sus implicaciones de seguridad.

    constructor(address scAddress) {
        sc = A(scAddress);
    }

    function addValue(uint8 addend) public returns(uint8) {

        uint8 value = sc.getValue();
        value = value + addend;
        sc.setValue(value);
        return sc.getValue();
        
        // try sc.setValue(value) returns(uint256 rtValue) {
        //     return(rtValue);
        // } catch Error(string memory){
        //     return 0;
        // }
        
    }

}