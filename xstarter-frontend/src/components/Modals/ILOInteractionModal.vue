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
      <q-card-section class="row" style="font-size: 20px;">
        <div class="text-center col-12 segoe-bold">
          Interacting With: &nbsp; {{ ILOName }} Initial Liquidity Offering
        </div>
        <div class="text-center col-12 segoe-bold text-wr">
          At Contract Address: &nbsp; {{ ILOInfo.ILOAddress }}
        </div>
        <div class="text-center col-12 segoe-bold text-wr">
          {{ ILOName }} Token Address: &nbsp; {{ ILOMoreInfo.projectToken }}
        </div>
        <div class="text-center col-12 segoe-bold text-wr">
          {{ ILOName }} LP Token Address: &nbsp; {{ ILOMoreInfo.liqPairAddr }}
        </div>
      </q-card-section>
<!--  Contribution Info    -->
      <q-card-section class="justify-center row" >
        <ILOInteractionInfoDisplay
          class="col-auto"
          :ILOName="ILOName"
          :ILOInfo="ILOInfo"
          :maxPerAddr="maxPerAddr"
          :fundingTokenSymbol="fundingTokenSymbol"
          :minPerAddr="minPerAddr"
          :currentContrib="currentContrib"
          :currentNativeTokenBalance="currentNativeTokenBalance"
          :currentShareOfProjectTokenBalance="currentShareOfProjectTokenBalance"
          :currentShareOfLPTokenBalance="currentShareOfLPTokenBalance"
          :projectTokenBlockLockForContributors="projectTokenBlockLockForContributors"
          :projectTokenTimeLockForContributors="projectTokenTimeLockForContributors"
          :LPTokenTimeLockForContributors="LPTokenTimeLockForContributors"
          :LPTokenBlockLockForContributors="LPTokenBlockLockForContributors"
          :ILOMoreInfo="ILOMoreInfo"
        />
      </q-card-section>

      <q-card-actions align="center">
<!--        <q-btn :disable="ILOStatus !== 'live'" outline class="btn-less-round" label="Contribute" @click="toggleContributeForm" />-->
        <q-btn outline class="btn-less-round" label="Contribute" @click="toggleContributeForm" />
        <q-btn outline :disable="currentShareOfProjectTokenBalance === 0" class="btn-less-round" rounded label="Withdraw Project Tokens" @click="toggleWithdrawContributionForm" />
        <q-btn outline :disable="currentShareOfLPTokenBalance === 0" class="btn-less-round" rounded label="Withdraw LP Tokens" @click="toggleWithdrawLPForm" />
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
      <div class="row justify-center q-my-xl ">
        <ABIGeneratedForm
          class="col-12 col-lg-9 q-pa-xl accountDisplayCard display-card"
          v-if="currentFunctionName && currentABI"
          :abi="currentABI"
          :title="formTitle"
          :function-name="currentFunctionName"
          :connected-contract="currentConnectedContract"
          :success-call-back="currentSuccessCallback"
          :close-btn-callback="currentCloseCallBack"
          :input-styling="{class: 'q-pl-sm', style: 'border: 2px Solid; border-radius: 10px;'}"
          :key="formKey"
        />
      </div>

    </q-card>


  </q-dialog>

</template>

<script>
// todo: https://docs.metamask.io/guide/registering-your-token.html#code-free-example
import {defineComponent, inject} from "vue";
import { abiUtils } from "boot/abiGenerator";
import { ethers } from 'boot/ethers'
import ABIGeneratedForm from "components/ABIGenerated/ABIGeneratedForm";
import xStarterProposalCode from 'src/artifacts/contracts/xStarterProposal.sol/xStarterProposal.json'
import xStarterPoolPairCode from 'src/artifacts/contracts/xStarterPoolPairB.sol/xStarterPoolPairB.json'
import ILOInteractionInfoDisplay from "components/CardDisplays/ILOInteractionInfoDisplay";
import {ILO_STATUS} from "src/constants";



export default defineComponent( {
  name: "ILOInteractionModal",
  components: {ILOInteractionInfoDisplay, ABIGeneratedForm},
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
      formTitle: {class:'form-title text-center', style: 'font-size: 41px;', name: ''},
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
      updatedILO: null,
      timeLocks: null,
      formKey: 0
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
    ILOProcessStatusText() {
      return ILO_STATUS[this.ILOProcessStatus]
    },
    projectTokenTimeLockForContributors() {
      return this.timeLocks ? this.timeLocks[0].toNumber() : 0
    },
    projectTokenBlockLockForContributors() {
      return this.timeLocks ? this.timeLocks[1].toNumber() : 0
    },

    LPTokenTimeLockForContributors() {
      return this.timeLocks ? this.timeLocks[4].toNumber() : 0
    },
    LPTokenBlockLockForContributors() {
      return this.timeLocks ? this.timeLocks[5].toNumber() : 0
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
      if (this.formType === 'contribute') {
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
      this.formKey++

    },
    toggleValidateForm() {
      if (this.formType === 'validateILO') {
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
      this.formKey++
    },

    toggleApproveTokensForLiquidityForm() {
      if (this.formType === 'approveTokensForLiquidityPair') {
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
      this.formKey++
    },

    toggleCreateLiquidityPoolForm() {
      if (this.formType === 'createLiquidityPool') {
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
      this.formKey++
    },

    toggleFinalizeILOForm() {
      if (this.formType === 'finalizeILO') {
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
      this.formKey++
    },

    toggleWithdrawContributionForm() {
      if (this.formType === 'withdraw') {
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
      this.currentCloseCallBack = this.toggleWithdrawContributionForm
      this.formKey++
    },

    toggleWithdrawLPForm() {
      if (this.formType === 'withdrawLiquidityTokens') {
        this.clearForm()
        return
      }
      // native token so no need to create allowance in funding token
      this.currentABI = this.poolPairABI
      this.formTitle.name = `Withdraw Your Share Of ${this.ILOName} LP Tokens`
      this.currentFunctionName = 'withdrawLiquidityTokens'
      this.formType = 'withdrawLiquidityTokens'
      this.currentConnectedContract = this.ILOContract.connect(this.getSigner())
      this.currentSuccessCallback = this.refreshBalances
      this.currentCloseCallBack = this.toggleWithdrawLPForm
      this.formKey++
    },

    async refreshBalances() {
      this.currentContrib = this.$helper.weiBigNumberToFloatEther(await this.ILOContract.fundingTokenBalanceOfFunder(this.currentAddress))
      this.currentNativeTokenBalance = this.$helper.weiBigNumberToFloatEther(await this.getSigner().getBalance())
      if (this.ILOProcessStatus < 6) {
        await this.refreshILOInfo()
      }

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
    },
    async getTimeLocks() {
      this.timeLocks = await this.ILOContract.getTimeLocks()
      console.log('timelocks are: ', this.timeLocks)

    }
  },
  async mounted() {
    await this.refreshBalances()
    await this.getTimeLocks()
  },
  watch: {
    connectedAccount: async function () {
      await this.refreshBalances()
    }
  }
})
</script>

<style lang="scss" scoped>

.btn-less-round {
  border-radius: 5px;
}

</style>
