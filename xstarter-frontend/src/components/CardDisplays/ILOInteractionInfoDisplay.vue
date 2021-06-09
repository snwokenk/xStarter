<template>
  <q-card flat square class="display-card accountDisplayCard q-py-md q-mb-lg" clickable>
    <q-card-section>
      <div class="text-center">
        Interacting With: &nbsp; {{ ILOName }} Initial Liquidity Offering
      </div>
      <div class="text-center">
        At Contract Address: &nbsp; {{ ILOInfo.ILOAddress }}
      </div>
    </q-card-section>
    <q-card-section class="justify-between q-gutter-y-md account-display-text text-center full-width">
      <div class="full-width row q-gutter-y-md justify-between">
        <div  class="row col-12 col-lg-6 text-left">
          <div class="col-12">Current Wallet Address:</div>
          <div class="col-12 segoe-bold text-positive">{{ connectedAccount[0] }}</div>
        </div>

        <div  class="col-12 row col-lg-6 text-left">
          <div class="col-12">Current ETH Balance</div>
          <div class="segoe-bold col-12 text-positive">{{ currentNativeTokenBalance }}</div>
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
          <div class="col-12">Current Contribution:</div>
          <div class="segoe-bold col-12 text-positive">{{ currentContrib }} {{ fundingTokenSymbol }}</div>
        </div>

        <div  class="col-12 row col-lg-6 text-left">
          <div class="col-12">Calculated Share Of {{ ILOName }} Tokens:</div>
          <div class="segoe-bold col-12 text-positive">{{ currentShareOfProjectTokenBalance ? currentShareOfProjectTokenBalance.toLocaleString(): 'Not Available' }}</div>
        </div>
      </div>

      <div class="full-width row justify-between">

        <div  class="col-12 row col-lg-6 text-left">
          <div class="col-12">Calculated Share Of {{ ILOName }} LP Tokens:</div>
          <div class="segoe-bold col-12 text-positive">{{ currentShareOfLPTokenBalance ? currentShareOfLPTokenBalance.toLocaleString(): 'Not Available' }}</div>
        </div>
      </div>



<!--      <div v-if="connectedAndPermissioned" class="q-mt-lg">-->
<!--        <q-btn outline rounded label="Create An Initial Liquidity Offering" />-->
<!--      </div>-->


    </q-card-section>
  </q-card>
</template>

<script>
import {defineComponent, inject} from "vue";
import {ACCEPTED_CHAINS, CHAIN_ID_TO_NAME} from "src/constants";

export default defineComponent( {
  name: "ILOInteractionInfoDisplay",
  props: [
    'ILOName',
    'ILOInfo',
    'maxPerAddr',
    'fundingTokenSymbol',
    'minPerAddr',
    'currentContrib',
    'currentNativeTokenBalance',
    'currentShareOfProjectTokenBalance',
    'currentShareOfLPTokenBalance'
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
    acceptedChain() {
      return Boolean(ACCEPTED_CHAINS[this.chainId])
    },
    currentBlockDate() {
      return new Date(this.blockInfo.timestamp * 1000)
    }
  }
})
</script>

<style scoped>

</style>
