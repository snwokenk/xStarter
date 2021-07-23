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
<!--              Circa 2021, xStarter is a Decentralized Ecosystem of Smart Contracts provided for-->
<!--              businesses world wide that are seeking to launch and maintain their-->
<!--              own crypto utility token.-->
              {{ ILODescription }}
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
                  {{ ILOAccess }}
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
                  {{ softCapFullDisplay.toLocaleString() }} {{ fundingTokenSymbol}}
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
                  {{ hardCapFullDisplay.toLocaleString() }} {{ fundingTokenSymbol}}
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
                  {{ minPerAddr.toLocaleString() }} {{ fundingTokenSymbol}}
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
                  {{ maxPerAddr.toLocaleString() }} {{ fundingTokenSymbol}}
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
                <div v-if="hardCapFullDisplay" class="segoe-bold info-text">
                  {{ softCapSwapRate.toLocaleString() }} tokens per 1 {{ fundingTokenSymbol }}
                </div>
                <div v-else class="segoe-bold info-text">
                  TBD
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
                <div v-if="hardCapFullDisplay" class="segoe-bold info-text">
                  {{ hardCapSwapRate.toLocaleString() }} tokens per 1 {{ fundingTokenSymbol }}
                </div>
                <div v-else class="segoe-bold info-text">
                  TBD
                </div>
                <div class="segoe-regular info-label">
                  Swap Rate @ Hard Cap
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
                <div v-if="hardCapFullDisplay" class="segoe-bold info-text">
                  {{ percentOfFundingTokenForLiqudity }}%
                </div>
                <div v-else class="segoe-bold info-text">
                  TBD
                </div>
                <div class="segoe-regular info-label">
                  % Of {{ fundingTokenSymbol }} Raised For Liquidity Pool
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
                <div v-if="hardCapFullDisplay" class="segoe-bold info-text">
                  {{ listingPremium }}%  Above Swap ILO Swap Rate
                </div>
                <div v-else class="segoe-bold info-text">
                  TBD
                </div>
                <div class="segoe-regular info-label">
                  Listing Premium
                </div>
              </div>
            </div>
<!--            <div class="straight-line" />-->


          </div>
        </div>


      </q-tab-panel>

      <q-tab-panel name="tokenomics">
        <div class="row justify-center q-py-md">
          <div class="display-card accountDisplayCard col-lg-7 col-12 q-pa-lg q-gutter-y-md" style="min-height: 250px;">

            <!--    token symbol       -->
            <div class="row  q-gutter-x-xl">
              <div class="col-auto">
                <div class="segoe-bold info-text">
                  {{ ILOInfo.tokenSymbol }}
                </div>
                <div class="segoe-regular info-label">
                  Token Symbol
                </div>
              </div>

            </div>
            <div class="straight-line" />

            <!--   type        -->
            <div class="row  q-gutter-x-xl">
              <div class="col-auto">
                <div class="segoe-bold info-text">
                  ERC20
                </div>
                <div class="segoe-regular info-label">
                  Token Type
                </div>
              </div>

            </div>
            <div class="straight-line" />

            <!--    total supply info        -->
            <div class="row q-gutter-x-xl">

              <div class="col-auto">
                <div class="segoe-bold info-text">
                  {{ totalSupply.toLocaleString() }}
                </div>
                <div class="segoe-regular info-label">
                  Total Token Supply
                </div>
              </div>
            </div>
            <div class="straight-line" />

            <!--    total supply info        -->
            <div class="row q-gutter-x-xl">

              <div class="col-auto">
                <div class="segoe-bold info-text">
                  {{ tokensForILO.toLocaleString() }}
                </div>
                <div class="segoe-regular info-label">
                  Tokens Supply
                </div>
              </div>
            </div>

          </div>
          <div class="display-card accountDisplayCard col-lg-7 col-12 q-pa-lg q-mt-lg" style="min-height: 250px;">
            <div class="row">

              <div class="col-12">
                <div class="segoe-bold info-text-header text-center">
                  Token Use Cases
                </div>
                <div class="segoe-regular info-text q-mt-md">
<!--                  xStarter tokens are used for governance and early access of ILOs launched on the xStarter Platform.-->
<!--                  xStarter tokens can also be used as a funding token for ILOs.-->
                  {{ ILOUseCase }}
                </div>
              </div>
            </div>
          </div>
        </div>


      </q-tab-panel>

    </q-tab-panels>

  </div>

</template>

<script>
import {defineComponent, inject} from "vue";
import {DEFAULT_CHAIN_FUNDING_TOKEN, SUPPORTED_FUNDING_TOKENS} from "src/constants";

export default defineComponent( {
  name: "ILOAdditionalInfoDisplay",
  setup() {
    let chainId = inject('$chainId')
    return {chainId}
  },
  props: {
    selectedILO: {
      type: Object,
      required: false
    },
    backBtnHandler: {
      type: Function,
      required: true
    },
    infoData: {
      type: Object,
      required: true
    }
  },
  data() {
    return {
      tab: 'about',

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
      let fundingSymbol = SUPPORTED_FUNDING_TOKENS[this.ILOInfo.fundingToken + '-' + this.chainId]
      if (fundingSymbol) {
        return fundingSymbol
      }else if (!this.connectedAndPermissioned) {
        return DEFAULT_CHAIN_FUNDING_TOKEN
      }
      return 'Custom Token'
    },
    minPerAddr() {
      return this.$helper.weiBigNumberToFloatEther(this.ILOMoreInfo.minPerAddr)
    },
    maxPerAddr() {
      return this.$helper.weiBigNumberToFloatEther(this.ILOMoreInfo.maxPerAddr)
    },

    totalSupply() {
      return this.$helper.weiBigNumberToFloatEther(this.ILOInfo.totalSupply)
    },

    tokensForILO() {

      return this.totalSupply * (this.ILOInfo.percentOfTokensForILO / 100)
      // return totalTokens
    },
    softCapSwapRate() {
      return (this.tokensForILO * (this.percentOfFundingTokenForLiqudity / 100)) / this.softCapFullDisplay
    },

    hardCapSwapRate() {
      return (this.tokensForILO * (this.percentOfFundingTokenForLiqudity / 100)) / this.hardCapFullDisplay
    },

    percentOfFundingTokenForLiqudity() {
      return 100 - this.ILOMoreInfo.percentTokensForTeam
    },

    listingPremium() {
      // percentTokensForTeam not greater than 20 or 20%
      return (this.percentOfFundingTokenForLiqudity * 2 ) - 100
    },
    ILODescription() {
      if (this.infoData && this.infoData.about) {
        return this.infoData.about.description ? this.infoData.about.description : ''
      }
      return ''
    },
    ILOAccess() {
      if (this.infoData && this.infoData.ILOInfo) {
        return this.infoData.ILOInfo.access ? this.infoData.ILOInfo.access : ''
      }
      return ''
    },

    ILOUseCase() {
      if (this.infoData && this.infoData.tokenomics) {
        return this.infoData.tokenomics.useCase ? this.infoData.tokenomics.useCase : ''
      }
      return ''
    }

    // infoData() {
    //   if (this.ILOInfo) {
    //     console.log('iloinfo is', this.ILOInfo.infoURL)
    //     return this.$ipfs_utils.getILOInfo(this.ILOInfo.infoURL)
    //   }
    //   return {}
    // }
  },
  methods: {

  },


  async mounted() {
    // handle back btn
    window.onpopstate = (event) => {
      window.onpopstate = null
      console.log('back btn hander', this.backBtnHandler)
      this.backBtnHandler()

    }
    // console.log('info CID', this.ILOInfo.infoURL, this.ILOInfo)

  }
})
</script>

<style scoped>

</style>
