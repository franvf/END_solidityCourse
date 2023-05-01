const myToken = artifacts.require("MyToken");
const gladiatorsGame = artifacts.require("GladiatorsGame")
const gladiatorNFT = artifacts.require("GladiatorNFT")

module.exports = async(deployer) => {
    await deployer.deploy(myToken)

    const metadataURI = "https://gateway.pinata.cloud/ipfs/QmVqBCtFCN3p4uDnDKSc7XfvPsRmeu3oQAxRVbxEAhyc3G/"
    await deployer.deploy(gladiatorNFT, metadataURI)

    const tknContract = await myToken.deployed()
    const tknAddress = await tknContract.address

    const gldContract = await gladiatorNFT.deployed()
    const gldAddress = await gldContract.address

    await deployer.deploy(gladiatorsGame, tknAddress, gldAddress)
  };
