<template>
  <q-page class="flex flex-center">
    <div class="row full-width justify-center q-gutter-y-xl q-my-xl">
      <q-form class=" display-card accountDisplayCard q-py-lg col-11 col-md-7 col-lg-5 q-gutter-y-lg" @submit.prevent.stop="generatePage" style="min-height: 200px;">
        <div class="text-center text-bold">
          Generate A Mint Page For A Deployed Contract
        </div>
        <div class="q-px-xl">
          <q-select v-model="chainIdVal" :options="chainIdOptions" :rules="[val => !!val || 'Field is required']" label="Select Chain" @update:model-value="onSelect" />
        </div>

        <div class="q-px-xl">
          <q-input  v-model="form.name" :rules="[val => !!val || 'Field is required']" placeholder="Name of NFT (ie. HungryBirds)" />
        </div>
        <div class="q-px-xl">
          <q-input  v-model="form.logoURL" placeholder="URL for you logo" />
        </div>
        <div class="q-px-xl">
          <q-input outlined v-model="form.description"  :rules="[val => !!val || 'Field is required']" placeholder="Description of your NFT project (Required)" type="textarea" style="min-height: 100px" />
        </div>
        <div class="q-px-xl">
          <q-input  v-model="arrayOfImages" placeholder="Comma separated sample image links(optional)" />
        </div>
        <div class="q-px-xl">
          <q-input  v-model="form.gif" placeholder="link to Gif (optional if images provided)" />
        </div>
        <div class="q-px-xl">
          <q-input  v-model="form.website" :rules="[val => !!val || 'Field is required']" placeholder="Website of NFT project" />
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
        <div class="q-px-xl">
          <q-input  v-model="form.NFTMeta.contractAddress" :rules="[val => !!val || 'Field is required']" placeholder="Address of NFT Contract" />
        </div>
        <div class="q-px-xl">
          <q-input  v-model="form.NFTMeta.mintFunction" :rules="[val => !!val || 'Field is required']" placeholder="Name of function, on smart contract, that is called to mint" />
        </div>
        <div class="q-px-xl">
          <q-input  v-model="form.NFTMeta.totalMint" :rules="[val => !!val || 'Field is required']" placeholder="Total number of NFTs to be minted" />
        </div>
        <div class="q-px-xl">
          <q-input  v-model="form.NFTMeta.reservedAmt" :rules="[val => !!val || 'Field is required']" placeholder="Number of NFTs reserved for team, etc" />
        </div>

        <div class="q-px-xl">
          <q-input  v-model="form.NFTMeta.maxMintPerTX" :rules="[val => !!val || 'Field is required']" placeholder="Number of NFTs that can be minted per transaction" />
        </div>
        <div class="q-px-xl">
          <q-input  v-model="form.NFTMeta.maxPerAddr" :rules="[val => !!val || 'Field is required']" placeholder="Total number of NFTs an address can mint" />
        </div>

        <div class="q-px-xl">
          <q-input  v-model="form.NFTMeta.mintPriceInEthers" :rules="[val => !!val || 'Field is required']" placeholder="Mint Price (ie 0.08)" />
        </div>

        <div class="q-px-xl">
          <q-input outlined v-model="abi" :rules="[val => !!val || 'Field is required']" placeholder="Paste contract ABI" type="textarea" style="min-height: 100px" />
        </div>

        <div class="row justify-center q-gutter-x-md">
          <q-btn :disable="disableBtn" label="Generate Page" outline rounded @click="generatePage" type="submit" />
          <q-spinner
            v-if="disableBtn"
            color="primary"
            size="3em"
          />
        </div>

        <div class="text-negative text-center">
          {{ generalError }}
        </div>

        <div  v-if="generatedPageUrl" class="text-center text-h6 col-11 wrap-word">
          Mint Page URL: {{ generatedPageUrl }} <q-btn icon="content_copy" @click="copyContract" /><q-btn icon="open_in_new" @click="() => openLink(generatedPageUrl)" />
        </div>
      </q-form>
    </div>
  </q-page>
</template>

<script>
import {defineComponent, inject} from "vue";
import {ethers} from "boot/ethers";
import ERC721Temp from "src/artifacts/contracts/xStarterNFTDeployTemplate.json";
import {copyToClipboard, openURL} from "quasar";

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
      disableBtn: false,
      chainIdVal: '',
      generatedPageUrl: '',
      arrayOfImages: '',
      generalError: '',
      abi: '',
      form: {
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
          reservedAmt: '',
          totalMint: '',
          maxMintPerTX: '',
          maxPerAddr: '',
          mintPriceInEthers: '',
          contractAddress: '',
          chainId: '',
          mintFunction: '',
          abi: ''
        }
      },
      optionalFields: {
        arrayOfImages: true,
        gif: true
      }
    }
  },
  computed: {
    chainIdOptions() {
      return this.getChainIdOptions()
    },
  },
  methods: {
    onSelect(val) {
      this.form.NFTMeta.chainId = val.value
    },
    allFieldsFilled() {
      for (const fieldVal of Object.keys(this.form)) {
        if (typeof this.form[fieldVal] !== 'object' &&!this.form[fieldVal]) {
          this.generalError = `${fieldVal} not filled out`
          return false
        }
      }
      // for (const fieldVal of Object.keys(this.form)) {
      //   if (typeof this.form[fieldVal] !== 'object' &&!this.form[fieldVal]) {
      //     this.generalError = `${fieldVal} not filled out`
      //     return false
      //   }
      // }
      this.generalError = ''
      return true
    },
    async copyContract() {
      await copyToClipboard(this.generatedPageUrl)
      this.$q.notify('Contract Address Copied!')
    },
    openLink(url) {
      openURL(url)
    },
    async generatePage() {
      if (this.arrayOfImages) {
        this.form.arrayOfImages = this.arrayOfImages.split(',')
      }
      this.convertABIToArray()
      const cidObj = await this.$ipfs_utils.saveILOInfo(this.form)
      if (cidObj) {
        this.generatedPageUrl = `https://www.xstarter.app/#/nft/mint/${cidObj.path}`
      }
    },

    convertABIToArray() {
      this.form.NFTMeta.abi = JSON.parse(this.abi)
    }
  }
})
</script>

<style scoped>

</style>
