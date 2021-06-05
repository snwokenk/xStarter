<template>
  <q-dialog
    :model-value="modelValue"
    persistent
    :maximized="true"
    transition-show="slide-up"
    transition-hide="slide-down"
    @update:model-value="minimize"
  >
    <q-card>
      <q-bar>
        <q-space />
        <q-btn dense flat icon="close" v-close-popup>
          <q-tooltip class="bg-white text-primary">Close</q-tooltip>
        </q-btn>
      </q-bar>

<!--  TITLE    -->
      <q-card-section>
        <div class="text-center">
          Interact With {{ ILOName }}
        </div>
      </q-card-section>
<!--  Contribution Info    -->
      <q-card-section class="text-center">
        <div>
          Current Account Address: &nbsp; {{ connectedAccount[0] }}
        </div>
        <div>
          Maximum Contribution Per Address: &nbsp; {{ maxPerAddr }} {{ fundingTokenSymbol }}
        </div>

        <div>
        Minimum Contribution Allowed Per Address: &nbsp; {{ minPerAddr }} {{ fundingTokenSymbol }}
        </div>

        <div>
          Current Contribution: &nbsp; {{ currentContrib }} {{ fundingTokenSymbol }}
        </div>
      </q-card-section>
      <ABIGeneratedForm v-if="currentFunctionName"  :abi="abi" :function-name="currentFunctionName"/>
    </q-card>


  </q-dialog>

</template>

<script>
import {defineComponent, inject} from "vue";
import { abiUtils } from "boot/abiGenerator";
import { ethers } from 'boot/ethers'
import ABIGeneratedForm from "components/ABIGenerated/ABIGeneratedForm";
import xStarterProposalCode from 'src/artifacts/contracts/xStarterProposal.sol/xStarterProposal.json'
import xStarterPoolPairCode from 'src/artifacts/contracts/xStarterPoolPairB.sol/xStarterPoolPairB.json'



export default defineComponent( {
  name: "ILOInteractionModal",
  components: {ABIGeneratedForm},
  setup() {
    const abi = xStarterProposalCode.abi
    const poolPairABI = xStarterPoolPairCode.abi
    const getProvider = inject('$getProvider')
    const connectedAccount = inject('$connectedAccounts')
    return {abi, poolPairABI, getProvider, connectedAccount}
  },
  data() {
    return {
      formFields: {},
      currentFunctionName: '',
      funcABI: {inputs: []},
      balanceChecked: false,
      currentContrib: 0
    }
  },
  props: {
    modelValue: {
      type: Boolean,
      default: false
    },
    ILOStatus: {
      type: String,
      required: true
    },
    anILO: {
      type: Object,
      required: true
    },
    ILOName: {
      type: String,
      required: true
    },
    fundingTokenSymbol: {
      type: String,
      required: true
    }
  },
  computed: {
    ILOInfo() {
      // struct ILOProposal
      return this.anILO.info
    },
    ILOMoreInfo() {
      // struct ILOAdditionalInfo
      return this.anILO.moreInfo
    },
    currentAddress() {
      return this.connectedAccount[0]
    },
    minPerAddr() {
      return this.$helper.weiBigNumberToFloatEther(this.ILOMoreInfo.minPerAddr)
    },
    maxPerAddr() {
      return this.$helper.weiBigNumberToFloatEther(this.ILOMoreInfo.maxPerAddr)
    },
    ILOContract() {
      return new ethers.Contract(this.ILOInfo.ILOAddress, this.poolPairABI, this.getProvider());
    },
    minPer: {

    }
  },
  methods: {
    minimize() {
      this.$emit('update:modelValue', !this.modelValue)
    }
  },
  async mounted() {
    const bal = await this.ILOContract.fundingTokenBalanceOfFunder(this.currentAddress)
    this.currentContrib = this.$helper.weiBigNumberToFloatEther(bal)
    console.log('bal is', bal)
  },
  watch: {
  }
})
</script>

<style scoped>

</style>
