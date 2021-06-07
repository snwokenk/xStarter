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

        <div>
          Calculated Share Of {{ ILOName }} Tokens: &nbsp; {{ currentShareOfProjectTokenBalance ? currentShareOfProjectTokenBalance.toLocaleString(): 'Not Available' }}
        </div>

        <div>
          Calculated Share Of {{ ILOName }} LP Tokens: &nbsp; {{ currentShareOfLPTokenBalance ? currentShareOfLPTokenBalance.toLocaleString(): 'Not Available' }}
        </div>
<!--        <div>-->
<!--          Current {{ ILOName }} Tokens Balance: &nbsp; {{ currentProjectTokenBalance }}-->
<!--        </div>-->
      </q-card-section>

      <q-card-actions align="center">
        <q-btn outline rounded label="Contribute" @click="toggleContributeForm"/>
        <q-btn outline rounded label="Withdraw" @click="toggleWithdrawForm" />
      </q-card-actions>
      <q-card-section>
        <div>
          ILO Has Ended Status is: {{ ILOProcessStatus }}
        </div>
      </q-card-section>
      <q-card-actions v-if="ILOStatus === 'ended'"  align="center">
        <q-btn :disable="ILOProcessStatus > 2"  outline rounded label="Validate" @click="toggleValidateForm"/>
        <q-btn :disable="ILOProcessStatus > 3" outline rounded label="Approve Tokens For Liquidity" @click="toggleApproveTokensForLiquidityForm"/>
        <q-btn :disable="ILOProcessStatus > 4" outline rounded label="Create Liquidity Pool" @click="toggleCreateLiquidityPoolForm"/>
        <q-btn :disable="ILOProcessStatus > 5" outline rounded label="Finalize ILO" @click="toggleFinalizeILOForm"/>
      </q-card-actions>
      <ABIGeneratedForm
        v-if="currentFunctionName && currentABI"
        :abi="currentABI"
        :title="formTitle"
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
    const proposalABI = xStarterProposalCode.abi
    const poolPairABI = xStarterPoolPairCode.abi
    const getProvider = inject('$getProvider')
    const getSigner = inject('$getSigner')
    const connectedAccount = inject('$connectedAccounts')
    return {proposalABI, poolPairABI, getProvider, getSigner, connectedAccount}
  },
  data() {
    return {
      formFields: {},
      formTitle: {class:'', style: '', name: ''},
      currentFunctionName: '',
      currentConnectedContract: null,
      balanceChecked: false,
      currentContrib: 0,
      currentNativeTokenBalance: null,
      currentProjectTokenBalance: null,
      currentShareOfProjectTokenBalance: null,
      currentShareOfLPTokenBalance: null,
      currentABI: null,
      currentSuccessCallback: null,
      currentCloseCallBack: null,
      formType: null,
      updatedILO: null
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
    usingILO() {
      return this.updatedILO ? this.updatedILO : this.anILO
    },
    ILOInfo() {
      // struct ILOProposal
      return this.usingILO.info
    },
    ILOMoreInfo() {
      // struct ILOAdditionalInfo
      return this.usingILO.moreInfo
    },
    ILOProcessStatus() {
      return this.ILOMoreInfo.ILOStatus
    },
    proposalAddress() {
      return this.anILO.proposalAddr
    },
    liquidityPairAddress() {
      return this.ILOMoreInfo.liqPairAddr
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
    ILOProposalContract() {
      return new ethers.Contract(this.proposalAddress, this.proposalABI, this.getProvider());
    },
    minPer: {

    }
  },
  methods: {
    minimize() {
      this.$emit('update:modelValue', !this.modelValue)
    },
    clearForm() {
      this.formType = null
      this.formTitle.name = ''
      this.currentABI = null
      this.currentFunctionName = ''
      this.currentConnectedContract = null
      this.currentSuccessCallback = null
      this.currentCloseCallBack = null
    },
    toggleContributeForm() {
      if (this.formType) {
        this.clearForm()
        return
      }

      if (this.ILOInfo.fundingToken === this.$ethers.constants.AddressZero) {
        // native token so no need to create allowance in funding token
        this.currentABI = this.poolPairABI
        this.formTitle.name = 'Contribute To ILO'
        this.currentFunctionName = 'contributeNativeToken'
        this.formType = 'contribute'
        this.currentConnectedContract = this.ILOContract.connect(this.getSigner())
        this.currentSuccessCallback = this.refreshBalances
        this.currentCloseCallBack = this.toggleContributeForm
      } else {
        console.log('funding token is not native must call allowance')
      }

    },
    toggleValidateForm() {
      if (this.formType) {
        this.clearForm()
        return
      }
        // native token so no need to create allowance in funding token
      this.currentABI = this.poolPairABI
      this.formTitle.name = 'Validate ILO'
      this.currentFunctionName = 'validateILO'
      this.formType = 'validateILO'
      this.currentConnectedContract = this.ILOContract.connect(this.getSigner())
      this.currentSuccessCallback = this.refreshBalances
      this.currentCloseCallBack = this.toggleValidateForm
    },

    toggleApproveTokensForLiquidityForm() {
      if (this.formType) {
        this.clearForm()
        return
      }
      // native token so no need to create allowance in funding token
      this.currentABI = this.poolPairABI
      this.formTitle.name = 'Approve Tokens For Liquidity Pool'
      this.currentFunctionName = 'approveTokensForLiquidityPair'
      this.formType = 'approveTokensForLiquidityPair'
      this.currentConnectedContract = this.ILOContract.connect(this.getSigner())
      this.currentSuccessCallback = this.refreshBalances
      this.currentCloseCallBack = this.toggleApproveTokensForLiquidityForm
    },

    toggleCreateLiquidityPoolForm() {
      if (this.formType) {
        this.clearForm()
        return
      }
      // native token so no need to create allowance in funding token
      this.currentABI = this.poolPairABI
      this.formTitle.name = 'Create Liquidity Pool on DEX'
      this.currentFunctionName = 'createLiquidityPool'
      this.formType = 'createLiquidityPool'
      this.currentConnectedContract = this.ILOContract.connect(this.getSigner())
      this.currentSuccessCallback = this.refreshBalances
      this.currentCloseCallBack = this.toggleCreateLiquidityPoolForm
    },

    toggleFinalizeILOForm() {
      if (this.formType) {
        this.clearForm()
        return
      }
      // native token so no need to create allowance in funding token
      this.currentABI = this.poolPairABI
      this.formTitle.name = 'Finalize ILO And Set Time Locks'
      this.currentFunctionName = 'finalizeILO'
      this.formType = 'finalizeILO'
      this.currentConnectedContract = this.ILOContract.connect(this.getSigner())
      this.currentSuccessCallback = this.refreshBalances
      this.currentCloseCallBack = this.toggleFinalizeILOForm
    },

    toggleWithdrawForm() {
      if (this.formType) {
        this.clearForm()
        return
      }
      // native token so no need to create allowance in funding token
      this.currentABI = this.poolPairABI
      this.formTitle.name = `Withdraw Your Share Of ${this.ILOName} Tokens`
      this.currentFunctionName = 'withdraw'
      this.formType = 'withdraw'
      this.currentConnectedContract = this.ILOContract.connect(this.getSigner())
      this.currentSuccessCallback = this.refreshBalances
      this.currentCloseCallBack = this.toggleWithdrawForm
    },

    async refreshBalances() {
      this.currentContrib = this.$helper.weiBigNumberToFloatEther(await this.ILOContract.fundingTokenBalanceOfFunder(this.currentAddress))
      this.currentNativeTokenBalance = this.$helper.weiBigNumberToFloatEther(await this.getSigner().getBalance())
      await this.refreshILOInfo()
      if (this.ILOProcessStatus >= 3) {
        // check project token share
        this.currentShareOfProjectTokenBalance = this.$helper.weiBigNumberToFloatEther(await this.ILOContract.projectTokenBalanceOfFunder(this.currentAddress))
      }
      if (this.ILOProcessStatus >= 5) {
        this.currentShareOfLPTokenBalance = this.$helper.weiBigNumberToFloatEther(await this.ILOContract.projectLPTokenBalanceOfFunder(this.currentAddress))
      }

    },
    async refreshILOInfo() {
      this.updatedILO = await this.ILOProposalContract.getCompactInfo()
    }
  },
  async mounted() {
    await this.refreshBalances()
  },
  watch: {
    connectedAccount: async function () {
      await this.refreshBalances()
    }
  }
})
</script>

<style scoped>

</style>
