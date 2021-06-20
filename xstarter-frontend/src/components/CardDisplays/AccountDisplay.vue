<template>
  <q-card flat square class="display-card accountDisplayCard q-py-md q-mb-lg q-px-lg q-gutter-y-sm" clickable>
    <q-card-section class="justify-between  account-display-text text-center full-width">
      <div class="full-width row justify-between">
        <div class="col-auto">
          <div v-if="chainId" class="full-width">
            You're connected to <span class="text-bold" :class="{'text-positive': acceptedChain, 'text-negative': !acceptedChain}">{{ chainIdName }}</span>
          </div>
          <div v-if="!metamaskInstalled" class="text-warning text-center full-width">
            Please Install Metamask
          </div>
          <div v-else-if="!connectedAndPermissioned" class="text-warning text-center full-width">
            Click the Connect Button to connect your Metamask wallet to xStarter
          </div>
          <div v-else-if="!acceptedChain" class="text-warning text-center full-width">
            Please connect to the xDai Layer 2 chain on metamask
          </div>
        </div>

        <div v-if="chainId && blockInfo.blockNumber !== 0" class="col-12 col-lg-6 text-left">
          Current Block Number: &nbsp; <span class="segoe-bold text-positive">{{blockInfo.blockNumber}}</span>
        </div>
      </div>

        <div v-if="chainId && blockInfo.blockNumber !== 0" class="row justify-between">

          <div class="col-12 col-lg-5 text-left">
            Current Block Timestamp: &nbsp; <span class="segoe-bold text-positive">{{blockInfo.timestamp}}</span>
          </div>

          <div class="col-12 col-lg-6 text-left">
            Current Block Date: &nbsp; <span class="segoe-bold text-positive">{{ currentBlockDate.toLocaleString() }}</span>
          </div>
        </div>



<!--      <div v-if="connectedAndPermissioned" class="q-mt-lg">-->
<!--        <q-btn outline rounded label="Create An Initial Liquidity Offering" />-->
<!--      </div>-->
      <div v-if="chainId !== 100 && connectedAndPermissioned" class="text-center q-mt-lg text-uppercase">
        <q-btn outline rounded label="Switch To xDai Chain to Metamask" @click="addXDai" />
      </div>
      <div v-if="chainId !== 77 && connectedAndPermissioned" class="text-center q-mt-lg text-uppercase">
        <q-btn outline rounded label="Switch To SPOA TEST network to Metamask" @click="addSPOATest" />
      </div>

    </q-card-section>
  </q-card>
</template>

<script>
import {defineComponent, inject, provide} from "vue";
import {ACCEPTED_CHAINS, CHAIN_ID_TO_NAME} from "src/constants";

export default defineComponent( {
  name: "AccountDisplay",
  setup() {
    const chainId = inject('$chainId')
    const blockInfo = inject('$blockInfo')
    const connectedAndPermissioned = inject('$connectedAndPermissioned',)
    const metaMaskEthereumChainAddRequest = inject('$metaMaskEthereumChainAddRequest') // function
    const metamaskInstalled = inject('$metamaskInstalled')
    return {
      chainId,
      metamaskInstalled,
      blockInfo,
      connectedAndPermissioned,
      metaMaskEthereumChainAddRequest
    }
  },
  computed: {
    chainIdName() {
      return !CHAIN_ID_TO_NAME[this.chainId] ? this.chainId : CHAIN_ID_TO_NAME[this.chainId]
    },
    acceptedChain() {
      return Boolean(ACCEPTED_CHAINS[this.chainId])
    },
    currentBlockDate() {
      return new Date(this.blockInfo.timestamp * 1000)
    }
  },
  methods: {
    async addXDai() {
      await this.metaMaskEthereumChainAddRequest(
        '0x64',
        'xDai',
        'xDai',
        'xDai',
        ['https://rpc.xdaichain.com/', 'https://xdai.poanetwork.dev/', 'https://dai.poa.network/'],
        ['https://blockscout.com/xdai/mainnet/'],
        ['']
      )
    },
    async addSPOATest() {
      await this.metaMaskEthereumChainAddRequest(
        '0x4D',
        'SPOA',
        'SPOA',
        'SPOA',
        ['https://sokol.poa.network'],
        ['https://blockscout.com/poa/sokol'],
        ['']
      )
    }
  }
})
</script>

<style scoped>

</style>
