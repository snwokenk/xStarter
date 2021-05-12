<template>
  <q-page class="flex flex-center">
<!--    <img-->
<!--      alt="Quasar logo"-->
<!--      src="~assets/quasar-logo-full.svg"-->
<!--    >-->
    <div class="display-container row q-gutter-y-lg q-gutter-x-md justify-center q-pt-md">
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
        startDate: '1620530069',
        endDate: '1620616469',
        logo_url: '/xstarter_blue2.jpg'
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
