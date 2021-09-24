<template>
  <q-page class="flex flex-center">

    <div class="row full-width justify-center q-gutter-y-xl q-my-xl">
      <div v-if="!chainId" class="row col-11  justify-center">
        <div class="display-card accountDisplayCard q-mb-lg col-10 col-lg-3 q-pa-xl">
          <NetworkSwitcher />
        </div>
      </div>
      <div v-else class="display-card accountDisplayCard q-py-lg col-11 col-md-7 col-lg-5 q-gutter-y-lg" style="min-height: 200px;">
        <div class="text-center text-bold">
          Deploy NFT
        </div>
        <div class="text-center text-body2">
          Connected to: {{ chainName }}
        </div>
<!--        <div class="q-px-xl">-->
<!--          <q-select v-model="form.chainIdVal" :options="chainIdOptions" label="Select Chain" />-->
<!--        </div>-->
        <div class="q-px-xl">
          <q-input  v-model="form.name" placeholder="Name Of NFT (ie. HungryBirds)" />
        </div>
        <div class="q-px-xl">
          <q-input  v-model="form.symbol" placeholder="Symbol (ie HBD) " />
        </div>
        <div class="q-px-xl">
          <q-input  v-model="form.baseNFTURI" placeholder="Base Token URI (ie HBD) " />
        </div>
        <div class="q-px-xl">
          <q-input  v-model="form.maxSupply" placeholder="Maximum amount of NFTs to be minted" />
        </div>
        <div class="q-px-xl">
          <q-input  v-model="form.reservedAmt" placeholder="Number Of NFTs Reserved For Team" />
        </div>
        <div class="q-px-xl">
          <q-input  v-model="form.maxPerTx" placeholder="Maximum Minted NFTs Per Transaction" />
        </div>

        <div class="q-px-xl">
          <q-input  v-model="form.maxPerAddr" placeholder="Maximum NFTs An Address Can Mint" />
        </div>

        <div class="q-px-xl">
          <q-input  v-model="form.mintPrice" placeholder="Mint Price (ie 0.08)" />
        </div>

        <!--        <div class="q-px-xl">-->
        <!--          <q-input filled v-model="galleryTokenId" placeholder="(Optional) view a single NFT by adding the token id"  />-->
        <!--        </div>-->
        <div class="row justify-center q-gutter-x-md">
          <q-btn :disable="disableMint" label="Deploy NFT" outline rounded @click="deployNFT" />
          <q-spinner
            v-if="disableMint"
            color="primary"
            size="3em"
          />
        </div>
        <div class="text-negative text-center">
          {{ generalError }}
        </div>
      </div>

      <div  v-if="deployedContractAddr" class="text-center text-h6 col-11 wrap-word">
        Deployed contract Address is : {{ deployedContractAddr }} <q-btn icon="content_copy" @click="copyContract" />
      </div>
    </div>

  </q-page>
</template>

<script>
import {defineComponent, inject} from "vue";
import NetworkSwitcher from "components/NetworkSwitcher";
import {ethers} from "boot/ethers";

import ERC721Temp from 'src/artifacts/contracts/xStarterNFTDeployTemplate.json'
import {CHAIN_ID_TO_NAME} from "src/constants";
import {copyToClipboard} from "quasar";

export default defineComponent({
  name: "NFTDeploymentPage",
  components: {NetworkSwitcher},
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
        name: '',
        symbol: '',
        baseNFTURI: '',
        maxSupply: '',
        maxPerTx: '',
        maxPerAddr: '',
        mintPrice: '',
        reservedAmt: ''
      },
      formErrors: {
        name: '',
        symbol: '',
        baseNFTURI: '',
        maxSupply: '',
        maxPerTx: '',
        maxPerAddr: '',
        mintPrice: '',
        reservedAmt: ''
      },
      disableMint: false,
      generalError: '',
      deployedContractAddr: ''
    }
  },
  computed: {
    chainIdOptions() {
      return this.getChainIdOptions()
    },
    chainName() {
      return this.chainId ? CHAIN_ID_TO_NAME[this.chainId] : ''
    }
  },
  methods: {
    async copyContract() {
      await copyToClipboard(this.deployedContractAddr)
      this.$q.notify('Contract Address Copied!')
    },
    allFieldsFilled() {
      for (const fieldVal of Object.keys(this.form)) {
        if (!this.form[fieldVal]) {
          this.generalError = `${fieldVal} not filled out`
          return false
        }

      }
      this.generalError = ''
      return true
    },
    async deployNFT() {
      if (!this.allFieldsFilled()) {
        return
      }
      this.disableMint = true
      const factory = this.getFactory()
      const form = this.form
      let contract
      try {
        contract = await factory.deploy(
          form.name,
          form.symbol,
          form.baseNFTURI,
          form.maxSupply,
          form.maxPerTx,
          form.maxPerAddr,
          this.$ethers.utils.parseEther(form.mintPrice ? form.mintPrice : '0'),
          form.reservedAmt
        )
      } catch (e) {
        this.generalError = e
        this.disableMint = false
        return
      }
      await contract.deployTransaction.wait()

      this.$q.notify(`Contract Deployed ${contract.address} `)

      this.deployedContractAddr = contract.address
      this.disableMint = false
    }
  },
  mounted() {
  }
})
</script>

<style scoped>

</style>
