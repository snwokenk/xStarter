<template>
  <q-page class="q-pt-md">
    <div v-if="showOrderForm"  class="row full-width justify-center q-my-xl">
      <OrderCreate @saveOrder="addToOrder"/>
    </div>
  </q-page>
</template>

<script>
import OrderCreate from "components/BlockchainTrading/OrderCreate";
/***
 * using xStarter contract
 * creates conditional orders. These orders can keep being tried till it goes through
 * ***/
export default {
  name: "DexConditionalAndPeriodic",
  components: {OrderCreate},
  data() {
    return {
      showOrderForm: true,
      open_orders: {
        sellOrders: [],
        buyOrders: []
      }
    }
  },
  methods: {
    addToOrder(orderObj) {
      this.open_orders[orderObj.name].push(orderObj.orderInst)
      // this.showOrderForm = false

    }
  }
}
</script>

<style scoped>

</style>
