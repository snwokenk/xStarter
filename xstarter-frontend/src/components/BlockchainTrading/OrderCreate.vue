<template>
  <div
    class="display-card accountDisplayCard q-py-lg col-11 col-md-7 col-lg-5 q-gutter-y-lg"
    style="min-height: 200px;"
  >
    <div class="text-center text-bold">
      Create Order <br />
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
        <div v-if="orderForm.selectedDex" class="col-12 q-my-sm">
          <q-select v-model="orderForm.selectedInputToken" :options="inputTokenOptions" label="Select Token You'll be Using To Buy" class="full-width" />
        </div>
        <!--        <div v-if="orderForm.selectedDex" class="col-12 q-my-sm">-->
        <!--          <q-checkbox v-model="actionTypes" val="notifySound" label="Notify Me With  An Alarm" />-->
        <!--        </div>-->

        <div v-if="orderForm.selectedInputToken" class="col-12 q-my-sm">
          <q-input v-model="amountOfInputCurrency" :label="`Amount of ${orderForm.selectedInputToken.label} ${preQuote.USDEquivalent ? $ethers.utils.formatUnits(preQuote.USDEquivalent, 18) : ''}` " />
        </div>

        <div v-if="orderForm.jsonRPC" class="col-12 q-my-sm">
          <q-input v-model="orderForm.outputTokenAddr" label="Address Of token wanted" />
        </div>
        <div v-if="orderForm.useBUSD" class="col-12 q-my-sm">
          <q-checkbox v-model="orderForm.useBUSD" label="Check if this pair's liquidity is mainly BUSD" />
        </div>
      </div>

      <div v-if="preQuote.route && preQuote.quote" class="col-12 row q-my-xl">
        <div class="col-12">
          {{ amountOfInputCurrency }} {{ orderForm.selectedInputToken.label}}
        </div>
        <div class="col-12">
          USD Equivalent: {{ parseFloat($ethers.utils.formatUnits(preQuote.USDEquivalent, 18)).toFixed(4) }}
        </div>

        <div class="col-12">
          FOR
        </div>

        <div class="col-12">
          {{ parseFloat($ethers.utils.formatUnits(preQuote.quote, 18)).toFixed(4) }} {{ preQuote.desiredTokenSymbol }} ({{ preQuote.desiredTokenName }})
        </div>
        <div class="col-12">
          price In BNB :  {{ priceInBNB }} <br />
          price In USD: {{ priceInUSD }}
        </div>
      </div>

      <div class="row" v-if="preQuote.route">
        <div class="col-lg-9 col-12  q-my-sm">
          <q-input v-model="orderForm.maxPriceInUSD" label="Max price in USD Per Token(leave at 0 to ignore)" />
        </div>
        <div class="col-12 q-mt-sm">
          <q-btn label="Try to Execute Once" @click="executeDexOrder" outline />
        </div>
        <div class="col-12 q-mt-sm">
          <q-btn  label="Try Until Sucessfull" @click="executeBuyTillSuccessFul" outline />
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
  'function symbol() view returns (string)'
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
  name: "OrderCreate",
  data() {
    return {
      actionTypes: [],
      priK: '',
      walletBalance: '',
      amountOfInputCurrency: 0,
      orderForm: {
        jsonRPC:'',
        blockchain: null,
        selectedDex: null,
        getWallet: null,
        getDex: null,
        getLocalProvider: null,
        amountOfInputCurrency: 0,  // amount of currency you're trying to swap ie 1 bnb, 100 busb,
        selectedInputToken: {
          label: 'BNB',
          value: '0xbb4cdb9cbd36b01bd1cbaebf2de08d9173bc095c',
          isNativeToken: true
        },
        outputTokenAddr: '',
        // this is the base currency of the pair ie some crypto might have a higher BUSD/outputTokenAddr liquidity than BNB
        useBUSD: false,
        // this is actual order details
        maxPriceInUSD: 0,
        minimumTokensBasedOnPrice: 0,
        minimumTokensWeiBasedOnPrice: ethers.BigNumber.from(0),
        retryAmount: 0

      },
      preQuote: {
        route:  null,
        quote: 0,
        USDEquivalent: 0,
        desiredTokenSymbol: '',
        desiredTokenName: '',
        desiredTokenDecimals: 0,
        currentBal: 0
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
      if (!this.orderForm.outputTokenAddr) { return null }
      const overrides = {
        value: this.orderForm.amountOfInputCurrency,
        gasPrice: this.$ethers.utils.parseUnits('10', 'gwei')
      }
      const xStarterInteract = new this.$ethers.Contract(xStarterInteractionAddr, xStarterInteractionABI, this.orderForm.getWallet())
      const response = await xStarterInteract.swapETHForTokensUsingDataFromBlockchain(
        this.orderForm.outputTokenAddr,
        this.orderForm.minimumTokensWeiBasedOnPrice,
        overrides // overrides must be last

      )
      console.log("response is", response)
      return response

    },

    async executeBuyTillSuccessFul() {
      // // first try to execute order
      // const response = await this.executeDexOrder()
      // // if response is not null then order was executed
      // if (response) { return response }
      const orderInst = new this.$order_manaage.BuyOrderCreate(this.orderForm, this.preQuote, this.$ethers, CHAIN_INFO_OBJ[this.orderForm.blockchain.value].avgBlockTime)
      orderInst.executeUntilSuccess()
      this.$emit('saveOrder', {name: 'buyOrders', orderInst})





    },
    async getQuoteWithSymbol() {
      if (!this.orderForm.amountOfInputCurrency || !this.orderForm.outputTokenAddr) { return }
      const xStarterInteract = new this.$ethers.Contract(xStarterInteractionAddr, xStarterInteractionABI, this.orderForm.getWallet())
      // todo: We assume that the native token is being used, and a representation of USD (ie BUSD on binance, USDT on ETHERS) is used as otherToken
      // todo: make it automatically sort if BUSD (or rep) is chosen as input
      console.log('eth amount', this.orderForm.amountOfInputCurrency, this.orderForm.amountOfInputCurrency.toString())
      try {
        const response = await xStarterInteract.getBestQuoteAndSymbolUsingWETH(this.orderForm.amountOfInputCurrency, this.orderForm.outputTokenAddr, this.orderForm.getWallet().address)
        console.log('response in try is', response)
        this.preQuote.quote = response.quote
        this.preQuote.route = response.route
        this.preQuote.USDEquivalent = response.USDEquivAmount
        this.preQuote.desiredTokenSymbol = response.outTokenInfo.symbol
        this.preQuote.desiredTokenName = response.outTokenInfo.name
        this.preQuote.desiredTokenDecimals = response.outTokenInfo.decimals
        this.preQuote.currentBal = response.outTokenInfo.addrBalance

        this.calculateMinTokens()
      } catch (e) {
        //todo add a view function that is called when no pairs are available
        console.log('error', e, typeof e)
        //todo add a view function that is called when no pairs are available
        const response = await xStarterInteract.getTokenInfoAndUSDEquivalent(this.orderForm.amountOfInputCurrency, this.orderForm.outputTokenAddr, this.orderForm.getWallet().address)
        console.log('response in is', response)
        this.preQuote.quote = 0
        this.preQuote.route = null
        this.preQuote.USDEquivalent = response.USDEquivAmount
        this.preQuote.desiredTokenSymbol = response.outTokenInfo.symbol
        this.preQuote.desiredTokenName = response.outTokenInfo.name
        this.preQuote.desiredTokenDecimals = response.outTokenInfo.decimals
        this.preQuote.currentBal = response.outTokenInfo.addrBalance
        this.calculateMinTokens()
      }

    },
    calculateMinTokens() {
      if (!this.orderForm.maxPriceInUSD || !parseFloat(this.orderForm.maxPriceInUSD) || !this.preQuote.USDEquivalent) { return }

      this.orderForm.minimumTokensBasedOnPrice = parseFloat(this.$ethers.utils.formatUnits(this.preQuote.USDEquivalent, 18)) / parseFloat(this.orderForm.maxPriceInUSD)
      this.orderForm.minimumTokensWeiBasedOnPrice = this.$ethers.utils.parseUnits(this.orderForm.minimumTokensBasedOnPrice.toString(), this.preQuote.desiredTokenDecimals)
    }
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
    amountOfInputCurrency: function (val, oldVal) {
      console.log('val is', val, typeof val)
      if (!val) { return }
      this.orderForm.amountOfInputCurrency = this.$ethers.utils.parseEther(val.toString())
      this.getQuoteWithSymbol()
    },
    'orderForm.outputTokenAddr': async function (val, oldVal) {
      await this.getQuoteWithSymbol()
    },
    'orderForm.amountOfInputCurrency': function (val, oldVal) {
      if (!this.orderForm.outputTokenAddr) { return }
    },

    'orderForm.maxPriceInUSD': function (val, oldVal) {
      this.calculateMinTokens()

    }
  }
}
</script>

<style scoped>

</style>
