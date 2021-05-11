<template>
  <q-page class="flex flex-center">
<!--    <img-->
<!--      alt="Quasar logo"-->
<!--      src="~assets/quasar-logo-full.svg"-->
<!--    >-->
    <div class="display-container">
      <LiquidityOfferingDisplay class="full-width"  :liquidity-offering="{}"/>
    </div>

  </q-page>
</template>

<script>
import { defineComponent } from 'vue';
import LiquidityOfferingDisplay from "components/LiquidityOfferingDisplay";

export default defineComponent({
  name: 'PageIndex',
  components: {LiquidityOfferingDisplay}
})
</script>
<style scoped lang="scss">
.display-container{
  width: 50%;
  min-width: 320px;
  max-width: 550px;
}
</style>
