const { ALCHEMYURL, XDAIURL, XDAIURL2,  XDAIBLOCKSCOUTARCHIVE, mnemonicTest } = require('./ignored_constants');

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
        url: XDAIBLOCKSCOUTARCHIVE,
      },
      blockGasLimit: 17000000,
      gasPrice: 1000000000,
      mining: {
        auto: false,
        interval: 5000
      },
      accounts: {
        mnemonic: mnemonicTest
      },
      timeout: 60000
    },
    spoa: {
      chainID: 77,
      url: 'https://sokol.poa.network',
      gas: 'auto',
      accounts: {
        mnemonic: mnemonicTest
      },
      timeout: 60000
    },
    kovan: {
      chainID: 42,
      url: 'https://kovan.poa.network/',
      gas: 'auto',
      accounts: {
        mnemonic: mnemonicTest
      },
      timeout: 60000
    },
    // ~ 15 second block time
    goerli: {
      chainID: 5,
      url: 'https://rpc.slock.it/goerli',
      gas: 'auto',
      accounts: {
        mnemonic: mnemonicTest
      },
      timeout: 60000
    },
  },
  paths: {
    artifacts: './xstarter-frontend/src/artifacts'
  }
};
