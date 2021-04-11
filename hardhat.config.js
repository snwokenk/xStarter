const { ALCHEMYURL } = require('./ignored_constants');

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
import {ALCHEMYURL} from "./ignored_constants";

module.exports = {
  solidity: "0.7.6",
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      forking: {
        url: ALCHEMYURL,
      },
      blockGasLimit: 10000000,
      mining: {
        auto: false,
        interval: 5000
      }
    },
  },
};
