<template>
  <div>

    <q-tabs
      v-model="tab"
      :class="{'text-dark': !$q.dark.isActive, 'text-light': $q.dark.isActive}"
      indicator-color="secondary"
      align="justify"
      narrow-indicator
      style="border-bottom: 1px solid #acecf4;"
    >
      <q-tab name="about" label="About" />
      <q-tab name="info" label="ILO Info" />
      <q-tab name="tokenomics" label="Tokenomics" />
    </q-tabs>

    <q-tab-panels class="dark-light-background" v-model="tab" animated>

<!--  about    -->
      <q-tab-panel name="about">
        <div class="row justify-center " :class="{'text-dark': !$q.dark.isActive, 'text-light': $q.dark.isActive}">
          <div class="col-lg-8 col-12">
            <div class="col-11 segoe-bold" style="font-size: 26px;">
              {{ ILOInfo.tokenName }}
            </div>

            <div class="col-11 segoe-regular q-mt-lg">
              Circa 2021, xStarter is a Decentralized Ecosystem of Smart Contracts provided for
              businesses world wide that are seeking to launch and maintain their
              own crypto utility token.
            </div>

            <div class="row col-11 q-mt-md">
              <div class="col-auto">
                <q-btn icon="fas fa-globe" round flat  target="_blank" type="a" href="https://www.xStarter.org" />
              </div>
              <div class="col-auto">
                <q-btn icon="fab fa-telegram-plane" round flat  target="_blank" type="a" href="https://t.me/xStarterDev" />
              </div>

              <div class="col-auto">
                <q-btn icon="fab fa-twitter" round flat target="_blank" type="a" href="https://www.twitter.com/xStarterdev" />
              </div>
            </div>
          </div>
        </div>
      </q-tab-panel>

      <q-tab-panel name="info">
        <div class="row justify-center">
          <div class="display-card accountDisplayCard col-lg-9 col-12" style="min-height: 250px;">
            Sam
          </div>
        </div>


      </q-tab-panel>

    </q-tab-panels>

  </div>

</template>

<script>
import {defineComponent} from "vue";

export default defineComponent( {
  name: "ILOAdditionalInfoDisplay",
  props: {
    selectedILO: {
      type: Object,
      required: false
    },
    backBtnHandler: {
      type: Function,
      required: true
    }
  },
  data() {
    return {
      tab: 'about'
    }
  },
  computed: {
    ILOInfo() {
      // struct ILOProposal
      return this.selectedILO.info
    },
    ILOMoreInfo() {
      // struct ILOAdditionalInfo
      return this.selectedILO.moreInfo
    }
  },
  methods: {

  },

  mounted() {
    // handle back btn
    window.onpopstate = (event) => {
      window.onpopstate = null
      console.log('back btn hander', this.backBtnHandler)
      this.backBtnHandler()

    }
  }
})
</script>

<style scoped>

</style>
