<template>
  <div class="full-width">
    <div class="display-container row q-gutter-y-lg q-gutter-x-lg justify-center q-pt-md q-px-md q-pb-lg q-my-md">
      <LiquidityOfferingDisplay
        v-for="(obj, index) in ILOs"
        :anILO="obj"
        :selectedILO="selectedILO"
        :key="index"
        class="ILODisplayCard col-11 col-lg-5"
        :liquidity-offering="listOfLiquidityOffering"
        :view-more-call-back="() => { changeSelectedILO(obj) }"
      />
    </div>

    <div>
      <ILOAdditionalInfoDisplay v-if="selectedILO" class="q-mt-md q-mb-lg" :backBtnHandler="() => { changeSelectedILO(selectedILO) }"  :selectedILO="selectedILO" />
    </div>
  </div>

</template>

<script>
import {defineComponent, inject, ref} from "vue";
import LiquidityOfferingDisplay from "components/CardDisplays/LiquidityOfferingDisplay";
import ILOAdditionalInfoDisplay from "components/ILOAdditionalInfoDisplay";

export default defineComponent( {
  name: "ILOMainDisplay",
  components: {ILOAdditionalInfoDisplay, LiquidityOfferingDisplay},
  setup() {
    let ILORound = ref(0)

    const getProvider = inject('$getProvider')
    const getSigner = inject('$getSigner')
    const getLaunchPadContract = inject('$getLaunchPadContract')
    const getConnectedAndPermissioned = inject('$getConnectedAndPermissioned')
    let connectedAndPermissioned = inject('$connectedAndPermissioned')
    let launchPadLoaded = inject('$launchPadLoaded')
    console.log('provider is ', getProvider())
    const getILOs = async (moveForward = 0) => {
      ILORound.value += moveForward
      const launchpad = getLaunchPadContract()
      return await launchpad.getProposals(ILORound.value)
    }
    const callLaunchPadFunction = inject('$callLaunchPadFunction')
    return {
      getProvider,
      getSigner,
      getLaunchPadContract,
      getConnectedAndPermissioned,
      connectedAndPermissioned,
      launchPadLoaded,
      ILORound,
      getILOs,
      callLaunchPadFunction
    }
  },
  data(){
    return {
      move: 0,
      ILOs: [],
      noOfILOs: 0,
      initialCheck: false,
      selectedILO: null
    }
  },
  computed: {
    listOfLiquidityOffering() {
      return  {
        startDate: '1620530069',
        endDate: '1621221269',
        logo_url: '/xstarter_blue2.jpg'
      }
    },
    currentILO() {
      return ILOs
    }
  },
  methods: {
    checkIt() {
      console.log('provider', this.getProvider())
    },
    changeSelectedILO(ILOObj) {
      // if no selected ILO, then set to ILO obj, else set to null
      console.log('calling change ILO')
      if (!this.selectedILO) {
        history.pushState({}, '')
      }
      this.selectedILO = !this.selectedILO ? ILOObj : null
    }
  },
  watch: {
    launchPadLoaded: async function(val)  {
      if (this.launchPadLoaded) {
        if (!this.initialCheck) {
          this.noOfILOs = await this.callLaunchPadFunction('noOfProposals')
          this.noOfILOs = this.noOfILOs.toNumber()
          this.initialCheck = true
        }
        const ILOs = await this.getILOs(this.move)
        this.ILOs = ILOs[0]
        console.log('launchpad loaded and ILOs is', ILOs)
        console.log('ILO index o',  ILOs[0][0].info)
      }
    }
  }
})
</script>

<style scoped>

</style>
