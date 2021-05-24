<template>
<q-card flat square class="q-py-md q-mb-lg q-px-lg q-gutter-y-sm" clickable>
  <div class="display-card-date-text" v-html="startLiveOrEndDisplay" />
  <q-card-section horizontal class="justify-between">
    <div>
      <q-avatar square size="4rem">
        <img :src="liquidityOffering.logo_url">
      </q-avatar>
    </div>
    <LiquidityDisplayDuration  :end-time="endTimestamp" :start-time="startTimestamp" :offering-status="ILOStatus"  :succeeded="false"/>
  </q-card-section>
  <q-card-section horizontal>
    <div class="text-weight-bolder display-card-name-text">
      xStarter
    </div>
  </q-card-section>
  <q-card-section horizontal>
    <div>
      <div class="amount-raised-text">
        Amount Raised
      </div>
      <div class="amount-raised-number-text">
        500K xDAI
      </div>
    </div>
  </q-card-section>
  <q-card-section horizontal>
    <div class="col-3">
      <div class="display-card-small-title text-left">
        Soft Cap
      </div>
      <div class="amount-raised-number-text text-left" style="font-size: 12px !important;">
        250K xDAI
      </div>
    </div>
    <div class="col-6">
      <div class="display-card-small-title text-center">
        Min/Max Per Address
      </div>
      <div class="amount-raised-number-text" style="font-size: 12px !important; text-align: center !important;">
        500/5K xDAI
      </div>
    </div>
    <div class="col-3">
      <div class="display-card-small-title text-right">
        Hard Cap
      </div>
      <div class="amount-raised-number-text" style="font-size: 12px !important; text-align: right !important;">
        1M xDAI
      </div>
    </div>
  </q-card-section>
  <q-card-section horizontal>
    <q-linear-progress class="progress-bar-style" :value="0.50">
      <div class="absolute-full flex flex-center">
        <q-badge  class="black-white-dark-theme" style="font-family: 'Segoe UI Bold',serif" label="50%" />
      </div>
    </q-linear-progress>
  </q-card-section>
  <q-card-actions>
    <q-btn rounded class="full-width" outline label="View more"/>
  </q-card-actions>
</q-card>
</template>

<script>
import { defineComponent } from 'vue'
import LiquidityDisplayDuration from "components/CardDisplays/LiquidityDisplayDuration";
export default defineComponent( {
  name: "LiquidityOfferingDisplay",
  components: {LiquidityDisplayDuration},
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
    ILOStatus() {
      const now = Date.now()
      if (now >= this.startTimestamp && now < this.endTimestamp) {
        return `live`
      }else if (now < this.startTimestamp) {
        return `starting`
      }else {
        return `ended`
      }
    },
    startLiveOrEndDisplay() {
      const endDate = new Date(this.endTimestamp)
      if (this.ILOStatus === 'live') {
        return `Ends on ${endDate}`
      }else if (this.ILOStatus === 'starting') {
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