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
    for (let i = 0; i < conditionalArray.length; i++) {
      if (!conditionalArray[i].isBase) {
        arrayOfBool.push(decodedData.args[conditionalArray[i].name] === conditionalArray[i].val)
      }else if (conditionalArray[i].isBase) {
        // if the previous bool was false and the next baseCond is an AND then this should return false
        // cuz False && True === false
        if (!arrayOfBool[i-1] && conditionalArray[i].value === '&&') {
          return false
        }else {}
      }
    }
    return true
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
