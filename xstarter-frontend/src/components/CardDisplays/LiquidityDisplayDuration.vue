<template>
  <div  v-if="offeringStatus === 'starting'" class="q-gutter-y-md">
    <div class="display-card-duration-container display-card-duration-container__ended display-card-duration-text"> Duration {{ durationDisplay }}</div>
    <div class="display-card-duration-container display-card-duration-text">{{ startsInDisplay.toLowerCase() === 'soon' ? 'Starting' : 'Starts in' }}  {{ startsInDisplay }}</div>
  </div>
  <div v-else-if="offeringStatus === 'live'" class="q-gutter-y-sm">
    <div class="display-card-duration-container display-card-duration-container__succeed display-card-duration-text display-card-duration-text__succeed row">
      <div class="col-4 row justify-end content-center"><div class="circle circle__succeed col-auto"/></div><div class="col-1" /><div class="col-7 text-left">Live</div>
    </div>
    <div class="display-card-duration-container display-card-duration-container__succeed display-card-duration-text display-card-duration-text__succeed"> Ends In {{ nowToEndDate }}</div>
  </div>
  <div v-else-if="offeringStatus === 'tbd'" class="q-gutter-y-md">
    <div class="display-card-duration-container display-card-duration-container__ended display-card-duration-text"> Duration TBD</div>
  </div>
  <div v-else class="q-gutter-y-md">
    <div v-if="succeeded" class="display-card-duration-container display-card-duration-container__succeed display-card-duration-text display-card-duration-text__succeed row">
      <div class="col-3 row justify-end content-center"><q-icon name="done" size="16px"/></div><div class="col-1" /><div class="col-8 text-left">Success</div>
    </div>
    <div v-else class="display-card-duration-container display-card-duration-container__failed display-card-duration-text display-card-duration-text__failed row">
      <div class="col-4 row justify-end content-center"><q-icon name="clear" size="16px"/></div><div class="col-1" /><div class="col-7 text-left">Failed</div>
    </div>
  </div>
</template>

<script>
import {defineComponent, inject} from 'vue'
import { date } from 'quasar'
export default defineComponent({
  name: "LiquidityDisplayDuration",
  setup() {
    const blockInfo = inject('$blockInfo')
    return {blockInfo}
  },
  props: {
    offeringStatus: {
      type: String,
      required: true
    },
    succeeded: {
      type: Boolean,
      required: true
    },
    startTime: {
      type: Number,
      required: true
    },
    endTime: {
      type: Number,
      required: true
    }
  },
  methods: {
    getDateDisplay(lesserDate, greaterDate, unit = 'hours') {
      return date.getDateDiff(new Date(greaterDate), new Date(lesserDate), unit)
    },

    getDateDisplayUnitsDeterminedDisplay(lesserDate, greaterDate) {
      let unit = 'minutes'
      let duration = date.getDateDiff(new Date(greaterDate), new Date(lesserDate), unit)
      // if less than 60 minutes then return else display in hours
      if (duration <= 1) {
        return 'Soon'
      }
      if (duration <= 60) {
        return `${duration} ${duration === 1 ? 'minute' : unit}`
      }
      unit = 'hours'
      duration = date.getDateDiff(new Date(greaterDate), new Date(lesserDate), unit)
      // if duration less than 48 hours return else display in days
      if (duration <= 48) {
        return `${duration} ${duration === 1 ? 'hour' : unit}`
      }
      unit = 'days'
      duration = date.getDateDiff(new Date(greaterDate), new Date(lesserDate), unit)
      return `${duration} ${duration === 1 ? 'day' : unit}}`

    }
  },
  computed: {
    nowToEndDate() {
      return this.getDateDisplayUnitsDeterminedDisplay(this.blockInfo.timestamp * 1000, this.endTime)
    },
    durationDisplay() {
      return this.getDateDisplayUnitsDeterminedDisplay(this.startTime, this.endTime)
    },
    startsInDisplay() {
      return this.getDateDisplayUnitsDeterminedDisplay(this.blockInfo.timestamp * 1000, this.startTime)
    }
  }
})
</script>

<style scoped lang="scss">
.circle{
  width: 7px !important;
  height: 7px !important;
  border-radius: 7px;
  &__succeed {
    background: #0DBF00;
    //border: 1px solid #bf0000;
  }
  &__failed {
    background: #bf0000;
    //border: 1px solid #bf0000;
  }
}
</style>
