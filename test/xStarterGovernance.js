const { expect } = require("chai");
const { BigNumber, utils } = require("ethers");
const { ethers } = require("hardhat");

function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}


// this will test out the xStarter ILO reg
describe('xStarter LaunchPad to Governance to LaunchPad ILO registration Process', function() {
    this.slow(240000);
    let xStarterLaunchPadFactory;
    let xStarterLaunchPadInst;
    let xStarterGovernanceFactory;
    let xStarterGovernanceInst;
    let xStarterTokenFactory;
    let xStarterTokenInst;
    let owner;
    let addr1;
    let addr2;
    let addr3;
    let addrs;
    beforeEach(async function() {
        // deploy xStarterToken
        if(!xStarterTokenInst){
            xStarterTokenFactory = await ethers.getContractFactory("contracts/xStarterToken.sol:XStarterToken")
            xStarterTokenInst = await xStarterTokenFactory.deploy(
                BigNumber.from('500000000'),
                []
            )
        }   
    })

    describe('Contracts Deployed Correctly', function() {
        it('xStartToken has correct Values', async function(){
            let amount = await xStarterTokenInst.totalSupply();
            console.log('amount is ', amount.toString());
            expect(amount).to.equal(utils.parseEther('500000000'));
        })
    })
})