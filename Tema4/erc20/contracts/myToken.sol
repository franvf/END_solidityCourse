//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20 {

    address private owner;
    address private gladiatorAddress;
    uint256 private tokenPrize = 0.01 ether;

    modifier onlyAuthorizedAccounts() {
        require(msg.sender == owner || msg.sender == gladiatorAddress, "Unauthorized");
        _;
    }

    constructor() ERC20("myToken", "MTK"){
        owner = msg.sender;
        _mint(address(this), 1_000_000 *10**18);
    }

    function mint(address to, uint256 amount) external onlyAuthorizedAccounts{
        _mint(to, amount);
    }

    function buyTokens(uint256 amount) external payable {
        require(balanceOf(address(this)) >= amount, "Amount exceeds contract balance");
        uint256 totalToPay = amount * tokenPrize;
        require(totalToPay == msg.value, "Prize is not correct");

        (bool success, ) = payable(owner).call{value: msg.value}("");
        require(success, "Payment not completed");
        _transfer(address(this), msg.sender, amount);        
    }

    function senTokens(address from, address to, uint256 amount) external {
        require(balanceOf(from) >= amount, "Amount exceeds sender's balance");
        _transfer(from, to, amount);
    }

    function setGladiatorAddress(address newAddress) external onlyAuthorizedAccounts returns(address){
        gladiatorAddress = newAddress;
        return gladiatorAddress;
    }

    function getGladiatorAddress() external view returns(address){
        return gladiatorAddress;
    }

}