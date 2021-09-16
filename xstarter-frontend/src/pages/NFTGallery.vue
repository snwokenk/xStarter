<template>
  <q-page>
    <div class="full-width justify-center row" style="border-bottom: 1px solid gray;">
<!--      <q-img v-if="$q.platform.is.mobile" :src="collectionBanner" style="width: 100%" />-->
      <q-img :src="collectionBanner" style="width: 80%; max-height: 300px"  />
    </div>
    <div class="full-width row justify-center" :style="$q.platform.is.mobile ? 'margin-top: -25px;' : 'margin-top: -50px;'">

      <q-avatar :size="$q.platform.is.mobile ? '125px' : '200px'">
        <img :src="collectionProfileLogo"  alt=""/>
      </q-avatar>
    </div>
    <div class="full-width justify-center row">
      <div class="row q-px-xl q-gutter-lg justify-center q-pb-xl" style="margin-top: 150px; max-width: 1250px">
        <ImageCardDisplay
          v-for="id in currentListOfTokenId"
          img-source="https://hungrybirds.art/firstgen/1.png"
          :baseURI="baseURI"
          :tokenId="id"
          :key="id"
          class="col-11 col-md-3"
        />
      </div>
    </div>
    <div class="q-pa-lg flex flex-center">
      <q-pagination
        v-model="current"
        color="black"
        :max="totalPages"
        :max-pages="6"
        :boundary-numbers="false"
      />
    </div>
  </q-page>

</template>

<script>
import {inject, ref} from "vue";
import ImageCardDisplay from "components/CardDisplays/ImageCardDisplay";

export default {
  name: "NFTGallery",
  components: {ImageCardDisplay},
  setup() {
    const getProvider = inject('$getProvider')
    const getSigner = inject('$getSigner')
    const getLaunchPadContract = inject('$getLaunchPadContract')
    const connectedAccount = inject('$connectedAccounts')
    let chainId = inject('$chainId')
    const getConnectedAndPermissioned = inject('$getConnectedAndPermissioned')
    // const mintABi = xStarterERC721Code.abi
    console.log('provider is ', getProvider())
    return {getProvider, getSigner, getLaunchPadContract, getConnectedAndPermissioned, connectedAccount, chainId, current: ref(1)}
  },
  computed: {
    collectionBanner() {
      return '/HungryBirds/HungryBirdsLogo.png'
    },
    collectionProfileLogo() {
      return '/HungryBirds/hungryBirds_square_logo.png'
    },
    maxPerPage() {
      return 12
    },
    totalItems() {
      return 10500
    },
    totalMinted() {
      return 10500
    },
    totalPages() {
      return Math.ceil(this.totalItems / this.maxPerPage)
    },
    baseURI() {
      return 'https://hungrybirds.art/firstgen/'
    },
    imageExtension() {
      return '.png'
    },
    currentListOfTokenId() {
      let imgData = []
      let lastIndex = this.totalMinted > this.current * this.maxPerPage ? this.current * this.maxPerPage : this.totalMinted
      for (let i = (this.current * this.maxPerPage) - this.maxPerPage; i < lastIndex; i++) {
        imgData.push(i)
      }
      return imgData
    },
    imagesObj() {
      let imgData = []

      for (let i = (this.current * this.maxPerPage) - this.maxPerPage; i < lastIndex; i++) {
        imgData.push(i)
      }
      return imgData
    }
  }
}
</script>

<style scoped>

</style>
