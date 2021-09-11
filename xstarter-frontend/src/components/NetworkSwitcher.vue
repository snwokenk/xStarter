<template>
<div v-if="showUI" class="row justify-center q-gutter-y-md">
  <div v-if="isWrongNetwork" class="text-negative text-bold col-12 text-center">
    Wrong Network !
  </div>
  <div>
    <q-btn outline rounded :label="bntLabel" @click="switchToNetwork" />
  </div>

</div>
</template>

<script>
import {inject} from "vue";
import {CHAIN_ID_TO_NAME, CHAIN_INFO_OBJ} from "src/constants";
// use this component to check for the right network and offer a chance to swtich
export default {
  name: "NetworkSwitcher",
  setup() {
    const getProvider = inject('$getProvider')
    const getSigner = inject('$getSigner')
    const getLaunchPadContract = inject('$getLaunchPadContract')
    const connectedAccount = inject('$connectedAccounts')
    const getConnectedAndPermissioned = inject('$getConnectedAndPermissioned')
    let chainId = inject('$chainId')
    const jsonRPCEndpoint = inject('$jsonRPCEndpoint')
    const metaMaskEthereumChainAddRequest = inject('$metaMaskEthereumChainAddRequest') // function
    // const mintABi = xStarterERC721Code.abi
    console.log('provider is ', getProvider())
    return {getProvider, getSigner, getLaunchPadContract, getConnectedAndPermissioned, metaMaskEthereumChainAddRequest, connectedAccount, chainId, jsonRPCEndpoint}
  },
  props: {
    requiredNetworkId: {
      type: [String, Number],
      required: false
    },
    optionalNetworkID: {
      type: [String, Number],
      required: false
    },

  },
  computed: {
    isWrongNetwork() {
      return !!(this.requiredNetworkId && this.chainId && (this.requiredNetworkId !== this.chainId));
    },
    showUI() {
      return !!((this.optionalNetworkID && parseInt(this.optionalNetworkID) !== parseInt(this.chainId)) || this.isWrongNetwork)
    },
    providedChainID() {
      return this.requiredNetworkId ? parseInt(this.requiredNetworkId) :
        this.optionalNetworkID ? parseInt(this.requiredNetworkId) : null
    },
    bntLabel() {
      return this.providedChainID ? `Switch to ${CHAIN_ID_TO_NAME[this.providedChainID]}` : ''
    }

  },
  methods: {
    async switchToNetwork() {
      await this.metaMaskEthereumChainAddRequest(
        CHAIN_INFO_OBJ[this.providedChainID].chainId,
        CHAIN_INFO_OBJ[this.providedChainID]
      )
    }
  }
}
</script>

<style scoped>

</style>
