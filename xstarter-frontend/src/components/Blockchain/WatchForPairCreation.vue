<template>
  <div class="row">
    <div class="full-width q-gutter-y-xl justify-center row q-mt-md">
      <div class="col-12 justify-center row">
        <q-btn label="listen and find pair by amount" outline @click="listenAndFilterPairCreatedByWETHReserve" />
      </div>
      <div class="col-12 row q-gutter-lg">
        <q-input class="col-5" outlined v-model="symbolFilter" label="symbol to filter" />
        <q-btn class="col-6" label="listen and find pair by symbol" outline @click="listenAndFilterPairCreatedBySymbol" />
      </div>
    </div>

    <div v-if="arrayOfFilteredDexPairByAmount.length" class="q-gutter-y-lg">
      <div class="col-12 text-center" v-for="obj in arrayOfFilteredDexPairByAmount" :key="obj.hash">
        pair address: {{ obj.pairAddr }} <br />
        token Address: {{ obj.tokenAddr }} <br />
        WETH(Native Token) Balance: {{ obj.WETHBal }}<br />
        reserve 1 or reserve 2 : {{ obj.reserveName}}
        <q-btn flat label="view on BscScan" @click="openLink(`https://bscscan.com/token/${obj.tokenAddr}`)" />
      </div>
    </div>

    <div v-if="arrayOfFilteredDexPairBySymbol.length" class="q-gutter-y-lg">
      <div class="col-12 text-center" v-for="obj in arrayOfFilteredDexPairBySymbol" :key="obj.hash">
        pair address: {{ obj.pairAddr }} <br />
        token Address: {{ obj.tokenAddr }} <br />
        Symbol: {{ obj.symbol }}<br />
        name : {{ obj.name}}<br />
        <q-btn flat label="view Token on BscScan" @click="openLink(`https://bscscan.com/token/${obj.tokenAddr}`)" />
        <q-btn flat label="view Pair LP on BscScan" @click="openLink(`https://bscscan.com/token/${obj.pairAddr}`)" />
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
      const pcakeRouter =  new ethers.Contract('0x10ED43C718714eb63d5aA57B78B54704E256024E', RouterABI, localProvider);
      // 0xca143ce32fe78f1f7019d7d551a6402fc5350c73
      const getPCakeRouter = () => {
        return pcakeRouter
      }

      const pcakeFactory = new ethers.Contract('0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73', FactoryABI, localProvider);
      const getPCakeFactory = () => {
        return pcakeFactory
      }

      const getERC20Contract = (tokenAddr) => {
        return new ethers.Contract(tokenAddr, ERC20ABI, localProvider);
      }

      // const mintABi = xStarterERC721Code.abi
      console.log('provider is ', getProvider())
      return {
        getProvider,
        getLocalProvider,
        getPCakeRouter,
        getPCakeFactory,
        getERC20Contract,
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
        symbolFilter: '',
        arrayOfFilteredDexPairByAmount: [],
        arrayOfFilteredDexPairBySymbol: [],
        arrayOfERC20: [],
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
          await this.filterHistoryPairEventsByLiquidity(prevEvents, minAmtInWeiBigNUmber)
        }
      },

      async listenAndFilterPairCreatedBySymbol() {
        // get previous
        // const minAmtInEthers = this.minAmtInEthers
        if (this.searchHistoric) {
          let prevEvents = await this.getHistoricPairCreatedEvents()
          await this.filterHistoryPairEventsBySymbol(prevEvents)
        }
        this.filterRealtimePairEventsBySymbol()
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
            this.queryAndFilterPairByAmount(deData.pair, minAmountInWeiBigNumber, deData.token0, 'reserve1')

          }else if (deData.token0 === this.WETH) {
            console.log('token 0 is weth', deData.token0 === this.WETH, deData.token1, this.WETH)
            this.queryAndFilterPairByAmount(deData.pair, minAmountInWeiBigNumber, deData.token1, 'reserve0')
          }
        }
      },
      async queryAndFilterPairByAmount(pairAddress, minAmountInWeiBigNumber, tokenAddress, reserve1Or0) {
        const reserves = await this.queryPairForReserves(pairAddress)
        console.log('reserves is', reserves, reserves[reserve1Or0].gte(minAmountInWeiBigNumber))
        if (reserves[reserve1Or0].gte(minAmountInWeiBigNumber)) {
          this.arrayOfFilteredDexPairByAmount.push({
            pairAddr: pairAddress,
            tokenAddr: tokenAddress,
            WETHBal: ethers.utils.formatEther(reserves[reserve1Or0]),
            reserveName: reserve1Or0
          })
        }else {
          console.log('not greater than ', this.minAmtInEthers)
        }
      },
      async filterHistoryPairEventsBySymbol(events = []) {
        console.log('events in history filter is', events)
        const symbolUppercase = this.symbolFilter.toUpperCase()
        for (let i = 0; i < events.length; i++) {
          let event = events[i]
          let deData = await event.decode(event.data, event.topics)
          if (deData.token1 === this.WETH) {
            this.queryAndFilterPairBySymbol(deData.pair, symbolUppercase, deData.token0)

          }else if (deData.token0 === this.WETH) {
            this.queryAndFilterPairBySymbol(deData.pair, symbolUppercase, deData.token1)

          }
        }
      },
      async filterRealtimePairEventsBySymbol() {
        const aContract = this.getPCakeFactory()
        // const provider = this.getLocalProvider()
        console.log('starting listen for event and filter by symbol')
        aContract.on('PairCreated', async (token0, token1, pair, indexInAllPairs, event) => {
          const symbolUppercase = this.symbolFilter.toUpperCase()
          if (token1 === this.WETH) {
            await this.queryAndFilterPairBySymbol(pair, symbolUppercase, token0)

          }else if (token0 === this.WETH) {
            await this.queryAndFilterPairBySymbol(pair, symbolUppercase, token1)

          }
        })
        console.log('listen for event and filter by symbol started')
      },
      async queryAndFilterPairBySymbol(pairAddress, symbol, tokenAddress) {
        // const reserves = await this.queryPairForReserves(pairAddress)
        // console.log('reserves is', reserves, reserves[reserve1Or0].gte(minAmountInWeiBigNumber))

        const ercContract = this.getERC20Contract(tokenAddress)
        const tokenSymbol =  await ercContract.symbol()
        if (tokenSymbol.toUpperCase() === symbol) {
          const name =  await ercContract.name()
          this.arrayOfFilteredDexPairBySymbol.push({
            pairAddr: pairAddress,
            tokenAddr: tokenAddress,
            symbol: tokenSymbol,
            name: name
          })
        }else {
          console.log(`tokensymbol not equals to ${symbol} but rather: ${tokenSymbol.toUpperCase()}`, pairAddress)
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

