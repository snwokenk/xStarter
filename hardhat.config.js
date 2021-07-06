const { ALCHEMYURL, ALCHEMYGOERLIURL, ANKR_XDAI_API_URL, XDAIURL2,  XDAIBLOCKSCOUTARCHIVE, mnemonicTest, privateKey } = require('./ignored_constants');

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
      url: ALCHEMYGOERLIURL,
      gasPrice: 2000000000,
      // url: 'https://services.fault.dev/',
      accounts:[`0x${privateKey}`]
    },
    xdai: {
      chainID: 100,
      url: ANKR_XDAI_API_URL,
      gasPrice: 6000000000,
      accounts:[`0x${privateKey}`]

    }
  },
  paths: {
    artifacts: './xstarter-frontend/src/artifacts'
  }
};
