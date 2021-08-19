<template>
  <q-page class="flex flex-center">
    <div class="display-card accountDisplayCard account-display-text q-pa-xl">
      This section will allow the creation and sale of NFTs priced in xStarter Tokens
    </div>
  </q-page>
</template>

<script>
import {defineComponent, inject, provide} from 'vue';
import xStarterProposalCode from 'src/artifacts/contracts/xStarterProposal.sol/xStarterProposal.json'


// json object of NFT project using xStarter NFT contracts
// token must be a xStarterNFTConvertibleToken
const exampleObj = {
  name: "HungryBirds.io",
  tokenInfo: {
    name: "HungryBirds",
    symbol: "HBD",
    totalSupply: "150000000",
    tokenAddress: "0x0"
  },
  NFTInfo: {

  },
  conversionInfo: {
    rate: "10000",
    fee: "500",
  },
website: "www.hungrybirds.io",

  }

export default defineComponent({
  name: 'NFTMintingAndConversion',
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
