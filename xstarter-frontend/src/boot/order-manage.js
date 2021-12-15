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
      tokenAmount: this.orderForm.minimumTokensWeiBasedOnPrice.toString()

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

}

class BuyOrderCreate extends BaseOrderCreate {
  constructor(orderForm, preQuote, ethers, intervalsInSeconds) {
    super(orderForm, preQuote, ethers, intervalsInSeconds);
    this.orderType = 'buy'
  }
  async executeOrder() {
    if (this.isCancelled || this.isSuccess ) { return }
    if (!this.orderForm.outputTokenAddr) { return null }
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
