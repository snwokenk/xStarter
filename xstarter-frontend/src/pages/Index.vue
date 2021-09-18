<template>
  <q-page class="flex flex-center">
    <div class="row q-px-xl justify-center q-gutter-md">
      <div class="text-h5 text-center col-11 col-md-8">
        xStarter Provides Tools To help you manage your crypto/NFT project (alpha version)
      </div>
      <div class="text-subtitle2 text-center col-11 col-md-8">
        For NFT Projects, you can deploy your NFT, generate a page to allow others to mint your nft, display your NFT art and metadata and many more.
        For those seeking to do an Inital DEX Offering, you can use our platform to launch one and after automatically initiate a market after.
      </div>
    </div>


    <div class="row full-width justify-center q-gutter-y-xl">
      <div class="col-11 col-md-9 col-lg-7 col-xl-6">
        <q-btn rounded outline label="NFT Tools" class="homeButtons full-width" @click="$router.push('/nft')" />
      </div>
      <div class="col-11 col-md-9 col-lg-7 col-xl-6">
        <q-btn rounded outline label="ILO/IDO Tools" class="homeButtons full-width" @click="$router.push('/ilo')" />
      </div>
    </div>

  </q-page>
</template>

<script>
import {defineComponent, inject, provide} from 'vue';
import LiquidityOfferingDisplay from "components/CardDisplays/LiquidityOfferingDisplay";
import ILOMainDisplay from "components/ILOMainDisplay";
import AccountDisplay from "components/CardDisplays/AccountDisplay";
import ABIGeneratedForm from "components/ABIGenerated/ABIGeneratedForm";
import xStarterProposalCode from 'src/artifacts/contracts/xStarterProposal.sol/xStarterProposal.json'

export default defineComponent({
  name: 'PageIndex',
  data() {
    return {
      currentView: 'ilo',
    }
  },
  computed: {
    listOfLiquidityOffering() {
      return  {
        startDate: '1620530069',
        endDate: '1621221269',
        logo_url: '/xstarter_blue2.jpg'
      }
    }
  },
  methods: {
    checkIt() {
      console.log('provider', this.getProvider())
    }

  }
})
</script>
<style scoped lang="scss">
.display-container{
  width: 80%;
  min-height: 300px;
}

</style>
