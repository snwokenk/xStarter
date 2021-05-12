<template>
  <q-page class="flex flex-center">
<!--    <img-->
<!--      alt="Quasar logo"-->
<!--      src="~assets/quasar-logo-full.svg"-->
<!--    >-->
    <div class="display-container row q-gutter-md justify-center q-pt-md">
      <LiquidityOfferingDisplay class="display-card col-md-10 col-lg-5"  :liquidity-offering="listOfLiquidityOffering"/>
      <LiquidityOfferingDisplay class="display-card col-md-10 col-lg-5"  :liquidity-offering="listOfLiquidityOffering"/>
<!--      <LiquidityOfferingDisplay class="display-card col-md-10 col-lg-5"  :liquidity-offering="listOfLiquidityOffering"/>-->
    </div>

  </q-page>
</template>

<script>
import { defineComponent } from 'vue';
import LiquidityOfferingDisplay from "components/LiquidityOfferingDisplay";

export default defineComponent({
  name: 'PageIndex',
  components: {LiquidityOfferingDisplay},
  setup() {
    return {}
  },
  computed: {
    listOfLiquidityOffering() {
      return  {
        startDate: '1620702869',
        endDate: '1621221269'
      }
    }
  }
})
</script>
<style scoped lang="scss">
.display-container{
  width: 80%;
  min-height: 300px;

}
</style>
