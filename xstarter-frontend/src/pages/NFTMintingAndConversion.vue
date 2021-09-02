<template>
  <q-page class="justify-center ">
    <div class="row justify-center q-pb-lg q-gutter-y-lg">
      <div class="col-auto">
        <img :src="logo" style="min-width: 300px; max-width: 90%" />
      </div>
      <div class="text-h6 col-9 col-lg-10" >
        {{ description }}
      </div>
      <div class="text-body1 text-center col-9 col-lg-6" >
        Minted: &nbsp; <span class="text-bold">{{ numberMinted }} / {{ maxMint }}</span>
      </div>
      <div class="col-11 col-lg-10 row justify-center">
        <q-form class="q-gutter-y-lg" style="max-width: 300px; min-width: 200px;" @submit.prevent>
          <q-input
            class="col-12"
            outlined
            v-model="form.numberToMint"
            label="Number Of NFTs To Mint"
            type="number"
            :rules="[checkMax]"
          />
          <q-btn
            outline
            rounded
            style="max-width: 300px; min-width: 200px;"
            label="mint"
            class="col-12"
            type="submit"
          />
        </q-form>
      </div>

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
  data() {
    return {
      form: {
        numberToMint: 0
      }
    }
  },
  computed: {
    logo() {
      return '/HungryBirds/HungryBirdsLogo.png'
    },
    description() {
      return `HungryBirds are a mix of programmatically generated NFT art and an ERC20 token. HungryBird uses a unique structure to provide instant liquidity for holders of HungryBirds NFTs and allows for indirect fractional ownership of it’s NFT Collection. In the HungryBird ecosystem, collectors can either hold a HungryBirds NFT or 10,000 NFT tokens and can easily convert between the two.
       A Total of 10,500 NFTs will be minted`
    },
    maxMint() {
      return 10500
    },
    maxMintPerTx() {
      return 30
    },
    numberMinted() {
      return 0
    }
  },
  methods: {
    checkIt() {
      console.log('provider', this.getProvider())
    },
    checkMax(val) {
      val = parseInt(val)
      if (val > 0 && val <= this.maxMintPerTx) { return  true }
      return `Must Mint Between 1 to ${this.maxMintPerTx} NFTs per transaction`
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
