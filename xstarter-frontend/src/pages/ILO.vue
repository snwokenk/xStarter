<template>
  <q-page class="flex flex-center">
    <div class="row full-width justify-center q-pt-lg">
      <AccountDisplay class="col-lg-5 col-xs-10"  />
    </div>

    <ILOMainDisplay v-if="currentView === 'ilo'" />

    <ABIGeneratedForm v-show="false" :display-names="{xStarterToken_: 'Address of xStarter Token'}" :abi="proposalABI" :title="{name: 'Create A Proposal', class: '', style: ''}" function-name="constructor"/>

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
  name: 'ILO',
  components: {ABIGeneratedForm, AccountDisplay, ILOMainDisplay},
  data() {
    return {
      currentView: 'ilo',
    }
  },
  setup() {
    const getProvider = inject('$getProvider')
    const getSigner = inject('$getSigner')
    const getLaunchPadContract = inject('$getLaunchPadContract')
    const getConnectedAndPermissioned = inject('$getConnectedAndPermissioned')
    const proposalABI = xStarterProposalCode.abi
    console.log('provider is ', getProvider())
    return {getProvider, getSigner, getLaunchPadContract, getConnectedAndPermissioned, proposalABI}
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
