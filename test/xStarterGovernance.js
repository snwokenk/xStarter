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
    let xStarterPoolPairInst;
    const uniswapRouter = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D";
    const uniswapFactory = "0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f";
    const WETH = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";

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
            poolPairFactory = await ethers.getContractFactory("contracts/xStarterPoolPairB.sol:xStarterPoolPairB");


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
                uniswapRouter,
                uniswapFactory
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

            await (await xStarterProposalInst.addMoreInfo(
                60,
                180,
                utils.parseEther('0.001'),
                utils.parseEther('0.10'),
                utils.parseEther('1'),
                utils.parseEther('1'),
                utils.parseEther('2')
                )).wait()

            let value = await xStarterProposalInst.getILOInfo();
            let ILOInfo = value[0]
            let ILOAdditional = value[1]
            console.log('ilo proposal is ', ILOInfo);
            console.log('ilo additional is ', ILOAdditional);
            // console.log('xStarter ILO Proposal addr', xStarterProposalInst.address)
            // console.log('token name is ', value.tokenName, typeof value);
            expect(ILOInfo.tokenName).to.equal("xStarter");
            expect(ILOInfo.tokenSymbol).to.equal("XSTN");
            expect(ILOInfo.totalSupply).to.equal(utils.parseEther('500000000'));
            expect(ILOInfo.percentOfTokensForILO).to.equal(70);
            expect(ILOInfo.fundingToken).to.equal(zeroAddress);
            expect(ILOAdditional.softcap).to.equal(utils.parseEther('1'));
            expect(await xStarterProposalInst.getLaunchpadAddress()).to.equal(xStarterLaunchPadInst.address );
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
            console.log('owner addr', owner.address)
            // address of xStarterPoolPair for the xStarter ILO
            await (await xStarterLaunchPadInst.connect(owner).deployXstarterILO(
                xStarterProposalInst.address,
                zeroAddress,
                "https://"
                
            )).wait()

            let proposalInfo = await xStarterLaunchPadInst.getProposal(xStarterProposalInst.address)
            console.log('address of pool pair is', proposalInfo.ILOAddress)
            console.log('adddress of xstarter ILo', xStarterProposalInst.address)
            // await expect().to.be.revertedWith("revert Not authorized")

        })

        it("setUpPoolPair Should Revert If Called By Non Admin", async function () {
            // Expect receives a value, and wraps it in an Assertion object. These
            // objects have a lot of utility methods to assert values.
              
              let startTime = parseInt(Date.now() / 1000) + 60;
              let endTime = parseInt(Date.now() / 1000) + 120;
              let proposalInfo = await xStarterLaunchPadInst.getProposal(xStarterProposalInst.address)
              xStarterPoolPairInst = poolPairFactory.attach(proposalInfo.ILOAddress)
            //   const poolPairFromOther = poolPair.connect(addr2);
              await expect(xStarterPoolPairInst.connect(addr2).setUpPoolPair(
                xStarterTokenInst.address,
                "xStarter", 
                "XSTN", 
                500000000,
                startTime,
                endTime,
            )).to.be.revertedWith("Administration: caller is not the admin");
              
          })
          it("setUpPoolPair Should succeed Admin", async function () {
            // Expect receives a value, and wraps it in an Assertion object. These
            // objects have a lot of utility methods to assert values.
              
              let startTime = parseInt(Date.now() / 1000) + 60;
              let endTime = parseInt(Date.now() / 1000) + 120;
              let proposalInfo = await xStarterLaunchPadInst.getProposal(xStarterProposalInst.address)
              xStarterPoolPairInst = poolPairFactory.attach(proposalInfo.ILOAddress)
            //   const poolPairFromOther = poolPair.connect(addr2);
              let response = await xStarterPoolPairInst.setUpPoolPair(
                xStarterTokenInst.address,
                "xStarter", 
                "XSTN", 
                500000000,
                startTime,
                endTime,
            )

            await expect(response.wait()).to.not.be.reverted
            expect(await xStarterPoolPairInst.projectToken()).to.equal(xStarterTokenInst.address);
            expect(await xStarterPoolPairInst.isSetup()).to.equal(true);
            expect(await xStarterPoolPairInst.startTime()).to.equal(startTime);
            expect(await xStarterPoolPairInst.endTime()).to.equal(endTime);
            expect(await xStarterPoolPairInst.totalTokensSupply()).to.equal(utils.parseEther('500000000'));
            // todo: add more checks, to make sure data from proposal contract was successfully added to ILO contract
              
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