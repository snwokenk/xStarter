<template>
  <q-layout view="hHh lpR fFf">

    <q-header elevated class="text-white q-pt-sm"  :class="{'bg-dark': $q.dark.isActive, 'bg-light': !$q.dark.isActive}" height-hint="98">
      <q-toolbar>
        <q-toolbar-title style="width: 10%" >
          <div >
            <img v-if="$q.dark.isActive" class="logo-style" src="~assets/xstarter_dark_logo.png">
            <img v-else class="logo-style" src="~assets/xstarter_light_logo.png">

          </div>
        </q-toolbar-title>
        <div class="q-gutter-x-sm">
          <q-btn rounded outline :label="connectBtnLabel"  :icon="metamaskInstalled.value ? undefined : 'error_outline'" :color="metamaskInstalled.value ? darkLightText: 'negative'" :disable="!metamaskInstalled.value" @click="connectEthereum"/>
          <q-btn label="sign" @click="signTx"/>
          <q-btn round flat :color="darkLightText" :icon="$q.dark.isActive ? 'light_mode' : 'dark_mode'" @click="setDarkMode"/>
        </div>
      </q-toolbar>

      <q-tabs align="center" :class="{'text-dark': !$q.dark.isActive, 'text-light': $q.dark.isActive}">
        <q-route-tab to="/" label="ILO"  />
        <q-route-tab to="/page2" label="Governance" />
        <q-route-tab to="/page3" label="NFT" />
      </q-tabs>
    </q-header>

    <q-page-container>
      <router-view />
    </q-page-container>

    <q-footer elevated class="text-white" :class="{'bg-dark': $q.dark.isActive, 'bg-light': !$q.dark.isActive}">
      <q-toolbar class="justify-center">
<!--        <q-toolbar-title>-->
<!--          <q-avatar>-->
<!--            <img src="https://cdn.quasar.dev/logo/svg/quasar-logo.svg">-->
<!--          </q-avatar>-->
<!--          <div>Title</div>-->
<!--        </q-toolbar-title>-->
        <div class="col-auto">
          <q-btn flat :color="darkLightText" label="About xStarter" target="_blank" icon-right="open_in_new" type="a" href="https://www.xstarter.org/" />
        </div>

      </q-toolbar>
    </q-footer>

  </q-layout>
</template>

<script>

// https://docs.metamask.io/guide/getting-started.html#basic-considerations
// https://docs.metamask.io/guide/ethereum-provider.html#methods
// https://ethereum.stackexchange.com/questions/97693/what-is-the-correct-way-to-deploy-a-react-app-that-uses-metamask

import { defineComponent, ref, watch, onMounted } from 'vue'
import { useQuasar } from 'quasar'
import { ethers } from 'boot/ethers'
import detectEthereumProvider from '@metamask/detect-provider';


export default defineComponent({
  name: 'MainLayout',

  components: {
  },

  setup () {
    const $q = useQuasar()
    const setDarkMode = async () => {
      $q.dark.toggle()
    }



    let provider = undefined
    let signer = undefined
    const ethereumProvider = ref(undefined)
    const metamaskInstalled = ref(false)
    const connectedAccounts = ref([])
    const connectedAndPermissioned = ref(Boolean(metamaskInstalled.value && connectedAccounts.value.length > 0))
    // check if you already have connection and permission
    // can be called when account or network changes
    const checkExisting = async () => {
      ethereumProvider.value = await detectEthereumProvider();
      metamaskInstalled.value = ref(Boolean(ethereumProvider.value))
      if (metamaskInstalled.value) {
        try {
          connectedAccounts.value = await ethereumProvider.value.request({
            method: 'eth_accounts'
          })
        }catch (e) {
          console.log(e)
          return
        }

      connectedAndPermissioned.value = metamaskInstalled.value && connectedAccounts.value.length > 0
      if (connectedAndPermissioned.value) {
        provider = new ethers.providers.Web3Provider(ethereumProvider.value)
        signer = provider.getSigner()
        console.log('is permssioned 1', connectedAndPermissioned.value, await provider.getBlockNumber())
      }
      ethereumProvider.value.on('accountsChanged', checkExisting)

      console.log('is permssioned 2', connectedAndPermissioned.value)
    }
    }
    onMounted(() => {
      checkExisting()
    })
    const connectEthereum = async () => {
      if (!metamaskInstalled.value) {
        console.log('please install metamask')
      }else {
        console.log('ethereum provider', ethereumProvider.value)

        if (connectedAndPermissioned.value) {return}
        try {
          connectedAccounts.value = await ethereumProvider.value.request({
            method: 'eth_requestAccounts'})
        }catch (e) {

        }

        connectedAndPermissioned.value = metamaskInstalled.value && connectedAccounts.value.length > 0

        // provider = new ethers.providers.Web3Provider(ethereumProvider.value)
        // signer = provider.getSigner()
        console.log(signer, 'signer value')
      }

    }
    const getProvider = () => {
      return provider
    }
    const getSigner = () => {
      return signer
    }
    return {
      setDarkMode,
      connectEthereum,
      checkExisting,
      getProvider,
      getSigner,
      metamaskInstalled,
      ethereumProvider,
      connectedAccounts,
      connectedAndPermissioned
    }
  },
  computed: {
    darkLightText(){
      return this.$q.dark.isActive ? 'light' : 'dark'
    },

    connectBtnLabel() {
      console.log('connected permission', this.connectedAndPermissioned)
      if (this.connectedAndPermissioned) {
        return 'Connected'
      }

      return this.metamaskInstalled.value ? 'Connect' : 'Install Metamask'
    }
  },
  methods: {
    async signTx() {
      console.log('this signer', this.getSigner(), this.ethereumProvider.selectedAddress)
      console.log('connected accounts', this.connectedAccounts)
      const resp = await this.getProvider().getBalance('0x9965507D1a55bcC2695C58ba16FB37d819B0A4dc');
      // const resp = await this.getSigner().sendTransaction({
      //   to: "0x9965507D1a55bcC2695C58ba16FB37d819B0A4dc",
      //   value: this.$ethers.utils.parseEther("1.0")
      // });
      // const resp = await this.provider.getBlockNumber()
      console.log('response is', resp, this.$ethers.utils.formatEther(resp), resp._isBigNumber)
    }
  },
  mounted() {

  }
})
</script>


