const { expect, util } = require("chai");
const { BigNumber, utils } = require("ethers");
const { ethers } = require("hardhat");

function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}


// this will test out the xStarter ILO reg
describe('xStarter LaunchPad to Governance to LaunchPad ILO registration Process', function() {
    this.slow(240000);
    const zeroAddress = "0x0000000000000000000000000000000000000000";
    let xStarterLaunchPadFactory;
    let xStarterLaunchPadInst;
    let xStarterGovernanceFactory;
    let xStarterGovernanceInst;
    let xStarterTokenFactory;
    let xStarterTokenInst;
    let xStarterNFTFactory;
    let xStarterNFTInst;
    let xStarterDeployerFactory;
    let xStarterDeployerInst;

    let owner;
    let addr1;
    let addr2;
    let addr3;
    let addrs;
    beforeEach(async function() {
        // deploy xStarterToken
        this.timeout(60000);
        if(!xStarterTokenInst){
            xStarterTokenFactory = await ethers.getContractFactory("xStarterToken")
            xStarterTokenInst = await xStarterTokenFactory.deploy(
                BigNumber.from('500000000'),
                []
            )
            // deploy governance
            xStarterGovernanceFactory = await ethers.getContractFactory("xStarterGovernance")
            xStarterGovernanceInst = await xStarterGovernanceFactory.deploy()

            // deploy launchpad
            xStarterLaunchPadFactory = await ethers.getContractFactory("xStarterLaunchPad")
            xStarterLaunchPadInst = await xStarterLaunchPadFactory.deploy()

            // deploy NFT
            xStarterNFTFactory = await ethers.getContractFactory("xStarterNFT")
            xStarterNFTInst = await xStarterNFTFactory.deploy()

            // deploy deployer
            xStarterDeployerFactory = await ethers.getContractFactory("contracts/xStarterLaunchPad.sol:xStarterDeployer")
            xStarterDeployerInst = await xStarterDeployerFactory.deploy()

            // initialize
            await (await xStarterNFTInst.initialize(
                xStarterGovernanceInst.address,
                xStarterTokenInst.address, 
                xStarterLaunchPadInst.address, 
                false
            )).wait()
            await (await xStarterGovernanceInst.initialize(
                xStarterTokenInst.address, 
                xStarterLaunchPadInst.address,
                xStarterNFTInst.address,
                false
            )).wait()

            await (await xStarterLaunchPadInst.initialize(
                xStarterGovernanceInst.address,
                xStarterTokenInst.address, 
                xStarterNFTInst.address, 
                xStarterDeployerInst.address, // xstarter deployer
                utils.parseEther('500'),
                false
            )).wait()

            await (await xStarterDeployerInst.initialize(
                xStarterLaunchPadInst.address
            )).wait()

        }   
    })

    describe('Contracts Deployed Correctly', function() {
        it('xStartToken has correct Values', async function(){
            let amount = await xStarterTokenInst.totalSupply();
            console.log('amount is ', amount.toString());
            expect(amount).to.equal(utils.parseEther('500000000'));
        })

        it('xStartDeployer has correct Values', async function(){
            let value = await xStarterDeployerInst.allowedCaller();
            console.log('value is ', value);
            expect(value).to.equal(xStarterLaunchPadInst.address);
        })

        it('xStartLaunchpad has correct Values', async function(){
            let value = await xStarterLaunchPadInst.xStarterContracts();
            console.log('value is ', value);
            expect(value[0]).to.equal(xStarterGovernanceInst.address);
            expect(value[1]).to.equal(xStarterTokenInst.address);
            expect(value[2]).to.equal(xStarterNFTInst.address);
            expect(value[3]).to.equal(xStarterDeployerInst.address);
        })

        it('xStarterGovernance has correct Values', async function(){
            let value = await xStarterGovernanceInst.xStarterContracts();
            console.log('value is ', value);
            expect(value[0]).to.equal(xStarterTokenInst.address);
            expect(value[1]).to.equal(xStarterLaunchPadInst.address);
            expect(value[2]).to.equal(xStarterNFTInst.address);
        })
        // [owner, addr1, addr2, addr3, ...addrs] = await ethers.getSigners();

        it('xStarterNFT has correct Values', async function(){
            let value = await xStarterNFTInst.xStarterContracts();
            console.log('value is ', value);
            expect(value[0]).to.equal(xStarterTokenInst.address);
            expect(value[1]).to.equal(xStarterGovernanceInst.address);
            expect(value[2]).to.equal(xStarterLaunchPadInst.address);
        })
    })

    describe('Create xStarter ILO', function() {

        it('xStarter distribu', async function(){
            let value = await xStarterNFTInst.xStarterContracts();
            console.log('value is ', value);
            expect(value[0]).to.equal(xStarterTokenInst.address);
            expect(value[1]).to.equal(xStarterGovernanceInst.address);
            expect(value[2]).to.equal(xStarterLaunchPadInst.address);
        })

    })
})