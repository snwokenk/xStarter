<template>
  <q-dialog
    :model-value="modelValue"
    persistent
    :maximized="true"
    transition-show="slide-up"
    transition-hide="slide-down"
    @update:model-value="minimize"
  >
    <q-card class="scroll">
      <q-bar>
        <q-space />
        <q-btn dense flat icon="close" v-close-popup>
          <q-tooltip class="bg-white text-primary">Close</q-tooltip>
        </q-btn>
      </q-bar>
      <q-card-section class="row modal-header-font ">
        <div class="text-center col-12 segoe-bold">
          Interacting With: &nbsp; {{ ILOName }} Initial Liquidity Offering
        </div>
      </q-card-section>

<!--  TITLE    -->
<!--      <div class="row justify-center full-width">-->
<!--        <q-expansion-item label="ILO Information" class="display-card col-lg-7 col-11 accountDisplayCard" default-opened>-->
<!--          <q-card-section class="row modal-header-font ">-->
<!--            <div class="text-center col-12 segoe-bold">-->
<!--              Interacting With: &nbsp; {{ ILOName }} Initial Liquidity Offering-->
<!--            </div>-->
<!--            <div class="text-center col-12 segoe-bold text-wr">-->
<!--              At Contract Address: &nbsp; {{ ILOInfo.ILOAddress }}-->
<!--            </div>-->
<!--            <div class="text-center col-12 segoe-bold text-wr">-->
<!--              {{ ILOName }} Token Address: &nbsp; {{ ILOMoreInfo.projectToken }}-->
<!--            </div>-->
<!--            <div class="text-center col-12 segoe-bold text-wr">-->
<!--              {{ ILOName }} LP Token Address: &nbsp; {{ ILOMoreInfo.liqPairAddr }}-->
<!--            </div>-->
<!--          </q-card-section>-->
<!--        </q-expansion-item>-->
<!--      </div>-->
      <q-card-section class="justify-center row full-width" >
        <ILOInteractionAddressesInfoDisplay
          class="col-lg-7 col-11"
          header-class="text-bold text-uppercase text-h6 text-center"
          default-opened
          :ILOName="ILOName"
          :ILOInfo="ILOInfo"
          :ILOMoreInfo="ILOMoreInfo"
          :ILOStatus="ILOStatus"
        />
      </q-card-section>


<!--  Contribution Info    -->
      <q-card-section class="justify-center row full-width" >
        <ILOInteractionInfoDisplay
          header-class="text-bold text-uppercase text-h5 text-center"
          class="col-lg-7 col-11"
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

      <q-card-actions align="center" class="q-gutter-y-md">
        <q-btn :disable="ILOStatus !== 'live'" outline class="btn-less-round" label="Contribute" @click="toggleContributeForm" />
<!--        <q-btn outline class="btn-less-round" label="Contribute" @click="toggleContributeForm" />-->
<!--  todo: withdraw tokens should be disabled until unlocked      -->
        <q-btn outline :disable="(!currentShareOfProjectTokenBalance && ILOInfo.admin.toLowerCase() !== currentAddress.toLowerCase()) || succeeded" class="btn-less-round" rounded label="Get Refund" @click="toggleRefundOnFailure" />
        <q-btn outline :disable="!currentShareOfProjectTokenBalance || !succeeded" class="btn-less-round" rounded label="Withdraw Project Tokens" @click="toggleWithdrawContributionForm" />
        <q-btn outline :disable="!currentShareOfLPTokenBalance || !succeeded" class="btn-less-round" rounded label="Withdraw LP Tokens" @click="toggleWithdrawLPForm" />
        <q-btn outline :disable="!succeeded" v-if="currentShareOfProjectTokenBalance || projectTokenBalanceOnERC20" class="btn-less-round" rounded label="Add Project Token To Wallet" @click="suggestToAddProjectToken"/>
      </q-card-actions>
      <q-card-section>
        <div v-if="ILOProcessStatus < 6 && ILOStatus === 'ended'">
          <div class="text-center" >
            ILO Has Ended. To Finalize The ILO, Click and Execute the Button Below In A 4 step process
          </div>
          <div class="text-center">
            ILO Status is: <span class="text-bold">{{ ILOProcessStatusText }}</span>
          </div>
        </div>
      </q-card-section>
      <q-card-actions v-if="ILOStatus === 'ended'"  align="center">
        <q-btn v-if="ILOProcessStatus  === 2 "  outline rounded label="Step 1: Validate " @click="toggleValidateForm"/>
        <q-btn v-if="ILOProcessStatus === 3 && succeeded" outline rounded label="Step 2: Approve Tokens For Liquidity" @click="toggleApproveTokensForLiquidityForm"/>
        <q-btn v-if="ILOProcessStatus === 4 && succeeded" outline rounded label="Step 3: Create Liquidity Pool" @click="toggleCreateLiquidityPoolForm"/>
        <q-btn v-if="ILOProcessStatus === 5 && succeeded" outline rounded label="Step 4: Finalize ILO" @click="toggleFinalizeILOForm"/>
      </q-card-actions>
      <div class="row justify-center q-my-xl ">
        <ABIGeneratedForm
          class="col-12 col-lg-9 q-pa-xl accountDisplayCard display-card"
          v-if="showABIForm"
          :abi="currentABI"
          :title="formTitle"
          :native-currency-symbol="fundingTokenSymbol"
          :function-name="currentFunctionName"
          :connected-contract="currentConnectedContract"
          :success-call-back="currentSuccessCallback"
          :close-btn-callback="currentCloseCallBack"
          :input-styling="{class: 'q-pl-sm', style: 'border: 2px Solid; border-radius: 10px;'}"
          :key="formKey"
          :default-values="formDefaultValues"
        />
        <div ref="#abiForm"></div>
      </div>

    </q-card>


  </q-dialog>

</template>

<script>
// todo: https://docs.metamask.io/guide/registering-your-token.html#code-free-example
import {defineComponent, inject, provide, ref} from "vue";
import { abiUtils } from "boot/abiGenerator";
import { ethers } from 'boot/ethers'
import ABIGeneratedForm from "components/ABIGenerated/ABIGeneratedForm";
import xStarterProposalCode from 'src/artifacts/contracts/xStarterProposal.sol/xStarterProposal.json'
import xStarterPoolPairCode from 'src/artifacts/contracts/xStarterPoolPairB.sol/xStarterPoolPairB.json'
import ERC20Code from 'src/artifacts/contracts/xStarterPoolPairB.sol/ProjectBaseToken.json'
import ILOInteractionInfoDisplay from "components/CardDisplays/ILOInteractionInfoDisplay";
import {ILO_STATUS, xStarter_ILO_Info, xStarter_ILO_IPFS_CID} from "src/constants";
import ILOInteractionAddressesInfoDisplay from "components/CardDisplays/ILOInteractionAddressesInfoDisplay";

import { scroll } from 'quasar'
const { getScrollTarget, setVerticalScrollPosition } = scroll



export default defineComponent( {
  name: "ILOInteractionModal",
  components: {ILOInteractionAddressesInfoDisplay, ILOInteractionInfoDisplay, ABIGeneratedForm},
  setup() {
    const proposalABI = xStarterProposalCode.abi
    const poolPairABI = xStarterPoolPairCode.abi
    const ERC20ABI = ERC20Code.abi
    const getProvider = inject('$getProvider')
    const getSigner = inject('$getSigner')
    const connectedAccount = inject('$connectedAccounts')
    const ethereumProvider = inject('$ethereumProvider')
    const metaMaskAssetAddRequest = inject('$metaMaskAssetAddRequest')
    const currentContrib = inject('$currentContrib')
    const changeCurrentContrib = inject('$changeCurrentContrib')
    return {proposalABI, poolPairABI, ERC20ABI, getProvider, getSigner, currentContrib, connectedAccount, ethereumProvider, metaMaskAssetAddRequest, changeCurrentContrib}
  },
  data() {
    return {
      formFields: {},
      formTitle: {class:'form-title text-center', style: 'font-size: 41px;', name: ''},
      currentFunctionName: '',
      currentConnectedContract: null,
      balanceChecked: false,
      // currentContrib: 0,
      currentNativeTokenBalance: null,
      currentProjectTokenBalance: null,
      currentShareOfProjectTokenBalance: null,
      projectTokenBalanceOnERC20: 0,
      currentShareOfLPTokenBalance: null,
      currentABI: null,
      currentSuccessCallback: null,
      currentCloseCallBack: null,
      formType: null,
      updatedILO: null,
      timeLocks: null,
      formDefaultValues: {},
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
    succeeded: {
      type: Boolean,
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
    showABIForm() {
      return this.currentFunctionName && this.currentABI
    },
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
    ERC20FundingContract() {
      console.log('signeer for provider is', this.getProvider(),this.getSigner(), this.getSigner().getAddress(), this.connectedAccount[0])
      if (this.ILOInfo.fundingToken !== this.$ethers.constants.AddressZero) {
        return new ethers.Contract(this.ILOInfo.fundingToken, this.ERC20ABI, this.getProvider());
      }
      return null

    },
    ERC20ProjectContract() {
      console.log('signeer for provider is', this.getProvider(),this.getSigner(), this.getSigner().getAddress(), this.connectedAccount[0])
      if (this.ILOMoreInfo.projectToken !== this.$ethers.constants.AddressZero) {
        return new ethers.Contract(this.ILOMoreInfo.projectToken, this.ERC20ABI, this.getProvider());
      }
      return null

    },
    ILOProposalContract() {
      return new ethers.Contract(this.proposalAddress, this.proposalABI, this.getProvider());
    },
    minPer: {

    }
  },
  methods: {
    scrollToElement (el) {
      console.log('ele in scroll is', el)
      const target = getScrollTarget(el)
      const offset = el.offsetTop
      const duration = 500
      setVerticalScrollPosition(target, offset, duration)
      console.log(target, offset, duration)
    },
    scrollToForm() {
      var element = this.$refs['#abiForm']
      var top = element.offsetTop
      window.scrollTo(0, top)
      console.log(element, top)
    },
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
        this.toggleContributeNativeForm()
      } else {
        this.toggleContributeERC20()
      }
      this.formKey++

    },
    toggleContributeNativeForm() {
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

    toggleContributeERC20() {
      if (this.formType === 'contribute') {
        this.clearForm()
        return
      }

      if (this.ILOInfo.fundingToken !== this.$ethers.constants.AddressZero) {
        // native token so no need to create allowance in funding token
        this.toggleApproveFundingERC20()
      }

    },
    // step 1
    toggleApproveFundingERC20() {
      if (this.formType === 'approveFundingToken') {
        this.clearForm()
        return
      }

      // TODO: check if there's already approval of tokens then call this.toggleContributeFundingToken
      // TODO: also have the ability to change Approval

      if (this.ILOInfo.fundingToken !== this.$ethers.constants.AddressZero) {
        // native token so no need to create allowance in funding token
        this.currentABI = this.ERC20ABI
        this.formTitle.name = 'Contribute To ILO: Approve Amount Of Tokens To Contribute'
        this.currentFunctionName = 'approve'
        this.formType = 'approveFundingToken'
        this.currentConnectedContract = this.ERC20FundingContract.connect(this.getSigner())
        this.currentSuccessCallback = this.toggleContributeFundingToken
        this.currentCloseCallBack = this.toggleApproveFundingERC20
        this.formDefaultValues = {
          spender: {defaultValue: this.ILOInfo.ILOAddress, readOnly: true},
        }
      }
      this.formKey++

    },
    // step 2
    toggleContributeFundingToken() {
      if (this.formType === 'contributeFunding') {
        this.clearForm()
        return
      }

      if (this.ILOInfo.fundingToken !== this.$ethers.constants.AddressZero) {
        // native token so no need to create allowance in funding token
        this.currentABI = this.poolPairABI
        this.formTitle.name = 'Contribute To ILO: Execute To Deposit Previously Approved Tokens'
        this.currentFunctionName = 'contributeFundingToken'
        this.formType = 'contributeFunding'
        this.currentConnectedContract = this.ILOContract.connect(this.getSigner())
        this.currentSuccessCallback = this.refreshBalances
        this.currentCloseCallBack = this.toggleContributeFundingToken
      } else {
        console.log('funding token is not native must call allowance')
      }
      this.formKey++

    },
    toggleRefundOnFailure() {
      if (this.formType === 'withdrawOnFailure') {
        this.clearForm()
        return
      }

        // native token so no need to create allowance in funding token
        this.currentABI = this.poolPairABI
        this.formTitle.name = 'ILO Failed: Get Refund'
        this.currentFunctionName = 'withdrawOnFailure'
        this.formType = 'withdrawOnFailure'
        this.currentConnectedContract = this.ILOContract.connect(this.getSigner())
        this.currentSuccessCallback = this.refreshBalances
        this.currentCloseCallBack = this.toggleRefundOnFailure
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
      this.changeCurrentContrib(this.$helper.weiBigNumberToFloatEther(await this.ILOContract.fundingTokenBalanceOfFunder(this.currentAddress)))
      this.currentNativeTokenBalance = this.$helper.weiBigNumberToFloatEther(await this.getSigner().getBalance())
      if (this.ILOProcessStatus < 6) {
        await this.refreshILOInfo()
      }

      if (this.ILOProcessStatus >= 3) {
        // check project token share
        this.currentShareOfProjectTokenBalance = this.$helper.weiBigNumberToFloatEther(await this.ILOContract.projectTokenBalanceOfFunder(this.currentAddress))
        console.log('project token is', this.currentShareOfProjectTokenBalance)
      }
      if (this.ILOProcessStatus >= 5) {
        this.currentShareOfLPTokenBalance = this.$helper.weiBigNumberToFloatEther(await this.ILOContract.projectLPTokenBalanceOfFunder(this.currentAddress))
      }

      if (this.ILOProcessStatus >= 5 && this.ERC20ProjectContract) {
        this.projectTokenBalanceOnERC20 = this.$helper.weiBigNumberToFloatEther(await this.ERC20ProjectContract.balanceOf(this.currentAddress))
      }

    },
    async refreshILOInfo() {
      this.updatedILO = await this.ILOProposalContract.getCompactInfo()
    },
    async suggestToAddProjectToken() {
      if (this.currentShareOfProjectTokenBalance > 0) {
        await this.metaMaskAssetAddRequest(this.ILOMoreInfo.projectToken, this.ILOInfo.tokenSymbol, '')
      }
    },
    async getTimeLocks() {
      this.timeLocks = await this.ILOContract.getTimeLocks()
      console.log('timelocks are: ', this.timeLocks)

    }
  },
  async mounted() {
    // console.log('ipfs utils', this.$ipfs_utils.saveILOInfo(xStarter_ILO_Info))
    // console.log('ipfs utils getILO info', this.$ipfs_utils.getILOInfo(xStarter_ILO_IPFS_CID))
    await this.refreshBalances()
    await this.getTimeLocks()
    console.log('ilo status is', this.ILOStatus, this.ILOProcessStatus)
    console.log('process ')
    // await this.suggestToAddTokenAndILO()
  },
  watch: {
    connectedAccount: async function () {
      await this.refreshBalances()
    },
    showABIForm: function (boolVal) {
      if (boolVal) {
        console.log('abi element', this.$refs['#abiForm'])
        this.scrollToElement(this.$refs['#abiForm'])
        // this.scrollToForm()
      }
    }
  }
})
</script>

<style lang="scss" scoped>

</style>
