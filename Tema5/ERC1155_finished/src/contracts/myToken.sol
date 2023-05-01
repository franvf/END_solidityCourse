//SPDX-License-Identifier: UNLICENSED

pragma solidity  ^0.8.17;

import "../../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20 {

    address private owner;
    address private gladiatorAddress;
    uint256 private tokenPrize = 0.01 ether;

    modifier onlyAuthorizedAccounts()  {
        require(msg.sender == owner || msg.sender == gladiatorAddress, "Unauthorized");
        _;
    }

    constructor() ERC20("myToken", "MTK"){
        owner = msg.sender;
        _mint(address(this), 1000000 * 10 ** 18);
    }

    function mint(address receiver, uint256 amount) external onlyAuthorizedAccounts{
        _mint(receiver, amount);
    }

    //buy token
    function buyTokens(uint256 amount) external payable { //Payable permite que una función o una address reciba ether en el propio contrato.
                                                          //La función recibe ether del msg.sender para pagar los tokens, y el owner recibe dicho ether
        require(balanceOf(address(this)) >= amount, "Amount exceeds contract's balance");
        uint256 totalToPay = (amount / 1 ether) * tokenPrize;
        require(msg.value == totalToPay, "Prize is not correct");
        (bool sent, ) = payable(owner).call{value: msg.value}(""); //call es una función de bajo nivel que se usa para interactuar con otros contratos. 
                                                                    //Puede ser insegura por lo que hay que hacer un uso muy controlado de ella.
                                                                    //Existen otras formas de mandar ether a contratos que serían send y trnasfer, pero 
                                                                    //no se recomiendan.
        require(sent, "Payment not completed");
        _transfer(address(this), msg.sender, amount);
    }

    //Send token to other accounts (send totken to friends, reward when player wins a fight)
    function sendTokens(address from, address receiver, uint256 amount) external {
        require(balanceOf(from) >= amount, "Amount exceeds sender's balance");
        _transfer(from, receiver, amount);
    }

    function setGladiatorAddress(address newAddress) external onlyAuthorizedAccounts returns(address) {
        gladiatorAddress = newAddress;
        //Event
        return gladiatorAddress;
    }

    function getGladiatorAddress() external view returns(address){
        return gladiatorAddress;
    }

}