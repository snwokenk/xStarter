<template>
  <q-expansion-item label="Your Info" class="display-card accountDisplayCard q-py-md q-mb-lg">
    <q-card flat square clickable class="display-card">
      <!--    <q-card-section>-->
      <!--      <div class="text-center">-->
      <!--        Interacting With: &nbsp; {{ ILOName }} Initial Liquidity Offering-->
      <!--      </div>-->
      <!--      <div class="text-center">-->
      <!--        At Contract Address: &nbsp; {{ ILOInfo.ILOAddress }}-->
      <!--      </div>-->
      <!--    </q-card-section>-->
      <q-card-section class="justify-between q-gutter-y-md account-display-text text-center full-width">
        <div class="full-width row q-gutter-y-md justify-between">
          <div class="col-12 text-center text-uppercase text-bold text-h6">Wallet Info</div>
          <div  class="row col-12 col-lg-6 text-left">
            <div class="col-12">Your Current Wallet Address:</div>
            <div class="col-12 segoe-bold text-positive text-address-font-size">{{ connectedAccount[0] }}</div>
          </div>

          <div  class="col-12 row col-lg-6 text-left">
            <div class="col-12">Your Current ETH Balance</div>
            <div class="segoe-bold col-12 text-positive">{{ currentNativeTokenBalance }}</div>
          </div>

        </div>

        <div class="row q-my-lg">
          <div class="col-12 text-center text-uppercase text-bold text-h6">
            Contribution Info
          </div>
        </div>

        <div class="row justify-between">

          <div class="col-12 row col-lg-5 text-left">
            <div class="col-12">Minimum Contribution Allowed Per Address:</div>
            <div class="segoe-bold col-12 text-positive">{{ minPerAddr }} {{ fundingTokenSymbol }}</div>
          </div>

          <div  class="col-12 row col-lg-6 text-left">
            <div class="col-12">Maximum Contribution Per Address:</div>
            <div class=" col-12 segoe-bold text-positive">{{ maxPerAddr }} {{ fundingTokenSymbol }}</div>
          </div>

        </div>

        <div class="full-width row justify-between">
          <div class="col-12 row col-lg-6 text-left">
            <div class="col-12">Your Current Contribution:</div>
            <div class="segoe-bold col-12 text-positive">{{ currentContrib }} {{ fundingTokenSymbol }}</div>
          </div>

          <div  class="col-12 row col-lg-6 text-left">
            <div class="col-12">Your Calculated Share Of {{ ILOName }} Tokens:</div>
            <div class="segoe-bold col-12 text-positive">{{ currentShareOfProjectTokenBalanceDisplay }}</div>
          </div>
        </div>

        <div class="full-width row justify-between">

          <div  class="col-12 row col-lg-6 text-left">
            <div class="col-12">Your Calculated Share Of {{ ILOName }} LP Tokens:</div>
            <div class="segoe-bold col-12 text-positive">{{ currentShareOfLPTokenBalanceDisplay }}</div>
          </div>

          <div  class="col-12 row col-lg-6 text-left">
            <div class="col-12">Project Tokens For Contributors Locked Till Block Number:</div>
            <div class="segoe-bold col-12 text-positive">{{ projectTokensLockedDisplay }}</div>
          </div>
        </div>

        <div class="full-width row justify-between">

          <div  class="col-12 row col-lg-6 text-left">
            <div class="col-12">Project Tokens For Contributors Locked Till Block Timestamp:</div>
            <div class="segoe-bold col-12 text-positive">{{ projectTokensTimeLockedDisplay }}</div>
          </div>

          <div  class="col-12 row col-lg-6 text-left">
            <div class="col-12">LP Tokens For Contributors Locked Till Block Number:</div>
            <div class="segoe-bold col-12 text-positive">{{ LPTokensLockedDisplay }}</div>
          </div>
        </div>

        <div class="full-width row justify-between">

          <div  class="col-12 row col-lg-6 text-left">
            <div class="col-12">LP Tokens For Contributors Locked Till Block Timestamp:</div>
            <div class="segoe-bold col-12 text-positive">{{ LPTokensTimeLockedDisplay }}</div>
          </div>
        </div>



        <!--      <div v-if="connectedAndPermissioned" class="q-mt-lg">-->
        <!--        <q-btn outline rounded label="Create An Initial Liquidity Offering" />-->
        <!--      </div>-->


      </q-card-section>
    </q-card>
  </q-expansion-item>

</template>

<script>
import {defineComponent, inject} from "vue";
import {ACCEPTED_CHAINS, CHAIN_ID_TO_NAME} from "src/constants";

export default defineComponent( {
  name: "ILOInteractionInfoDisplay",
  props: [
    'ILOName',
    'ILOInfo',
    'ILOMoreInfo',
    'ILOStatus',
    'maxPerAddr',
    'fundingTokenSymbol',
    'minPerAddr',
    'currentContrib',
    'currentNativeTokenBalance',
    'currentShareOfProjectTokenBalance',
    'currentShareOfLPTokenBalance',
    'projectTokenTimeLockForContributors',
    'projectTokenBlockLockForContributors',
    'LPTokenTimeLockForContributors',
    'LPTokenBlockLockForContributors'
  ],
  setup() {
    const chainId = inject('$chainId')
    const blockInfo = inject('$blockInfo')
    const connectedAndPermissioned = inject('$connectedAndPermissioned',)
    const connectedAccount = inject('$connectedAccounts')
    return {
      chainId,
      blockInfo,
      connectedAndPermissioned,
      connectedAccount
    }
  },
  computed: {
    chainIdName() {
      return !CHAIN_ID_TO_NAME[this.chainId] ? this.chainId : CHAIN_ID_TO_NAME[this.chainId]
    },
    currentShareOfProjectTokenBalanceDisplay() {
      if (this.currentShareOfProjectTokenBalance) {
        return this.currentShareOfProjectTokenBalance.toLocaleString()
      }else if (this.ILOMoreInfo.ILOStatus >= 6) {
        return 0
      } else {
        return 'Not Available'
      }
    },

    currentShareOfLPTokenBalanceDisplay() {
      if (this.currentShareOfLPTokenBalance) {
        return this.currentShareOfLPTokenBalance.toLocaleString()
      }else if (this.ILOMoreInfo.ILOStatus >= 6) {
        return 0
      } else {
        return 'Not Available'
      }
    },
    acceptedChain() {
      return Boolean(ACCEPTED_CHAINS[this.chainId])
    },
    currentBlockDate() {
      return new Date(this.blockInfo.timestamp * 1000)
    },
    projectTokensLockedDisplay() {
      if (!this.projectTokenBlockLockForContributors) {
        return 'N/A'
      }else if (this.blockInfo.blockNumber >= this.projectTokenBlockLockForContributors && this.blockInfo.timestamp >= this.projectTokenTimeLockForContributors) {
        return 'Tokens Unlocked '
      }else if (this.blockInfo.blockNumber >= this.projectTokenBlockLockForContributors) {
        return `Block Unlocked Waiting For Block Timestamp of ${this.projectTokenBlockLockForContributors}`
      }
      return this.projectTokenBlockLockForContributors
    },

    projectTokensTimeLockedDisplay() {
      if (!this.projectTokenTimeLockForContributors) {
        return 'N/A'
      }else if (this.blockInfo.timestamp >= this.projectTokenTimeLockForContributors && this.blockInfo.blockNumber >= this.projectTokenBlockLockForContributors) {
        return 'Tokens Unlocked '
      }else if (this.blockInfo.timestamp >= this.projectTokenTimeLockForContributors) {
        return `Timestamp Unlocked Waiting For Block ${this.projectTokenBlockLockForContributors}`
      }
      return (new Date(this.projectTokenTimeLockForContributors * 1000)).toLocaleString()
    },
    LPTokensLockedDisplay() {
      if (!this.LPTokenBlockLockForContributors) {
        return 'N/A'
      }else if (this.blockInfo.blockNumber >= this.LPTokenBlockLockForContributors && this.blockInfo.timestamp >= this.LPTokenTimeLockForContributors) {
        return 'Tokens Unlocked '
      }else if (this.blockInfo.blockNumber >= this.LPTokenBlockLockForContributors) {
        return `Block Unlocked Waiting For Block Timestamp of ${this.LPTokenBlockLockForContributors}`
      }
      return this.LPTokenBlockLockForContributors
    },

    LPTokensTimeLockedDisplay() {
      if (!this.LPTokenTimeLockForContributors) {
        return 'N/A'
      }else if (this.blockInfo.timestamp >= this.LPTokenTimeLockForContributors && this.blockInfo.blockNumber >= this.LPTokenBlockLockForContributors) {
        return 'Tokens Unlocked '
      }else if (this.blockInfo.timestamp >= this.LPTokenTimeLockForContributors) {
        return `Timestamp Unlocked Waiting For Block ${this.LPTokenBlockLockForContributors}`
      }
      return (new Date(this.LPTokenTimeLockForContributors * 1000)).toLocaleString()
    }
  }
})
</script>

<style scoped>

</style>
