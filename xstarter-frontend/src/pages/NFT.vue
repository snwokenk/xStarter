<template>
  <q-page class="flex flex-center q-py-xl">
<!--    <div class="display-card accountDisplayCard account-display-text q-pa-xl">-->
<!--      This section will allow the creation and sale of NFTs priced in xStarter Tokens-->
<!--    </div>-->
    <div class="row full-width justify-center q-gutter-y-xl">
      <div class="col-11 col-md-9 col-lg-7 col-xl-6">
        <q-btn rounded outline label="Deploy Your NFT" class="homeButtons full-width" @click="$router.push('/nft/deploy')" />
      </div>
      <div class="col-11 col-md-9 col-lg-7 col-xl-6">
        <q-btn rounded outline label="Generate A Mint Page For Your NFT" class="homeButtons full-width" @click="$router.push('/ilo')" />
      </div>
      <q-space class="col-12" />

      <div class="display-card accountDisplayCard q-py-lg col-11 col-md-7 col-lg-5 q-gutter-y-lg" style="min-height: 200px;">
        <div class="text-center text-bold">
          View NFT Gallery
        </div>
        <div class="q-px-xl">
          <q-select v-model="chainIdVal" :options="chainIdOptions" label="Select Chain" />
        </div>
        <div class="q-px-xl">
          <q-input  v-model="galleryAddr" placeholder="Enter NFT Address (Required)" />
        </div>
        <!--        <div class="q-px-xl">-->
        <!--          <q-input filled v-model="galleryTokenId" placeholder="(Optional) view a single NFT by adding the token id"  />-->
        <!--        </div>-->
        <div class="row justify-center">
          <q-btn :disable="!galleryAddr" label="View" outline rounded @click="goToGallery" />
        </div>
      </div>
    </div>


  </q-page>
</template>

<script>
import {defineComponent, inject, provide} from 'vue';

export default defineComponent({
  name: 'NFT',
  setup() {
    const getProvider = inject('$getProvider')
    const getChainIdOptions = inject('$getChainIdOptions')
    const getSigner = inject('$getSigner')
    const getLaunchPadContract = inject('$getLaunchPadContract')
    const getConnectedAndPermissioned = inject('$getConnectedAndPermissioned')
    console.log('provider is ', getProvider())
    return {getProvider, getSigner, getLaunchPadContract, getConnectedAndPermissioned, getChainIdOptions}
  },
  computed: {
    chainIdOptions() {
      return this.getChainIdOptions()
    }
  },
  data() {
    return {
      chainIdVal: {value: '1', label: 'Ethereum Main Net'},
      galleryAddr: '',
      galleryTokenId: ''
    }
  },
  methods: {
    goToGallery() {
      this.$router.push({name: 'nft_gallery', params: {chainId: this.chainIdVal.value, contractAddress: this.galleryAddr}})
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
