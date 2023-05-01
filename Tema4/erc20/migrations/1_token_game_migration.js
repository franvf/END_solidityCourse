const myToken = artifacts.require("MyToken");
const game = artifacts.require("GladiatorsGame")

module.exports = async(deployer) => {
  await deployer.deploy(myToken);

  const tknContrac = await myToken.deployed()
  const tknAddress = await tknContrac.address

  await deployer.deploy(game, tknAddress)
};
