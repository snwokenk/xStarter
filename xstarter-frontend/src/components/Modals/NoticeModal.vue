<template>
  <GeneralModal  v-model="showDialog" :persistent="true">
    <div class="row content-center justify-center">
      <div class="q-mb-xl segoe-bold text-h4 text-center">
        Disclaimer
      </div>
      <div class="q-mb-md q-px-xl text-body1 text-center">
        xStarter is a decentralized and community governed initial liquidity offering (ILO) platform.
        Anyone can propose an ILO and the community then votes to accept or reject the proposal.
        This shouldn't be taken as a form of due diligence and each person using this platform must understand the risk
        involved in the decentralized nature fo cryptocurrencies.

        You assume all risk involved in using this platform and agree to do your own research and due diligence before using this platform
      </div>
      <div class="q-mb-md segoe-bold q-pa-xl text-body1 text-center">
        You assume all risk involved in using this platform and agree to do your own research and due diligence before using this platform
      </div>
      <div>
        <q-btn
          outline
          size="lg"
          :label="'I Agree'"
          :color="darkLightText"
          @click="acceptRisk"
        />
      </div>
    </div>
  </GeneralModal>

</template>

<script>
import {defineComponent} from "vue";
import GeneralModal from "components/Modals/GeneralModal";

export default defineComponent(  {
  name: "NoticeModal",
  components: {GeneralModal},
  props: {
    modelValue: {
      type: Boolean,
      required: true
    },
    persistent: {
      type: Boolean,
      default: false
    }
  },
  methods:{
    emitModalValue(val) {
      this.$emit('update:modelValue', val)
    },
    acceptRisk() {
      this.$q.sessionStorage.set('accRK', true)
      this.emitModalValue(false)
    }
  },
  computed: {
    darkLightText(){
      return this.$q.dark.isActive ? 'light' : 'dark'
    },
    showDialog: {
      set: function (val) {
        this.emitModalValue(val)
      },
      get: function () {
        return this.modelValue
      }
    }
  }
})
</script>

<style scoped>

</style>
