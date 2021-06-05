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
          Interacting With: &nbsp; {{ ILOName }} Initial Liquidity Offering
        </div>
        <div class="text-center">
          At Contract Address: &nbsp; {{ ILOInfo.ILOAddress }}
        </div>
      </q-card-section>
<!--  Contribution Info    -->
      <q-card-section align="center">
        <div>
          Current Wallet Address: &nbsp; {{ connectedAccount[0] }}
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

        <div>
          Current ETH Balance: &nbsp; {{ currentNativeTokenBalance }}
        </div>
      </q-card-section>

      <q-card-actions align="center">
        <q-btn outline rounded label="Contribute" @click="toggleContributeForm"/>
        <q-btn outline rounded label="Withdraw" />
      </q-card-actions>
      <ABIGeneratedForm
        v-if="currentFunctionName && currentABI"
        :abi="currentABI"
        :function-name="currentFunctionName"
        :connected-contract="currentConnectedContract"
        :success-call-back="currentSuccessCallback"
        :close-btn-callback="currentCloseCallBack"
      />
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
    const getSigner = inject('$getSigner')
    const connectedAccount = inject('$connectedAccounts')
    return {abi, poolPairABI, getProvider, getSigner, connectedAccount}
  },
  data() {
    return {
      formFields: {},
      currentFunctionName: '',
      currentConnectedContract: null,
      balanceChecked: false,
      currentContrib: 0,
      currentNativeTokenBalance: null,
      currentABI: null,
      currentSuccessCallback: null,
      currentCloseCallBack: null,
      formType: null
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
      console.log('signeer for provider is', this.getProvider(),this.getSigner(), this.getSigner().getAddress(), this.connectedAccount[0])
      return new ethers.Contract(this.ILOInfo.ILOAddress, this.poolPairABI, this.getProvider());
    },
    minPer: {

    }
  },
  methods: {
    minimize() {
      this.$emit('update:modelValue', !this.modelValue)
    },
    toggleContributeForm() {
      if (this.formType) {
        this.formType = null
        this.currentABI = null
        this.currentFunctionName = ''
        this.currentConnectedContract = null
        this.currentSuccessCallback = null
        this.currentCloseCallBack = null
        return
      }

      if (this.ILOInfo.fundingToken === this.$ethers.constants.AddressZero) {
        // native token so no need to create allowance in funding token
        this.currentABI = this.poolPairABI
        this.currentFunctionName = 'contributeNativeToken'
        this.formType = 'contribute'
        this.currentConnectedContract = this.ILOContract.connect(this.getSigner())
        this.currentSuccessCallback = this.refreshBalances
        this.currentCloseCallBack = this.toggleContributeForm
      } else {
        console.log('funding token is not native must call allowance')
      }

    },
    async refreshBalances() {
      this.currentContrib = this.$helper.weiBigNumberToFloatEther(await this.ILOContract.fundingTokenBalanceOfFunder(this.currentAddress))
      this.currentNativeTokenBalance = this.$helper.weiBigNumberToFloatEther(await this.getSigner().getBalance())
    }
  },
  async mounted() {
    await this.refreshBalances()
  },
  watch: {
  }
})
</script>

<style scoped>

</style>
