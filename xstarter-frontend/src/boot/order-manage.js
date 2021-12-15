import { boot } from 'quasar/wrappers'
import {xStarterInteractionABI, xStarterInteractionAddr} from "src/constants";

class BaseOrderCreate {
  constructor(orderForm, preQuote, ethers, intervalsInSeconds) {
    this.orderForm = orderForm
    this.preQuote = preQuote
    this.$ethers = ethers
    this.intervalsInSeconds = intervalsInSeconds
    this.timeoutObj = null
  }

  updateOrderForm(orderForm) {
    this.orderForm = orderForm
  }
  updatePreQuote(preQuote) {
    this.preQuote = preQuote
  }

}

class BuyOrderCreate extends BaseOrderCreate {
  constructor(orderForm, preQuote, ethers, intervalsInSeconds) {
    super(orderForm, preQuote, ethers, intervalsInSeconds);
  }
  async executeOrder() {
    console.log('this is', this, typeof this);
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
