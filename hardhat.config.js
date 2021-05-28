const { ALCHEMYURL } = require('./ignored_constants');

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
require("@nomiclabs/hardhat-web3");
require("@nomiclabs/hardhat-waffle");

module.exports = {
  solidity:{
    compilers: [
      {
        version: "0.8.0",
        settings: {
          optimizer: {
            enabled: true,
            runs: 100
          }
        }
      },
      {
        version: "0.6.6",
        settings: {
          optimizer: {
            enabled: true,
            runs: 100
          }
        }
      },
      {
        version: "0.5.16",
        settings: {
          optimizer: {
            enabled: true,
            runs: 100
          }
        }
      },
    ]
  },
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      forking: {
        url: ALCHEMYURL,
      },
      blockGasLimit: 17000000,
      mining: {
        auto: false,
        interval: 5000
      }
    },
  },
  paths: {
    artifacts: './xstarter-frontend/src/artifacts'
  }
};
