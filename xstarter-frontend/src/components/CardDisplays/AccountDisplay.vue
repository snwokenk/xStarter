<template>
  <q-card flat square class="display-card accountDisplayCard q-py-md q-mb-lg q-px-lg q-gutter-y-sm" clickable>
    <q-card-section class="justify-between text-center full-width">
      <div v-if="chainId" class="full-width">
        You're connected to <span class="text-bold" :class="{'text-positive': acceptedChain, 'text-negative': !acceptedChain}">{{ chainIdName }}</span>
      </div>
      <div v-if="!acceptedChain" class="text-warning text-center full-width">
        Please connect to the xDai Layer 2 chain on metamask
      </div>
      <div v-if="chainId && blockInfo.blockNumber !== 0">
        <div>
          Current Block Number: &nbsp; <span class="segoe-bold text-positive">{{blockInfo.blockNumber}}</span>
        </div>
        <div>
          Current Block Timestamp: &nbsp; <span class="segoe-bold text-positive">{{blockInfo.timestamp}}</span>
        </div>

        <div>
          Current Block Date: &nbsp; <span class="segoe-bold text-positive">{{ currentBlockDate.toLocaleString() }}</span>
        </div>
        </div>

    </q-card-section>
  </q-card>
</template>

<script>
import {defineComponent, inject} from "vue";
import {ACCEPTED_CHAINS, CHAIN_ID_TO_NAME} from "src/constants";

export default defineComponent( {
  name: "AccountDisplay",
  setup() {
    const chainId = inject('$chainId')
    const blockInfo = inject('$blockInfo')
    return {
      chainId,
      blockInfo
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
  }
})
</script>

<style scoped>

</style>
