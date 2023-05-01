//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import '../node_modules/@openzeppelin/contracts/token/ERC1155/ERC1155.sol';
import '../node_modules/@openzeppelin/contracts/utils/Strings.sol';

//Elegimos tokens ERC1155 para poder crear varios gladiadores de una misma
//clase. ERC1155 nos permite esto y además podemos establecer un URI para cada
//gladiador

contract GladiatorNFT is ERC1155{

    using Strings for uint256;
    
    address private gladiatorAddress;
    address private owner;
    string private baseURI;

    mapping(address => uint256) ownerOf;

    modifier onlyAuthorizedAccounts()  {
        require(msg.sender == owner || msg.sender == gladiatorAddress, "Unauthorized");
        _;
    }

    constructor(string memory newBaseURI) ERC1155(baseURI){
        owner = msg.sender;
        baseURI = newBaseURI;
    }

    //mint just from gameAddress
    function mint(address receiver, uint256 tokenId) external onlyAuthorizedAccounts {
        _mint(receiver, tokenId, 1, "");
        tokenURI(tokenId);
        ownerOf[receiver] = tokenId;
    }

    //URI
    function tokenURI(uint256 tokenId) public view returns (string memory) {
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString(), ".json")) : "";
    }

    function getGladiatorAddress() external view returns(address){
        return gladiatorAddress;
    }

    //Getter
    function getMyNFT() external view returns(uint256){
        return ownerOf[msg.sender];
    }

    
    function setGladiatorAddress(address newAddress) external onlyAuthorizedAccounts returns(address) {
        gladiatorAddress = newAddress;
        //Event
        return gladiatorAddress;
    }
}