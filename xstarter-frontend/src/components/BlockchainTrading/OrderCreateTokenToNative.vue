<template>
  <div
    class="display-card accountDisplayCard q-py-lg col-11 col-md-7 col-lg-5 q-gutter-y-lg"
    style="min-height: 200px;"
  >
    <div class="text-center text-bold">
      Create Order Sell tokens for native token (ETH, BNB, MATIC etc) <br /><br />
      ***This uses an xStarter deployed contract to route your traders***
      *** It does a precheck and reduces the possibility of tx being reverted while your gas is spent.
      *** also allows you to add a large slippage without been sniped
    </div>
    <div class="row q-px-xl">
      <div class="row col-12 q-pa-sm">
        <div v-if="orderForm.getWallet" class="col-12">
          {{ orderForm.getWallet ? orderForm.getWallet().address: '' }} - {{ walletBalance ? $helper.weiBigNumberToFloatEther(walletBalance).toString() : '' }}
        </div>

        <div class="col-12 q-my-sm">
          <q-select v-model="orderForm.blockchain" :options="arrayOfBlockChains"  label="Select Blockchain" />
        </div>
        <div v-if="orderForm.blockchain" class="col-12 q-my-sm">
          <q-input v-model="orderForm.jsonRPC" label="please provide a third part json rpc url (getblock, alchemy etc) to use." />
        </div>
        <div v-if="!orderForm.wallet && orderForm.jsonRPC" class="col-12 q-my-sm">
          <q-input v-model="priK" label="Enter Private Key Of A Wallet Address (Not mnenomic, this is stored only for this session)" />
        </div>
        <div v-if="arrayOfAvailableDex && orderForm.getWallet" class="col-12 q-my-sm">
          <q-select v-model="orderForm.selectedDex" :options="arrayOfAvailableDex" label="Select DEX" class="full-width"/>
        </div>
        <div   v-if="orderForm.selectedDex" class="col-12 q-my-sm">
          <q-input v-model="orderForm.outputTokenAddr" label="Address Of token to sell" />
        </div>

        <div  v-if="orderForm.selectedDex && orderForm.outputTokenAddr" class="col-12 q-my-sm">
          <div  v-if="!preQuote.currentBal" >
            You Have No Balance (You can still continue with the order and have it run until successful)<br/>
            This is useful if you anticipate buying this token and would like to have a script running that will sell at a given price
          </div>
          <q-input v-model="orderForm.percentToSell" label="percent of token balance to sell (ie for 50% enter 50" />
        </div>

        <div v-if="orderForm.outputTokenAddr && orderForm.percentToSell" class="col-12 q-my-sm">
          <q-input v-model="orderForm.minPriceInUSD" label="Set Desired Price in US Dollars to get minimum native tokens" @update:model-value="getMinNativeTokensBasedOnDesiredPrice" debounce="1000" />
        </div>

        <div v-if="orderForm.jsonRPC" class="col-12 q-my-sm">
          <q-input v-model="orderForm.minimumNativeTokensBasedOnPrice" label="Manually Adjust minimum native tokens wanted(ie BNB, ETH, MATIC etc)" />
        </div>
      </div>

<!--      <div v-if="preQuote.route && preQuote.quote" class="col-12 row q-my-xl">-->
<!--        <div class="col-12">-->
<!--          {{ amountOfInputCurrency }} {{ orderForm.selectedInputToken.label}}-->
<!--        </div>-->
<!--        <div class="col-12">-->
<!--          USD Equivalent: {{ parseFloat($ethers.utils.formatUnits(preQuote.USDEquivalent, 18)).toFixed(4) }}-->
<!--        </div>-->

<!--        <div class="col-12">-->
<!--          FOR-->
<!--        </div>-->

<!--        <div class="col-12">-->
<!--          {{ parseFloat($ethers.utils.formatUnits(preQuote.quote, 18)).toFixed(4) }} {{ preQuote.desiredTokenSymbol }} ({{ preQuote.desiredTokenName }})-->
<!--        </div>-->
<!--        <div class="col-12">-->
<!--          price In BNB :  {{ priceInBNB }} <br />-->
<!--          price In USD: {{ priceInUSD }}-->
<!--        </div>-->
<!--      </div>-->

      <div class="row" v-if="orderForm.outputTokenAddr">
        <div class="col-12 q-mt-sm">
          <q-btn label="Try to Execute Once" @click="executeDexOrder" outline />
        </div>
        <div class="col-12 q-mt-sm">
          <q-btn  label="Try Until Sucessfull" @click="executeSellTillSuccessFul" outline />
        </div>
      </div>




    </div>
  </div>
</template>

<script>
const ERC20ABI = [
  'function balanceOf(address owner) view returns (uint256 balance)',
  'function totalSupply() view returns (uint)',
  'function name() view  returns (string)',
  'function symbol() view returns (string)',
  'function decimals() view returns (uint8)',
  'function allowance(address owner, address spender) view returns (uint)',
  'function approve(address spender, uint value) returns (bool)'
]
// todo: create sell order, currently only buy order
import {
  ARRAY_OF_BLOCKCHAINS,
  BLOCKCHAIN_TO_DEX,
  CHAIN_INFO_OBJ,
  MAJOR_TOKEN_ADDR_ARRAY,
  xStarterInteractionABI, xStarterInteractionAddr
} from "src/constants";
import {ethers} from "boot/ethers";

export default {
  name: "OrderCreateTokenToNative",
  data() {
    return {
      actionTypes: [],
      priK: '',
      walletBalance: '',
      amountOfInputCurrency: 0,
      currentBal: 0,
      nativeTokenUSDPrice: null,
      orderForm: {
        jsonRPC:'',
        blockchain: null,
        selectedDex: null,
        getWallet: null,
        getDex: null,
        percentToSell:50,
        getLocalProvider: null,
        outputTokenAddr: '',
        // this is actual order details
        maxPriceInUSD: 0,
        minPriceInUSD: 0,
        minimumNativeTokensBasedOnPrice: 0,
        minimumNativeTokensWeiBasedOnPrice: ethers.BigNumber.from(0),
        retryAmount: 0

      },
      preQuote: {
        route:  null,
        quote: 0,
        USDEquivalent: 0,
        desiredTokenSymbol: '',
        desiredTokenName: '',
        desiredTokenDecimals: 0,
        currentBal: 0,
        currentAllowance: 0
      }
    }
  },
  computed: {
    priceInBNB() {
      if (!this.preQuote.quote || !this.orderForm.amountOfInputCurrency) { return 0}

      const bnbAmt = parseFloat(this.$ethers.utils.formatUnits(this.orderForm.amountOfInputCurrency, 18))
      const tokenAmt = parseFloat(this.$ethers.utils.formatUnits(this.preQuote.quote, 18))

      return (bnbAmt/tokenAmt).toFixed(18)
    },
    priceInUSD() {
      if (!this.preQuote.quote || !this.orderForm.amountOfInputCurrency) { return 0}

      const usdAmt =  parseFloat(this.$ethers.utils.formatUnits(this.preQuote.USDEquivalent, 18))
      const tokenAmt = parseFloat(this.$ethers.utils.formatUnits(this.preQuote.quote, 18))

      return (usdAmt/tokenAmt).toFixed(18)
    },
    inputTokenOptions() {
      return [...MAJOR_TOKEN_ADDR_ARRAY]
    },

    arrayOfAvailableDex() {
      if (this.orderForm.blockchain) {
        return BLOCKCHAIN_TO_DEX[this.orderForm.blockchain.value]
      }
      return null
    },
    arrayOfBlockChains() {
      return [...ARRAY_OF_BLOCKCHAINS]
    },
  },
  methods: {
    async getWalletBalance() {
      if (!this.orderForm.getWallet) { return}
      this.walletBalance = await this.orderForm.getWallet().getBalance()
    },
    async getQuote() {
      if (!this.orderForm.getDex) { return null }
      const bnbPath = [this.inputTokenOptions.find(obj => obj.isNativeToken), this.orderForm.outputTokenAddr]
      this.orderForm.getDex().getAmountsOut(this.orderForm.amountOfInputCurrency, )

    },

    async executeDexOrder() {
      if (!this.orderForm.outputTokenAddr || !this.orderForm.minimumNativeTokensWeiBasedOnPrice) { return null }
      const overrides = {
        gasPrice: this.$ethers.utils.parseUnits('10', 'gwei')
      }
      await this.getAllowance()

      if (!this.preQuote.currentAllowance || this.preQuote.currentAllowance < this.preQuote.currentBal) {
        await this.approveAmounts()
        if (!this.preQuote.currentAllowance) {
          console.log('allowance still at zero, probably wallet address has 0 tokens')
          return
        }
      // if allowance is not zero, then must have token balance
        await this.getMinNativeTokensBasedOnDesiredPrice()

      }
      await this.getMinNativeTokensBasedOnDesiredPrice
      const xStarterInteract = new this.$ethers.Contract(xStarterInteractionAddr, xStarterInteractionABI, this.orderForm.getWallet())
      const response = await xStarterInteract.swapPercentOfApprovedBalance(
        this.orderForm.outputTokenAddr,
        this.orderForm.percentToSell,
        this.orderForm.minimumNativeTokensWeiBasedOnPrice,
        overrides // overrides must be last

      )
      console.log("response is", response)
      return response

    },

    async executeSellTillSuccessFul() {
      // // first try to execute order
      // const response = await this.executeDexOrder()
      // // if response is not null then order was executed
      // if (response) { return response }
      const orderInst = new this.$order_manaage.BuyOrderCreate(this.orderForm, this.preQuote, this.$ethers, CHAIN_INFO_OBJ[this.orderForm.blockchain.value].avgBlockTime)
      orderInst.executeUntilSuccess()
      this.$emit('saveOrder', {name: 'buyOrders', orderInst})





    },

    async approveAmounts() {
      const tokenInst = new this.$ethers.Contract(this.orderForm.outputTokenAddr, ERC20ABI, this.orderForm.getWallet())
      if (!this.preQuote.currentBal) {
        await this.getTokenBalance()
      }
      if (!this.preQuote.currentBal) { return }
      const response = await tokenInst.approve(xStarterInteractionAddr, this.$ethers.utils.parseEther(this.preQuote.currentBal.toString()))
      console.log('in approve response is', response)
      await this.getAllowance()
    },
    async getTokenBalance() {
      console.log('getting token balance1')
      if (!this.orderForm.outputTokenAddr || !this.orderForm.getWallet) { return }
      console.log('getting token balance 2')
      const tokenInst = new this.$ethers.Contract(this.orderForm.outputTokenAddr, ERC20ABI, this.orderForm.getWallet())
      console.log('tokeninst', tokenInst)
      const response = await tokenInst.balanceOf(this.orderForm.getWallet().address)

      const response2 = !this.preQuote.desiredTokenDecimals ?  await tokenInst.decimals() : this.preQuote.desiredTokenDecimals
      console.log('response',response)
      this.preQuote.desiredTokenDecimals = response2
      this.preQuote.currentBal = parseFloat(this.$ethers.utils.formatUnits(response, this.preQuote.desiredTokenDecimals))

      return this.preQuote.currentBal
    },
    async getAllowance() {
      console.log('getting token balance1')
      if (!this.orderForm.outputTokenAddr || !this.orderForm.getWallet) { return }
      console.log('getting token balance 2')
      const tokenInst = new this.$ethers.Contract(this.orderForm.outputTokenAddr, ERC20ABI, this.orderForm.getWallet())
      console.log('tokeninst', tokenInst)
      const response = await tokenInst.allowance(this.orderForm.getWallet().address, xStarterInteractionAddr)
      console.log('response',response)
      const response2 = !this.preQuote.desiredTokenDecimals ?  await tokenInst.decimals() : this.preQuote.desiredTokenDecimalsconst
      console.log('response2',response2)
      this.preQuote.desiredTokenDecimals = response2
      this.preQuote.currentAllowance = parseFloat(this.$ethers.utils.formatUnits(response, this.preQuote.desiredTokenDecimals))

      return this.preQuote.currentAllowance
    },
    async getMinNativeTokensBasedOnDesiredPrice() {
      if (!this.orderForm.minPriceInUSD || !parseFloat(this.orderForm.minPriceInUSD) || !this.orderForm.outputTokenAddr) { return }
      const xStarterInteract = new this.$ethers.Contract(xStarterInteractionAddr, xStarterInteractionABI, this.orderForm.getWallet())
      // try {
        // get rate for 1 native token
        const response = await xStarterInteract.getUSDAmountOfWETH(this.$ethers.utils.parseEther('1.0'))
      console.log('response', response)
        const nativeTokenPrice = parseFloat(this.$ethers.utils.formatEther(response))
      console.log('nativetoken', nativeTokenPrice)
        const tokensToSell = (this.preQuote.currentBal *  this.orderForm.percentToSell) / 100
      console.log('tokens to sell', tokensToSell)
        const usdEquivalent = tokensToSell * parseFloat(this.orderForm.minPriceInUSD)
      console.log('usd equiv', usdEquivalent)
        this.orderForm.minimumNativeTokensBasedOnPrice  = usdEquivalent / nativeTokenPrice
      console.log('usd / native', usdEquivalent / nativeTokenPrice)
        this.orderForm.minimumNativeTokensWeiBasedOnPrice = this.$ethers.utils.parseEther(this.orderForm.minimumNativeTokensBasedOnPrice.toString())

      // }catch (e) {
      //   console.log('error', e)
      // }
    },
    // async getQuoteWithSymbol() {
    //   if (!this.orderForm.amountOfInputCurrency || !this.orderForm.outputTokenAddr) { return }
    //   const xStarterInteract = new this.$ethers.Contract(xStarterInteractionAddr, xStarterInteractionABI, this.orderForm.getWallet())
    //   // todo: We assume that the native token is being used, and a representation of USD (ie BUSD on binance, USDT on ETHERS) is used as otherToken
    //   // todo: make it automatically sort if BUSD (or rep) is chosen as input
    //   console.log('eth amount', this.orderForm.amountOfInputCurrency, this.orderForm.amountOfInputCurrency.toString())
    //   try {
    //     const response = await xStarterInteract.getBestQuoteAndSymbolUsingWETH(this.orderForm.amountOfInputCurrency, this.orderForm.outputTokenAddr, this.orderForm.getWallet().address)
    //     console.log('response in try is', response)
    //     this.preQuote.quote = response.quote
    //     this.preQuote.route = response.route
    //     this.preQuote.USDEquivalent = response.USDEquivAmount
    //     this.preQuote.desiredTokenSymbol = response.outTokenInfo.symbol
    //     this.preQuote.desiredTokenName = response.outTokenInfo.name
    //     this.preQuote.desiredTokenDecimals = response.outTokenInfo.decimals
    //     this.preQuote.currentBal = response.outTokenInfo.addrBalance
    //
    //     this.calculateMinTokens()
    //   } catch (e) {
    //     //todo add a view function that is called when no pairs are available
    //     console.log('error', e, typeof e)
    //     //todo add a view function that is called when no pairs are available
    //     const response = await xStarterInteract.getTokenInfoAndUSDEquivalent(this.orderForm.amountOfInputCurrency, this.orderForm.outputTokenAddr, this.orderForm.getWallet().address)
    //     console.log('response in is', response)
    //     this.preQuote.quote = 0
    //     this.preQuote.route = null
    //     this.preQuote.USDEquivalent = response.USDEquivAmount
    //     this.preQuote.desiredTokenSymbol = response.outTokenInfo.symbol
    //     this.preQuote.desiredTokenName = response.outTokenInfo.name
    //     this.preQuote.desiredTokenDecimals = response.outTokenInfo.decimals
    //     this.preQuote.currentBal = response.outTokenInfo.addrBalance
    //     this.calculateMinTokens()
    //   }
    //
    // },
    // calculateMinTokens() {
    //   if (!this.orderForm.minPriceInUSD || !parseFloat(this.orderForm.minPriceInUSD) || !this.preQuote.USDEquivalent) { return }
    //
    //   this.orderForm.minimumTokensBasedOnPrice = parseFloat(this.$ethers.utils.formatUnits(this.preQuote.USDEquivalent, 18)) / parseFloat(this.orderForm.maxPriceInUSD)
    //   this.orderForm.minimumTokensWeiBasedOnPrice = this.$ethers.utils.parseUnits(this.orderForm.minimumTokensBasedOnPrice.toString(), this.preQuote.desiredTokenDecimals)
    // }
  },
  watch:{
    priK: function (val, oldVal) {
      if (!val || !this.orderForm.jsonRPC || this.orderForm.getWallet) { return }
      // const blockchainDetails = CHAIN_INFO_OBJ[this.orderForm.blockchain.value]
      const localProvider =  new ethers.providers.JsonRpcProvider(this.orderForm.jsonRPC);
      this.orderForm.getLocalProvider = () => {
        return localProvider
      }
      // const bt = blockchainDetails.avgBlockTime
      // const blockChainTime = bt && bt < 5000  ?  blockchainDetails.avgBlockTime: 5000
      // localProvider.pollingInterval = blockChainTime / 2
      const wallet = new this.$ethers.Wallet(val, this.orderForm.getLocalProvider())
      this.orderForm.getWallet = () => {
        return wallet
      }
      this.getWalletBalance()
    },
    'orderForm.selectedDex': function (val, oldVal) {
      if (!val || !this.orderForm.getWallet || !this.orderForm.getLocalProvider) {return }

      const dex = new this.$ethers.Contract(val.routerAddress, val.routerABI, this.orderForm.getLocalProvider())
      this.orderForm.getDex = () => {
        return dex
      }
    },
    'orderForm.outputTokenAddr': async function (val, oldVal) {
      await this.getTokenBalance()
    },
    'orderForm.amountOfInputCurrency': function (val, oldVal) {
      if (!this.orderForm.outputTokenAddr) { return }
    },

    // 'orderForm.minPriceInUSD': function (val, oldVal) {
    //   this.getMinNativeTokensBasedOnDesiredPrice()
    //
    // }
  }
}
</script>

<style scoped>

</style>
