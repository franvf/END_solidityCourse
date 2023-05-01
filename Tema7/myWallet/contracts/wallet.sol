//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";

import "@openzeppelin/contracts/governance/Governor.sol";
import "./GovernorContract.sol";

contract UserWalletFactory {

    //mapping
    mapping(address => address) userWallet;

    //events
    event walletCreated(address walletAddress, address owner);
    function buildWallet() external returns(address){
        require(userWallet[msg.sender] == address(0), "You can't create mor than one wallet");
        UserWallet walletContract = new UserWallet(msg.sender);
        userWallet[msg.sender] = address(walletContract);

        emit walletCreated(address(walletContract), msg.sender);
        return address(walletContract);
    }

    function getWalletOf(address walletOwner) external view returns(address){
        return userWallet[walletOwner];
    }
}

contract UserWallet {

    address walletOwner;

    event itemsTransferred(address[] to, address[] items, uint256[] amounts);

    modifier onlyOwner() {
        require(walletOwner == msg.sender, "Access denied");
        _; 
    }

    constructor(address newOwner){
        walletOwner = newOwner;   
    }

    
    //function transferItems
    function transferItems(address[] calldata to, address[] calldata items, uint256[] calldata amounts) external onlyOwner {

        require(items.length == amounts.length && items.length == to.length, "Arrays lenghts must be equals");

        for(uint256 i; i < items.length; i++){
            IERC20 item = IERC20(items[i]);
            require(item.balanceOf(address(this)) >= amounts[i], "You don't have enough tokens");
            bool success = item.transfer(to[i], amounts[i]);
            require(success, "Something went wrong transferring your tokens");
        }

        emit itemsTransferred(to, items, amounts);

    }

    //function delegateMyVotes
    function delegateMyTokens(address tokenAddress) external onlyOwner {
        ERC20Votes tokenContract = ERC20Votes(tokenAddress);
        tokenContract.delegate(address(this));
    }

    //function votePurpose
    function votePurpose(address payable governanceAddress, uint256 proposalId, uint8 support) external onlyOwner {
        MyGovernor governanceContract = MyGovernor(governanceAddress); 
        governanceContract.castVote(proposalId, support);
    }

    //function executePurpose
    function executePurpose(
    address payable governanceAddress, 
    address tokenAddress, 
    uint256 proposalId,
    address[] memory targets, 
    uint256[] memory values, 
    bytes[] memory calldatas,
        bytes32 descriptionHash) 
    external onlyOwner {
        ERC20Votes tokenContract = ERC20Votes(tokenAddress);
        require(tokenContract.balanceOf(address(this)) >= 10 ether, "You don't have enough tokens");

        MyGovernor governorContract = MyGovernor(governanceAddress);
        governorContract.executeProposal(proposalId, targets,values, calldatas, descriptionHash);
    }

    //function getAddress
    function getAddress() external view returns(address){
        return address(this);
    }
}