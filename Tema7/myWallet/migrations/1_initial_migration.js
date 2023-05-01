const governor = artifacts.require("MyGovernor");
const token = artifacts.require("GovernanceToken")
const timeLock = artifacts.require("MyTimeLock")

const {ethers} = require("hardhat")

module.exports = async (deployer)  => {
  
  await deployer.deploy(token)
  const tokenContract = await token.deployed()

  const tokenFactory = await ethers.getContractFactory("GovernanceToken")

  await deployer.deploy(timeLock, 0, [], [])
  const timeLockContract = await timeLock.deployed()

  await deployer.deploy(governor, tokenContract.address, timeLockContract.address, tokenContract.address)
  
};
