const timelock = artifacts.require("MyTimeLock");

module.exports = async (deployer) =>{
    await deployer.deploy(timelock, 0, [], [])
}