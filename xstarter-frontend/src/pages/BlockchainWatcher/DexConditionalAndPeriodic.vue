<template>
  <q-page class="q-pt-md">
    <div v-if="!showOrderForm"   class="row full-width justify-center q-my-xl">
      <q-btn label="Create Another Order" outline @click="showOrderForm = true" />
    </div>
    <div v-else class="row full-width justify-center q-my-xl">
      <OrderCreate @saveOrder="addToOrder"/>
    </div>


    <div v-if="open_orders.buyOrders.length" class="row full-width justify-center q-gutter-y-lg">
      <div v-for="(obj, ind) in open_orders.buyOrders" class="col-12 col-lg-7 row justify-center q-gutter-y-sm  q-pa-xl display-card accountDisplayCard" :key="ind">
        <div v-for="(key, ind2) in Object.keys(obj.orderInfo)" class="col-12" :key="ind2">
          {{ key }} : {{ obj.orderInfo[key]}}
        </div>
<!--        <q-btn :label="obj.isCancelled" />-->
      </div>
    </div>


  </q-page>
</template>

<script>
// todo: add a way of editing and canceling existing polling order,
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
      this.showOrderForm = false

    }
  }
}
</script>

<style scoped>

</style>
