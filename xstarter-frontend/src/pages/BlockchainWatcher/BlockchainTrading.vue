<template>
  <q-page class="q-pt-md">
    <div class="row justify-center q-mb-xl">
      <div>
        Use this tool to watch the supported blockchains and add conditions which can trigger an action
        (notification, buy/sell token on dex, transfer token, call a function on a contract)
      </div>
    </div>
    <div class="row full-width justify-center q-my-xl">
      <div class="col-12 col-md-3">
        <q-btn rounded label="Create A Trigger" outline class="full-width" @click="toggleForm" />
      </div>
    </div>

    <div class="row full-width justify-center q-my-xl">
    <TriggerForm v-if="showTriggerForm" @saveTrigger="onSaveTrigger"/>
    </div>
    <div v-if="triggers" class="row full-width justify-center q-my-xl">
      <ActionBox @startListening="onStartListening" />
    </div>
  </q-page>

</template>

<script>
import {defineComponent} from "vue";
import TriggerForm from "components/BlockchainTrading/TriggerForm";
import ActionBox from "components/BlockchainTrading/ActionBox";
/*** this page will allow users to
 * 1, Start listening for transactions on a blockchain
 * 2, watch the blockchain for a type of transaction, and filter by address, native token amount
 * 3, add an action buy/sell a token from a dex, send a token, send native token
 *
 * ***/

export default defineComponent( {
  name: "BlockchainTrading",
  components: {ActionBox, TriggerForm},
  setup() {
    return {}
  },
  data() {
    return {
      showTriggerForm: false,
      triggers: null
    }
  },
  methods: {
    toggleForm() {
      this.showTriggerForm = !this.showTriggerForm
    },
    onSaveTrigger(value) {
      this.triggers = value
    },

    onStartListening(actionValues) {
      console.log('should start listening', actionValues, this.triggers)
    }
  }

})
</script>

<style scoped>

</style>
