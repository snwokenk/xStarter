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

<!--          <q-btn-->
<!--            rounded-->
<!--            outline-->
<!--            size="md"-->
<!--            :label="connectBtnLabel"-->
<!--            :icon="metamaskInstalled ? undefined : 'error_outline'"-->
<!--            :color="metamaskInstalled ? darkLightText: 'negative'"-->
<!--            :disable="!metamaskInstalled"-->
<!--            @click="connectEthereum"-->
<!--          />-->
          <q-btn
            rounded
            outline
            size="md"
            :label="connectBtnLabel"
            :icon="metamaskInstalled ? undefined : 'error_outline'"
            :color="metamaskInstalled ? darkLightText: 'negative'"
            @click="connectOrInstallBtn"
          />


<!--          <q-btn-dropdown-->
<!--            rounded-->
<!--            outline-->
<!--            size="md"-->
<!--            :label="connectBtnLabel"-->
<!--            :disable-dropdown="!connectedAndPermissioned"-->
<!--            :icon="metamaskInstalled ? undefined : 'error_outline'"-->
<!--            :color="metamaskInstalled ? darkLightText: 'negative'"-->
<!--            :disable="!metamaskInstalled"-->
<!--            @click="connectEthereum"-->
<!--          >-->
<!--            <q-list>-->
<!--              <q-item clickable v-close-popup >-->
<!--                <q-item-section>-->
<!--                  <q-item-label>Create ILO</q-item-label>-->
<!--                </q-item-section>-->
<!--              </q-item>-->
<!--            </q-list>-->

<!--          </q-btn-dropdown>-->
<!--          <q-btn outline :color="darkLightText" label="sign"  @click="callContract"/>-->
          <q-btn round flat :color="darkLightText" :icon="$q.dark.isActive ? 'light_mode' : 'dark_mode'" @click="setDarkMode"/>
        </div>
      </q-toolbar>

      <q-tabs align="center" :class="{'text-dark': !$q.dark.isActive, 'text-light': $q.dark.isActive}">
        <q-route-tab to="/" label="ILO"  />
        <q-route-tab to="/page2" label="Governance" disable>
          <q-badge label="Coming Soon" :color="darkLightText" :text-color="darkLightTextReverse" style="font-size: 8px;" floating />
        </q-route-tab>
        <q-route-tab to="/page3" label="NFT" disable>
          <q-badge label="Coming Soon" :color="darkLightText" :text-color="darkLightTextReverse" style="font-size: 8px;" floating />
        </q-route-tab>
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
    <WalletConnectModal v-if="!connectedAndPermissioned" v-model="showWalletConnectModal" />

  </q-layout>
</template>

<script>

// https://docs.metamask.io/guide/getting-started.html#basic-considerations
// https://docs.metamask.io/guide/ethereum-provider.html#methods
// https://ethereum.stackexchange.com/questions/97693/what-is-the-correct-way-to-deploy-a-react-app-that-uses-metamask
// todo: use walletconnect for qr code connecting https://docs.walletconnect.org/quick-start/dapps/web3-provider

import {defineComponent, ref, watch, onMounted, provide, inject} from 'vue'
import { useQuasar } from 'quasar'
import { ethers } from 'boot/ethers'
import { abiUtils } from "boot/abiGenerator";
import detectEthereumProvider from '@metamask/detect-provider';
import MetaMaskOnboarding from '@metamask/onboarding';
import { JSON_RPC_ENDPOINT, LAUNCHPAD_ADDRESS} from "src/constants";
// import data from 'src/artifacts/contracts/xStarterPoolPairB.sol/xStarterPoolPairB.json';
import launchpadCode from 'src/artifacts/contracts/xStarterLaunchPad.sol/xStarterLaunchPad.json';
import xStarterProposalCode from 'src/artifacts/contracts/xStarterLaunchPad.sol/xStarterLaunchPad.json'
import WalletConnectModal from "components/Modals/WalletConnectModal";



export default defineComponent({
  name: 'MainLayout',

  components: {WalletConnectModal},

  setup () {
    const $q = useQuasar()
    const setDarkMode = async () => {
      $q.dark.toggle()
    }

    // console.log('xstarterpropsal code', typeof  xStarterProposalCode, xStarterProposalCode)
    console.log('xstarter constructor abi', abiUtils.getConstructorObj(xStarterProposalCode.abi))

    let provider = undefined
    let signer = undefined
    let launchPadContract = undefined
    let launchPadLoaded = ref(false)
    provide('$launchPadLoaded', launchPadLoaded)
    let jsonRPCEndpoint = ref(JSON_RPC_ENDPOINT)
    provide('$jsonRPCEndpoint', jsonRPCEndpoint)
    const ethereumProvider = ref(undefined)
    provide('$ethereumProvider', ethereumProvider)
    let chainId = ref(undefined)
    provide('$chainId', chainId)
    let blockInfo = ref({timestamp: 0, blockNumber: 0})
    provide('$blockInfo', blockInfo)
    const metamaskInstalled = ref(false)
    provide('$metamaskInstalled', metamaskInstalled)
    const connectedAccounts = ref([])
    provide('$connectedAccounts', connectedAccounts)
    const connectedAndPermissioned = ref(Boolean(metamaskInstalled.value && connectedAccounts.value.length > 0))
    provide('$connectedAndPermissioned', connectedAndPermissioned)
    // check if you already have connection and permission
    // can be called when account or network changes

    let selectedTab = 'ilo'
    const changeExistingTab =  (value) => {
      selectedTab = value
    }
    const getExistingTab = () => {
      return selectedTab
    }
    const connectUsingJsonRPCProvider = async () => {

      console.log('connecting using json rpc', jsonRPCEndpoint.value, process.env.IS_NETWORK)
      provider  = await new ethers.providers.JsonRpcProvider(jsonRPCEndpoint.value);
      console.log('json rpc provider is', provider)
      if (provider) {
        launchPadContract = await new ethers.Contract(LAUNCHPAD_ADDRESS.default, launchpadCode.abi, provider)
        if (launchPadContract) {
          launchPadLoaded.value = true
        }

        provider.on("block", async (blockNumber) => {
          console.log('received block event')
          const block = await  provider.getBlock()
          blockInfo.value = {timestamp: block.timestamp, blockNumber: blockNumber}
        })
        // chainId.value = (await provider.getNetwork())['chainId']
      }

    }
    const metaMaskAssetAddRequest = async (tokenAddress, tokenSymbol, tokenImage) => {
      try {
        // wasAdded is a boolean. Like any RPC method, an error may be thrown.
        const wasAdded = await ethereumProvider.value.request({
          method: 'wallet_watchAsset',
          params: {
            type: 'ERC20', // Initially only supports ERC20, but eventually more!
            options: {
              address: tokenAddress, // The address that the token is at.
              symbol: tokenSymbol, // A ticker symbol or shorthand, up to 5 chars.
              decimals: 18, // The number of decimals in the token
              image: tokenImage, // A string url of the token logo
            },
          },
        });

        if (wasAdded) {
          console.log('was added');
        } else {
          console.log('not added');
        }
      } catch (error) {
        console.log(error);
      }

    }
    provide('$metaMaskAssetAddRequest', metaMaskAssetAddRequest)

    const metaMaskEthereumChainAddRequest = async (
      chainId,
      chainName,
      currencyName,
      currencySymbol,
      rpcArray,
      blockExplorerArray,
      iconUrlArray,
    ) => {
      let wasAdded = false
      try {
        await ethereum.request({
          method: 'wallet_switchEthereumChain',
          params: [{ chainId: chainId }],
        });
        wasAdded = true
      } catch (error) {
        // if it was a switch error
        if (error.code === 4902) {
          try {
            wasAdded = await ethereumProvider.value.request({
              method: 'wallet_addEthereumChain',
              params: [{
                chainId: chainId, // A 0x-prefixed hexadecimal string
                chainName: chainName,
                nativeCurrency: {
                  name: currencyName,
                  symbol: currencySymbol, // 2-6 characters long
                  decimals: 18,
                },
                rpcUrls: rpcArray,
                blockExplorerUrls: blockExplorerArray,
                iconUrls: iconUrlArray, // Currently ignored.
              }],
            })

            if (wasAdded) {
              console.log('chain was added');
            } else {
              console.log('chain not added');
            }
          }catch (error) {
            console.log(error);
          }
        }else {
          console.log('non switch error', error)
        }
      }
      return wasAdded

    }
    provide('$metaMaskEthereumChainAddRequest', metaMaskEthereumChainAddRequest)
    const connectUsingWebProvider = async (accountsChanged = null) => {
      if (metamaskInstalled.value) {
        console.log('meta mask installed')
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

          chainId.value = (await provider.getNetwork())['chainId'] // getNetwork = {chain id, chain name}
          launchPadContract = await new ethers.Contract(LAUNCHPAD_ADDRESS[chainId.value] || '', launchpadCode.abi, signer)
          if (launchPadContract) {
            launchPadLoaded.value = true
          }
          // reload if chain is changed
          ethereumProvider.value.on('chainChanged', (chainId) => {
            window.location.reload();
          })
          // checks to see if any account has permission
          ethereumProvider.value.on('accountsChanged',() => { checkExisting(true) })
          provider.on("block", async (blockNumber) => {
            console.log('received block event')
            const block = await  provider.getBlock()
            blockInfo.value = {timestamp: block.timestamp, blockNumber: blockNumber}
          })
        }else {
          launchPadLoaded.value = false
          provider = undefined
          signer = undefined
          launchPadContract = undefined
          console.log('connecteda')
          if (accountsChanged) {
            // if accounts was just changed an no accounts is connected reload
            window.location.reload();
          } else {
            // this is probably from a reload, so use jsonrpc provider
            if (provider) {
              provider.off("block")
            }

            await connectUsingJsonRPCProvider()
          }


        }
      }
    }
    const checkExisting = async (accountsChanged = null) => {
      // check if an web3 wallet is visible
      ethereumProvider.value = await detectEthereumProvider();
      metamaskInstalled.value = ethereumProvider.value ? Boolean(ethereumProvider.value) : false
      console.log('etherruem prov is', ethereumProvider.value, metamaskInstalled.value)
       if (metamaskInstalled.value) {
         await connectUsingWebProvider(accountsChanged)
       }else {
        await connectUsingJsonRPCProvider()
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
        if (connectedAndPermissioned.value) {
          checkExisting();
        }

        // provider = new ethers.providers.Web3Provider(ethereumProvider.value)
        // signer = provider.getSigner()
        console.log(signer, 'signer value')
      }

    }

    provide('$connectEthereum', connectEthereum)
    const getProvider = () => {
      return provider
    }
    provide('$getProvider', getProvider)

    const getSigner = () => {
      return signer
    }
    provide('$getSigner', getSigner)


    const getConnectedAndPermissioned = () => {
      return connectedAndPermissioned
    }
    provide('$getConnectedAndPermissioned', getConnectedAndPermissioned)

    const getLaunchPadContract = () => {
      return  launchPadContract
    }
    provide('$getLaunchPadContract', getLaunchPadContract)

    const callLaunchPadFunction = async (functionName, argsList = []) => {
      const launchpad = getLaunchPadContract()
      console.log('launchpad is', launchpad)
      return await launchpad[functionName](...argsList)
    }

    provide('$callLaunchPadFunction', callLaunchPadFunction)


    return {
      setDarkMode,
      connectEthereum,
      checkExisting,
      getProvider,
      getSigner,
      getLaunchPadContract,
      connectUsingJsonRPCProvider,
      metaMaskEthereumChainAddRequest,
      metamaskInstalled,
      ethereumProvider,
      connectedAccounts,
      connectedAndPermissioned,
      launchPadContract,
      launchPadLoaded,
      chainId,
      blockInfo
    }
  },
  data() {
    return {
      showWalletConnectModal: false,
    }
  },
  computed: {
    darkLightText(){
      return this.$q.dark.isActive ? 'light' : 'dark'
    },
    darkLightTextReverse(){
      return this.$q.dark.isActive ? 'dark' : 'light'
    },

    connectBtnLabel() {
      console.log('connected permission', this.connectedAndPermissioned)
      if (this.connectedAndPermissioned) {
        let addr = this.connectedAccounts[0]

        return `${addr.slice(0, 6)}....${addr.slice(addr.length - 4)}`
      }

      return this.metamaskInstalled ? 'Connect' : 'Install Metamask'
    }
  },
  methods: {
    connectOrInstallBtn() {
      if (!this.connectedAndPermissioned) {
        if (this.connectBtnLabel === 'Connect') {
          this.showWalletConnectModal = !this.showWalletConnectModal
        }else {
          const onboarding = new MetaMaskOnboarding();
          onboarding.startOnboarding()
        }
      }

    },
    async signTx() {
      console.log('this signer', this.getSigner(), this.getProvider(), this.ethereumProvider.selectedAddress)
      console.log('connected accounts', this.connectedAccounts)
      const resp = await this.getProvider().getBalance('0x9965507D1a55bcC2695C58ba16FB37d819B0A4dc');
      // const resp = await this.getSigner().sendTransaction({
      //   to: "0x9965507D1a55bcC2695C58ba16FB37d819B0A4dc",
      //   value: this.$ethers.utils.parseEther("1.0")
      // });
      // const resp = await this.provider.getBlockNumber()
      console.log('response is', resp, this.$ethers.utils.formatEther(resp), resp._isBigNumber)
    },
    async callContract() {
      const launchpad = this.getLaunchPadContract()
      const getValue = await launchpad.getProposals('0')
      console.log('get proposals', getValue)
      // console.log('_minPerAddr', getValue._minPerAddr.toString())

      // listen to contract events
      const filter = {
        address: launchpad.address,
        topic: Object.values(launchpad.filters)
      }
      launchpad.on(filter, (result) => {
        console.log('result in event is', result)
      })
      console.log('ilo contract', launchpad, getValue)
    }
  },
  mounted() {
    console.log('get provider', this.getProvider())
    // console.log('process env', process.env)
    // console.log('ipfs utils', this.$ipfs_utils.addILOAbout('xStarter', 'xStarter is a ', {facebook: 'httpsskfd'}))
  },
  watch: {
    jsonRPCEndpoint: async function() {
      await this.checkExisting(false)

    }
  }
})
</script>


