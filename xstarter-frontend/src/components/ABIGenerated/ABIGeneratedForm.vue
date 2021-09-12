<template>
  <q-form>
    <div style="margin-bottom: 50px;" :class="title.class" :style="title.style">
      {{ title.name}}
    </div>

    <div class="full-width q-gutter-y-md">
      <div v-for="(obj, ind) in funcInputs" :key="ind" >
        <q-input
          :readonly="readOnlyObjs[obj.name]"
          :class="inputStyling.class"
          :style="inputStyling.style"
          v-model="formFields[obj.name]"
          :label="!displayNames[obj.name] ? obj.name : displayNames[obj.name]"
          @update:model-value="(val) => { onInput(obj.name, val) }"
        />
      </div>
      <div>
        <div v-if="errorMessage" class="text-negative ">
          {{ errorMessage }}
        </div>
        <div v-if="successMessage" class="text-positive">
          Success! TX hash: {{ successMessage }}
        </div>
        <div v-if="funcABI.stateMutability === 'payable'">
          <q-input
            :class="inputStyling.class"
            :style="inputStyling.style"
            :readonly="payableReadOnly"
            v-model="payableValue"
            :label="`${nativeCurrencySymbol} to send`"
          />
        </div>
        <div class="q-pl-xs" v-if="funcABI.inputs.length === 0 && funcABI.stateMutability === 'nonpayable'">
          No Inputs required. Click Execute to call function
        </div>
        <div class="row q-mt-lg justify-center">
          <q-btn rounded outline class="col-3" :label="actionBtnLabel" @click="execute" />
          <div class="col-1" v-if="closeBtnCallback"/>
          <q-btn rounded outline v-if="closeBtnCallback" class="col-6" label="cancel" @click="closeBtnCallback"/>
        </div>
        <div v-if="waitingOnTx" class="row text-positive justify-center q-my-lg">
          <div class="col-auto">
            <q-spinner-hourglass
              color="positive"
              size="4em"
            />
          </div>

         <div class="col-12 text-center">
           Transaction In Progress
         </div>
        </div>
      </div>
    </div>
  </q-form>

</template>

<script>
import {defineComponent} from "vue";
import { abiUtils } from "boot/abiGenerator";

export default defineComponent( {
  name: "ABIGeneratedForm",
  setup() {

    return {}
  },
  data() {
    return {
      formFields: {
      },
      errorMessage: '',
      successMessage: '',
      waitingOnTx: false,
      payableReadOnly: false,
      payableValue: '',
      funcABI: {inputs: [], stateMutability: ''},
      funcInputs: [],
      readOnlyObjs: {}, // value: bool
      hideObjs: {}
    }
  },
  props: {
    modelValue: {
      type: Boolean,
      default: false
    },
    title: {
      type: Object, // fields = 'name', 'class', 'style'
      default: () => {return {name: '', class: '', style: ''}}
    },
    functionType: {
      type: String,
      default: 'function' // can be 'function', 'constructor'
    },
    actionBtnLabel: {
      type: String,
      default: 'execute'
    },
    nativeCurrencySymbol: {
      type: String,
      default: 'ETH'
    },
    abi: {
      type: Object,
      required: true
    },

    functionName: {
      type: String,
      required: true

    },
    displayNames: {
      type: Object,
      default: () => {return {}}  // {functionParameter: 'Display names'}
    },

    defaultValues: {
      type: Object,
      default: () => {return {}}  // {functionParameter: {defaultValue: value, readOnly: bool, show: bool}
    },
    connectedContract: {
      type: Object,
      required: false
    },
    closeBtnCallback: {
      type: Function,
      required: false
    },
    // a parameter tied to a payable, for example if minting and each mint requires a certain amount of native tokens
    parameterToPayable: {
      type: Object,
      required: false // {paramName: '', amtPerEach: } parameter that should be used to calculate payable value
    },
    successCallBack: {
      type: Function,
      required: false
    },
    inputStyling: {
      type: Object,
      default: () => {
        return {class: '', style: ''}
      }
    }
  },
  methods: {
    minimize() {
      this.$emit('update:modelValue', !this.modelValue)
    },
    callBeforeExecute() {
      this.successMessage = ''
      this.errorMessage = ''
      this.waitingOnTx = true
    },
    callAfterExecute() {
      this.waitingOnTx = false
    },
    onInput(fieldName, fieldVal) {
      console.log('field name is', fieldName, fieldVal)
      if (this.payableReadOnly && this.parameterToPayable.paramName === fieldName) {
        const bigNumberPayable = this.$ethers.utils.parseEther(parseFloat(this.parameterToPayable.amtPerEach).toString()).mul(parseFloat(fieldVal)).toString()
        this.payableValue = fieldVal ? this.$helper.weiBigNumberToFloatEther(bigNumberPayable).toString() : 0
      }
    },
    convertFieldToEther() {
      // todo: have a way of deciding which to use
      const fieldsForm = {...this.formFields}
      if (this.formFields.value) {
        fieldsForm.value = this.$ethers.utils.parseEther(this.formFields.value)
      }
      return fieldsForm
    },
    async execute() {
      this.callBeforeExecute()
      let response;
      try {
        // to convert field sto ether
        const formFields = this.convertFieldToEther()
        if (this.funcABI.stateMutability === 'payable' && this.payableValue){

          let nonce = Date.now()
          console.log("calling nonce", nonce)
          response = await this.connectedContract[this.functionName](
            ...Object.values(formFields),
            {
            value: this.$ethers.utils.parseEther(this.payableValue),
            gasPrice: this.$ethers.utils.parseEther('0.000000001')
          })
        } else {
          console.log('formfields', formFields)

          response = await this.connectedContract[this.functionName]( ...Object.values(formFields),{
            gasPrice: this.$ethers.utils.parseEther('0.000000001') // 1 gwei
          })
        }
        let tx = await response.wait()
        console.log('tx is', tx)

        this.payableValue = ''
        this.successMessage = tx.transactionHash
        this.callAfterExecute()
        if (typeof this.successCallBack === 'function') {
          console.log('success call back is', this.successCallBack)
          this.successCallBack()
        }
      }catch (e) {
        console.log('caught error', e)
        this.errorMessage = e.data && e.data.message ? e.data.message : e.message
        this.callAfterExecute()
      }


    }
  },
  mounted() {
    const funcABI = abiUtils.getFunctionObj(this.abi, this.functionName, this.functionType)
    if (funcABI) {
      this.funcABI = {...funcABI}
    }
    console.log('func abi', funcABI)
  },
  watch: {
    funcABI: async function(val)  {
      // Add Defaults
      // {functionParameter: {defaultValue: value, readOnly: bool, hide: bool
      this.funcInputs = val.inputs
      for (const inputObj of val.inputs) {
        this.formFields[inputObj.name] = ''
        const defaultObj = this.defaultValues[inputObj.name]
        if (defaultObj) {
          this.formFields[inputObj.name] = !!defaultObj.defaultValue ? defaultObj.defaultValue : ''
          this.readOnlyObjs[inputObj.name] = !!defaultObj.readOnly
          this.hideObjs[inputObj.name] = !!defaultObj.hide
        }

        if (this.parameterToPayable && this.funcInputs.some(obj => obj.name === this.parameterToPayable.paramName)) {
          console.log('payable is readonly')
          this.payableReadOnly = true
          this.payableValue = 0
        }
      }
    }
  }
} )
</script>

<style scoped>

</style>
