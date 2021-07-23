<template>
  <q-expansion-item label="Addresses Of ILO Project" class="display-card accountDisplayCard q-py-md q-mb-lg">
    <q-card flat square clickable class="display-card q-mt-md">
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
<!--          <div class="col-12 text-center text-uppercase text-bold text-h6">Initial Liquidity Offering Info</div>-->
          <div  class="row col-12 col-lg-6 text-left">
            <div class="col-12">Name Of ILO:</div>
            <div class="col-12 segoe-bold text-positive text-address-font-size">{{ ILOName }}</div>
          </div>

          <div  class="col-12 row col-lg-6 text-left">
            <div class="col-12">Contract Address Of ILO Smart Contract</div>
            <div class="segoe-bold col-12 text-positive wrap-word">{{ ILOInfo.ILOAddress }}</div>
          </div>

        </div>

        <div class="row justify-between">

          <div class="col-12 row col-lg-5 text-left">
            <div class="col-12">Project's Token Address</div>
            <div class="segoe-bold col-12 text-positive wrap-word">{{ ILOMoreInfo.projectToken }}</div>
          </div>

          <div  class="col-12 row col-lg-6 text-left">
            <div class="col-12">Project's LP Token Address:</div>
            <div class=" col-12 segoe-bold text-positive wrap-word">{{ ILOMoreInfo.liqPairAddr }}</div>
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
  name: "ILOInteractionAddressesInfoDisplay",
  props: [
    'ILOName',
    'ILOInfo',
    'ILOMoreInfo',
    'ILOStatus',
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
