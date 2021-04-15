const { expect } = require("chai");
const { BigNumber } = require("ethers");


describe("xStarterPoolPairB WITH contract deployed token", function(){
   const uniswapRouter = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D";
   const uniswapFactory = "0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f";
   const zeroAddress = "0x0000000000000000000000000000000000000000";
   const decimals = "18"
   const anEther = 10 ** decimals
   
  let poolPairFactory;
  let poolPair;
  let owner;
  let addr1;
  let addr2;
  let addrs;

  beforeEach(async function () {
    // Get the ContractFactory and Signers here.
    poolPairFactory = await ethers.getContractFactory("xStarterPoolPairB");
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();

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

    // let startTime = (parseInt(Date.now() / 1000) + 120).toString();
    // let endTime = (parseInt(Date.now() / 1000) + 240).toString;
    // await poolPair.setUpPoolPair(
    //     zeroAddress,
    //     "xyz",
    //     "xyz",
    //     decimals,
    //     "500000000",
    //     startTime,
    //     endTime,
    // )
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
    it("Should Revert If Called By Non Admin", async function () {
      // Expect receives a value, and wraps it in an Assertion object. These
      // objects have a lot of utility methods to assert values.
        
        let startTime = parseInt(Date.now() / 1000) + 120;
        let endTime = parseInt(Date.now() / 1000) + 240;
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

    it("Should be setup", async function () {
        // Expect receives a value, and wraps it in an Assertion object. These
        // objects have a lot of utility methods to assert values.
          
        let startTime = (parseInt(Date.now() / 1000) + 120);
        let endTime = (parseInt(Date.now() / 1000) + 240);
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

        console.log('addr', addr);
        let supply = await poolPair.totalTokensSupplyControlled();
        console.log('supply1', BigNumber.from(supply).toString());
        expect(await poolPair.projectToken()).to.not.equal(zeroAddress);
        expect(await poolPair.isSetup()).to.equal(true);
        expect(await poolPair.startTime()).to.equal(startTime);
        expect(await poolPair.endTime()).to.equal(endTime);

          
      });

    // If the callback function is async, Mocha will `await` it.
    // it("Should set the right router and factory address", async function () {
    //     // Expect receives a value, and wraps it in an Assertion object. These
    //     // objects have a lot of utility methods to assert values.
  
    //     // This test expects the Admin variable stored in the contract to be equal
    //     // to our Signer's owner.
    //     expect(await poolPair.addressOfDex()).to.equal(uniswapRouter);
    //     expect(await poolPair.addressOfDexFactory()).to.equal(uniswapFactory);
    //   });

  });
  describe('depositAllToken', function() {
      it('should revert because all tokens automatically depositied', async function(){
        let response = await poolPair.depositAllTokenSupply();
        await expect(response.wait()).to.be.reverted
      })

      it('should revert because only admin can call', async function(){
        let response = await poolPair.connect(addr1).depositAllTokenSupply();
        await expect(response.wait()).to.be.reverted
      })
      it('totalsupplycontrol should be greater than 0', async function() {
          let supply = await poolPair.totalTokensSupplyControlled()
          let addr = await poolPair.projectToken()

          console.log('supply2 is', BigNumber.from(supply));
          console.log('addr2', addr);
          expect(supply).to.be.gt(0)
      })
  })

})