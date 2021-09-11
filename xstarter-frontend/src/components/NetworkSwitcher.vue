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
import MetaMaskOnboarding from "@metamask/onboarding";
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
    let showWalletConnectModal = inject('$showWalletConnectModal')
    const jsonRPCEndpoint = inject('$jsonRPCEndpoint')
    const metamaskInstalled = inject('$metamaskInstalled')
    const metaMaskEthereumChainAddRequest = inject('$metaMaskEthereumChainAddRequest') // function
    // const mintABi = xStarterERC721Code.abi
    console.log('provider is ', getProvider())
    return {
      getProvider,
      getSigner,
      getLaunchPadContract,
      getConnectedAndPermissioned,
      metaMaskEthereumChainAddRequest,
      connectedAccount,
      chainId,
      jsonRPCEndpoint,
      showWalletConnectModal,
      metamaskInstalled
    }
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
  data() {
    return {
      calledConnect: false
    }
  },
  computed: {
    isWrongNetwork() {
      return !!(this.requiredNetworkId && this.chainId && (this.requiredNetworkId !== this.chainId));
    },
    showUI() {
      if (!this.chainId) { return true }
      return !!((this.optionalNetworkID && parseInt(this.optionalNetworkID) !== parseInt(this.chainId)) || this.isWrongNetwork)
    },
    providedChainID() {
      return this.requiredNetworkId ? parseInt(this.requiredNetworkId) :
        this.optionalNetworkID ? parseInt(this.requiredNetworkId) : null
    },
    bntLabel() {
      if (!this.connectedAccount.length) {
        return 'Connect To Metamask'
      }
      return this.providedChainID ? `Switch to ${CHAIN_ID_TO_NAME[this.providedChainID]}` : ''
    }

  },
  methods: {
    async switchToNetwork() {
      if (this.bntLabel === 'Connect To Metamask') {
        return await this.connectOrInstallBtn()
      }
      await this.metaMaskEthereumChainAddRequest(
        CHAIN_INFO_OBJ[this.providedChainID].chainId,
        CHAIN_INFO_OBJ[this.providedChainID]
      )
    },
    async connectOrInstallBtn() {
      if (!this.connectedAndPermissioned) {
        this.calledConnect = true
        if (this.metamaskInstalled) {
          this.showWalletConnectModal = !this.showWalletConnectModal
        }else {
          const onboarding = new MetaMaskOnboarding();
          onboarding.startOnboarding()
        }
      }

    },
  },
  watch: {
    connectedAccount: function (newObj, oldObj) {
      console.log('connected watch old, new', oldObj, newObj)
      console.log('connected watch old, new', oldObj.length, newObj.length)
      if ((oldObj.length && !newObj.length) || (newObj.length && !oldObj.length)) {
        if (this.calledConnect) {
          window.location.reload()
        }

      }

    }
  }
}
</script>

<style scoped>

</style>
