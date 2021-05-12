<template>
<q-card flat square class="q-py-md q-px-lg q-gutter-y-md">
  <div class="display-card-date-text" v-html="startLiveOrEndDisplay" />
  <q-card-section horizontal class="justify-between">
    <div>
      <q-avatar square size="4rem">
        <img :src="liquidityOffering.logo_url">
      </q-avatar>
    </div>
    <div class="q-gutter-y-md">
      <div class="display-card-duration-container display-card-duration-text"> Duration 2 days</div>
      <div class="display-card-duration-container display-card-duration-text"> Starts in 21 days</div>
    </div>

  </q-card-section>
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
  },
  computed: {
    startTimestamp() {
      return parseInt(this.liquidityOffering.startDate) * 1000
    },
    endTimestamp() {
      return parseInt(this.liquidityOffering.endDate) * 1000
    },
    startLiveOrEndDisplay() {
      const now = Date.now()
      const endDate = new Date(this.endTimestamp)
      if (now >= this.startTimestamp && now < this.endTimestamp) {
        return `Ends on ${endDate}`
      }else if (now < this.startTimestamp) {
        return `Starts on  ${new Date(this.startTimestamp)}`
      }else {
        return `Ended on ${endDate}`
      }
    }
  }
})
</script>

<style scoped>

</style>
