<template >
  <q-card v-if="!selectedILO || selectedILO.proposalAddr === anILO.proposalAddr" flat square class=" display-card q-py-md q-mb-lg q-px-lg q-gutter-y-sm" clickable>
    <div class="display-card-date-text" v-html="startLiveOrEndDisplay" />
    <q-card-section horizontal class="justify-between">
      <div>
        <q-avatar square size="4rem">
          <img :src="liquidityOffering.logo_url">
        </q-avatar>
      </div>
      <LiquidityDisplayDuration  :end-time="endTimestamp" :start-time="startTimestamp" :offering-status="ILOStatus"  :succeeded="ILOSuccess"/>
    </q-card-section>
    <q-card-section horizontal>
      <div class="text-weight-bolder display-card-name-text">
        {{ ILOInfo.tokenName }}
      </div>
    </q-card-section>
    <q-card-section horizontal>
      <div>
        <div class="amount-raised-text">
          Amount Raised
        </div>
        <div class="amount-raised-number-text">
          {{ amountRaised }} {{ fundingTokenSymbol }}
        </div>
      </div>
    </q-card-section>
    <q-card-section horizontal>
      <div class="col-3">
        <div class="display-card-small-title text-left">
          Soft Cap
        </div>
        <div class="amount-raised-number-text text-left" style="font-size: 12px !important;">
          {{ softCap }} {{ fundingTokenSymbol }}
        </div>
      </div>
      <div class="col-6">
        <div class="display-card-small-title text-center">
          Min/Max Per Address
        </div>
        <div class="amount-raised-number-text" style="font-size: 12px !important; text-align: center !important;">
          {{ minPerAddr }}/{{ maxPerAddr }} {{ fundingTokenSymbol }}
        </div>
      </div>
      <div class="col-3">
        <div class="display-card-small-title text-right">
          Hard Cap
        </div>
        <div class="amount-raised-number-text" style="font-size: 12px !important; text-align: right !important;">
          {{ hardCap }} {{ fundingTokenSymbol }}
        </div>
      </div>
    </q-card-section>
    <q-card-section horizontal>
      <q-linear-progress class="progress-bar-style" :value="amtRaisedProgress">
        <div class="absolute-full flex flex-center">
          <q-badge  class="black-white-dark-theme" style="font-family: 'Segoe UI Bold',serif" :label="progressBarLabel" />
        </div>
      </q-linear-progress>
    </q-card-section>
    <q-card-actions align="stretch" class="q-gutter-y-md q-py-md">
      <q-btn rounded class="full-width" outline :label="isSelected ? 'Back': 'View more'" @click="viewMoreCallBack"/>
      <q-btn rounded class="full-width" outline v-if="isSelected && connectedAndPermissioned"  label="Participate"  @click="viewModal = true"/>
    </q-card-actions>

    <ILOInteractionModal
      v-if="viewModal"
      v-model="viewModal"
      :anILO="anILO"
      :ILOName="ILOInfo.tokenName"
      :ILOStatus="ILOStatus"
      :fundingTokenSymbol="fundingTokenSymbol"
    />
  </q-card>
</template>

<script>
import {defineComponent, inject, ref} from 'vue'
import LiquidityDisplayDuration from "components/CardDisplays/LiquidityDisplayDuration";
import {SUPPORTED_FUNDING_TOKENS} from "src/constants";
import ILOInteractionModal from "components/Modals/ILOInteractionModal";
export default defineComponent( {
  name: "LiquidityOfferingDisplay",
  components: {ILOInteractionModal, LiquidityDisplayDuration},
  props: {
    liquidityOffering: {
      type: Object,
      required: true
    },
    anILO: {
      type: Object,
      required: true
    },
    viewMoreCallBack: {
      type: Function,
      required: true
    },
    selectedILO: {
      type: Object,
      default: null
    }
  },
  setup(){
    const connectedAndPermissioned = inject('$connectedAndPermissioned',)
    const viewModal = ref(false)

    return {connectedAndPermissioned, viewModal}
  },
  computed: {
    isSelected() {
      return !!this.selectedILO && this.anILO.proposalAddr === this.selectedILO.proposalAddr
    },
    startTimestamp() {
      return parseInt(this.ILOMoreInfo.startTime) * 1000
    },
    fundingTokenSymbol() {
      if (SUPPORTED_FUNDING_TOKENS[this.ILOInfo.fundingToken]) {
        return SUPPORTED_FUNDING_TOKENS[this.ILOInfo.fundingToken]
      }
      return 'Custom Token'
    },
    endTimestamp() {
      return parseInt(this.ILOMoreInfo.endTime) * 1000
    },
    progressBarLabel() {
      return parseFloat(this.amtRaisedProgress*100).toFixed(2) + '%'
    },
    amountRaised() {
      // const amtRaised = parseFloat(this.$ethers.utils.formatEther(this.ILOMoreInfo.amountRaised.toString()))
      const amtRaised = this.$helper.weiBigNumberToFloatEther(this.ILOMoreInfo.amountRaised)
      if ( amtRaised >= 1000000) {
        return `${amtRaised}M`
      } else if (amtRaised >= 1000) {
        return `${amtRaised}K`
      }
      return amtRaised
    },
    softCap() {
      const amt = this.$helper.weiBigNumberToFloatEther(this.ILOMoreInfo.softcap)
      if ( amt >= 1000000) {
        return `${amt}M`
      } else if (amt >= 1000) {
        return `${amt}K`
      }
      return amt
    },
    hardCap() {
      const amt = this.$helper.weiBigNumberToFloatEther(this.ILOMoreInfo.hardcap)
      if ( amt >= 1000000) {
        return `${amt}M`
      } else if (amt >= 1000) {
        return `${amt}K`
      }
      return amt
    },

    minPerAddr() {
      const amt = this.$helper.weiBigNumberToFloatEther(this.ILOMoreInfo.minPerAddr)
      if ( amt >= 1000000) {
        return `${amt}M`
      } else if (amt >= 1000) {
        return `${amt}K`
      }
      return amt
    },
    maxPerAddr() {
      const amt = this.$helper.weiBigNumberToFloatEther(this.ILOMoreInfo.maxPerAddr)
      if ( amt >= 1000000) {
        return `${amt}M`
      } else if (amt >= 1000) {
        return `${amt}K`
      }
      return amt
    },
    ILOStatus() {
      const now = Date.now()
      if (this.startTimestamp === 0) {
        return 'tbd'
      }
      if (now >= this.startTimestamp && now < this.endTimestamp) {
        return `live`
      }else if (now < this.startTimestamp) {
        return `starting`
      }else {
        return `ended`
      }
    },
    amtRaisedProgress() {
      if (this.$helper.weiBigNumberToFloatEther(this.ILOMoreInfo.hardcap) !== 0) {
        return this.$helper.weiBigNumberToFloatEther(this.ILOMoreInfo.amountRaised) / this.$helper.weiBigNumberToFloatEther(this.ILOMoreInfo.hardcap)
      }

      return 0
    },
    ILOSuccess() {
      if (this.$helper.weiBigNumberToFloatEther(this.ILOMoreInfo.softcap) !== 0) {
        return this.$helper.weiBigNumberToFloatEther(this.ILOMoreInfo.amountRaised) >= this.$helper.weiBigNumberToFloatEther(this.ILOMoreInfo.softcap)
      }
      return null
    },
    startLiveOrEndDisplay() {
      const endDate = new Date(this.endTimestamp)
      if (this.ILOStatus === 'live') {
        return `Ends on ${endDate}`
      }else if (this.ILOStatus === 'starting') {
        return `Starts on  ${new Date(this.startTimestamp)}`
      }else if (this.ILOStatus === 'tbd') {
        return `Starting To Be Determined`
      } else {
        return `Ended on ${endDate}`
      }
    },
    ILOInfo() {
      // struct ILOProposal
      return this.anILO.info
    },
    ILOMoreInfo() {
      // struct ILOAdditionalInfo
      return this.anILO.moreInfo
    }
  },
  methods: {

  }
})
</script>

<style scoped>

</style>
