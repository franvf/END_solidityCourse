//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GovernanceToken is ERC20Votes, Ownable {
    uint256 public supply = 100 ether;

    constructor()
        ERC20("END_Token", "END")
        ERC20Permit("END_Token"){
            _mint(msg.sender, supply);
        }

    function mint(uint256 numTokens) public onlyOwner {
        _mint(msg.sender, numTokens);
    }

    //Required overrides by solidity

    // actualiza los checkpoints necesarios tras realizar una transferencia de tokens
    function _afterTokenTransfer(address from, address to, uint256 amount) internal override(ERC20Votes){
        super._afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal override(ERC20Votes){
        super._mint(account, amount);
    }

    function _burn(address account, uint256 amount) internal override(ERC20Votes){
        super._burn(account, amount);
    }
}