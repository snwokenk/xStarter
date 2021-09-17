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
          :jsonRPCEndPoint="jsonRPCEndPoint"
          class="col-11 col-md-3 "
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
import {CHAIN_INFO_OBJ} from "src/constants";
import {ethers} from "boot/ethers";

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

  data() {
    return {
      erc721ABI: [
        'function ownerOf(uint256 tokenId) view returns (address owner)',
        'function balanceOf(address owner) view returns (uint256 balance)',
        'function tokenURI(uint256 tokenId) view returns (string memory)',
        'function totalSupply() view returns (uint)'
      ],
      totalSupply: 0
    }
  },
  computed: {
    jsonRPCEndPoint() {
      return CHAIN_INFO_OBJ[this.$route.params.chainId].rpcUrls[0]
    },
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
      return 9
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
      let lastIndex = this.totalSupply > this.current * this.maxPerPage ? this.current * this.maxPerPage : this.totalSupply
      for (let i = (this.current * this.maxPerPage) - this.maxPerPage; i < lastIndex; i++) {
        imgData.push(i)
      }
      return imgData
    },
    erc721Contract() {
      return new ethers.Contract(this.contractAddress, this.erc721ABI, this.getProvider());
    },
    contractAddress() {
      return this.$route.params.contractAddress
    }
  },
  methods: {
    // if need to sign
    async getConnectedContract() {
      if (!this.erc721Contract) {return null}
      return await this.erc721Contract.connect(this.getSigner())
    },
    async readOnlyERC721Contract() {
      const provider  = await new ethers.providers.JsonRpcProvider(this.jsonRPCEndPoint);
      console.log('providers is ', provider)
      return new ethers.Contract(this.contractAddress, this.erc721ABI, provider);
    }
  },
  async mounted() {
    const readOnlyContract = await this.readOnlyERC721Contract()
    this.totalSupply = await readOnlyContract.totalSupply()
  }
}
</script>

<style scoped>

</style>
