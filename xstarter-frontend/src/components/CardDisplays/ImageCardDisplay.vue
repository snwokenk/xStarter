<template>
  <q-card
    @mouseenter="isHovered = true"
    @mouseleave="isHovered = false"
    :flat="isHovered"
    :bordered="isHovered"
    class="cursor-pointer"
  >
    <img :src="imgSource" v-if="!isHovered" style="width: 100%">
    <q-card-section v-if="imgDesc && !isHovered" class="q-mt-sm">
      <div>
        {{imgDesc}}
      </div>
      <div>
        Owner : &nbsp; {{ ownerOf.substring(0, 9) }}.....
      </div>
    </q-card-section>
    <q-card-section v-if="isHovered">
      <div  >
        <div  class="row" v-for="(obj, ind) in imgAttrs" :key="ind">
          <div class="col-12 text-body2 text-bold text-center">
            {{ obj.trait_type }}
          </div>
          <div class="col-12 text-caption text-center">
            {{ obj.value }}
          </div>
        </div>
      </div>
    </q-card-section>
  </q-card>
</template>

<script>
import {ethers} from "boot/ethers";
import {inject, provide, ref} from "vue";

export default {
  name: "ImageCardDisplay",
  setup() {
    const getProvider = inject('$getProvider')
    const getSigner = inject('$getSigner')
    const getLaunchPadContract = inject('$getLaunchPadContract')
    const connectedAccount = inject('$connectedAccounts')
    let chainId = inject('$chainId')
    const getConnectedAndPermissioned = inject('$getConnectedAndPermissioned')
    const getReadOnlyERC721Contract = inject('$getReadOnlyERC721Contract')
    // const mintABi = xStarterERC721Code.abi
    console.log('provider is ', getProvider())
    return {getProvider, getSigner, getLaunchPadContract, getConnectedAndPermissioned, getReadOnlyERC721Contract, connectedAccount, chainId, current: ref(1)}
  },
  props: {
    // imgSource: {
    //   type: String,
    //   required: true
    // },
    baseURI: {
      type: String,
      required: true
    },
    tokenId: {
      type: [String, Number]
    },
    jsonRPCEndPoint: {
      type: String,
      required: true
    }
  },
  data() {
    return {
      imgSource: '',
      imgDesc: '',
      imgAttrs: '',
      isHovered: false,
      ownerOf: '',
      erc721ABI: [
        'function ownerOf(uint256 tokenId) view returns (address owner)',
        'function balanceOf(address owner) view returns (uint256 balance)',
        'function tokenURI(uint256 tokenId) view returns (string memory)',
        'function totalSupply() view returns (uint)'
      ]
    }
  },
  computed: {
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
    // async readOnlyERC721Contract() {
    //   const provider  = await new ethers.providers.JsonRpcProvider(this.jsonRPCEndPoint);
    //   console.log('providers is ', provider)
    //   return new ethers.Contract(this.contractAddress, this.erc721ABI, provider);
    // },
    async getTokenURIMetadata(tokenURI) {
      const QmIndex = tokenURI.indexOf('Qm')
      if (tokenURI.toLowerCase().includes('http')) {
        return await this.$api.get(tokenURI)
      }else if (tokenURI.toLowerCase().includes('ipfs') && QmIndex > -1) {
        return await this.$api.get('https://ipfs.io/ipfs/' + tokenURI.slice(QmIndex))
      }
    },
    async getImgSource(rawImgSrc) {
      const QmIndex = rawImgSrc.indexOf('Qm')
      console.log('qm included ', QmIndex)
      if (rawImgSrc.toLowerCase().includes('http')) {
        return rawImgSrc
      }else if (rawImgSrc.toLowerCase().includes('ipfs') && QmIndex > -1) {

        return 'https://ipfs.io/ipfs/' + rawImgSrc.slice(QmIndex)
      }
    }
  },
  async mounted() {
    // get metadata should have image, description
    // const metaData = await this.$api.get(`${this.baseURI}${this.tokenId}`)
    console.log('the endpoint is', this.jsonRPCEndPoint)
    const readOnlyContract = await this.getReadOnlyERC721Contract()
    const tokenURI = await readOnlyContract.tokenURI(this.tokenId)
    console.log('the tokenURI is', tokenURI)
    this.ownerOf = await readOnlyContract.ownerOf(this.tokenId)
    // const metaData = await this.$api.get(tokenURI)
    const metaData = await this.getTokenURIMetadata(tokenURI)
    console.log('metadata is', this.tokenId, metaData)
    this.imgSource = await this.getImgSource(metaData.data.image)
    this.imgDesc = metaData.data.description
    this.imgAttrs = metaData.data.attributes ? metaData.data.attributes : []

  }
}
</script>

<style scoped>

</style>
