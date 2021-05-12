<template>
<q-card flat square bordered class="q-py-sm">
  <div class="display-card-date-text" v-html="startLiveOrEndDisplay" />
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
        `Ended on ${endDate}`
      }
      const dateTimestamp =
      console.log('datetime is', dateTimestamp)
      let newDate = new Date(dateTimestamp)

      return newDate
    }
  }
})
</script>

<style scoped>

</style>
