<template>
  <div class="row">
    <div class="full-width justify-center row q-mt-md">
      <q-btn label="find past paircreated" outline @click="listenAndFilterPairCreatedByWETHReserve" />
    </div>

    <div class="q-gutter-y-lg">
      <div class="col-12 text-center" v-for="obj in arrayOfFilteredDexPair" :key="obj.hash">
        pair address: {{ obj.pairAddr }} <br />
        token Address: {{ obj.tokenAddr }} <br />
        WETH(Native Token) Balance: {{ obj.WETHBal }}<br />
        reserve 1 or reserve 2 : {{ obj.reserveName}}
        <q-btn flat label="view on BscScan" @click="openLink(`https://bscscan.com/token/${obj.tokenAddr}`)" />
      </div>
    </div>


  </div>
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
const PairABI = [
  'function balanceOf(address owner) view returns (uint256 balance)',
  'function totalSupply() view returns (uint)',
  'function name() view  returns (string)',
  'function symbol() view returns (string)',
  'function getReserves() view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast)'
]

// todo: currently for bsc and PCakeSwap, make it chain agnostic
// https://docs.ethers.io/v5/getting-started/#getting-started--events
export default defineComponent( {
    name: "WatchForPairCreation",
    setup() {
      const getProvider = inject('$getProvider')
      const getSigner = inject('$getSigner')
      const getLaunchPadContract = inject('$getLaunchPadContract')
      const connectedAccount = inject('$connectedAccounts')
      let chainId = inject('$chainId')
      const getConnectedAndPermissioned = inject('$getConnectedAndPermissioned')
      const WETH = ethers.utils.getAddress('0xbb4cdb9cbd36b01bd1cbaebf2de08d9173bc095c')
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
      return {
        getProvider,
        getLocalProvider,
        getPCakeRouter,
        getPCakeFactory,
        getSigner,
        getLaunchPadContract,
        getConnectedAndPermissioned,
        connectedAccount,
        chainId,
        current: ref(1),
        WETH
      }
    },
    data() {
      return {
        arrayOfTxs: [],
        minAmtInEthers: 5,
        searchHistoric: true,
        arrayOfFilteredDexPair: [],
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

      async listenAndFilterPairCreatedByWETHReserve() {
        // get previous
        // const minAmtInEthers = this.minAmtInEthers
        if (this.searchHistoric) {
          // const minAmtStr = minAmtInEthers.toString()
          console.log('min amout str', this.minAmtInEthers)
          const minAmtInWeiBigNUmber = ethers.utils.parseEther(this.minAmtInEthers.toString())
          console.log('big number for ethers', minAmtInWeiBigNUmber)
          let prevEvents = await this.getHistoricPairCreatedEvents()
          this.filterHistoryPairEventsByLiquidity(prevEvents, minAmtInWeiBigNUmber)
        }
      },

      // 1
      async getHistoricPairCreatedEvents() {
        const aContract = this.getPCakeFactory()
        const events = await aContract.queryFilter('PairCreated', -5000, 'latest')
        // console.log('events is', events)
        // const i = 2
        // if (events && events.length) {
        //   const deData = await events[i].decode(events[i].data, events[i].topics)
        //   console.log('deData is', deData)
        //   const pairReserves = await this.queryPairForReserves(deData.pair)
        //   console.log('pair reservers', pairReserves)
        //   console.log('pair reservers', ethers.utils.formatEther(pairReserves.reserve1), deData.token0 )
        // }

        return events
      },
      //2
      async filterHistoryPairEventsByLiquidity(events = [], minAmountInWeiBigNumber) {
        console.log('events in history filter is', events)
        for (let i = 0; i < events.length; i++) {
          let event = events[i]
          let deData = await event.decode(event.data, event.topics)
          if (deData.token1 === this.WETH) {
            console.log('token 1 is weth', deData.token1 === this.WETH, deData.token0, this.WETH)
            this.queryAndFilterPair(deData.pair, minAmountInWeiBigNumber, deData.token0, 'reserve1')

          }else if (deData.token0 === this.WETH) {
            console.log('token 0 is weth', deData.token0 === this.WETH, deData.token1, this.WETH)
            this.queryAndFilterPair(deData.pair, minAmountInWeiBigNumber, deData.token1, 'reserve0')
          }
        }
        // for (const event of events) {
        //   let deData = await event.decode(event.data, event.topics)
        //   if (deData.token1 === this.WETH) {
        //     console.log('deData.token0', deData.token0)
        //     // this.queryPairForReserves(deData.pair)
        //   }
        // }
      },
      async queryAndFilterPair(pairAddress, minAmountInWeiBigNumber, tokenAddress, reserve1Or0) {
        const reserves = await this.queryPairForReserves(pairAddress)
        console.log('reserves is', reserves, reserves[reserve1Or0].gte(minAmountInWeiBigNumber))
        if (reserves[reserve1Or0].gte(minAmountInWeiBigNumber)) {
          this.arrayOfFilteredDexPair.push({
            pairAddr: pairAddress,
            tokenAddr: tokenAddress,
            WETHBal: ethers.utils.formatEther(reserves[reserve1Or0]),
            reserveName: reserve1Or0
          })
        }else {
          console.log('not greater than ', this.minAmtInEthers)
        }
      },
      // 3
      async queryPairForReserves(pairAddress) {
        const pairContract = new ethers.Contract(pairAddress, PairABI, this.getLocalProvider());
        console.log('pair Address for', pairContract)
        return await pairContract.getReserves()
      },
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

