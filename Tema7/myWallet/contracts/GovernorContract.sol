// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/governance/Governor.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorSettings.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotesQuorumFraction.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorTimelockControl.sol";

import "./GovernanceToken.sol";

contract MyGovernor is Governor, GovernorSettings, GovernorCountingSimple, GovernorVotes, GovernorVotesQuorumFraction, GovernorTimelockControl {

    mapping(address => bool) allowedWallets;
    mapping(address => bool) isAdmin;

    modifier onlyAllowedWallets() {
        require(allowedWallets[msg.sender], "Wallet not allowed");
        _;
    }

    modifier onlyAdmin() {
        require(isAdmin[msg.sender], "Unauthorized");
        _;
    }

    GovernanceToken public myToken;
    constructor(IVotes _token, TimelockController _timelock, address myTokenAddress)
        Governor("END Governor")
        GovernorSettings(0, 3, 0)
        GovernorVotes(_token)
        GovernorVotesQuorumFraction(75)
        GovernorTimelockControl(_timelock)
    {
        myToken = GovernanceToken(myTokenAddress);
        isAdmin[msg.sender] = true;
    }


    // My functions

    function getWalletVotesWeight(address walletAddress, uint256 blockNumber) public view returns(uint256){
        return _getVotes(walletAddress, blockNumber, "");
    }

    function executeProposal(uint256 proposalId, address[] memory targets, uint256[] memory values, bytes[] memory calldatas, bytes32 descriptionHash)
        external 
        onlyAllowedWallets
    {   
        super._execute(proposalId, targets, values, calldatas, descriptionHash);
    }

    function addAllowedWallet(address newWallet) external onlyAdmin {
        allowedWallets[newWallet] = true;
    }

    function getIsWalletAllowed(address wallet) external view returns(bool){
        return allowedWallets[wallet];
    }

    // The following functions are overrides required by Solidity.

    function votingDelay()
        public
        view
        override(IGovernor, GovernorSettings)
        returns (uint256)
    {
        return super.votingDelay();
    }

    function votingPeriod()
        public
        view
        override(IGovernor, GovernorSettings)
        returns (uint256)
    {
        return super.votingPeriod();
    }

    function quorum(uint256 blockNumber)
        public
        view
        override(IGovernor, GovernorVotesQuorumFraction)
        returns (uint256)
    {
        return super.quorum(blockNumber);
    }

    function state(uint256 proposalId)
        public
        view
        override(Governor, GovernorTimelockControl)
        returns (ProposalState)
    {
        return super.state(proposalId);
    }

    function propose(address[] memory targets, uint256[] memory values, bytes[] memory calldatas, string memory description)
        public
        override(Governor, IGovernor)
        returns (uint256)
    {
        return super.propose(targets, values, calldatas, description);
    }

    function proposalThreshold()
        public
        view
        override(Governor, GovernorSettings)
        returns (uint256)
    {
        return super.proposalThreshold();
    }


    function _cancel(address[] memory targets, uint256[] memory values, bytes[] memory calldatas, bytes32 descriptionHash)
        internal
        override(Governor, GovernorTimelockControl)
        returns (uint256)
    {
        return super._cancel(targets, values, calldatas, descriptionHash);
    }

    function _executor()
        internal
        view
        override(Governor, GovernorTimelockControl)
        returns (address)
    {
        return super._executor();
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(Governor, GovernorTimelockControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _execute(uint256 proposalId, address[] memory targets, uint256[] memory values, bytes[] memory calldatas, bytes32 descriptionHash) internal override(Governor, GovernorTimelockControl) {
        super._execute(proposalId, targets, values, calldatas, descriptionHash);
    }
}