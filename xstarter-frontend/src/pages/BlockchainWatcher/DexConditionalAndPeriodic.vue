<template>
  <q-page class="q-pt-md">
    <div v-if="showOrderForm && formType === 'buy'" class="row full-width justify-center q-my-xl">
      <OrderCreateNativeToToken @saveOrder="addToOrder"/>
    </div>
    <div v-else-if="showOrderForm && formType === 'sell'" class="row full-width justify-center q-my-xl">
      <OrderCreateTokenToNative @saveOrder="addToOrder"/>
    </div>
    <div v-else class="row full-width justify-center q-gutter-md q-my-xl">
      <q-btn label="Create Buy Order" outline @click="() => showOrder('buy')" />
      <q-btn label="Create Sell Order" outline @click="() => showOrder('sell')" />
    </div>


    <div v-if="open_orders.buyOrders.length" class="row full-width justify-center q-my-xl q-gutter-y-lg">
      <div v-for="(obj, ind) in open_orders.buyOrders" class="col-12 col-lg-7 row justify-center q-gutter-y-sm  q-pa-xl display-card accountDisplayCard" :key="ind">
        <div v-for="(key, ind2) in Object.keys(obj.orderInfo)" class="col-12" :key="ind2">
          {{ key }} : {{ obj.orderInfo[key]}}
        </div>
<!--        <q-btn :label="obj.isCancelled" />-->
      </div>
    </div>

    <div v-if="open_orders.sellOrders.length" class="row full-width justify-center q-my-xl q-gutter-y-lg">
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
import OrderCreateNativeToToken from "components/BlockchainTrading/OrderCreateNativeToToken";
import OrderCreateTokenToNative from "components/BlockchainTrading/OrderCreateTokenToNative";
/***
 * using xStarter contract
 * creates conditional orders. These orders can keep being tried till it goes through
 * ***/
export default {
  name: "DexConditionalAndPeriodic",
  components: {OrderCreateTokenToNative, OrderCreateNativeToToken},
  data() {
    return {
      showOrderForm: false,
      formType: 'sell',
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

    },
    showOrder(formType = 'buy') {
      console.log('form type is', formType)
      this.formType = formType
      this.showOrderForm = true
    },
    closeOrderForm() {
      this.showOrderForm = false
      this.formType = ''

    }
  }
}
</script>

<style scoped>

</style>
