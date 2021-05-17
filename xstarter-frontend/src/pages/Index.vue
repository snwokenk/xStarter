<template>
  <q-page class="flex flex-center">
<!--    <img-->
<!--      alt="Quasar logo"-->
<!--      src="~assets/quasar-logo-full.svg"-->
<!--    >-->
    <q-btn label="Sam" @click="checkIt" />
    <div class="display-container row q-gutter-y-lg q-gutter-x-lg justify-center q-py-lg q-my-md">
      <LiquidityOfferingDisplay class="display-card col-md-10 col-lg-5"  :liquidity-offering="listOfLiquidityOffering"/>
<!--      <LiquidityOfferingDisplay class="display-card col-md-10 col-lg-5"  :liquidity-offering="listOfLiquidityOffering"/>-->
<!--      <LiquidityOfferingDisplay class="display-card col-md-10 col-lg-5"  :liquidity-offering="listOfLiquidityOffering"/>-->
<!--      <LiquidityOfferingDisplay class="display-card col-md-10 col-lg-5"  :liquidity-offering="listOfLiquidityOffering"/>-->
<!--      <LiquidityOfferingDisplay class="display-card col-md-10 col-lg-5"  :liquidity-offering="listOfLiquidityOffering"/>-->
<!--      <LiquidityOfferingDisplay class="display-card col-md-10 col-lg-5"  :liquidity-offering="listOfLiquidityOffering"/>-->
<!--      <LiquidityOfferingDisplay class="display-card col-md-10 col-lg-5"  :liquidity-offering="listOfLiquidityOffering"/>-->
    </div>

  </q-page>
</template>

<script>
import {defineComponent, inject, provide} from 'vue';
import LiquidityOfferingDisplay from "components/CardDisplays/LiquidityOfferingDisplay";

export default defineComponent({
  name: 'PageIndex',
  components: {LiquidityOfferingDisplay},
  setup() {
    const getProvider = inject('$getProvider')
    const getSigner = inject('$getSigner')
    const getLaunchPadContract = inject('$getLaunchPadContract')
    const getConnectedAndPermissioned = inject('$getConnectedAndPermissioned')
    console.log('provider is ', getProvider())
    return {getProvider, getSigner, getLaunchPadContract, getConnectedAndPermissioned}
  },
  computed: {
    listOfLiquidityOffering() {
      return  {
        startDate: '1620530069',
        endDate: '1621221269',
        logo_url: '/xstarter_blue2.jpg'
      }
    }
  },
  methods: {
    checkIt() {
      console.log('provider', this.getProvider())
    }
  }
})
</script>
<style scoped lang="scss">
.display-container{
  width: 80%;
  min-height: 300px;

}
</style>
