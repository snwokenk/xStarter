<template>
  <div class="display-container row q-gutter-y-lg q-gutter-x-lg justify-center q-py-lg q-my-md">
    <LiquidityOfferingDisplay class="display-card col-md-10 col-lg-5"  :liquidity-offering="listOfLiquidityOffering"/>
    <q-btn label="Sam" @click="move += 1"/>
  </div>
</template>

<script>
import {defineComponent, inject, ref} from "vue";
import LiquidityOfferingDisplay from "components/CardDisplays/LiquidityOfferingDisplay";

export default defineComponent( {
  name: "ILOMainDisplay",
  components: {LiquidityOfferingDisplay},
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
    return {getProvider, getSigner, getLaunchPadContract, getConnectedAndPermissioned, connectedAndPermissioned,launchPadLoaded, ILORound, getILOs}
  },
  data(){
    return {
      move: 0,
      ILOs: []
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
  },
  watch: {
    launchPadLoaded: async function(val)  {
      if (this.launchPadLoaded) {
        const ILOs = await this.getILOs(this.move)
        console.log('launchpad loaded and ILOs is', ILOs)
        console.log('ILO index o',  ILOs[0][0].info)
      }
    }
  }
})
</script>

<style scoped>

</style>
