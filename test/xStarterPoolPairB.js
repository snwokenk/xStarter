const { expect } = require("chai");
const { BigNumber, utils } = require("ethers");
const { ethers } = require("hardhat");
// const getRevertReason = require('eth-revert-reason')

function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

describe("xStarterPoolPairB WITH contract deployed token", function(){
   const uniswapRouter = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D";
   const uniswapFactory = "0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f";
   const WETH = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";
   const zeroAddress = "0x0000000000000000000000000000000000000000";
   const decimals = "18";
   const anEther = 10 ** decimals;
   const startTimeLen = 60;
   const endTimeLen = 120;
   this.slow(240000)
   
  let poolPairFactory;
  let poolPair;
  let projectTokenInst;
  let liquidityTokenInst;
  let routerContractFactory;
  let routerFactoryContractFactory;
  let routerInst;
  let routerFactoryInst;
  let owner;
  let addr1;
  let addr2;
  let addr3;
  let addrs;

  beforeEach(async function () {
    // Get the ContractFactory and Signers here.
    if(!poolPair) {
        // print out test private key
        // https://ethereum.stackexchange.com/a/79319/71015
        let testMnemomic = "test test test test test test test test test test test junk"
        let mnemonicWallet = ethers.Wallet.fromMnemonic(testMnemomic);
        console.log('test private key is', mnemonicWallet.privateKey);
        poolPairFactory = await ethers.getContractFactory("xStarterPoolPairB");
        projectTokenFactory = await ethers.getContractFactory("contracts/xStarterPoolPairB.sol:ProjectBaseTokenERC20");
        liquidityPairTokenFactory = await ethers.getContractFactory("contracts/UniswapFactory.sol:UniswapV2Pair")
        routerContractFactory = await ethers.getContractFactory("UniswapV2Router02");
        routerFactoryContractFactory = await ethers.getContractFactory('UniswapV2Factory');
        [owner, addr1, addr2, addr3, ...addrs] = await ethers.getSigners();

        // To deploy our contract, we just have to call Token.deploy() and await
        // for it to be deployed(), which happens onces its transaction has been
        // mined.
        poolPair = await poolPairFactory.deploy(
            owner.address,
            "70","1","15500000","1800","60",
            "10000000000000000","10000000000000000",
            "1000000000000000000", "1000000000000000000", 
            "2000000000000000000", zeroAddress,
            uniswapRouter, uniswapFactory
        );
        
    }

  });

  describe("Deployment", function () {
    // `it` is another Mocha function. This is the one you use to define your
    // tests. It receives the test name, and a callback function.

    // If the callback function is async, Mocha will `await` it.
    it("Should set the right Admin", async function () {
      // Expect receives a value, and wraps it in an Assertion object. These
      // objects have a lot of utility methods to assert values.

      // This test expects the Admin variable stored in the contract to be equal
      // to our Signer's owner.
        expect(await poolPair.admin()).to.equal(owner.address);
        console.log(poolPair.address)
    });

    // If the callback function is async, Mocha will `await` it.
    it("Should set the right router and factory address", async function () {
        // Expect receives a value, and wraps it in an Assertion object. These
        // objects have a lot of utility methods to assert values.
  
        // This test expects the Admin variable stored in the contract to be equal
        // to our Signer's owner.
        expect(await poolPair.addressOfDex()).to.equal(uniswapRouter);
        expect(await poolPair.addressOfDexFactory()).to.equal(uniswapFactory);
      });

  });

  describe("setUpPoolPair Transaction", function () {
    // `it` is another Mocha function. This is the one you use to define your
    // tests. It receives the test name, and a callback function.

    // // If the callback function is async, Mocha will `await` it.
    it("setUpPoolPair Should Revert If Called By Non Admin", async function () {
      // Expect receives a value, and wraps it in an Assertion object. These
      // objects have a lot of utility methods to assert values.
        
        let startTime = parseInt(Date.now() / 1000) + startTimeLen;
        let endTime = parseInt(Date.now() / 1000) + endTimeLen;
        const poolPairFromOther = poolPair.connect(addr2);
        await expect(poolPairFromOther.setUpPoolPair(
          zeroAddress,
          "xyz",
          "xyz",
          decimals,
          500000000,
          startTime,
          endTime,
      )).to.be.revertedWith("Administration: caller is not the admin");
        
    });

    it("setUpPoolPair Should be setup contract when admin calls", async function () {
        // Expect receives a value, and wraps it in an Assertion object. These
        // objects have a lot of utility methods to assert values.
          
        let startTime = (parseInt(Date.now() / 1000) + startTimeLen);
        let endTime = (parseInt(Date.now() / 1000) + endTimeLen);
        const response = await poolPair.setUpPoolPair(
            zeroAddress,
            "xyz",
            "xyz",
            decimals,
            500000000,
            startTime,
            endTime,
        )
        

        await expect(response.wait()).to.not.be.reverted
        
        let addr = await poolPair.projectToken();
        let supply = await poolPair.totalTokensSupplyControlled();
        expect(await poolPair.projectToken()).to.not.equal(zeroAddress);
        expect(await poolPair.isSetup()).to.equal(true);
        expect(await poolPair.startTime()).to.equal(startTime);
        expect(await poolPair.endTime()).to.equal(endTime);

          
      });



  });

  describe('depositAllToken', function() {
      

      it('should revert because only admin can call', async function(){
        await expect(poolPair.connect(addr1).depositAllTokenSupply()).to.be.revertedWith("Administration: caller is not the admin");
      })
      it('should revert because tokens automatically deposited when created by contract', async function(){
        await expect(poolPair.depositAllTokenSupply()).to.be.revertedWith("revert already deposited");
      })
      it('totalsupplycontrol should be equal to 500 million tokens or 500 million * 10 ** 18', async function() {
          let supply = await poolPair.totalTokensSupplyControlled()
          let addr = await poolPair.projectToken()

          expect(supply).to.be.equal(BigNumber.from('500000000000000000000000000'))
      })
  })

  describe('contributeNativeToken', function() {
      

    it('should revert because event not open', async function(){
    //   console.log('response is',response)
      await expect(poolPair.connect(addr1).contributeNativeToken({value: '1000000000000000000'})).to.be.revertedWith("ILO event not open");
    })

    it('wait till open, contribute and check balance has changed', async function(){
        // because this will wait for some time let mocha know setting to 3 minutes 
        this.timeout(240000)
        for (let index = 0; index < 10; index++) {
            await sleep(20000);
            let isOpen = await poolPair.isEventOpen()
            console.log('event is open', isOpen)

            if(isOpen) {break}
            
        }
        let response = await poolPair.connect(addr1).contributeNativeToken({value: utils.parseEther('1.0')});
        await response.wait();
        let val = await poolPair.fundingTokenBalanceOfFunder(addr1.address);
        expect(BigNumber.from(val).toString()).to.equal('1000000000000000000');
        let amtRaised = await poolPair.amountRaised()
        expect(BigNumber.from(amtRaised).toString()).to.equal('1000000000000000000');

        response = await poolPair.connect(addr2).contributeNativeToken({value: utils.parseEther('1.0')});
        await response.wait();
        val = await poolPair.fundingTokenBalanceOfFunder(addr2.address);
        expect(BigNumber.from(val).toString()).to.equal('1000000000000000000');
        amtRaised = await poolPair.amountRaised()
        expect(BigNumber.from(amtRaised).toString()).to.equal('2000000000000000000');

        await expect(poolPair.connect(addr3).contributeNativeToken({value: utils.parseEther('1.0')})).to.be.revertedWith("revert ILO event not open")
        val = await poolPair.fundingTokenBalanceOfFunder(addr3.address);
        expect(BigNumber.from(val).toString()).to.equal('0');

      })

      it('event should be done because maximum reached', async function() {
        let isDone = await poolPair.isEventDone()
        let isOpen = await poolPair.isEventOpen()
        // should be true since max raise is 2 ethers
        expect(isDone).to.equal(true);
        expect(isOpen).to.equal(false);
      })
})

describe('validateILO', function() {
      

    it('ILO should succeed', async function(){
      let response = await poolPair.validateILO();
    //   console.log('response is',response)
      await expect(response.wait()).to.not.be.reverted;
      let ILOFailed = await poolPair.ILOFailed();
      expect(ILOFailed).to.equal(false);
      expect(await poolPair.tokensForLiquidity()).to.equal('175000000000000000000000000')
    })
})

describe('approveTokensForLiquidityPair', function() {
      // this checks to make sure tokens are approved for uniswap or uniswap forks dex exchanges

    it('approval should succeed', async function(){
      let response = await poolPair.approveTokensForLiquidityPair();
      await expect(response.wait()).to.not.be.reverted;

      // check project token allowances
      let projectTokenAddr = await poolPair.projectToken()
      projectTokenInst = await projectTokenFactory.attach(projectTokenAddr)
      let amount = await projectTokenInst.totalSupply();
      console.log('amount is', amount.toString());
      expect(amount).to.equal('500000000000000000000000000');

      amount = await projectTokenInst.allowance(poolPair.address, uniswapRouter)

      console.log('allowance amount is ', amount.toString())
      expect(amount).to.equal('175000000000000000000000000');
    })
})

describe('approveTokensForLiquidityPair', function() {
    // this checks to make sure tokens are approved for uniswap or uniswap forks dex exchanges
  it('allowance amount should be correct', async function(){

    // check project token allowances
    let projectTokenAddr = await poolPair.projectToken()
    projectTokenInst = await projectTokenFactory.attach(projectTokenAddr)
    let amount = await projectTokenInst.totalSupply();
    console.log('amount is', amount.toString());
    expect(amount).to.equal('500000000000000000000000000');

    amount = await projectTokenInst.allowance(poolPair.address, uniswapRouter)

    console.log('allowance amount is ', amount.toString())
    expect(amount).to.equal('175000000000000000000000000');
  })
})

describe('createLiquidityPool', function() {
    // this checks to make sure tokens are approved for uniswap or uniswap forks dex exchanges

  it('lp creation should succeed', async function(){
    let response = await poolPair.createLiquidityPool();
    await expect(response.wait()).to.not.be.reverted;
  })

  it('lp tokens should be greater than 0', async function(){

    // check project token allowances
    let lpTokenAmount = await poolPair.availLPTokens()
    console.log('amount is', lpTokenAmount.toString());
    expect(lpTokenAmount).to.be.gte(0);

    // validate weth address, and project token address lp pair address same as poolpair

    
  })
})

  describe('finalizeILO', function() {
    // this checks to make sure tokens are approved for uniswap or uniswap forks dex exchanges

  it('lp creation should succeed', async function(){
    let response = await poolPair.finalizeILO();
    await expect(response.wait()).to.not.be.reverted;
  })

  it('liquidity pool address should be same on pool pair and uniswap* factory', async function(){

    let routerFactoryAddr = await poolPair.addressOfDexFactory()
    routerFactoryInst = await routerFactoryContractFactory.attach(routerFactoryAddr)
    let projectTokenAddr = await poolPair.projectToken()

    let lpAddr1 = await routerFactoryInst.getPair(WETH, projectTokenAddr)

    let lpAddr2 = await poolPair.liquidityPairAddress()

    console.log('lp address from factory and lp address from pool pair', lpAddr1, lpAddr2)
    expect(lpAddr2).to.equal(lpAddr1);

    // validate weth address, and project token address lp pair address same as poolpair

    
  })
})

describe('check timelocks', function() {
  // this checks to make sure tokens are approved for uniswap or uniswap forks dex exchanges

it('should be timlocked', async function(){
  let timeLockSet = await poolPair.isTimeLockSet();
  expect(timeLockSet).to.equal(true);
})

it('should revert when trying to withdraw token as contributor', async function(){
    //   console.log('response is',response)
      await expect(poolPair.connect(addr1).withdraw()).to.be.revertedWith("revert withdrawal locked");
})
it('should revert when trying to withdraw token as project owner', async function(){
    //   console.log('response is',response)
      await expect(poolPair.withdrawAdmin()).to.be.revertedWith("revert withdrawal locked");
})

})

describe('withdraw tokens', function() {

  it('should equal right amount', async function(){
    // this checks to make sure tokens are approved for uniswap or uniswap forks dex exchanges
    // because this will wait for some time let mocha know setting to 3 minutes 
    this.timeout(240000)
    for (let index = 0; index < 10; index++) {
        await sleep(20000);
        let contributionLocked = await poolPair.isContribTokenLocked();
        console.log('contribution locked', contributionLocked)

        if(!contributionLocked) {break}
        
    }
      let bal = await poolPair.projectTokenBalanceOfFunder(addr1.address);
      console.log('balance is', bal.toString())
        // 500 million tokens, 350 million for ilo, 50% for liquidity, so 175 million remaining, only 2 contributors so 87.5 million * 10 ** 18
      expect(bal.toString()).to.be.equal('87500000000000000000000000')

      let response = await poolPair.connect(addr1).withdraw();
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

      let allowBal = await projectTokenInst.allowance(poolPair.address, addr1.address);
      expect(allowBal.toString()).to.be.equal('87500000000000000000000000')

        
  })
  
  it('after transferFrom balanceOf should be right amount', async function(){
    // this checks to make sure tokens are approved for uniswap or uniswap forks dex exchanges
    // because this will wait for some time let mocha know setting to 3 minutes 

      let response = await projectTokenInst.connect(addr1).transferFrom(poolPair.address, addr1.address, '87500000000000000000000000')
      await response.wait()

      let tokenBalance = await projectTokenInst.balanceOf(addr1.address)
      expect(tokenBalance.toString()).to.equal('87500000000000000000000000')

        
  })
  


})

describe('withdraw admin tokens', function() {

  it('should equal right amount', async function(){
    // this checks to make sure tokens are approved for uniswap or uniswap forks dex exchanges
    // because this will wait for some time let mocha know setting to 3 minutes 
    this.timeout(240000)
    for (let index = 0; index < 10; index++) {
        await sleep(20000);
        let projectTokenLocked = await poolPair.isProjTokenLocked();
        console.log('project token locked', projectTokenLocked)

        if(!projectTokenLocked) {break}
        
    }
      let bal = await poolPair.adminBalance();
      console.log('admin balance is', bal.toString())
        // 500 million tokens, 350 million for ilo, 50% for liquidity, so 175 million remaining, only 2 contributors so 87.5 million * 10 ** 18
      expect(bal.toString()).to.be.equal('150000000000000000000000000')

      //   console.log('response is',response)
      await expect(poolPair.connect(addr1).withdrawAdmin()).to.be.revertedWith("Administration: caller is not the admin");

      response = await poolPair.withdrawAdmin();
      //   console.log('response is',response)
      await expect(response.wait()).to.not.be.reverted;

      let allowBal = await projectTokenInst.allowance(poolPair.address, owner.address);
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
        let liqTokenLocked = await poolPair.isLiqTokenLocked();
        console.log('project token locked', liqTokenLocked)

        if(!liqTokenLocked) {break}
        
    }
      let bal = await poolPair.projectLPTokenBalanceOfFunder(addr1.address);
      console.log('project lp token balance is', bal.toString())
        // 500 million tokens, 350 million for ilo, 50% for liquidity, so 175 million remaining, only 2 contributors so 87.5 million * 10 ** 18
      expect(bal.toString()).to.be.equal('9354143466934853000000')


      let response = await poolPair.connect(addr1).withdrawLiquidityTokens();
      // expect(response).to.equal(true)
      await expect(response.wait()).to.not.be.reverted;

        
  })

  it('liquidity balance should equal right amount', async function(){
    // this checks to make sure tokens are approved for uniswap or uniswap forks dex exchanges
    // because this will wait for some time let mocha know setting to 3 minutes 

      await expect(poolPair.connect(addr1).withdrawLiquidityTokens()).to.be.revertedWith("revert No tokens");

      let liqTokenAddress = await poolPair.liquidityPairAddress()
      liquidityTokenInst = await liquidityPairTokenFactory.attach(liqTokenAddress)

      let allowBal = await liquidityTokenInst.allowance(poolPair.address, addr1.address);
      expect(allowBal.toString()).to.be.equal('9354143466934853000000')
      
      response = await liquidityTokenInst.connect(addr1).transferFrom(poolPair.address, addr1.address, '9354143466934853000000')
      await response.wait()


      let tokenBalance = await liquidityTokenInst.balanceOf(addr1.address)
      expect(tokenBalance.toString()).to.equal('9354143466934853000000')

      let newBal = await poolPair.projectLPTokenBalanceOfFunder(addr1.address);
      console.log('project lp token balance after withdrawal', newBal.toString())
      expect(newBal).to.be.equal(0)

        
  })

})

})