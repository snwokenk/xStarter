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
        <div class="row justify-center q-py-md">
          <div class="display-card accountDisplayCard col-lg-7 col-12 q-pa-lg q-gutter-y-md" style="min-height: 250px;">

            <!--    access info        -->
            <div class="row  q-gutter-x-xl">
              <div class="col-auto">
                <q-icon name="fas fa-users" size="lg" />
              </div>
              <div class="col-auto">
                <div class="segoe-bold info-text">
                  Early Access For XSTN Holders / Open To Public
                </div>
                <div class="segoe-regular info-label">
                  Access
                </div>
              </div>

            </div>
            <div class="straight-line" />

            <!--    softcap info        -->
            <div class="row  q-gutter-x-xl">
              <div class="col-auto">
                <q-icon name="fab fa-ethereum" size="lg" />
              </div>
              <div class="col-auto">
                <div class="segoe-bold info-text">
                  {{ softCapFullDisplay }} {{ fundingTokenSymbol}}
                </div>
                <div class="segoe-regular info-label">
                  SoftCap
                </div>
              </div>

            </div>
            <div class="straight-line" />

            <!--    hardcap info        -->
            <div class="row q-gutter-x-xl">
              <div class="col-auto">
                <q-icon name="fab fa-ethereum" size="lg" />
              </div>
              <div class="col-auto">
                <div class="segoe-bold info-text">
                  {{ hardCapFullDisplay }} {{ fundingTokenSymbol}}
                </div>
                <div class="segoe-regular info-label">
                  HardCap
                </div>
              </div>
            </div>
            <div class="straight-line" />

            <!--    min spend per address info        -->
            <div class="row q-gutter-x-xl">
              <div class="col-auto">
                <q-icon name="fab fa-ethereum" size="lg" />
              </div>
              <div class="col-auto">
                <div class="segoe-bold info-text">
                  {{ minPerAddr }} {{ fundingTokenSymbol}}
                </div>
                <div class="segoe-regular info-label">
                  Minimum Spend Per Address
                </div>
              </div>
            </div>
            <div class="straight-line" />

            <!--    max spend per address info        -->
            <div class="row q-gutter-x-xl">
              <div class="col-auto">
                <q-icon name="fab fa-ethereum" size="lg" />
              </div>
              <div class="col-auto">
                <div class="segoe-bold info-text">
                  {{ maxPerAddr }} {{ fundingTokenSymbol}}
                </div>
                <div class="segoe-regular info-label">
                  Maximum Spend Per Address
                </div>
              </div>
            </div>
            <div class="straight-line" />


            <!--    swap rate range @ softcap info        -->
            <div class="row q-gutter-x-xl">
              <div class="col-auto">
                <q-icon name="fab fa-ethereum" size="lg" />
              </div>
              <div class="col-auto">
                <div class="segoe-bold info-text">
                  {{ softCapSwapRate }} tokens per 1 {{ fundingTokenSymbol }}
                </div>
                <div class="segoe-regular info-label">
                  Swap Rate @ Soft Cap
                </div>
              </div>
            </div>
            <div class="straight-line" />

            <!--    swap rate range @ hardcap info        -->
            <div class="row q-gutter-x-xl">
              <div class="col-auto">
                <q-icon name="fab fa-ethereum" size="lg" />
              </div>
              <div class="col-auto">
                <div class="segoe-bold info-text">
                  {{ hardCapSwapRate }} tokens per 1 {{ fundingTokenSymbol }}
                </div>
                <div class="segoe-regular info-label">
                  Swap Rate @ Hard Cap
                </div>
              </div>
            </div>
            <div class="straight-line" />


          </div>
        </div>


      </q-tab-panel>

    </q-tab-panels>

  </div>

</template>

<script>
import {defineComponent} from "vue";
import {SUPPORTED_FUNDING_TOKENS} from "src/constants";

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
    },
    softCapFullDisplay() {
      return this.$helper.weiBigNumberToFloatEther(this.ILOMoreInfo.softcap)
    },
    hardCapFullDisplay() {
      return this.$helper.weiBigNumberToFloatEther(this.ILOMoreInfo.hardcap)
    },
    fundingTokenSymbol() {
      if (SUPPORTED_FUNDING_TOKENS[this.ILOInfo.fundingToken]) {
        return SUPPORTED_FUNDING_TOKENS[this.ILOInfo.fundingToken]
      }
      return 'Custom Token'
    },
    minPerAddr() {
      return this.$helper.weiBigNumberToFloatEther(this.ILOMoreInfo.minPerAddr)
    },
    maxPerAddr() {
      return this.$helper.weiBigNumberToFloatEther(this.ILOMoreInfo.maxPerAddr)
    },

    tokensForILO() {
      let totalTokens = this.$helper.weiBigNumberToFloatEther(this.ILOInfo.totalSupply)
      return totalTokens * (this.ILOInfo.percentOfTokensForILO / 100)
      // return totalTokens
    },
    softCapSwapRate() {
      return this.tokensForILO / this.softCapFullDisplay
    },

    hardCapSwapRate() {
      return this.tokensForILO / this.hardCapFullDisplay
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
