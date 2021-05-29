import { boot } from 'quasar/wrappers'
import { ethers } from "ethers";


const helper = {
  weiBigNumberToFloatEther(weiInBigNumber) {
    return parseFloat(ethers.utils.formatEther(weiInBigNumber.toString()))
  }
}

export default boot(({ app }) => {
  // for use inside Vue files (Options API) through this.$ethers

  app.config.globalProperties.$ethers = ethers
  app.config.globalProperties.$helper = helper

})

export {ethers}
