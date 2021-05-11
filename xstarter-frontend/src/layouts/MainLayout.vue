<template>
  <q-layout view="hHh lpR fFf">

    <q-header elevated class="text-white q-pt-sm"  :class="{'bg-dark': $q.dark.isActive, 'bg-light': !$q.dark.isActive}" height-hint="98">
      <q-toolbar>
        <q-toolbar-title style="width: 10%" >
          <div >
            <img v-if="$q.dark.isActive" class="logo-style" src="~assets/xstarter_dark_logo.webp">
            <img v-else class="logo-style" src="~assets/xstarter_light_logo.png">

          </div>
        </q-toolbar-title>
        <div class="q-gutter-x-sm">
          <q-btn rounded outline :label="metamaskInstalled.value ? 'Connect' : 'Install Metamask'"  :icon="metamaskInstalled.value ? undefined : 'error_outline'" :color="darkLightText" :disable="!metamaskInstalled.value" @click="connectEthereum"/>
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

import { defineComponent, ref, watch } from 'vue'
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



    const provider = ref(undefined)
    const signer = ref(undefined)
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
        }
      }

      connectedAndPermissioned.value = metamaskInstalled.value && connectedAccounts.value.length > 0

      console.log('is permssioned', connectedAndPermissioned.value)
    }
    checkExisting()
    const connectEthereum = async () => {
      if (!metamaskInstalled.value) {
        console.log('please install metamask')
      }else {
        console.log('ethereum provider', ethereumProvider.value)
        if (provider.value && signer.value) {return}

        connectedAccounts.value = await ethereumProvider.value.request({
          method: 'eth_requestAccounts'})
        connectedAndPermissioned.value = metamaskInstalled.value && connectedAccounts.value.length > 0

        provider.value = new ethers.providers.Web3Provider(ethereumProvider.value)
        signer.value = provider.value.getSigner()
        console.log(signer.value, 'signer value')
      }

    }
    return {
      setDarkMode,
      connectEthereum,
      checkExisting,
      provider,
      signer,
      metamaskInstalled,
      ethereumProvider,
      connectedAccounts,
      connectedAndPermissioned
    }
  },
  computed: {
    darkLightText(){
      return this.$q.dark.isActive ? 'light' : 'dark'
    }
  },
  methods: {
    async signTx() {
      console.log('this signer', this.signer)
      const tx = this.signer.sendTransaction({
        to: "ricmoo.firefly.eth",
        value: this.$ethers.utils.parseEther("1.0")
      });
      // const resp = await this.provider.getBlockNumber()
      // console.log('response is', resp)
    }
  }
})
</script>


