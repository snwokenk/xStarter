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
    <TriggerForm v-if="showTriggerForm"/>
    </div>
  </q-page>

</template>

<script>
import {defineComponent} from "vue";
import TriggerForm from "components/BlockchainTrading/TriggerForm";
/*** this page will allow users to
 * 1, Start listening for transactions on a blockchain
 * 2, watch the blockchain for a type of transaction, and filter by address, native token amount
 * 3, add an action buy/sell a token from a dex, send a token, send native token
 *
 * ***/

export default defineComponent( {
  name: "BlockchainTrading",
  components: {TriggerForm},
  setup() {
    return {}
  },
  data() {
    return {
      showTriggerForm: false
    }
  },
  methods: {
    toggleForm() {
      this.showTriggerForm = !this.showTriggerForm
    }
  }

})
</script>

<style scoped>

</style>
