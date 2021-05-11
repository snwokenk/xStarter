<template>
<q-card>
  <div class="text-h1">Samuel</div>
</q-card>
</template>

<script>
import { defineComponent } from 'vue'
export default defineComponent( {
  name: "LiquidityOfferingDisplay",
  props: {
    liquidityOffering: {
      type: Object,
      required: true
    }
  },
  setup(){
    return {}
  }
})
</script>

<style scoped>

</style>
