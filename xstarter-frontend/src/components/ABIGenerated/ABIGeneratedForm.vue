<template>
  <q-form class="full-width">
    <div :class="title.class" :style="title.style">
      {{ title.name}}
    </div>

    <div class="full-width q-gutter-y-md">
      <div v-for="(obj, ind) in funcABI.inputs" :key="ind" >
        <q-input v-model="formFields[obj.name]" :label="!displayNames[obj.name] ? obj.name : displayNames[obj.name]"  />
      </div>
      <div>
        <div v-if="errorMessage" class="text-negative">
          {{ errorMessage }}
        </div>
        <div v-if="successMessage" class="text-positive">
          Success! TX hash: {{ successMessage }}
        </div>
        <div v-if="funcABI.stateMutability === 'payable'">
          <q-input v-model="payableValue" label="Ethers to send"/>
        </div>
        <div v-if="funcABI.inputs.length === 0 && funcABI.stateMutability === 'nonpayable'">
          No Inputs required. Click Execute to call function
        </div>
        <div class="row">
          <q-btn class="col-6" label="execute" @click="execute" />
          <q-btn v-if="closeBtnCallback" class="col-6" label="cancel" @click="closeBtnCallback"/>
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
      payableValue: '',
      funcABI: {inputs: [], stateMutability: ''}
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
    connectedContract: {
      type: Object,
      required: false
    },
    closeBtnCallback: {
      type: Function,
      required: false
    },
    successCallBack: {
      type: Function,
      required: false
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
    async execute() {
      this.callBeforeExecute()
      let response;
      try {
        if (this.funcABI.stateMutability === 'payable' && this.payableValue){
          response = await this.connectedContract[this.functionName]({value: this.$ethers.utils.parseEther(this.payableValue)})
        } else {
          response = await this.connectedContract[this.functionName]()
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
    console.log('conected contract is', this.connectedContract)
    const funcABI = abiUtils.getFunctionObj(this.abi, this.functionName, this.functionType)
    console.log('abi func is', funcABI)
    if (funcABI) {
      this.funcABI = {...funcABI}
    }

    console.log('func abi', funcABI)
  }
} )
</script>

<style scoped>

</style>
