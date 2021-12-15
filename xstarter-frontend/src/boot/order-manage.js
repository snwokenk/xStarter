import { boot } from 'quasar/wrappers'
import {xStarterInteractionABI, xStarterInteractionAddr} from "src/constants";

// todo: on polling orders, have a way to notify
class BaseOrderCreate {
  constructor(orderForm, preQuote, ethers, intervalsInSeconds) {
    this.orderForm = orderForm
    this.preQuote = preQuote
    this.$ethers = ethers
    this.intervalsInSeconds = intervalsInSeconds
    this.timeoutObj = null
    this.orderType = ''
    this.isSuccess = false
    this.isCancelled = false
    this.preQuoteUpdated = ''
  }

  get orderInfo() {
    return {
      tokenAddress: this.orderForm.outputTokenAddr,
      chain: this.orderForm.blockchain.label,
      chainId: this.orderForm.blockchain.value,
      dex: this.orderForm.selectedDex.label,
      walletAddress: this.orderForm.getWallet().address,
      orderType: this.orderType,
      WETH_Amount: this.$ethers.utils.formatEther(this.orderForm.amountOfInputCurrency),
      tokenAmount: this.orderForm.minimumTokensWeiBasedOnPrice.toString(),
      preQuoteUpdated: this.preQuoteUpdated

    }
  }
  updateOrderForm(orderForm) {
    this.orderForm = orderForm
  }
  updatePreQuote(preQuote) {
    this.preQuote = preQuote
  }
  cancel() {
    this.isCancelled = true
  }
  calculateMinTokens() {
    if (!this.orderForm.maxPriceInUSD || !parseFloat(this.orderForm.maxPriceInUSD) || !this.preQuote.USDEquivalent) { return }

    this.orderForm.minimumTokensBasedOnPrice = parseFloat(this.$ethers.utils.formatUnits(this.preQuote.USDEquivalent, 18)) / parseFloat(this.orderForm.maxPriceInUSD)
    this.orderForm.minimumTokensWeiBasedOnPrice = this.$ethers.utils.parseUnits(this.orderForm.minimumTokensBasedOnPrice.toString(), this.preQuote.desiredTokenDecimals)
  }

  async getPreQuote() {
    const xStarterInteract = new this.$ethers.Contract(xStarterInteractionAddr, xStarterInteractionABI, this.orderForm.getWallet())
    try {
      const response = await xStarterInteract.getBestQuoteAndSymbolUsingWETH(this.orderForm.amountOfInputCurrency, this.orderForm.outputTokenAddr, this.orderForm.getWallet().address)
      // console.log('response is', response)
      this.preQuote.quote = response.quote
      this.preQuote.route = response.route
      this.preQuote.USDEquivalent = response.USDEquivAmount
      this.preQuote.desiredTokenSymbol = response.outTokenInfo.symbol
      this.preQuote.desiredTokenName = response.outTokenInfo.name
      this.preQuote.desiredTokenDecimals = response.outTokenInfo.decimals
      this.preQuote.currentBal = response.outTokenInfo.addrBalance

      this.calculateMinTokens()
    } catch (e) {
      console.log(e, typeof e)
      //todo add a view function that is called when no pairs are available
      const response = await xStarterInteract.getTokenInfoAndUSDEquivalent(this.orderForm.amountOfInputCurrency, this.orderForm.outputTokenAddr, this.orderForm.getWallet().address)
      // console.log('response is', response)
      this.preQuote.quote = 0
      this.preQuote.route = null
      this.preQuote.USDEquivalent = response.USDEquivAmount
      this.preQuote.desiredTokenSymbol = response.outTokenInfo.symbol
      this.preQuote.desiredTokenName = response.outTokenInfo.name
      this.preQuote.desiredTokenDecimals = response.outTokenInfo.decimals
      this.preQuote.currentBal = response.outTokenInfo.addrBalance
    }

    this.preQuoteUpdated = Date()
  }

}

class BuyOrderCreate extends BaseOrderCreate {
  constructor(orderForm, preQuote, ethers, intervalsInSeconds) {
    super(orderForm, preQuote, ethers, intervalsInSeconds);
    this.orderType = 'buy'
  }
  async executeOrder() {
    if (this.isCancelled || this.isSuccess ) { return }
    if (!this.orderForm.outputTokenAddr) { return null }
    await this.getPreQuote()
    const overrides = {
      value: this.orderForm.amountOfInputCurrency,
      gasPrice: this.$ethers.utils.parseUnits('10', 'gwei')
    }
    const xStarterInteract = new this.$ethers.Contract(xStarterInteractionAddr, xStarterInteractionABI, this.orderForm.getWallet())

    try {
      const response = await xStarterInteract.swapETHForTokensUsingDataFromBlockchain(
        this.orderForm.outputTokenAddr,
        this.orderForm.minimumTokensWeiBasedOnPrice,
        overrides // overrides must be last

      )
      console.log("response is", response)
      this.isSuccess = true
      return response
    }catch (e) {
      console.log('error occurred', e)
      this.timeoutObj = setTimeout(this.executeOrder.bind(this), this.intervalsInSeconds)

    }

  }

  executeUntilSuccess() {
    console.log('in execute success', this, this.intervalsInSeconds)
    this.timeoutObj = setTimeout(this.executeOrder.bind(this), this.intervalsInSeconds)
  }

  stopIntervalCall() {
    if (this.timeoutObj) {
      clearTimeout(this.timeoutObj)
    }
  }
}

class SellOrderCreate extends BaseOrderCreate {
  constructor(orderForm, preQuote, ethers, intervalsInSeconds) {
    super(orderForm, preQuote, ethers, intervalsInSeconds);
    this.orderType = 'sell'
  }
  executeOrder() {
    // super.executeOrder();
  }
}


const order_manage = {
  BuyOrderCreate,
  SellOrderCreate
}

export default boot(({ app }) => {
  // for use inside Vue files (Options API) through this.$ethers

  app.config.globalProperties.$order_manaage = order_manage

})

export { order_manage }
