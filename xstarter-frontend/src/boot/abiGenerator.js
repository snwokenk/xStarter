import { boot } from 'quasar/wrappers'

const abiUtils = {
  getFunctionObj(abi, functionName, functionType) {
    if (functionType === 'constructor' || functionName === 'constructor') {
      return this.getConstructorObj(abi)
    }
    let funcParams = []
    // get all items matching function type
    let funcTypes = abi.filter(obj => obj.type === functionType.toLowerCase())

    // if functypes is empty return
    if (!funcTypes.length) { return undefined }

    return funcTypes.find(obj => obj.name.toLowerCase() === functionName)
  },

  getConstructorObj(abi) {
    console.log('type of', typeof abi, abi)
    // get all items matching function type
    return abi.find(obj => obj.type === 'constructor')
  }
}

export default boot(({ app }) => {
  // for use inside Vue files (Options API) through this.$ethers

  app.config.globalProperties.$abiUtils = abiUtils


})

export { abiUtils }
