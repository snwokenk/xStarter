<template>
  <q-card flat square class="display-card accountDisplayCard q-py-md q-mb-lg q-px-lg q-gutter-y-sm" clickable>
    <q-card-section class="justify-between text-center full-width">
      <div v-if="chainId" class="full-width">
        You're connected to <span class="text-bold" :class="{'text-positive': acceptedChain, 'text-negative': !acceptedChain}">{{ chainIdName }}</span>
      </div>
      <div v-if="!acceptedChain" class="text-warning text-center full-width">
        Please connect to the xDai Layer 2 chain on metamask
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
    return {
      chainId
    }
  },
  computed: {
    chainIdName() {
      return !CHAIN_ID_TO_NAME[this.chainId] ? this.chainId : CHAIN_ID_TO_NAME[this.chainId]
    },
    acceptedChain() {
      return Boolean(ACCEPTED_CHAINS[this.chainId])
    }
  }
})
</script>

<style scoped>

</style>
