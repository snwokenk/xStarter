<template>
<div v-if="showUI" class="row justify-center q-gutter-y-md">
  <div v-if="useAsManualSwitcher && connected">
      <div class="q-px-xl">
        <q-select :model-value="chainVal" :options="chainIdOptions" label="Switch Chain" @update:model-value="switchToNetworkOnSelect" />
      </div>
  </div>
  <div v-else class="col-12 row justify-center">
    <div v-if="isWrongNetwork" class="text-negative text-bold col-12 text-center">
      Wrong Network !
    </div>
    <div v-if="bntLabel === 'Connect Wallet' && $q.platform.is.mobile" class="text-negative text-bold">
      Mobile Users access this site through your in-wallet browser!
    </div>
    <div>
      <q-btn outline rounded :label="bntLabel" @click="switchToNetwork" />
    </div>
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
    const getChainIdOptions = inject('$getChainIdOptions')
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
      getChainIdOptions,
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
    useAsManualSwitcher: {
      type: Boolean,
      default: false
    }

  },
  data() {
    return {
      calledConnect: false,
      chainVal: null
    }
  },
  computed: {
    connected() {
      return !!this.connectedAccount.length
    },
    chainIdOptions() {
      return this.getChainIdOptions()
    },
    isWrongNetwork() {
      return !!(this.requiredNetworkId && this.chainId && (this.requiredNetworkId !== this.chainId));
    },
    showUI() {
      if (!this.chainId) { return true }
      return !!(
        (this.optionalNetworkID && parseInt(this.optionalNetworkID) !== parseInt(this.chainId)) ||
        this.isWrongNetwork ||
        (this.useAsManualSwitcher && this.connected)
      )
    },
    providedChainID() {
      return this.requiredNetworkId ? parseInt(this.requiredNetworkId) :
        this.optionalNetworkID ? parseInt(this.requiredNetworkId) : null
    },
    bntLabel() {
      if (!this.connected) {
        return 'Connect Wallet'
      }
      return this.providedChainID ? `Switch to ${CHAIN_ID_TO_NAME[this.providedChainID]}` : ''
    }

  },
  methods: {
    async switchToNetwork() {
      if (this.bntLabel === 'Connect Wallet') {
        return await this.connectOrInstallBtn()
      }
      await this.metaMaskEthereumChainAddRequest(
        CHAIN_INFO_OBJ[this.providedChainID].chainId,
        CHAIN_INFO_OBJ[this.providedChainID]
      )
    },
    async switchToNetworkOnSelect(val) {
      try {
        await this.metaMaskEthereumChainAddRequest(
          CHAIN_INFO_OBJ[val.value].chainId,
          CHAIN_INFO_OBJ[val.value]
        )
        this.chainVal = val
      }catch (e) {
        console.log(e)
      }

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
  mounted() {
    if (this.connected) {
      this.chainVal = this.chainIdOptions.find(obj => obj.value === this.chainId.toString())
    }
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
