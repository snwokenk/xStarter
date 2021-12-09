<template>
  <q-form class=" display-card accountDisplayCard q-py-lg col-11 col-md-7 col-lg-5 q-gutter-y-lg" @submit.prevent.stop="generatePage" style="min-height: 200px;">
    <div class="text-center text-bold">
      Create A BlockChain Trigger
    </div>
    <div class="q-px-xl">
      <q-select v-model="form.blockchain" :options="arrayOfBlockChains" :rules="[val => !!val || 'Field is required']" label="Select Blockchain" />
    </div>

    <div class="q-px-xl">
      <q-select v-model="form.triggerType" :options="arrayOfTriggerTypes" :rules="[val => !!val || 'Field is required']" label="Type Of Trigger" />
    </div>

    <div v-if="arrayOfAvailableDex" class="q-px-xl">
      <q-select v-model="form.selectedDex" :options="arrayOfAvailableDex" label="Select DEX" class="full-width"/>
    </div>

    <div v-if="form.selectedDex" class="q-px-xl">
      <q-select v-model="form.selectedFunctions" multiple :options="availableFunctions" label="Select Function(s) To Create Triggers" class="full-width"/>
    </div>
    <div v-if="form.selectedFunctions.length" class="q-px-xl row">
      <div v-for="obj in form.selectedFunctions" class="col-12 row" :key="obj.label">
<!--        <FunctionConditionals :function-input-obj="obj" />-->
        <FunctionConditionals2 :disable="Object.keys(functionTriggersObj).length" :function-input-obj="obj" @saveTrigger="saveFunctionTrigger"/>
      </div>
    </div>
  </q-form>
</template>

<script>
import {defineComponent} from "vue";
import {ARRAY_OF_BLOCKCHAINS, BLOCKCHAIN_TO_DEX} from "src/constants";
// import FunctionConditionals from "components/BlockchainTrading/FunctionConditionals";
import FunctionConditionals2 from "components/BlockchainTrading/FunctionConditionals2";

export default defineComponent(  {
  name: "TriggerForm",
    components: {FunctionConditionals2},
    data() {
    return {
      form: {
        blockchain: null,
        triggerType: null,
        selectedDex: null,
        selectedContract: null,
        selectedFunctions: []
      },
      functionTriggersObj: {

      },
      blockchainToFunctionTriggers: {

      },
      availableFunctions: []
    }
  },
  computed: {
    arrayOfAvailableDex() {
      if (this.form.triggerType && this.form.triggerType.value === 1) {
        return BLOCKCHAIN_TO_DEX[this.form.blockchain.value]
      }
      return null
    },
    arrayOfBlockChains() {
      return [...ARRAY_OF_BLOCKCHAINS]
    },
    arrayOfTriggerTypes() {
      return [
        {
          label: 'Watch DEX Transactions',
          value: 1
        },
        {
          label: 'Watch Native Token Transfers',
          value: 2
        },
        {
          label: 'Watch Contract Function Calls',
          value: 3
        },
      ]
    }
  },
  methods: {
    saveFunctionTrigger(value) {
      console.log('value is', value)
      this.functionTriggersObj[value.funcName] = value.triggers
      const  selectedContract = this.form.selectedDex || this.form.selectedContract
      const contractAddress = selectedContract.routerAddress || selectedContract.contractAddress
      const contractABI = selectedContract.routerABI || selectedContract.contractABI
      if (!this.blockchainToFunctionTriggers[this.form.blockchain.label]) {
        this.blockchainToFunctionTriggers[this.form.blockchain.label] = {
          details: this.form.blockchain,

        }
        this.blockchainToFunctionTriggers[this.form.blockchain.label][contractAddress] = {
          contractABI
        }

      }else if (!this.blockchainToFunctionTriggers[this.form.blockchain.label][contractAddress]) {
        this.blockchainToFunctionTriggers[this.form.blockchain.label][contractAddress] = {
          contractABI
        }
      }

      this.blockchainToFunctionTriggers[this.form.blockchain.label][contractAddress][value.funcName] = this.functionTriggersObj[value.funcName]
      this.$emit('saveTrigger', this.blockchainToFunctionTriggers)
    }
  },
  watch: {
    'form.blockchain': function () {
      this.form.triggerType = null
      // this.form.selectedFunctions = []
    },
    'form.triggerType': function () {
      this.form.selectedDex = null
      this.form.selectedFunctions = []
    },
    'form.selectedDex': function (val, oldVal) {
      if (!val || !val.routerABI) { return }
      const abi = JSON.parse(val.routerABI)
      const temp = []

      for (const obj of abi) {
        if(obj.stateMutability in {nonpayable: true, payable: true} && obj.type === 'function' && obj.name) {
          temp.push({label: obj.name, value: obj})
        }
      }
      this.availableFunctions = temp
      console.log(this.availableFunctions)
    }
  }
}
)
</script>

<style scoped>

</style>
