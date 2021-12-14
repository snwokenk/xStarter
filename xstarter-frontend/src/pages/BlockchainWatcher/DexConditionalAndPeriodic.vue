<template>
  <q-page class="q-pt-md">
    <div  class="row full-width justify-center q-my-xl">
      <OrderCreate />
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
}
</script>

<style scoped>

</style>
