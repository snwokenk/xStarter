<template>
  <q-form class=" display-card accountDisplayCard q-py-lg col-11 col-md-7 col-lg-5 q-gutter-y-lg" @submit.prevent.stop="generatePage" style="min-height: 200px;">
    <div class="text-center text-bold">
      Create A BlockChain Trigger
    </div>
    <div class="q-px-xl">
      <q-select v-model="form.blockchain" :options="arrayOfBlockChains" :rules="[val => !!val || 'Field is required']" label="Select Blockchain" />
    </div>

    <div class="q-px-xl">
      <q-select v-model="form.triggerType" :options="arrayOfTriggerTypes" :rules="[val => !!val || 'Field is required']" label="Type Of Trigger" />
    </div>

    <div v-if="arrayOfAvailableDex" class="q-px-xl">
      <q-select v-model="form.selectedDex" :options="arrayOfAvailableDex" label="Select DEX" class="full-width"/>
    </div>

    <div v-if="form.selectedDex" class="q-px-xl">
      <q-select v-model="form.selectedFunctions" multiple :options="availableFunctions" label="Select Function(s) To Create Triggers" class="full-width"/>
    </div>
    <div v-if="form.selectedFunctions.length" class="q-px-xl row">
      <div v-for="obj in form.selectedFunctions" class="col-12 row" :key="obj.label">
<!--        <FunctionConditionals :function-input-obj="obj" />-->
        <FunctionConditionals2 :function-input-obj="obj" />


      </div>
    </div>

<!--    <div class="q-px-xl">-->
<!--      <q-input  v-model="form.name" :rules="[val => !!val || 'Field is required']" placeholder="Name of NFT (ie. HungryBirds)" />-->
<!--    </div>-->
<!--    <div class="q-px-xl">-->
<!--      <q-input  v-model="form.logoURL" placeholder="URL for you logo" />-->
<!--    </div>-->
<!--    <div class="q-px-xl">-->
<!--      <q-input outlined v-model="form.description"  :rules="[val => !!val || 'Field is required']" placeholder="Description of your NFT project (Required)" type="textarea" style="min-height: 100px" />-->
<!--    </div>-->
<!--    <div class="q-px-xl">-->
<!--      <q-input  v-model="arrayOfImages" placeholder="Comma separated sample image links(optional)" />-->
<!--    </div>-->
<!--    <div class="q-px-xl">-->
<!--      <q-input  v-model="form.gif" placeholder="link to Gif (optional if images provided)" />-->
<!--    </div>-->
<!--    <div class="q-px-xl">-->
<!--      <q-input  v-model="form.website" :rules="[val => !!val || 'Field is required']" placeholder="Website of NFT project" />-->
<!--    </div>-->
<!--    <div class="q-px-xl">-->
<!--      <q-input  v-model="form.socialMedia.twitter" placeholder="Twitter handle (optional)" />-->
<!--    </div>-->
<!--    <div class="q-px-xl">-->
<!--      <q-input  v-model="form.socialMedia.discord" placeholder="Discord handle (optional)" />-->
<!--    </div>-->
<!--    <div class="q-px-xl">-->
<!--      <q-input  v-model="form.socialMedia.telegram" placeholder="Telegram handle (optional)" />-->
<!--    </div>-->
<!--    <div class="q-px-xl">-->
<!--      <q-input  v-model="form.socialMedia.instagram" placeholder="Instagram handle (optional)" />-->
<!--    </div>-->
<!--    <div class="q-px-xl">-->
<!--      <q-input  v-model="form.NFTMeta.contractAddress" :rules="[val => !!val || 'Field is required']" placeholder="Address of NFT Contract" />-->
<!--    </div>-->
<!--    <div class="q-px-xl">-->
<!--      <q-input  v-model="form.NFTMeta.mintFunction" :rules="[val => !!val || 'Field is required']" placeholder="Name of function, on smart contract, that is called to mint" />-->
<!--    </div>-->
<!--    <div class="q-px-xl">-->
<!--      <q-input  v-model="form.NFTMeta.totalMint" :rules="[val => !!val || 'Field is required']" placeholder="Total number of NFTs to be minted" />-->
<!--    </div>-->
<!--    <div class="q-px-xl">-->
<!--      <q-input  v-model="form.NFTMeta.reservedAmt" :rules="[val => !!val || 'Field is required']" placeholder="Number of NFTs reserved for team, etc" />-->
<!--    </div>-->

<!--    <div class="q-px-xl">-->
<!--      <q-input  v-model="form.NFTMeta.maxMintPerTX" :rules="[val => !!val || 'Field is required']" placeholder="Number of NFTs that can be minted per transaction" />-->
<!--    </div>-->
<!--    <div class="q-px-xl">-->
<!--      <q-input  v-model="form.NFTMeta.maxPerAddr" :rules="[val => !!val || 'Field is required']" placeholder="Total number of NFTs an address can mint" />-->
<!--    </div>-->

<!--    <div class="q-px-xl">-->
<!--      <q-input  v-model="form.NFTMeta.mintPriceInEthers" :rules="[val => !!val || 'Field is required']" placeholder="Mint Price (ie 0.08)" />-->
<!--    </div>-->

<!--    <div class="q-px-xl">-->
<!--      <q-input outlined v-model="abi" :rules="[val => !!val || 'Field is required']" placeholder="Paste contract ABI" type="textarea" style="min-height: 100px" />-->
<!--    </div>-->

<!--    <div class="row justify-center q-gutter-x-md">-->
<!--      <q-btn :disable="disableBtn" label="Generate Page" outline rounded @click="generatePage" type="submit" />-->
<!--      <q-spinner-->
<!--        v-if="disableBtn"-->
<!--        color="primary"-->
<!--        size="3em"-->
<!--      />-->
<!--    </div>-->

<!--    <div class="text-negative text-center">-->
<!--      {{ generalError }}-->
<!--    </div>-->

<!--    <div  v-if="generatedPageUrl" class="text-center text-h6 col-11 wrap-word">-->
<!--      Mint Page URL: {{ generatedPageUrl }} <q-btn icon="content_copy" @click="copyContract" /><q-btn icon="open_in_new" @click="() => openLink(generatedPageUrl)" />-->
<!--    </div>-->
  </q-form>
</template>

<script>
import {defineComponent} from "vue";
import {ARRAY_OF_BLOCKCHAINS, BLOCKCHAIN_TO_DEX} from "src/constants";
// import FunctionConditionals from "components/BlockchainTrading/FunctionConditionals";
import FunctionConditionals2 from "components/BlockchainTrading/FunctionConditionals2";

export default defineComponent(  {
  name: "TriggerForm",
    components: {FunctionConditionals2},
    data() {
    return {
      form: {
        blockchain: null,
        triggerType: null,
        selectedDex: null,
        selectedFunctions: []
      },
      availableFunctions: []
    }
  },
  computed: {
    arrayOfAvailableDex() {
      if (this.form.triggerType && this.form.triggerType.value === 1) {
        return BLOCKCHAIN_TO_DEX[this.form.blockchain.value]
      }
      return null
    },
    arrayOfBlockChains() {
      return [...ARRAY_OF_BLOCKCHAINS]
    },
    arrayOfTriggerTypes() {
      return [
        {
          label: 'Watch DEX Transactions',
          value: 1
        },
        {
          label: 'Watch Native Token Transfers',
          value: 2
        },
        {
          label: 'Watch Contract Function Calls',
          value: 3
        },
      ]
    }
  },
  watch: {
    'form.triggerType': function () {
      this.form.selectedDex = null
      this.form.selectedFunctions = []
    },
    'form.selectedDex': function (val, oldVal) {
      if (!val || !val.routerABI) { return }
      const abi = JSON.parse(val.routerABI)
      const temp = []

      for (const obj of abi) {
        if(obj.stateMutability in {nonpayable: true, payable: true} && obj.type === 'function' && obj.name) {
          temp.push({label: obj.name, value: obj})
        }
      }
      this.availableFunctions = temp
      console.log(this.availableFunctions)
    }
  }
}
)
</script>

<style scoped>

</style>
