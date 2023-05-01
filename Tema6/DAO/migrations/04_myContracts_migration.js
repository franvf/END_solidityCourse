const myToken = artifacts.require("MyToken");
const gladiatorNFT = artifacts.require("GladiatorNFT");
const gladiatorsGame = artifacts.require("GladiatorsGame");

module.exports = async(deployer) => {
  await deployer.deploy(myToken);

  const metadataURI = "https://gateway.pinata.cloud/ipfs/QmcRWwPJTqfqLAFC7LX1oNwLipvoTsbtjidYbchDzfCove/"
  await deployer.deploy(gladiatorNFT, metadataURI)

  const tokenContract = await myToken.deployed()
  const tokenAddress = await tokenContract.address

  const nftContract = await gladiatorNFT.deployed()
  const nftAddress = await nftContract.address

  const gameContract = await deployer.deploy(gladiatorsGame, tokenAddress, nftAddress)

  await tokenContract.setGladiatorAddress(gameContract.address)
  await nftContract.setGladiatorAddress(gameContract.address)
};
