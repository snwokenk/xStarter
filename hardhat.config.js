const { ALCHEMYURL, ALCHEMYGOERLIURL, MoralisBSCArchive,  XDAIURL, ANKR_XDAI_API_URL, XDAIURL2, BSCURL, NodeRealBSCURL,  XDAIBLOCKSCOUTARCHIVE, mnemonicTest, privateKey } = require('./ignored_constants');

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
require("@nomiclabs/hardhat-web3");
require("@nomiclabs/hardhat-waffle");

module.exports = {
  solidity:{
    compilers: [
      {
        version: "0.8.1",
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
        url: MoralisBSCArchive
      },
      blockGasLimit: 30000000,
      gasPrice: 1000000000,
      mining: {
        auto: false,
        interval: 3000
      },
      accounts: {
        mnemonic: mnemonicTest,
        accountsBalance: '10000000000000000000000000' // 1 million ethers for testing
      },
      timeout: 60000
    },
    // hardhat: {
    //   forking: {
    //     url: XDAIBLOCKSCOUTARCHIVE,
    //   },
    //   blockGasLimit: 17000000,
    //   gasPrice: 1000000000,
    //   mining: {
    //     auto: false,
    //     interval: 5000
    //   },
    //   accounts: {
    //     mnemonic: mnemonicTest,
    //     accountsBalance: '10000000000000000000000000' // 1 million ethers for testing
    //   },
    //   timeout: 60000
    // },
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
    /* uncomment when trying to deploy to xDai */
    // xdai: {
    //   chainID: 100,
    //   url: ANKR_XDAI_API_URL,
    //   gasPrice: 3000000000,
    //   accounts:[`0x${privateKey}`]

    // }
  },
  paths: {
    artifacts: './xstarter-frontend/src/artifacts'
  }
};
