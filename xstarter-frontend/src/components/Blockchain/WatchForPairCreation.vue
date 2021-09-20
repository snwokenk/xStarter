<template>
  <q-page class="flex flex-center">
    <div class="full-width justify-center row">
      <q-btn label="start listening" outline @click="listenAndFilterTransaction" />
    </div>

    <div class="column q-gutter-y-lg">
      <div class="col-12 text-center" v-for="obj in arrayOfERC20" :key="obj.hash">
        tx hash: {{ obj.hash }} <br />
        token Address: {{ obj.tokenAddr }} <br />
        token name: {{ obj.name }}
        <q-btn flat label="view on BscScan" @click="openLink(`https://bscscan.com/token/${obj.tokenAddr}`)" />
      </div>
    </div>


  </q-page>
</template>

<script>
import {defineComponent, inject, ref} from 'vue';
import {ethers} from "boot/ethers";
import { openURL } from 'quasar'

const ERC20ABI = [
  'function balanceOf(address owner) view returns (uint256 balance)',
  'function totalSupply() view returns (uint)',
  'function name() view  returns (string)',
  'function symbol() view returns (string)'
]

const RouterABI = [
  'function balanceOf(address owner) view returns (uint256 balance)',
  'function totalSupply() view returns (uint)',
  'function name() view  returns (string)',
  'function symbol() view returns (string)'
]

const FactoryABI = [
  'event PairCreated(address indexed token0, address indexed token1, address pair, uint)',
  'function getPair(address tokenA, address tokenB) view returns (address pair)',
  'function allPairs(uint) view returns (address pair)'
]

export default defineComponent( {
    name: "WatchForPairCreation",
    setup() {
      const getProvider = inject('$getProvider')
      const getSigner = inject('$getSigner')
      const getLaunchPadContract = inject('$getLaunchPadContract')
      const connectedAccount = inject('$connectedAccounts')
      let chainId = inject('$chainId')
      const getConnectedAndPermissioned = inject('$getConnectedAndPermissioned')
      const localProvider =  new ethers.providers.JsonRpcProvider('https://bsc-dataseed.binance.org/');
      const getLocalProvider = () => {
        return localProvider
      }
      const pcakeRouter =  new ethers.Contract('0x10ED43C718714eb63d5aA57B78B54704E256024E', ERC20ABI, localProvider);
      // 0xca143ce32fe78f1f7019d7d551a6402fc5350c73
      const getPCakeRouter = () => {
        return pcakeRouter
      }

      const pcakeFactory = new ethers.Contract('0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73', FactoryABI, localProvider);
      const getPCakeFactory = () => {
        return pcakeFactory
      }

      // const mintABi = xStarterERC721Code.abi
      console.log('provider is ', getProvider())
      return {getProvider, getLocalProvider,getPCakeRouter, getPCakeFactory, getSigner, getLaunchPadContract, getConnectedAndPermissioned, connectedAccount, chainId, current: ref(1)}
    },
    data() {
      return {
        arrayOfTxs: [],
        arrayOfERC20: [],
        erc20ABI: [
          'function balanceOf(address owner) view returns (uint256 balance)',
          'function totalSupply() view returns (uint)',
          'function name() view  returns (string)',
          'function symbol() view returns (string)'
        ],
        provider: null
      }
    },
    methods: {
      openLink(url) {
        openURL(url)
      },
      async getHistoryPairCreated() {
        const aContract = this.getPCakeFactory()
      },
      async listenForTransaction() {
        const provider = this.getProvider()
        console.log('provider is', provider)
        provider.on("pending", (tx) => {
          console.log('tx creates is', tx.creates)
          if (this.creates) {
            this.arrayOfTxs.push({hash: tx.hash, creates: tx.creates})
          }
        });
        console.log('provider is', provider)
      },
      async listenForBSCTransaction() {
        const provider =  new this.$ethers.providers.JsonRpcProvider('https://bsc-dataseed.binance.org/');
        console.log('provider is', provider)
        provider.on("pending", (tx) => {
          console.log('tx creates is', tx.creates, tx.hash)
          if (tx.creates) {
            this.arrayOfTxs.push({hash: tx.hash, creates: tx.creates})
          }
        });
        console.log('provider is', provider)
      },

      async listenAndFilterTransaction() {
        // const provider =  new this.$ethers.providers.JsonRpcProvider('https://bsc-dataseed.binance.org/');
        const provider = this.getLocalProvider()
        console.log('provider is', provider)
        provider.on("block", async (blockNumber) => {
          // console.log('block number', blockNumber)
          const blockWithTx = await provider.getBlockWithTransactions(blockNumber)

          this.getTxWithContractCreation(blockWithTx.transactions)
        });
        console.log('provider is', provider)
      },
      async getTxWithContractCreation(arrayOfTx) {
        for (const tx of arrayOfTx) {
          // console.log(tx)
          if (tx.creates) {
            console.log('tx creates', tx.creates)
            const name = await this.checkIfERC20(tx.creates)
            this.arrayOfTxs.push(tx)
            if (name) {
              this.arrayOfERC20.push({hash: tx.hash, tokenAddr: tx.creates, name: name})
            }
          }
        }
      },
      async checkIfERC20(contractAddress) {
        const provider = this.getLocalProvider()
        const contract = new this.$ethers.Contract(contractAddress, this.erc20ABI, provider);
        console.log('contract variable created', contract)
        let name;
        try {
          name = await contract.name()
        } catch (e) {
          console.log('not an erc20 token')
          return  null
        }
        console.log('is erc20 name is', name)
        return name
      }
      // async blockListenerFunc(blockNo, provider) {
      //  this.getTxWithContractCreation( await provider.getBlockWithTransactions(blockNo))
      // }
    },

    mounted() {
    }
  }
)
</script>

<style scoped>

</style>

