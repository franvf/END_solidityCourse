const governorContract = artifacts.require("MyGovernor")
const timelock = artifacts.require("MyTimeLock")
const governanceToken = artifacts.require("GovernanceToken")

module.exports = async (deployer) => {
    const gTokenContract = await governanceToken.deployed()
    const timelockContract = await timelock.deployed()
    await deployer.deploy(governorContract, gTokenContract.address, timelockContract.address, gTokenContract.address)
}