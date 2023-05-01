const governanceToken = artifacts.require("GovernanceToken");

module.exports = async (deployer) =>{
    await deployer.deploy(governanceToken)
}