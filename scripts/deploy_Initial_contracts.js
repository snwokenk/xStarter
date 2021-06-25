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
    let counter = 0;
    let uniswapRouter;
    let uniswapFactory;
    let WETH;
    let mineLen = process.env.IS_NETWORK !== 'goerli' ? 5 : 15;
    

    // for xStarter ILO
    // let contributionLockSeconds = process.env.IS_NETWORK !== 'xdai' ? 86400 : 1209600  // on xdai prod 14 day lock
    // let liquidityPairLockSeconds = process.env.IS_NETWORK !== 'xdai' ? 129600 : 31536000 // on xdai prod 365 days in seconds lock 
    // let initialStartTime = 1800
    // let initialEndTime = 7200;
    let minimumPerSwap = process.env.IS_NETWORK !== 'xdai' ? utils.parseEther('0.001')  : utils.parseEther('50') // on xdai minimum per addr is 500 or 500 xdai ie $100 
    let minimumPerAddress = process.env.IS_NETWORK !== 'xdai' ? utils.parseEther('0.01')  : utils.parseEther('100') // on xdai minimum per addr is 500 or 500 xdai ie $100 
    let maximumPerAddress = process.env.IS_NETWORK !== 'xdai' ? utils.parseEther('0.03') : utils.parseEther('5000') // on xdai maximum per addr is 2500 or 2500 xdai ie $2500
    let softcap = process.env.IS_NETWORK !== 'xdai' ? utils.parseEther('0.03')  : utils.parseEther('500000') // on xdai softcap is 500000 or $500k
    let hardcap = process.env.IS_NETWORK !== 'xdai' ? utils.parseEther('0.05')  : utils.parseEther('1500000') // on xdai hardcap is 1.5 million or $1.5M
    
    let initialStartTime = 180
    let initialEndTime = 600;
    let contributionLockSeconds = 300  // on xdai prod 14 day lock
    let liquidityPairLockSeconds = 600// on xdai prod 365 days in seconds lock 

    // uses honeyswap address
    console.log('process env is', process.env.XDAI_DEX)
    if(process.env.XDAI_DEX) {
        uniswapRouter = "0x1C232F01118CB8B424793ae03F870aa7D0ac7f77";
        uniswapFactory = "0xa818b4f111ccac7aa31d0bcc0806d64f2e0737d7";
        // this is really address for WXDAI on honeyswap xDai
        WETH = '0xe91D153E0b41518A2Ce8Dd3D7944Fa863463a97d'
    }else {
        // uses uniswap address on eth test nets
        uniswapRouter = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D";
        uniswapFactory = "0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f";
        WETH = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";

    }
    
    const getAccounts = async () => {
        [owner, addr1, addr2, addr3, ...addrs] = await ethers.getSigners();
        
    }
    const getRandom = () => {
        return counter++
    }

    const populateFactory = async () => {
        console.log('owner is', owner.address)
        xStarterTokenFactory = await ethers.getContractFactory("xStarterToken")
            xStarterTokenInst = await xStarterTokenFactory.deploy(
                BigNumber.from('500000000'),
                [],
                // {nonce: Date.now() + getRandom()}
            )

            console.log('token inst', xStarterTokenInst.address)

            // deploy deployer
            // deploys pool pair
            xStarterDeployerFactory = await ethers.getContractFactory("contracts/xStarterLaunchPad.sol:xStarterDeployer")
            xStarterDeployerInst = await xStarterDeployerFactory.deploy(
                //  {nonce: Date.now() + getRandom()}
            )

            console.log('deployer inst is', xStarterDeployerInst.address)

            // deploy erc deployer
            // deploys erc20 tokens for projecr
            xStarterERCDeployerFactory = await ethers.getContractFactory("contracts/xStarterPoolPairB.sol:xStarterERCDeployer")
            xStarterERCDeployerInst = await xStarterERCDeployerFactory.deploy(
                // {nonce: Date.now() + getRandom()}
            )

            console.log('erc deployer inst is', xStarterERCDeployerInst.address)
            
            console.log('mineLen', mineLen)
            // deploy launchpad
            xStarterLaunchPadFactory = await ethers.getContractFactory("xStarterLaunchPad")
            xStarterLaunchPadInst = await xStarterLaunchPadFactory.deploy(
                xStarterTokenInst.address, 
                xStarterDeployerInst.address, // xstarter deployer
                xStarterERCDeployerInst.address,
                utils.parseEther('5000'),
                utils.parseEther('50000'), // 5000 tokens required  OR
                utils.parseEther('50'), // 50 LP tokens
                mineLen,
                uniswapRouter,
                uniswapFactory,
                owner.address,
                // {nonce: Date.now() + getRandom()}
            )
            console.log('xStarterLaunchpad inst is', xStarterLaunchPadInst.address)

            await (await xStarterDeployerInst.setAllowedCaller(xStarterLaunchPadInst.address)).wait()
            console.log('xStarterDeployerInst inst is after set allowed', xStarterDeployerInst.address)
            await (await xStarterERCDeployerInst.setAdmin(xStarterLaunchPadInst.address))
            console.log('xStarterERCDeployerInst inst is after set allowed', xStarterERCDeployerInst.address)
            
            
            // deploy governance
            xStarterGovernanceFactory = await ethers.getContractFactory("xStarterGovernance")
            xStarterGovernanceInst = await xStarterGovernanceFactory.deploy(
                // {nonce: Date.now() + getRandom()}
            )

            console.log('xStarterGOV inst is', xStarterGovernanceInst.address)
            

            await (await xStarterGovernanceInst.initialize(
                xStarterTokenInst.address, 
                xStarterLaunchPadInst.address
            ))

            console.log('governance inst is', xStarterGovernanceInst.address)

            xStarterProposalFactory = await ethers.getContractFactory("xStarterProposal")
            poolPairFactory = await ethers.getContractFactory("contracts/xStarterPoolPairB.sol:xStarterPoolPairB");

            xStarterProposalInst = await xStarterProposalFactory.deploy(
                "xStarter", 
                "XSTN", 
                "QmUEMTSMYwqXZZNGm4T6UVec9igJssgeKQpajJiCrTN9DF", 
                utils.parseEther('500000000'),
                70,
                ethers.constants.AddressZero,
                // fundingTokenInst.address,
                xStarterLaunchPadInst.address 
            );

            console.log('xstarter proposal inst is', xStarterProposalInst.address)

            await (await xStarterProposalInst.addMoreInfo(
                contributionLockSeconds,
                liquidityPairLockSeconds,
                minimumPerSwap,
                minimumPerAddress,
                maximumPerAddress,
                softcap,
                hardcap,
                20
                )).wait()
            
            
                console.log('xstarter proposal inst is after add more info', xStarterProposalInst.address)


            await (await xStarterLaunchPadInst.connect(owner).deployXstarterILO(
                xStarterProposalInst.address
            )).wait()
            console.log('xstarter proposal inst is after add more info', xStarterProposalInst.address)

            let startTime = parseInt(Date.now() / 1000) + initialStartTime;
            let endTime = parseInt(Date.now() / 1000) + initialEndTime;
            let proposalInfo = await xStarterLaunchPadInst.getProposal(xStarterProposalInst.address)
            xStarterPoolPairInst = poolPairFactory.attach(proposalInfo.info.ILOAddress)
          //   const poolPairFromOther = poolPair.connect(addr2);
            await (await xStarterPoolPairInst.setUpPoolPair(
              xStarterTokenInst.address,
            //   xStarterERCDeployerInst.address,
              "xStarter", 
              "XSTN", 
              500000000,
              startTime,
              endTime,
          )).wait()
          await (await xStarterTokenInst.approve(xStarterPoolPairInst.address, utils.parseEther('500000000'))).wait()
          await (await xStarterPoolPairInst.depositAllTokenSupply()).wait()




    }
    await getAccounts();
    await populateFactory();

    // console.log('owner addr is', owner.address)
    // console.log('xStarterLaunchpad address is', xStarterLaunchPadInst.address)
    // console.log('xStarterDeployer Address is', xStarterDeployerInst.address)

}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });

