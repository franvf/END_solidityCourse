require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-web3")

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {

  defaultNetwork: "ganache",
  networks: {
    ganache: {
      url: "http://127.0.0.1:7545"
    }
  },

  solidity: "0.8.19",
  // setings: {
  //   optimizer: {
  //     enabled: true,
  //     runs: 200
  //   }
  // }
};
