import { boot } from 'quasar/wrappers'
import { ethers } from "ethers";


export default boot(({ app }) => {
  // for use inside Vue files (Options API) through this.$ethers

  app.config.globalProperties.$ethers = ethers
  app.config.globalProperties.$blockchain = {
    provider: undefined,
    ethereumProvider: undefined,
    signer: undefined,
    connectedAccounts: [],
    connectedAndPermissioned: false,
    contracts: {
      ILOContract: undefined
    }
  }

})

export {ethers}
