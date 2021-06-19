const { expect, util } = require("chai");
const { BigNumber, utils } = require("ethers");
const { ethers } = require("hardhat");

function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}


// // this will test out the xStarter ILO reg
// describe('xStarter LaunchPad to Governance to LaunchPad ILO registration Process', function() {
//     this.slow(240000);
//     const zeroAddress = "0x0000000000000000000000000000000000000000";
//     let xStarterLaunchPadFactory;
//     let xStarterLaunchPadInst;
//     let xStarterGovernanceFactory;
//     let xStarterGovernanceInst;
//     let xStarterTokenFactory;
//     let xStarterTokenInst;
//     let xStarterNFTFactory;
//     let xStarterNFTInst;
//     let xStarterDeployerFactory;
//     let xStarterDeployerInst;
//     let xStarterERCDeployerFactory;
//     let xStarterERCDeployerInst;
//     let xStarterProposalFactory;
//     let xStarterProposalInst;
//     let xStarterPoolPairInst;
//     let routerFactoryContractFactory;
//     let liquidityPairTokenFactory;
//     let liquidityTokenInst;
//     let initialStartTime = 60
//     let initialEndTime = 300;


//     // // quickswap
//     // const uniswapRouter = "0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff"
//     // const uniswapFactory = "0x5757371414417b8C6CAad45bAeF941aBc7d3Ab32";

//     // honeyswap on xDai
//     const uniswapRouter = "0x1C232F01118CB8B424793ae03F870aa7D0ac7f77";
//     const uniswapFactory = "0xa818b4f111ccac7aa31d0bcc0806d64f2e0737d7";
//     // this is really address for WXDAI on honeyswap xDai
//     const WETH = '0xe91D153E0b41518A2Ce8Dd3D7944Fa863463a97d'

//     // const uniswapRouter = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D";
//     // const uniswapFactory = "0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f";
//     // const WETH = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";

//     let owner;
//     let addr1;
//     let addr2;
//     let addr3;
//     let addrs;
//     beforeEach(async function() {
//         // deploy xStarterToken
//         this.timeout(60000);
//         if(!xStarterTokenInst){
//             [owner, addr1, addr2, addr3, ...addrs] = await ethers.getSigners();

//             console.log('address of owner is', owner.address)


//             routerFactoryContractFactory = await ethers.getContractFactory('UniswapV2Factory');
//             liquidityPairTokenFactory = await ethers.getContractFactory("contracts/UniswapFactory.sol:UniswapV2Pair")
            
//             xStarterNFTFactory = await ethers.getContractFactory("xStarterNFT")
//             xStarterTokenFactory = await ethers.getContractFactory("xStarterToken")
//             xStarterTokenInst = await xStarterTokenFactory.deploy(
//                 BigNumber.from('500000000'),
//                 []
//             )

//             // deploy deployer
//             xStarterDeployerFactory = await ethers.getContractFactory("contracts/xStarterLaunchPad.sol:xStarterDeployer")
//             xStarterDeployerInst = await xStarterDeployerFactory.deploy()

//             // deploy erc deployer
//             xStarterERCDeployerFactory = await ethers.getContractFactory("contracts/xStarterPoolPairB.sol:xStarterERCDeployer")
//             xStarterERCDeployerInst = await xStarterERCDeployerFactory.deploy()
            

//             // deploy launchpad
//             xStarterLaunchPadFactory = await ethers.getContractFactory("xStarterLaunchPad")
//             xStarterLaunchPadInst = await xStarterLaunchPadFactory.deploy(
//                 xStarterTokenInst.address, 
//                 xStarterDeployerInst.address, // xstarter deployer
//                 xStarterERCDeployerInst.address,
//                 utils.parseEther('500'),
//                 utils.parseEther('5000'), // 5000 tokens required  OR
//                 utils.parseEther('50'), // 50 LP tokens
//                 uniswapRouter,
//                 uniswapFactory,
//                 owner.address
//             )
            
//             // deploy governance
//             xStarterGovernanceFactory = await ethers.getContractFactory("xStarterGovernance")
//             xStarterGovernanceInst = await xStarterGovernanceFactory.deploy()

//             // deploy NFT
//             xStarterNFTFactory = await ethers.getContractFactory("xStarterNFT")
//             xStarterNFTInst = await xStarterNFTFactory.deploy()

//             xStarterProposalFactory = await ethers.getContractFactory("xStarterProposal")
//             poolPairFactory = await ethers.getContractFactory("contracts/xStarterPoolPairB.sol:xStarterPoolPairB");


            

//             // initialize
//             await (await xStarterNFTInst.initialize(
//                 xStarterGovernanceInst.address,
//                 xStarterTokenInst.address, 
//                 xStarterLaunchPadInst.address, 
//                 false
//             )).wait()
//             await (await xStarterGovernanceInst.initialize(
//                 xStarterTokenInst.address, 
//                 xStarterLaunchPadInst.address,
//                 xStarterNFTInst.address,
//                 false
//             )).wait()

//             // await (await xStarterLaunchPadInst.initialize(
//             //     xStarterGovernanceInst.address,
//             //     xStarterTokenInst.address, 
//             //     xStarterNFTInst.address, 
//             //     xStarterDeployerInst.address, // xstarter deployer
//             //     utils.parseEther('500'),
//             //     uniswapRouter,
//             //     uniswapFactory
//             // )).wait()

//             await (await xStarterDeployerInst.setAdmin(
//                 xStarterLaunchPadInst.address
//             )).wait()
//             await (await xStarterERCDeployerInst.setAdmin(
//                 xStarterLaunchPadInst.address
//             )).wait()

//             console.log('launchpad is', xStarterLaunchPadInst.address)
//             console.log('governance is', xStarterGovernanceInst.address)

//         }   
//     })

//     describe('Contracts Deployed Correctly', function() {
//         it('xStartToken has correct Values', async function(){
//             let amount = await xStarterTokenInst.totalSupply();
//             console.log('amount is ', amount.toString());
//             expect(amount).to.equal(utils.parseEther('500000000'));
//         })

//         it('xStartDeployer has correct Values', async function(){
//             let value = await xStarterDeployerInst.admin();
//             console.log('allowedCaller is ', value);
//             expect(value).to.equal(xStarterLaunchPadInst.address);
//         })

//         it('xStartLaunchpad has correct Values', async function(){
//             let value = await xStarterLaunchPadInst.xStarterContracts();
//             console.log('xStarterContracts from launchpad is ', value);
//             // expect(value[0]).to.equal(xStarterGovernanceInst.address);
//             expect(value[1]).to.equal(xStarterTokenInst.address);
//             // expect(value[2]).to.equal(xStarterNFTInst.address);
//             expect(value[3]).to.equal(xStarterDeployerInst.address);
//             expect(value[4]).to.equal(xStarterERCDeployerInst.address);
//         })

//         it('xStarterGovernance has correct Values', async function(){
//             let value = await xStarterGovernanceInst.xStarterContracts();
//             console.log('xStarterContracts from governance is ', value);
//             expect(value[0]).to.equal(xStarterTokenInst.address);
//             expect(value[1]).to.equal(xStarterLaunchPadInst.address);
//             expect(value[2]).to.equal(xStarterNFTInst.address);
//         })
        

//         it('xStarterNFT has correct Values', async function(){
//             let value = await xStarterNFTInst.xStarterContracts();
//             console.log('value is ', value);
//             expect(value[0]).to.equal(xStarterTokenInst.address);
//             expect(value[1]).to.equal(xStarterGovernanceInst.address);
//             expect(value[2]).to.equal(xStarterLaunchPadInst.address);
//         })
//     })

//     describe('Create xStarter ILO Proposal', function() {
//         it('ILOProposal Contract deployed correctly', async function(){
//             xStarterProposalInst = await xStarterProposalFactory.deploy(
//                 "xStarter", 
//                 "XSTN", 
//                 "QmbesxZ1QQyWksXgLf6MY8okvzpcUFsFybdiSHtmKmahcX", 
//                 utils.parseEther('500000000'),
//                 70,
//                 zeroAddress,
//                 xStarterLaunchPadInst.address 
//             );

//             await (await xStarterProposalInst.addMoreInfo(
//                 60,
//                 180,
//                 utils.parseEther('0.001'),
//                 utils.parseEther('0.10'),
//                 utils.parseEther('1'),
//                 utils.parseEther('1'),
//                 utils.parseEther('2'),
//                 20
//                 )).wait()

//             let value = await xStarterProposalInst.getCompactInfo();
//             let ILOInfo = value.info
//             let ILOAdditional = value.moreInfo
//             console.log('ilo proposal is ', ILOInfo);
//             console.log('ilo additional is ', ILOAdditional);
//             // console.log('xStarter ILO Proposal addr', xStarterProposalInst.address)
//             // console.log('token name is ', value.tokenName, typeof value);
//             expect(ILOInfo.tokenName).to.equal("xStarter");
//             expect(ILOInfo.tokenSymbol).to.equal("XSTN");
//             expect(ILOInfo.totalSupply).to.equal(utils.parseEther('500000000'));
//             expect(ILOInfo.percentOfTokensForILO).to.equal(70);
//             expect(ILOInfo.fundingToken).to.equal(zeroAddress);
//             expect(ILOAdditional.softcap).to.equal(utils.parseEther('1'));
//             expect(await xStarterProposalInst.getLaunchpadAddress()).to.equal(xStarterLaunchPadInst.address );
//         })

//     })

//     describe('add initial xStarter ILO proposal to launchpad', function() {
//         // using the same info, but this should revert since deployXstarterILO hasn't been called by creator
//         it('adding of another ILO proposal before initial should revert', async function(){
//             await expect(xStarterLaunchPadInst.registerILOProposal(
//                 xStarterProposalInst.address
//             )).to.be.revertedWith("revert Initial xStarter ILO not deployed")
//         })

//         it('deploying of initial ILO should revert if not called by admin', async function(){
//             await expect(xStarterLaunchPadInst.connect(addr1).deployXstarterILO(
//                 xStarterProposalInst.address
                
//             )).to.be.revertedWith("revert Not authorized")
//         })

//         it('deploying of initial ILO should succeed with allowedCaller', async function(){
//             console.log('owner addr', owner.address)
//             // address of xStarterPoolPair for the xStarter ILO
//             await (await xStarterLaunchPadInst.connect(owner).deployXstarterILO(
//                 xStarterProposalInst.address
//             )).wait()

//             let proposalInfo = await xStarterLaunchPadInst.getProposal(xStarterProposalInst.address)
//             console.log('address of pool pair is', proposalInfo.info.ILOAddress)
//             console.log('adddress of xstarter ILo', xStarterProposalInst.address)
//             // await expect().to.be.revertedWith("revert Not authorized")

//         })

//         it("setUpPoolPair Should Revert If Called By Non Admin", async function () {
//             // Expect receives a value, and wraps it in an Assertion object. These
//             // objects have a lot of utility methods to assert values.
              
//               let startTime = parseInt(Date.now() / 1000) + initialStartTime;
//               let endTime = parseInt(Date.now() / 1000) + initialEndTime;
//               console.log('start time and endtime is', startTime, endTime)
//               let proposalInfo = await xStarterLaunchPadInst.getProposal(xStarterProposalInst.address)
//               xStarterPoolPairInst = poolPairFactory.attach(proposalInfo.info.ILOAddress)
//             //   const poolPairFromOther = poolPair.connect(addr2);
//               await expect(xStarterPoolPairInst.connect(addr2).setUpPoolPair(
//                 xStarterTokenInst.address,
//                 xStarterERCDeployerInst.address,
//                 "xStarter", 
//                 "XSTN", 
//                 500000000,
//                 startTime,
//                 endTime,
//             )).to.be.revertedWith("revert Not authorized");
              
//           })
//           it("setUpPoolPair Should succeed Admin", async function () {
//             // Expect receives a value, and wraps it in an Assertion object. These
//             // objects have a lot of utility methods to assert values.
              
//               let startTime = parseInt(Date.now() / 1000) + initialStartTime;
//               let endTime = parseInt(Date.now() / 1000) + initialEndTime;
//               let proposalInfo = await xStarterLaunchPadInst.getProposal(xStarterProposalInst.address)
//               xStarterPoolPairInst = poolPairFactory.attach(proposalInfo.info.ILOAddress)
//             //   const poolPairFromOther = poolPair.connect(addr2);
//               let response = await xStarterPoolPairInst.setUpPoolPair(
//                 xStarterTokenInst.address,
//                 xStarterERCDeployerInst.address,
//                 "xStarter", 
//                 "XSTN", 
//                 500000000,
//                 startTime,
//                 endTime,
//             )

//             await expect(response.wait()).to.not.be.reverted
//             expect(await xStarterPoolPairInst.projectToken()).to.equal(xStarterTokenInst.address);
//             expect(await xStarterPoolPairInst.isSetup()).to.equal(true);
//             expect(await xStarterPoolPairInst.startTime()).to.equal(startTime);
//             expect(await xStarterPoolPairInst.endTime()).to.equal(endTime);
//             expect(await xStarterPoolPairInst.totalTokensSupply()).to.equal(utils.parseEther('500000000'));
//             // todo: add more checks, to make sure data from proposal contract was successfully added to ILO contract
              
//           })

//           it("deposit tokens to ILO", async function () {

//             let response = await xStarterTokenInst.approve(xStarterPoolPairInst.address, utils.parseEther('500000000'))
//             await response.wait()
//             response = await xStarterTokenInst.allowance(owner.address,xStarterPoolPairInst.address)
//             console.log('allowance is', response)
//             expect(response).to.equal(BigNumber.from('500000000000000000000000000'))
//             const depositing = await xStarterPoolPairInst.depositAllTokenSupply()
//             await expect(depositing.wait()).to.not.be.reverted
//         })
//         it('ILO project tokens held should be equal to 500 million tokens or 500 million * 10 ** 18', async function() {
//           let supply = await xStarterPoolPairInst.tokensHeld()
//           let addr = await xStarterPoolPairInst.projectToken()

//           expect(supply).to.be.equal(BigNumber.from('500000000000000000000000000'))
//           expect(addr).to.be.equal(xStarterTokenInst.address)
//         })

//     })

//     describe("Contribute Native Token in xStarter ILO", function() {

//         it('should revert because event not open', async function(){
//         //   console.log('response is',response)
//         await expect(xStarterPoolPairInst.connect(addr1).contributeNativeToken({value: '1000000000000000000'})).to.be.revertedWith("ILO event not open");
//         })

//         it('wait till open, contribute and check balance has changed', async function(){
//         // because this will wait for some time let mocha know setting to 3 minutes 
//         this.timeout(340000)
//         for (let index = 0; index < 15; index++) {
//             await sleep(20000);
//             let isOpen = await xStarterPoolPairInst.isEventOpen()
//             console.log('event is open', isOpen)

//             if(isOpen) {break}
            
//         }
//         let response = await xStarterPoolPairInst.connect(addr1).contributeNativeToken({value: utils.parseEther('1.0')});
//         await response.wait();
//         let val = await xStarterPoolPairInst.fundingTokenBalanceOfFunder(addr1.address);
//         expect(BigNumber.from(val).toString()).to.equal('1000000000000000000');
//         let amtRaised = await xStarterPoolPairInst.amountRaised()
//         expect(BigNumber.from(amtRaised).toString()).to.equal('1000000000000000000');

//         response = await xStarterPoolPairInst.connect(addr2).contributeNativeToken({value: utils.parseEther('1.0')});
//         await response.wait();
//         val = await xStarterPoolPairInst.fundingTokenBalanceOfFunder(addr2.address);
//         expect(BigNumber.from(val).toString()).to.equal('1000000000000000000');
//         amtRaised = await xStarterPoolPairInst.amountRaised()
//         expect(BigNumber.from(amtRaised).toString()).to.equal('2000000000000000000');

//         await expect(xStarterPoolPairInst.connect(addr3).contributeNativeToken({value: utils.parseEther('1.0')})).to.be.revertedWith("revert ILO event not open")
//         val = await xStarterPoolPairInst.fundingTokenBalanceOfFunder(addr3.address);
//         expect(BigNumber.from(val).toString()).to.equal('0');

//       })
        
//     })

//     describe("validate xStarter ILO", function() {
        
//         it('ILO should succeed', async function(){
//             let response = await xStarterPoolPairInst.validateILO();
//             //   console.log('response is',response)
//             await expect(response.wait()).to.not.be.reverted;
//             let ILOFailed = await xStarterPoolPairInst.ILOFailed();
//             expect(ILOFailed).to.equal(false);
//             expect(await xStarterPoolPairInst.tokensForLiquidity()).to.equal('175000000000000000000000000')
//         })
//         it('team should have funding token allocated', async function(){
//             let teamAmount = await xStarterPoolPairInst.fundingTokenForTeam();
//             console.log('team amount  is',teamAmount.toString())
//             expect(teamAmount).to.be.equal(utils.parseEther('0.40'));
//             let amountRaiseAvail = await xStarterPoolPairInst.fundingTokenAvail();
//             expect(amountRaiseAvail).to.equal(utils.parseEther('1.60'));
//             console.log('amount raise available after team tokens taking',amountRaiseAvail.toString())
//             expect(await xStarterPoolPairInst.tokensForLiquidity()).to.equal('175000000000000000000000000')
//         })
//     })

//     describe('approveTokensForLiquidityPair', function() {
//               // this checks to make sure tokens are approved for uniswap or uniswap forks dex exchanges
//             this.timeout(40000)
//             it('approval should succeed', async function(){
//               let response = await xStarterPoolPairInst.approveTokensForLiquidityPair();
//               await expect(response.wait()).to.not.be.reverted;
        
//               // check project token allowances
//             //   let projectTokenAddr = await xStarterPoolPairInst.projectToken()
//               let amount = await xStarterTokenInst.totalSupply();
//               console.log('amount is', amount.toString());
//               expect(amount).to.equal('500000000000000000000000000');
        
//               amount = await xStarterTokenInst.allowance(xStarterPoolPairInst.address, uniswapRouter)
        
//               console.log('allowance amount is ', amount.toString())
//               expect(amount).to.equal('175000000000000000000000000');
//             })
//     })


//     describe('createLiquidityPool', function() {
//         // this checks to make sure tokens are approved for uniswap or uniswap forks dex exchanges

//         it('lp creation should succeed', async function(){
//             let response = await xStarterPoolPairInst.createLiquidityPool();
//             await expect(response.wait()).to.not.be.reverted;
//         })

//         it('lp address should be a non zero address', async function(){
//             let lpAddr1 = await xStarterPoolPairInst.liquidityPairAddress();
//             expect(lpAddr1).to.not.equal(zeroAddress);
//         })

//         it('lp tokens should be greater than 0', async function(){

//             // check project token allowances
//             let lpTokenAmount = await xStarterPoolPairInst.availLPTokens()
//             console.log('lp token amount is', lpTokenAmount.toString());
//             expect(lpTokenAmount).to.be.gte(0);

//             // validate weth address, and project token address lp pair address same as poolpair

//         })
//     })

//     describe('finalizeILO', function() {
//     // this checks to make sure tokens are approved for uniswap or uniswap forks dex exchanges

//         it('lp creation should succeed', async function(){
//             let response = await xStarterPoolPairInst.finalizeILO();
//             await expect(response.wait()).to.not.be.reverted;
//         })

//         it('liquidity pool address should be same on pool pair and uniswap* factory', async function(){

//             let routerFactoryAddr = await xStarterPoolPairInst.addressOfDexFactory()
//             routerFactoryInst = await routerFactoryContractFactory.attach(routerFactoryAddr)
//             let projectTokenAddr = await xStarterPoolPairInst.projectToken()

//             let lpAddr1 = await routerFactoryInst.getPair(WETH, projectTokenAddr)

//             let lpAddr2 = await xStarterPoolPairInst.liquidityPairAddress()

//             console.log('lp address from factory and lp address from pool pair', lpAddr1, lpAddr2)
//             expect(lpAddr2).to.equal(lpAddr1);

//             // validate weth address, and project token address lp pair address same as poolpair

            
//         })
//     })

//     describe('check timelocks', function() {
//         // this checks to make sure tokens are approved for uniswap or uniswap forks dex exchanges

//         it('should be timlocked', async function(){
//         let timeLockSet = await xStarterPoolPairInst.isTimeLockSet();
//         expect(timeLockSet).to.equal(true);
//         })

//         it('should revert when trying to withdraw token as contributor', async function(){
//             //   console.log('response is',response)
//             await expect(xStarterPoolPairInst.connect(addr1).withdraw()).to.be.revertedWith("revert withdrawal locked");
//         })
//         it('should revert when trying to withdraw token as project owner', async function(){
//             //   console.log('response is',response)
//             await expect(xStarterPoolPairInst.withdrawAdmin()).to.be.revertedWith("revert withdrawal locked");
//         })

//     })

//     describe('withdraw tokens', function() {

//         it('should equal right amount', async function(){
//             // this checks to make sure tokens are approved for uniswap or uniswap forks dex exchanges
//             // because this will wait for some time let mocha know setting to 3 minutes 
//             this.timeout(240000)
//             for (let index = 0; index < 10; index++) {
//                 await sleep(20000);
//                 let contributionLocked = await xStarterPoolPairInst.isContribTokenLocked();
//                 console.log('contribution locked', contributionLocked)

//                 if(!contributionLocked) {break}
                
//             }
//             let bal = await xStarterPoolPairInst.projectTokenBalanceOfFunder(addr1.address);
//             console.log('balance is', bal.toString())
//                 // 500 million tokens, 350 million for ilo, 50% for liquidity, so 175 million remaining, only 2 contributors so 87.5 million * 10 ** 18
//             expect(bal.toString()).to.be.equal('87500000000000000000000000')

//             let response = await xStarterPoolPairInst.connect(addr1).withdraw();
//             //   console.log('response is',response)
//             await expect(response.wait()).to.not.be.reverted;

//             // let allowBal = await projectTokenInst.allowance(poolPair.address, addr1.address);
//             // expect(allowBal).to.be.equal(bal)

//             // response = await projectTokenInst.connect(addr1).transferFrom(poolPair.address, addr1.address)
//             // await response.wait()

//             // let tokenBalance = await projectTokenInst.balanceOf(addr.address)
//             // expect(tokenBalance.toString()).to.equal('87500000000000000000000000')

                
//         })

//         it('allowance should equal right amount', async function(){
//             // this checks to make sure tokens are approved for uniswap or uniswap forks dex exchanges
//             // because this will wait for some time let mocha know setting to 3 minutes 

//             let allowBal = await xStarterTokenInst.balanceOf(addr1.address);
//             expect(allowBal.toString()).to.be.equal('87500000000000000000000000')

                
//         })
        
//         // it('after transferFrom balanceOf should be right amount', async function(){
//         //     // this checks to make sure tokens are approved for uniswap or uniswap forks dex exchanges
//         //     // because this will wait for some time let mocha know setting to 3 minutes 

//         //     let response = await xStarterTokenInst.connect(addr1).transferFrom(xStarterPoolPairInst.address, addr1.address, '87500000000000000000000000')
//         //     await response.wait()

//         //     let tokenBalance = await xStarterTokenInst.balanceOf(addr1.address)
//         //     expect(tokenBalance.toString()).to.equal('87500000000000000000000000')

                
//         // })
        


//     })

//     describe('withdraw admin tokens', function() {

//         it('should equal right amount', async function(){
//             // this checks to make sure tokens are approved for uniswap or uniswap forks dex exchanges
//             // because this will wait for some time let mocha know setting to 3 minutes 
//             this.timeout(240000)
//             for (let index = 0; index < 10; index++) {
//                 await sleep(20000);
//                 let projectTokenLocked = await xStarterPoolPairInst.isProjTokenLocked();
//                 console.log('project token locked', projectTokenLocked)

//                 if(!projectTokenLocked) {break}
                
//             }
//             let bal = await xStarterPoolPairInst.adminBalance();
//             console.log('admin balance is', bal.toString())
//                 // 500 million tokens, 350 million for ilo, 50% for liquidity, so 175 million remaining, only 2 contributors so 87.5 million * 10 ** 18
//             expect(bal.toString()).to.be.equal('150000000000000000000000000')

//             //   console.log('response is',response)
//             await expect(xStarterPoolPairInst.connect(addr1).withdrawAdmin()).to.be.revertedWith("revert Not authorized");

//             response = await xStarterPoolPairInst.withdrawAdmin();
//             //   console.log('response is',response)
//             await expect(response.wait()).to.not.be.reverted;

//             let allowBal = await xStarterTokenInst.balanceOf(owner.address);
//             expect(allowBal.toString()).to.be.equal('150000000000000000000000000')

                
//         })

//     })


//     describe('withdraw liquidity tokens', function() {

//         it('should equal right amount', async function(){
//             // this checks to make sure tokens are approved for uniswap or uniswap forks dex exchanges
//             // because this will wait for some time let mocha know setting to 3 minutes 
//             this.timeout(240000)
//             for (let index = 0; index < 10; index++) {
//                 await sleep(20000);
//                 let liqTokenLocked = await xStarterPoolPairInst.isLiqTokenLocked();
//                 console.log('project token locked', liqTokenLocked)

//                 if(!liqTokenLocked) {break}
                
//             }
//             let bal = await xStarterPoolPairInst.projectLPTokenBalanceOfFunder(addr1.address);
//             console.log('project lp token balance is', bal.toString())
//                 // 500 million tokens, 350 million for ilo, 50% for liquidity, so 175 million remaining, only 2 contributors so 87.5 million * 10 ** 18
//             expect(bal.toString()).to.be.equal('8366600265340755000000')


//             let response = await xStarterPoolPairInst.connect(addr1).withdrawLiquidityTokens();
//             // expect(response).to.equal(true)
//             await expect(response.wait()).to.not.be.reverted;

                
//         })

//         it('liquidity balance should equal right amount', async function(){
//             // this checks to make sure tokens are approved for uniswap or uniswap forks dex exchanges
//             // because this will wait for some time let mocha know setting to 3 minutes 

//             await expect(xStarterPoolPairInst.connect(addr1).withdrawLiquidityTokens()).to.be.revertedWith("revert No tokens");

//             let liqTokenAddress = await xStarterPoolPairInst.liquidityPairAddress()
//             liquidityTokenInst = await liquidityPairTokenFactory.attach(liqTokenAddress)

//             let tokenBalance = await liquidityTokenInst.balanceOf(addr1.address);
//             expect(tokenBalance.toString()).to.be.equal('8366600265340755000000')
            
//             // response = await liquidityTokenInst.connect(addr1).transferFrom(xStarterPoolPairInst.address, addr1.address, '8366600265340755000000')
//             // await response.wait()


//             // let tokenBalance = await liquidityTokenInst.balanceOf(addr1.address)
//             // expect(tokenBalance.toString()).to.equal('8366600265340755000000')

//             let newBal = await xStarterPoolPairInst.projectLPTokenBalanceOfFunder(addr1.address);
//             console.log('project lp token balance after withdrawal', newBal.toString())
//             expect(newBal).to.be.equal(0)

                
//         })

//     })

    
// })


// ******** Testing using ERC20 token as funding token



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
    let xStarterERCDeployerFactory;
    let xStarterERCDeployerInst;
    let xStarterProposalFactory;
    let xStarterProposalInst;
    let xStarterPoolPairInst;
    let routerFactoryContractFactory;
    let liquidityPairTokenFactory;
    let liquidityTokenInst;
    let projectTokenFactory;
    let fundingTokenInst;
    let initialStartTime = 60
    let initialEndTime = 7200;


    // // quickswap
    // const uniswapRouter = "0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff"
    // const uniswapFactory = "0x5757371414417b8C6CAad45bAeF941aBc7d3Ab32";

    // honeyswap on xDai
    const uniswapRouter = "0x1C232F01118CB8B424793ae03F870aa7D0ac7f77";
    const uniswapFactory = "0xa818b4f111ccac7aa31d0bcc0806d64f2e0737d7";
    // this is really address for WXDAI on honeyswap xDai
    const WETH = '0xe91D153E0b41518A2Ce8Dd3D7944Fa863463a97d'

    // const uniswapRouter = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D";
    // const uniswapFactory = "0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f";
    // const WETH = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";

    let owner;
    let addr1;
    let addr2;
    let addr3;
    let addr4
    let addr5
    let addrs;
    beforeEach(async function() {
        // deploy xStarterToken
        this.timeout(60000);
        if(!xStarterTokenInst){
            [owner, addr1, addr2, addr3, addr4, addr5, ...addrs] = await ethers.getSigners();

            console.log('address of owner is', owner.address)


            routerFactoryContractFactory = await ethers.getContractFactory('UniswapV2Factory');
            liquidityPairTokenFactory = await ethers.getContractFactory("contracts/UniswapFactory.sol:UniswapV2Pair")
            
            xStarterNFTFactory = await ethers.getContractFactory("xStarterNFT")
            xStarterTokenFactory = await ethers.getContractFactory("xStarterToken")
            xStarterTokenInst = await xStarterTokenFactory.deploy(
                BigNumber.from('500000000'),
                []
            )

            projectTokenFactory = await ethers.getContractFactory("contracts/xStarterPoolPairB.sol:ProjectBaseTokenERC20");
            fundingTokenInst = await projectTokenFactory.deploy(
            "abc",
            "abc",
            BigNumber.from('500000000000000000000000000'),
            owner.address
            )
            await fundingTokenInst.transfer(addr1.address, '10000000000000000000')
            await fundingTokenInst.transfer(addr2.address, '10000000000000000000')
            await fundingTokenInst.transfer(addr3.address, '10000000000000000000')
            await fundingTokenInst.transfer(addr4.address, '10000000000000000000')
            await fundingTokenInst.transfer(addr5.address, '10000000000000000000')


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
                utils.parseEther('500'),
                utils.parseEther('5000'), // 5000 tokens required  OR
                utils.parseEther('50'), // 50 LP tokens
                uniswapRouter,
                uniswapFactory,
                owner.address
            )
            
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

            console.log('launchpad is', xStarterLaunchPadInst.address)
            console.log('governance is', xStarterGovernanceInst.address)
            console.log('funding token is', fundingTokenInst.address)

        }   
    })

    describe('Contracts Deployed Correctly', function() {
        it('xStartToken has correct Values', async function(){
            let amount = await xStarterTokenInst.totalSupply();
            console.log('amount is ', amount.toString());
            expect(amount).to.equal(utils.parseEther('500000000'));
        })

        it('xStartDeployer has correct Values', async function(){
            let value = await xStarterDeployerInst.admin();
            console.log('allowedCaller is ', value);
            expect(value).to.equal(xStarterLaunchPadInst.address);
        })

        it('xStartLaunchpad has correct Values', async function(){
            let value = await xStarterLaunchPadInst.xStarterContracts();
            console.log('xStarterContracts from launchpad is ', value);
            // expect(value[0]).to.equal(xStarterGovernanceInst.address);
            expect(value[1]).to.equal(xStarterTokenInst.address);
            // expect(value[2]).to.equal(xStarterNFTInst.address);
            expect(value[3]).to.equal(xStarterDeployerInst.address);
            expect(value[4]).to.equal(xStarterERCDeployerInst.address);
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

    describe('Create xStarter ILO Proposal', function() {
        it('ILOProposal Contract deployed correctly', async function(){
            xStarterProposalInst = await xStarterProposalFactory.deploy(
                "xStarter", 
                "XSTN", 
                "QmbesxZ1QQyWksXgLf6MY8okvzpcUFsFybdiSHtmKmahcX", 
                utils.parseEther('500000000'),
                70,
                fundingTokenInst.address,
                xStarterLaunchPadInst.address 
            );

            await (await xStarterProposalInst.addMoreInfo(
                60,
                180,
                utils.parseEther('0.001'),
                utils.parseEther('0.10'),
                utils.parseEther('1'),
                utils.parseEther('1'),
                utils.parseEther('4'),
                20
                )).wait()

            let value = await xStarterProposalInst.getCompactInfo();
            let ILOInfo = value.info
            let ILOAdditional = value.moreInfo
            console.log('ilo proposal is ', ILOInfo);
            console.log('ilo additional is ', ILOAdditional);
            // console.log('xStarter ILO Proposal addr', xStarterProposalInst.address)
            // console.log('token name is ', value.tokenName, typeof value);
            expect(ILOInfo.tokenName).to.equal("xStarter");
            expect(ILOInfo.tokenSymbol).to.equal("XSTN");
            expect(ILOInfo.totalSupply).to.equal(utils.parseEther('500000000'));
            expect(ILOInfo.percentOfTokensForILO).to.equal(70);
            expect(ILOInfo.fundingToken).to.equal(fundingTokenInst.address);
            expect(ILOAdditional.softcap).to.equal(utils.parseEther('1'));
            expect(await xStarterProposalInst.getLaunchpadAddress()).to.equal(xStarterLaunchPadInst.address );
        })

    })

    describe('add initial xStarter ILO proposal to launchpad', function() {
        // using the same info, but this should revert since deployXstarterILO hasn't been called by creator
        it('adding of another ILO proposal before initial should revert', async function(){
            await expect(xStarterLaunchPadInst.registerILOProposal(
                xStarterProposalInst.address
            )).to.be.revertedWith("revert Initial xStarter ILO not deployed")
        })

        it('deploying of initial ILO should revert if not called by admin', async function(){
            await expect(xStarterLaunchPadInst.connect(addr1).deployXstarterILO(
                xStarterProposalInst.address
                
            )).to.be.revertedWith("revert Not authorized")
        })

        it('deploying of initial ILO should succeed with allowedCaller', async function(){
            console.log('owner addr', owner.address)
            // address of xStarterPoolPair for the xStarter ILO
            await (await xStarterLaunchPadInst.connect(owner).deployXstarterILO(
                xStarterProposalInst.address
            )).wait()

            let proposalInfo = await xStarterLaunchPadInst.getProposal(xStarterProposalInst.address)
            console.log('address of pool pair is', proposalInfo.info.ILOAddress)
            console.log('adddress of xstarter ILo', xStarterProposalInst.address)
            // await expect().to.be.revertedWith("revert Not authorized")

        })

        it("setUpPoolPair Should Revert If Called By Non Admin", async function () {
            // Expect receives a value, and wraps it in an Assertion object. These
            // objects have a lot of utility methods to assert values.
              
              let startTime = parseInt(Date.now() / 1000) + initialStartTime;
              let endTime = parseInt(Date.now() / 1000) + initialEndTime;
              console.log('start time and endtime is', startTime, endTime)
              let proposalInfo = await xStarterLaunchPadInst.getProposal(xStarterProposalInst.address)
              xStarterPoolPairInst = poolPairFactory.attach(proposalInfo.info.ILOAddress)
            //   const poolPairFromOther = poolPair.connect(addr2);
              await expect(xStarterPoolPairInst.connect(addr2).setUpPoolPair(
                xStarterTokenInst.address,
                xStarterERCDeployerInst.address,
                "xStarter", 
                "XSTN", 
                500000000,
                startTime,
                endTime,
            )).to.be.revertedWith("revert Not authorized");
              
          })
          it("setUpPoolPair Should succeed Admin", async function () {
            // Expect receives a value, and wraps it in an Assertion object. These
            // objects have a lot of utility methods to assert values.
              
              let startTime = parseInt(Date.now() / 1000) + initialStartTime;
              let endTime = parseInt(Date.now() / 1000) + initialEndTime;
              let proposalInfo = await xStarterLaunchPadInst.getProposal(xStarterProposalInst.address)
              xStarterPoolPairInst = poolPairFactory.attach(proposalInfo.info.ILOAddress)
            //   const poolPairFromOther = poolPair.connect(addr2);
              let response = await xStarterPoolPairInst.setUpPoolPair(
                xStarterTokenInst.address,
                xStarterERCDeployerInst.address,
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

          it("deposit tokens to ILO", async function () {

            let response = await xStarterTokenInst.approve(xStarterPoolPairInst.address, utils.parseEther('500000000'))
            await response.wait()
            response = await xStarterTokenInst.allowance(owner.address,xStarterPoolPairInst.address)
            console.log('allowance is', response)
            expect(response).to.equal(BigNumber.from('500000000000000000000000000'))
            const depositing = await xStarterPoolPairInst.depositAllTokenSupply()
            await expect(depositing.wait()).to.not.be.reverted
        })
        it('ILO project tokens held should be equal to 500 million tokens or 500 million * 10 ** 18', async function() {
          let supply = await xStarterPoolPairInst.tokensHeld()
          let addr = await xStarterPoolPairInst.projectToken()

          expect(supply).to.be.equal(BigNumber.from('500000000000000000000000000'))
          expect(addr).to.be.equal(xStarterTokenInst.address)
        })

    })

    describe("Contribute Native Token in xStarter ILO", function() {

        it('should revert because event not open', async function(){
        //   console.log('response is',response)
        await expect(xStarterPoolPairInst.connect(addr1).contributeNativeToken({value: '1000000000000000000'})).to.be.revertedWith("ILO event not open");
        })

        it('wait till open, contribute and check balance has changed', async function(){
        // because this will wait for some time let mocha know setting to 3 minutes 
        this.timeout(340000)
        for (let index = 0; index < 15; index++) {
            await sleep(20000);
            let isOpen = await xStarterPoolPairInst.isEventOpen()
            console.log('event is open', isOpen)

            if(isOpen) {break}
            
        }



        // first contribution
        let response = await fundingTokenInst.connect(addr1).approve(xStarterPoolPairInst.address, utils.parseEther('1.0'))
        await response.wait()
        response = await xStarterPoolPairInst.connect(addr1).contributeFundingToken();
        await response.wait();
        let val = await xStarterPoolPairInst.fundingTokenBalanceOfFunder(addr1.address);
        expect(BigNumber.from(val).toString()).to.equal('1000000000000000000');
        let amtRaised = await xStarterPoolPairInst.amountRaised()
        expect(BigNumber.from(amtRaised).toString()).to.equal('1000000000000000000');


        // second contribution
        response = await fundingTokenInst.connect(addr2).approve(xStarterPoolPairInst.address, utils.parseEther('1.0'))
        await response.wait()
        response = await xStarterPoolPairInst.connect(addr2).contributeFundingToken();
        await response.wait();
        val = await xStarterPoolPairInst.fundingTokenBalanceOfFunder(addr2.address);
        expect(BigNumber.from(val).toString()).to.equal('1000000000000000000');
        amtRaised = await xStarterPoolPairInst.amountRaised()
        expect(BigNumber.from(amtRaised).toString()).to.equal('2000000000000000000');


        // third contribution should revert

        response = await fundingTokenInst.connect(addr3).approve(xStarterPoolPairInst.address, utils.parseEther('1.0'))
        await response.wait()

        await expect(xStarterPoolPairInst.connect(addr3).contributeFundingToken()).to.be.revertedWith("revert ILO event not open")
        val = await xStarterPoolPairInst.fundingTokenBalanceOfFunder(addr3.address);
        expect(BigNumber.from(val).toString()).to.equal('0');




        // let response = await xStarterPoolPairInst.connect(addr1).contributeNativeToken({value: utils.parseEther('1.0')});
        // await response.wait();
        // let val = await xStarterPoolPairInst.fundingTokenBalanceOfFunder(addr1.address);
        // expect(BigNumber.from(val).toString()).to.equal('1000000000000000000');
        // let amtRaised = await xStarterPoolPairInst.amountRaised()
        // expect(BigNumber.from(amtRaised).toString()).to.equal('1000000000000000000');

        // response = await xStarterPoolPairInst.connect(addr2).contributeNativeToken({value: utils.parseEther('1.0')});
        // await response.wait();
        // val = await xStarterPoolPairInst.fundingTokenBalanceOfFunder(addr2.address);
        // expect(BigNumber.from(val).toString()).to.equal('1000000000000000000');
        // amtRaised = await xStarterPoolPairInst.amountRaised()
        // expect(BigNumber.from(amtRaised).toString()).to.equal('2000000000000000000');

        // await expect(xStarterPoolPairInst.connect(addr3).contributeNativeToken({value: utils.parseEther('1.0')})).to.be.revertedWith("revert ILO event not open")
        // val = await xStarterPoolPairInst.fundingTokenBalanceOfFunder(addr3.address);
        // expect(BigNumber.from(val).toString()).to.equal('0');

      })
        
    })

    describe("validate xStarter ILO", function() {
        
        it('ILO should succeed', async function(){
            let response = await xStarterPoolPairInst.validateILO();
            //   console.log('response is',response)
            await expect(response.wait()).to.not.be.reverted;
            let ILOFailed = await xStarterPoolPairInst.ILOFailed();
            expect(ILOFailed).to.equal(false);
            expect(await xStarterPoolPairInst.tokensForLiquidity()).to.equal('175000000000000000000000000')
        })
        it('team should have funding token allocated', async function(){
            let teamAmount = await xStarterPoolPairInst.fundingTokenForTeam();
            console.log('team amount  is',teamAmount.toString())
            expect(teamAmount).to.be.equal(utils.parseEther('0.40'));
            let amountRaiseAvail = await xStarterPoolPairInst.fundingTokenAvail();
            expect(amountRaiseAvail).to.equal(utils.parseEther('1.60'));
            console.log('amount raise available after team tokens taking',amountRaiseAvail.toString())
            expect(await xStarterPoolPairInst.tokensForLiquidity()).to.equal('175000000000000000000000000')
        })
    })

    describe('approveTokensForLiquidityPair', function() {
              // this checks to make sure tokens are approved for uniswap or uniswap forks dex exchanges
            this.timeout(40000)
            it('approval should succeed', async function(){
              let response = await xStarterPoolPairInst.approveTokensForLiquidityPair();
              await expect(response.wait()).to.not.be.reverted;
        
              // check project token allowances
            //   let projectTokenAddr = await xStarterPoolPairInst.projectToken()
              let amount = await xStarterTokenInst.totalSupply();
              console.log('amount is', amount.toString());
              expect(amount).to.equal('500000000000000000000000000');
        
              amount = await xStarterTokenInst.allowance(xStarterPoolPairInst.address, uniswapRouter)
        
              console.log('allowance amount is ', amount.toString())
              expect(amount).to.equal('175000000000000000000000000');
            })
    })


    describe('createLiquidityPool', function() {
        // this checks to make sure tokens are approved for uniswap or uniswap forks dex exchanges

        it('lp creation should succeed', async function(){
            let response = await xStarterPoolPairInst.createLiquidityPool();
            await expect(response.wait()).to.not.be.reverted;
        })

        it('lp address should be a non zero address', async function(){
            let lpAddr1 = await xStarterPoolPairInst.liquidityPairAddress();
            expect(lpAddr1).to.not.equal(zeroAddress);
        })

        it('lp tokens should be greater than 0', async function(){

            // check project token allowances
            let lpTokenAmount = await xStarterPoolPairInst.availLPTokens()
            console.log('lp token amount is', lpTokenAmount.toString());
            expect(lpTokenAmount).to.be.gte(0);

            // validate weth address, and project token address lp pair address same as poolpair

        })
    })

    describe('finalizeILO', function() {
    // this checks to make sure tokens are approved for uniswap or uniswap forks dex exchanges

        it('lp creation should succeed', async function(){
            let response = await xStarterPoolPairInst.finalizeILO();
            await expect(response.wait()).to.not.be.reverted;
        })

        it('liquidity pool address should be same on pool pair and uniswap* factory', async function(){

            let routerFactoryAddr = await xStarterPoolPairInst.addressOfDexFactory()
            routerFactoryInst = await routerFactoryContractFactory.attach(routerFactoryAddr)
            let projectTokenAddr = await xStarterPoolPairInst.projectToken()

            let lpAddr1 = await routerFactoryInst.getPair(fundingTokenInst.address, projectTokenAddr)

            let lpAddr2 = await xStarterPoolPairInst.liquidityPairAddress()

            console.log('lp address from factory and lp address from pool pair', lpAddr1, lpAddr2)
            expect(lpAddr2).to.equal(lpAddr1);

            // validate weth address, and project token address lp pair address same as poolpair

            
        })
    })

    describe('check timelocks', function() {
        // this checks to make sure tokens are approved for uniswap or uniswap forks dex exchanges

        it('should be timlocked', async function(){
        let timeLockSet = await xStarterPoolPairInst.isTimeLockSet();
        expect(timeLockSet).to.equal(true);
        })

        it('should revert when trying to withdraw token as contributor', async function(){
            //   console.log('response is',response)
            await expect(xStarterPoolPairInst.connect(addr1).withdraw()).to.be.revertedWith("revert withdrawal locked");
        })
        it('should revert when trying to withdraw token as project owner', async function(){
            //   console.log('response is',response)
            await expect(xStarterPoolPairInst.withdrawAdmin()).to.be.revertedWith("revert withdrawal locked");
        })

    })

    describe('withdraw tokens', function() {

        it('should equal right amount', async function(){
            // this checks to make sure tokens are approved for uniswap or uniswap forks dex exchanges
            // because this will wait for some time let mocha know setting to 3 minutes 
            this.timeout(240000)
            for (let index = 0; index < 10; index++) {
                await sleep(20000);
                let contributionLocked = await xStarterPoolPairInst.isContribTokenLocked();
                console.log('contribution locked', contributionLocked)

                if(!contributionLocked) {break}
                
            }
            let bal = await xStarterPoolPairInst.projectTokenBalanceOfFunder(addr1.address);
            console.log('balance is', bal.toString())
                // 500 million tokens, 350 million for ilo, 50% for liquidity, so 175 million remaining, only 2 contributors so 87.5 million * 10 ** 18
            expect(bal.toString()).to.be.equal('87500000000000000000000000')

            let response = await xStarterPoolPairInst.connect(addr1).withdraw();
            //   console.log('response is',response)
            await expect(response.wait()).to.not.be.reverted;

            // let allowBal = await projectTokenInst.allowance(poolPair.address, addr1.address);
            // expect(allowBal).to.be.equal(bal)

            // response = await projectTokenInst.connect(addr1).transferFrom(poolPair.address, addr1.address)
            // await response.wait()

            // let tokenBalance = await projectTokenInst.balanceOf(addr.address)
            // expect(tokenBalance.toString()).to.equal('87500000000000000000000000')

                
        })

        it('allowance should equal right amount', async function(){
            // this checks to make sure tokens are approved for uniswap or uniswap forks dex exchanges
            // because this will wait for some time let mocha know setting to 3 minutes 

            let allowBal = await xStarterTokenInst.balanceOf(addr1.address);
            expect(allowBal.toString()).to.be.equal('87500000000000000000000000')

                
        })
        
        // it('after transferFrom balanceOf should be right amount', async function(){
        //     // this checks to make sure tokens are approved for uniswap or uniswap forks dex exchanges
        //     // because this will wait for some time let mocha know setting to 3 minutes 

        //     let response = await xStarterTokenInst.connect(addr1).transferFrom(xStarterPoolPairInst.address, addr1.address, '87500000000000000000000000')
        //     await response.wait()

        //     let tokenBalance = await xStarterTokenInst.balanceOf(addr1.address)
        //     expect(tokenBalance.toString()).to.equal('87500000000000000000000000')

                
        // })
        


    })

    describe('withdraw admin tokens', function() {

        it('should equal right amount', async function(){
            // this checks to make sure tokens are approved for uniswap or uniswap forks dex exchanges
            // because this will wait for some time let mocha know setting to 3 minutes 
            this.timeout(240000)
            for (let index = 0; index < 10; index++) {
                await sleep(20000);
                let projectTokenLocked = await xStarterPoolPairInst.isProjTokenLocked();
                console.log('project token locked', projectTokenLocked)

                if(!projectTokenLocked) {break}
                
            }
            let bal = await xStarterPoolPairInst.adminBalance();
            console.log('admin balance is', bal.toString())
                // 500 million tokens, 350 million for ilo, 50% for liquidity, so 175 million remaining, only 2 contributors so 87.5 million * 10 ** 18
            expect(bal.toString()).to.be.equal('150000000000000000000000000')

            //   console.log('response is',response)
            await expect(xStarterPoolPairInst.connect(addr1).withdrawAdmin()).to.be.revertedWith("revert Not authorized");

            response = await xStarterPoolPairInst.withdrawAdmin();
            //   console.log('response is',response)
            await expect(response.wait()).to.not.be.reverted;

            let allowBal = await xStarterTokenInst.balanceOf(owner.address);
            expect(allowBal.toString()).to.be.equal('150000000000000000000000000')

                
        })

    })


    describe('withdraw liquidity tokens', function() {

        it('should equal right amount', async function(){
            // this checks to make sure tokens are approved for uniswap or uniswap forks dex exchanges
            // because this will wait for some time let mocha know setting to 3 minutes 
            this.timeout(240000)
            for (let index = 0; index < 10; index++) {
                await sleep(20000);
                let liqTokenLocked = await xStarterPoolPairInst.isLiqTokenLocked();
                console.log('project token locked', liqTokenLocked)

                if(!liqTokenLocked) {break}
                
            }
            let bal = await xStarterPoolPairInst.projectLPTokenBalanceOfFunder(addr1.address);
            console.log('project lp token balance is', bal.toString())
                // 500 million tokens, 350 million for ilo, 50% for liquidity, so 175 million remaining, only 2 contributors so 87.5 million * 10 ** 18
            expect(bal.toString()).to.be.equal('8366600265340755000000')


            let response = await xStarterPoolPairInst.connect(addr1).withdrawLiquidityTokens();
            // expect(response).to.equal(true)
            await expect(response.wait()).to.not.be.reverted;

                
        })

        it('liquidity balance should equal right amount', async function(){
            // this checks to make sure tokens are approved for uniswap or uniswap forks dex exchanges
            // because this will wait for some time let mocha know setting to 3 minutes 

            await expect(xStarterPoolPairInst.connect(addr1).withdrawLiquidityTokens()).to.be.revertedWith("revert No tokens");

            let liqTokenAddress = await xStarterPoolPairInst.liquidityPairAddress()
            liquidityTokenInst = await liquidityPairTokenFactory.attach(liqTokenAddress)

            let tokenBalance = await liquidityTokenInst.balanceOf(addr1.address);
            expect(tokenBalance.toString()).to.be.equal('8366600265340755000000')
            
            // response = await liquidityTokenInst.connect(addr1).transferFrom(xStarterPoolPairInst.address, addr1.address, '8366600265340755000000')
            // await response.wait()


            // let tokenBalance = await liquidityTokenInst.balanceOf(addr1.address)
            // expect(tokenBalance.toString()).to.equal('8366600265340755000000')

            let newBal = await xStarterPoolPairInst.projectLPTokenBalanceOfFunder(addr1.address);
            console.log('project lp token balance after withdrawal', newBal.toString())
            expect(newBal).to.be.equal(0)

                
        })

    })

    
})