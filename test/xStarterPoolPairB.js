const { expect } = require("chai");
const { BigNumber, utils } = require("ethers");

function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

describe("xStarterPoolPairB WITH contract deployed token", function(){
   const uniswapRouter = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D";
   const uniswapFactory = "0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f";
   const zeroAddress = "0x0000000000000000000000000000000000000000";
   const decimals = "18";
   const anEther = 10 ** decimals;
   const startTimeLen = 60;
   const endTimeLen = 120;
   this.slow(240000)
   
  let poolPairFactory;
  let poolPair;
  let owner;
  let addr1;
  let addr2;
  let addr3;
  let addrs;

  beforeEach(async function () {
    // Get the ContractFactory and Signers here.
    if(!poolPair) {

        poolPairFactory = await ethers.getContractFactory("xStarterPoolPairB");
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
        const response = await poolPairFromOther.setUpPoolPair(
            zeroAddress,
            "xyz",
            "xyz",
            decimals,
            500000000,
            startTime,
            endTime,
        )
        await expect(response.wait()).to.be.reverted;


        // to.be.reverted not working so just make sure nothing changed
        //expect(await poolPair.isSetup()).to.equal(false);
        
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
        let response = await poolPair.connect(addr1).depositAllTokenSupply();
        await expect(response.wait()).to.be.reverted;
      })
      it('should revert because tokens automatically deposited when created by contract', async function(){
        let response = await poolPair.depositAllTokenSupply();
        await expect(response.wait()).to.be.reverted;
      })
      it('totalsupplycontrol should be equal to 500 million tokens or 500 million * 10 ** 18', async function() {
          let supply = await poolPair.totalTokensSupplyControlled()
          let addr = await poolPair.projectToken()

          expect(supply).to.be.equal(BigNumber.from('500000000000000000000000000'))
      })
  })

  describe('contributeNativeToken', function() {
      

    it('should revert because event not open', async function(){
      let response = await poolPair.connect(addr1).contributeNativeToken({value: '1000000000000000000'});
    //   console.log('response is',response)
      await expect(response.wait()).to.be.reverted;
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
        let val = await poolPair.balanceOfFunder(addr1.address);
        expect(BigNumber.from(val[0]).toString()).to.equal('1000000000000000000');
        let amtRaised = await poolPair.amountRaised()
        expect(BigNumber.from(amtRaised).toString()).to.equal('1000000000000000000');

        response = await poolPair.connect(addr2).contributeNativeToken({value: utils.parseEther('1.0')});
        await response.wait();
        val = await poolPair.balanceOfFunder(addr2.address);
        expect(BigNumber.from(val[0]).toString()).to.equal('1000000000000000000');
        amtRaised = await poolPair.amountRaised()
        expect(BigNumber.from(amtRaised).toString()).to.equal('2000000000000000000');

        response = await poolPair.connect(addr3).contributeNativeToken({value: utils.parseEther('1.0')});
        await expect(response.wait()).to.be.reverted
        val = await poolPair.balanceOfFunder(addr3.address);
        expect(BigNumber.from(val[0]).toString()).to.equal('0');

    
        

      })

      it('event should be done', async function() {
        let isDone = await poolPair.isEventDone()
        let isOpen = await poolPair.isEventOpen()
        // should be true since max raise is 2 ethers
        expect(isDone).to.equal(true);
        expect(isOpen).to.equal(false);
      })
    // it('should revert because tokens automatically deposited when created by contract', async function(){
    //   let response = await poolPair.depositAllTokenSupply();
    //   await expect(response.wait()).to.be.reverted;
    // })
    // it('totalsupplycontrol should be equal to 500 million tokens or 500 million * 10 ** 18', async function() {
    //     let supply = await poolPair.totalTokensSupplyControlled()
    //     let addr = await poolPair.projectToken()

    //     expect(supply).to.be.equal(BigNumber.from('500000000000000000000000000'))
    // })
})

})