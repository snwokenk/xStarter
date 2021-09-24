<template>
  <q-page class="flex flex-center">
    <div class="row full-width justify-center q-gutter-y-xl q-my-xl">
      <div class=" display-card accountDisplayCard q-py-lg col-11 col-md-7 col-lg-5 q-gutter-y-lg" style="min-height: 200px;">
        <div class="text-center text-bold">
          Generate A Mint Page For A Deployed Contract
        </div>
        <div class="q-px-xl">
          <q-select v-model="form.chainIdVal" :options="chainIdOptions" label="Select Chain" />
        </div>

        <div class="q-px-xl">
          <q-input  v-model="form.name" placeholder="Name of NFT (ie. HungryBirds)" />
        </div>
        <div class="q-px-xl">
          <q-input  v-model="form.logoURL" placeholder="URL for you logo" />
        </div>
        <div class="q-px-xl">
          <q-input outlined v-model="form.description" placeholder="Description of your NFT project (Required)" type="textarea" style="min-height: 100px" />
        </div>
        <div class="q-px-xl">
          <q-input  v-model="form.arrayOfImages" placeholder="Comma separated sample image links(optional)" />
        </div>
        <div class="q-px-xl">
          <q-input  v-model="form.gif" placeholder="link to Gif (optional if images provided)" />
        </div>
        <div class="q-px-xl">
          <q-input  v-model="form.website" placeholder="Website of NFT project" />
        </div>
        <div class="q-px-xl">
          <q-input  v-model="form.socialMedia.twitter" placeholder="Twitter handle (optional)" />
        </div>
        <div class="q-px-xl">
          <q-input  v-model="form.socialMedia.discord" placeholder="Discord handle (optional)" />
        </div>
        <div class="q-px-xl">
          <q-input  v-model="form.socialMedia.telegram" placeholder="Telegram handle (optional)" />
        </div>
        <div class="q-px-xl">
          <q-input  v-model="form.socialMedia.instagram" placeholder="Instagram handle (optional)" />
        </div>

        <!--      <div class="row justify-center q-gutter-x-md">-->
        <!--        <q-btn :disable="disableMint" label="Deploy NFT" outline rounded @click="deployNFT" />-->
        <!--        <q-spinner-->
        <!--          v-if="disableMint"-->
        <!--          color="primary"-->
        <!--          size="3em"-->
        <!--        />-->
        <!--      </div>-->
        <!--      <div class="text-negative text-center">-->
        <!--        {{ generalError }}-->
        <!--      </div>-->
      </div>
    </div>

  </q-page>
</template>

<script>
import {defineComponent, inject} from "vue";
import {ethers} from "boot/ethers";
import ERC721Temp from "src/artifacts/contracts/xStarterNFTDeployTemplate.json";

export default defineComponent({
  name: "NFTMintPageGenerator",
  setup() {
    const getProvider = inject('$getProvider')
    const getChainIdOptions = inject('$getChainIdOptions')
    const getSigner = inject('$getSigner')
    const getLaunchPadContract = inject('$getLaunchPadContract')
    const getConnectedAndPermissioned = inject('$getConnectedAndPermissioned')
    let chainId = inject('$chainId')
    console.log('provider is ', getProvider())

    // The factory we use for deploying contracts
    const getFactory = () => {
      return new ethers.ContractFactory(ERC721Temp.abi, ERC721Temp.data.bytecode, getSigner())
    }

    return {
      getProvider,
      getSigner,
      getLaunchPadContract,
      getConnectedAndPermissioned,
      getChainIdOptions,
      getFactory,
      chainId
    }
  },
  data() {
    return {
      form: {
        chainIdVal: '',
        logoURL: '',
        description: "",
        arrayOfImages: '', // should be converted to an Array before saving to ipfs
        website: '',
        gif: '',
        socialMedia: {
          twitter: '',
          discord: '',
          telegram: '',
          instagram: ''
        },
        NFTMeta: {
          maxMint: '',
          reservedAmt: '',
          totalMint: '',
          maxMintPerTX: '',
          maxPerAddr: '',
          mintPriceInEthers: '',
          contractAddress: '',
          chainId: '',
          mintFunction: '',
          abi: []
        }

      }
    }
  },
  computed: {
    chainIdOptions() {
      return this.getChainIdOptions()
    },
  }
})
</script>

<style scoped>

</style>
