const { expect, util } = require("chai");
const { BigNumber, utils } = require("ethers");
const { ethers } = require("hardhat");






async function main() {
    let owner;
    let addr1;
    let addr2;
    let addr3;
    let addrs;
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
    let xStarterERCDeployerFactory;
    let xStarterERCDeployerInst;
    let xStarterProposalFactory;
    let xStarterProposalInst;
    let xStarterPoolPairInst;
    const uniswapRouter = "0x1C232F01118CB8B424793ae03F870aa7D0ac7f77";
    const uniswapFactory = "0xa818b4f111ccac7aa31d0bcc0806d64f2e0737d7";
    const getAccounts = async () => {
        [owner, addr1, addr2, addr3, ...addrs] = await ethers.getSigners();
        
    }

    const populateFactory = async () => {
        xStarterTokenFactory = await ethers.getContractFactory("xStarterToken")
            xStarterTokenInst = await xStarterTokenFactory.deploy(
                BigNumber.from('500000000'),
                []
            )

            // deploy deployer
            xStarterDeployerFactory = await ethers.getContractFactory("contracts/xStarterLaunchPad.sol:xStarterDeployer")
            xStarterDeployerInst = await xStarterDeployerFactory.deploy()

            // deploy erc deployer
            xStarterERCDeployerFactory = await ethers.getContractFactory("contracts/xStarterPoolPairB.sol:xStarterERCDeployer")
            xStarterERCDeployerInst = await xStarterERCDeployerFactory.deploy()
            

            // deploy launchpad
            xStarterLaunchPadFactory = await ethers.getContractFactory("xStarterLaunchPad")
            xStarterLaunchPadInst = await xStarterLaunchPadFactory.deploy(
                xStarterTokenInst.address, 
                xStarterDeployerInst.address, // xstarter deployer
                xStarterERCDeployerInst.address,
                utils.parseEther('5000'),
                utils.parseEther('50000'), // 5000 tokens required  OR
                utils.parseEther('50'), // 50 LP tokens
                uniswapRouter,
                uniswapFactory,
                owner.address,
                {nonce: Date.now()}
            )
            console.log('xStarerLaunchpad inst is', xStarterLaunchPadInst.address)
            
            // deploy governance
            xStarterGovernanceFactory = await ethers.getContractFactory("xStarterGovernance")
            xStarterGovernanceInst = await xStarterGovernanceFactory.deploy()

            // deploy NFT
            xStarterNFTFactory = await ethers.getContractFactory("xStarterNFT")
            xStarterNFTInst = await xStarterNFTFactory.deploy()

            xStarterProposalFactory = await ethers.getContractFactory("xStarterProposal")
            poolPairFactory = await ethers.getContractFactory("contracts/xStarterPoolPairB.sol:xStarterPoolPairB");


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

            // await (await xStarterLaunchPadInst.initialize(
            //     xStarterGovernanceInst.address,
            //     xStarterTokenInst.address, 
            //     xStarterNFTInst.address, 
            //     xStarterDeployerInst.address, // xstarter deployer
            //     utils.parseEther('500'),
            //     uniswapRouter,
            //     uniswapFactory
            // )).wait()

            await (await xStarterDeployerInst.setAdmin(
                xStarterLaunchPadInst.address
            )).wait()
            await (await xStarterERCDeployerInst.setAdmin(
                xStarterLaunchPadInst.address
            )).wait()

    }
    await getAccounts();
    await populateFactory();

    console.log('owner addr is', owner.address)
    console.log('xStarterLaunchpad address is', xStarterLaunchPadInst.address)

}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });

