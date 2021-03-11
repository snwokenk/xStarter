// https://ethereum.stackexchange.com/questions/17558/what-does-deploy-link-exactly-do-in-truffle
// https://forum.openzeppelin.com/t/erc777-constructor-arguments/664/5

const XStarterToken = artifacts.require("xStarterToken");

require('@openzeppelin/test-helpers/configure')({ web3 });

const { singletons } = require('@openzeppelin/test-helpers');

const initialSupply = 500000000
const defaultOperators = [];
module.exports = async function(deployer, network, accounts) {
  if (network === 'live') {

  }else {
    const erc1820 = singletons.ERC1820Registry(accounts[0])
    deployer.deploy(XStarterToken, initialSupply, defaultOperators, {from: accounts[0]});
  }
  
  
};

