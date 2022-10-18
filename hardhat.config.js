require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-chai-matchers");
require("@nomiclabs/hardhat-ethers");
require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */
const GOERLI_URL = process.env.GOERLI_URL;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
module.exports = {
  solidity: "0.8.9",
  networks: {
    goerli: {
      url: GOERLI_URL,
      accounts: [PRIVATE_KEY]
    }
  },
  etherscan: {
    apiKey: {
      goerli: process.env.GOERLI_API_KEY
    } 
  }
};
