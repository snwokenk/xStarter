<template>
  <div
    class="display-card accountDisplayCard q-py-lg col-11 col-md-7 col-lg-5 q-gutter-y-lg"
    style="min-height: 200px;"
  >
    <div class="text-center text-bold">
      What Action(s) Should Happen On A Trigger
    </div>
    <div class="row q-px-xl">
      <div class="col-6 col-lg-4">
        <q-checkbox v-model="actionTypes" val="notifySound" label="Notify Me With  An Alarm" />
      </div>
      <div class="col-6 col-lg-4">
        <q-checkbox v-model="actionTypes" val="swapToken" label="Swap Token And Set Max Price" />
      </div>
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
          Swapping: {{ amountOfInputCurrency }} {{ orderForm.selectedInputToken.label}}
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


      <div class="col-12 q-mt-sm">
        <q-btn :disable="!actionTypes.length" label="Start Listening For Triggers" @click="this.$emit('startListening', actionTypes)" outline />
      </div>

    </div>
  </div>
</template>

<script>
import {
  ARRAY_OF_BLOCKCHAINS,
  BLOCKCHAIN_TO_DEX,
  CHAIN_INFO_OBJ,
  MAJOR_TOKEN_ADDR_ARRAY,
  xStarterInteractionABI, xStarterInteractionAddr
} from "src/constants";
import {ethers} from "boot/ethers";

export default {
  name: "ActionBox",
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
        maxPriceInUSD: 0,

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

    async getQuoteWithSymbol() {
      if (!this.orderForm.amountOfInputCurrency || !this.orderForm.outputTokenAddr) { return }
      const xStarterInteract = new this.$ethers.Contract(xStarterInteractionAddr, xStarterInteractionABI, this.orderForm.getWallet())
      // todo: We assume that the native token is being used, and a representation of USD (ie BUSD on binance, USDT on ETHERS) is used as otherToken
      // todo: make it automatically sort if BUSD (or rep) is chosen as input
      const response = await xStarterInteract.getBestQuoteAndSymbolUsingWETH(this.orderForm.amountOfInputCurrency, "0x0d0621ad4ec89da1cf0f371d6205229f04bcb378", this.orderForm.getWallet().address)
      // console.log('response is', response)
      this.preQuote.quote = response.quote
      this.preQuote.route = response.route
      this.preQuote.USDEquivalent = response.USDEquivAmount
      this.preQuote.desiredTokenSymbol = response.outTokenInfo.symbol
      this.preQuote.desiredTokenName = response.outTokenInfo.name
      this.preQuote.desiredTokenDecimals = response.outTokenInfo.decimals
      this.preQuote.currentBal = response.outTokenInfo.addrBalance
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


    }
  }
}
</script>

<style scoped>

</style>
