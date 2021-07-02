<template>
  <q-page class="flex flex-center">
    <div class="display-card accountDisplayCard account-display-text q-pa-xl">
      This section will allow those holding xStarter tokens to be able to approve proposed ILOs and other governance proposals
    </div>
  </q-page>
</template>

<script>
import {defineComponent, inject, provide} from 'vue';
import xStarterProposalCode from 'src/artifacts/contracts/xStarterProposal.sol/xStarterProposal.json'

export default defineComponent({
  name: 'PageGovernance',
  setup() {
    const getProvider = inject('$getProvider')
    const getSigner = inject('$getSigner')
    const getLaunchPadContract = inject('$getLaunchPadContract')
    const getConnectedAndPermissioned = inject('$getConnectedAndPermissioned')
    const proposalABI = xStarterProposalCode.abi
    console.log('provider is ', getProvider())
    return {getProvider, getSigner, getLaunchPadContract, getConnectedAndPermissioned, proposalABI}
  },
  computed: {},
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
