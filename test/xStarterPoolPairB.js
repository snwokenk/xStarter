const { expect } = require("chai");

describe("xStarterPoolPairB Contract", function(){
   let uniswapRouter = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D";
   let uniswapFactory = "0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f";
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
        "2000000000000000000", "0x0000000000000000000000000000000000000000",
        uniswapRouter, uniswapFactory
    );
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
      console.log('owner address is', owner.address)
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

    // it("Should assign the total supply of tokens to the owner", async function () {
    //   const ownerBalance = await hardhatToken.balanceOf(owner.address);
    //   expect(await hardhatToken.totalSupply()).to.equal(ownerBalance);
    // });
  });

})