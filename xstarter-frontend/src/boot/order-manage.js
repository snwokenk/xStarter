import { boot } from 'quasar/wrappers'
import {xStarterInteractionABI, xStarterInteractionAddr} from "src/constants";


const ERC20ABI = [
  'function balanceOf(address owner) view returns (uint256 balance)',
  'function totalSupply() view returns (uint)',
  'function name() view  returns (string)',
  'function symbol() view returns (string)',
  'function decimals() view returns (uint8)',
  'function allowance(address owner, address spender) view returns (uint)',
  'function approve(address spender, uint value) returns (bool)'
]

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
      maxPriceInUsd: this.orderForm.maxPriceInUSD,
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
  }
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
  }
  async approveAmounts() {
    const tokenInst = new this.$ethers.Contract(this.orderForm.outputTokenAddr, ERC20ABI, this.orderForm.getWallet())
    if (!this.preQuote.currentBal) {
      await this.getTokenBalance()
    }
    if (!this.preQuote.currentBal) { return }
    const response = await tokenInst.approve(xStarterInteractionAddr, this.$ethers.utils.parseEther(this.preQuote.currentBal.toString()))
    console.log('in approve response is', response)
    await this.getAllowance()
  }
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
  }
  async executeOrder() {
    if (!this.orderForm.outputTokenAddr || !this.orderForm.minimumNativeTokensWeiBasedOnPrice) { return null }
    const overrides = {
      gasPrice: this.$ethers.utils.parseUnits('10', 'gwei')
    }
    await this.getAllowance()

    if (!this.preQuote.currentAllowance || this.preQuote.currentAllowance < this.preQuote.currentBal) {
      await this.approveAmounts()
      if (!this.preQuote.currentAllowance) {
        console.log('allowance still at zero, probably wallet address has 0 tokens')
        this.timeoutObj = setTimeout(this.executeOrder.bind(this), this.intervalsInSeconds)
        return
      }
      // if allowance is not zero, then must have token balance
      await this.getMinNativeTokensBasedOnDesiredPrice()
    }
    const xStarterInteract = new this.$ethers.Contract(xStarterInteractionAddr, xStarterInteractionABI, this.orderForm.getWallet())
    const response = await xStarterInteract.swapPercentOfApprovedBalance(
      this.orderForm.outputTokenAddr,
      this.orderForm.percentToSell,
      this.orderForm.minimumNativeTokensWeiBasedOnPrice,
      overrides // overrides must be last

    )
    console.log("response is", response)
    return response
  }

  executeUntilSuccess() {
    console.log('in execute success', this, this.intervalsInSeconds)
    this.timeoutObj = setTimeout(this.executeOrder.bind(this), this.intervalsInSeconds)
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
