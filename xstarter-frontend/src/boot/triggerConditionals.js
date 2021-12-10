import { boot } from 'quasar/wrappers'

class TriggerConditional {
  static isValid(conditionalArray) {
    for (let i = 0; i < conditionalArray.length; i++) {
      if (i === 0 && conditionalArray[i].isBase) {
        return false
      }else if (i !== 0 && conditionalArray[i].isBase && conditionalArray[i-1].isBase) {
        return false
      }
    }
    return true
  }
  static checkTxBoolean(decodedData, conditionalArray) {
    const arrayOfBool = []
    let txBoolean = false
    for (let i = 0; i < conditionalArray.length; i++) {
      const inputVal = conditionalArray[i].type === 'address' ?  decodedData.args[conditionalArray[i].name].toLowerCase() : decodedData.args[conditionalArray[i].name]
      const condVal = conditionalArray[i].type === 'address' ? conditionalArray[i].value.toLowerCase() : conditionalArray[i].value
      if (i !== 0) {
        // if next in conditional is AND and txBoolean is false then return false
        if (conditionalArray[i].isBase ) {
          // if next in conditional is AND and txBoolean is false then return false
          // since AND requires all to be
          if (conditionalArray[i].value === '&&' && !txBoolean) {
            return  false
          }
        }else {
          // each array contains a conditional object which has a function that
          txBoolean = conditionalArray[i].conditional.checkConditional(inputVal, condVal, conditionalArray[i].value2)
        }

      }else {
        txBoolean = conditionalArray[i].conditional.checkConditional(inputVal, condVal, conditionalArray[i].value2)
      }
    }
    return txBoolean
  }
  checkTxBoolean(decodedData, conditionalArray) {
    return TriggerConditional.checkTxBoolean(decodedData, conditionalArray)
  }

  isValid(conditionalArray) {
   return TriggerConditional.isValid(conditionalArray)
  }
}

const triggerConditional = new TriggerConditional()
export default boot(({ app }) => {
  // for use inside Vue files (Options API) through this.$ethers

  app.config.globalProperties.$triggerConditional = triggerConditional

})

export { triggerConditional }
