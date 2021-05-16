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
    let xStarterProposalFactory;
    let xStarterProposalInst;

    let owner;
    let addr1;
    let addr2;
    let addr3;
    let addrs;
    beforeEach(async function() {
        // deploy xStarterToken
        this.timeout(60000);
        if(!xStarterTokenInst){
            [owner, addr1, addr2, addr3, ...addrs] = await ethers.getSigners();
            xStarterNFTFactory = await ethers.getContractFactory("xStarterNFT")
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

            xStarterProposalFactory = await ethers.getContractFactory("xStarterProposal")


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

            console.log('launchpad is', xStarterLaunchPadInst.address)
            console.log('governance is', xStarterGovernanceInst.address)

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
            console.log('allowedCaller is ', value);
            expect(value).to.equal(xStarterLaunchPadInst.address);
        })

        it('xStartLaunchpad has correct Values', async function(){
            let value = await xStarterLaunchPadInst.xStarterContracts();
            console.log('xStarterContracts from launchpad is ', value);
            expect(value[0]).to.equal(xStarterGovernanceInst.address);
            expect(value[1]).to.equal(xStarterTokenInst.address);
            expect(value[2]).to.equal(xStarterNFTInst.address);
            expect(value[3]).to.equal(xStarterDeployerInst.address);
        })

        it('xStarterGovernance has correct Values', async function(){
            let value = await xStarterGovernanceInst.xStarterContracts();
            console.log('xStarterContracts from governance is ', value);
            expect(value[0]).to.equal(xStarterTokenInst.address);
            expect(value[1]).to.equal(xStarterLaunchPadInst.address);
            expect(value[2]).to.equal(xStarterNFTInst.address);
        })
        

        it('xStarterNFT has correct Values', async function(){
            let value = await xStarterNFTInst.xStarterContracts();
            console.log('value is ', value);
            expect(value[0]).to.equal(xStarterTokenInst.address);
            expect(value[1]).to.equal(xStarterGovernanceInst.address);
            expect(value[2]).to.equal(xStarterLaunchPadInst.address);
        })
    })

    describe('Create xStarter ILO', function() {

        it('deploy ILOProposal Contract', async function(){
            xStarterProposalInst = await xStarterProposalFactory.deploy(
                "xStarter", 
                "XSTN", 
                "https://", 
                utils.parseEther('500000000'),
                70,
                zeroAddress,
                xStarterLaunchPadInst.address 
            );

            let value = await xStarterProposalInst.getILOInfo();
            console.log('value is ', value);
            console.log('xStarter ILO addr', xStarterProposalInst.address)
            console.log('token name is ', value.tokenName, typeof value);
            expect(value.tokenName).to.equal("xStarter");
            expect(value.tokenSymbol).to.equal("XSTN");
            expect(value.totalSupply).to.equal(utils.parseEther('500000000'));
            expect(value.percentOfTokensForILO).to.equal(70);
            expect(value.fundingToken).to.equal(zeroAddress);
            expect(await xStarterProposalInst.getLaunchpadAddress()).to.equal(xStarterLaunchPadInst.address );
            // expect(value[1]).to.equal(xStarterGovernanceInst.address);
            // expect(value[2]).to.equal(xStarterLaunchPadInst.address);
        })

    })

    describe('deploy initial xStarter ILO to launchpad', function() {
        // using the same info, but this should revert since deployXstarterILO hasn't been called by creator
        it('deployment of another ILO before initial should revert', async function(){
            await expect(xStarterLaunchPadInst.registerILOProposal(
                xStarterProposalInst.address,
                "xStarter", 
                "XSTN", 
                "https://", 
                utils.parseEther('500000000'),
                70,
                zeroAddress,
            )).to.be.revertedWith("revert Initial xStarter ILO not deployed")
        })

        it('deploying of initial ILO should revert if not called by allowedCaller', async function(){
            await expect(xStarterLaunchPadInst.connect(addr1).deployXstarterILO(
                xStarterProposalInst.address,
                zeroAddress,
                "https://"
                
            )).to.be.revertedWith("revert Not authorized")
        })

        it('deploying of initial ILO should succeed with allowedCaller', async function(){
            await expect(xStarterLaunchPadInst.deployXstarterILO(
                xStarterProposalInst.address,
                zeroAddress,
                "https://"
                
            )).to.be.revertedWith("revert Not authorized")

        })
        // it('register ILOProposal Contract', async function(){
        //     xStarterProposalInst = await xStarterProposalFactory.deploy(
        //         "xStarter", 
        //         "XSTN", 
        //         "https://", 
        //         utils.parseEther('500000000'),
        //         70,
        //         zeroAddress,
        //         xStarterLaunchPadInst.address 
        //     );

        //     let value = await xStarterProposalInst.getILOInfo();
        //     console.log('value is ', value);
        //     console.log('token name is ', value.tokenName, typeof value);
        //     expect(value.tokenName).to.equal("xStarter");
        //     expect(value.tokenSymbol).to.equal("XSTN");
        //     expect(value.totalSupply).to.equal(utils.parseEther('500000000'));
        //     expect(value.percentOfTokensForILO).to.equal(70);
        //     expect(value.fundingToken).to.equal(zeroAddress);
        //     expect(await xStarterProposalInst.getLaunchpadAddress()).to.equal(xStarterLaunchPadInst.address );
        //     // expect(value[1]).to.equal(xStarterGovernanceInst.address);
        //     // expect(value[2]).to.equal(xStarterLaunchPadInst.address);
        // })

    })
})