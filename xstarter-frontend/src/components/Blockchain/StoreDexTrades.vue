<template>
  <div class="row">
    <div class="full-width justify-center col-12 row q-mt-md">
      <div class="col-12 justify-center row">
        <q-btn label="listen for volume" outline @click="listenAndFilterTransaction" />
        <q-btn label="Compute" outline @click="computeVolume" />
        <q-btn label="Compute Paginate" outline @click="computeVolumePaginated" />
      </div>
<!--      <div class="col-12 row q-gutter-lg">-->
<!--        <q-input class="col-5" outlined v-model="symbolFilter" label="symbol to filter" />-->
<!--        <q-btn class="col-6" label="listen and find pair by symbol" outline @click="listenAndFilterPairCreatedBySymbol" />-->
<!--      </div>-->
    </div>
    <div class="col-12" v-if="listeningDate"> Started Listening {{ listeningDate  }}</div>
    <div v-if="tokenAndVolume.length" class="q-gutter-y-lg col-12">
      <div class="text-center" v-for="obj in tokenAndVolumeSorted" :key="obj.tokenAddr">
        Token Address : {{ obj.tokenAddr }} <br />
        Sell Volume: {{ $ethers.utils.formatEther(obj.sellVolume.toString()) }} <br />
        Buy Volume: {{ $ethers.utils.formatEther(obj.buyVolume.toString()) }}<br />
        total: {{ $ethers.utils.formatEther(obj.total.toString()) }}<br />
        net: {{ $ethers.utils.formatEther(obj.net.toString()) }}
        <q-btn flat label="view on BscScan" @click="openLink(`https://bscscan.com/token/${obj.tokenAddr}`)" />
      </div>
    </div>

<!--    <div v-if="arrayOfFilteredDexPairBySymbol.length" class="q-gutter-y-lg">-->
<!--      <div class="col-12 text-center" v-for="obj in arrayOfFilteredDexPairBySymbol" :key="obj.hash">-->
<!--        pair address: {{ obj.pairAddr }} <br />-->
<!--        token Address: {{ obj.tokenAddr }} <br />-->
<!--        Symbol: {{ obj.symbol }}<br />-->
<!--        name : {{ obj.name}}<br />-->
<!--        <q-btn flat label="view Token on BscScan" @click="openLink(`https://bscscan.com/token/${obj.tokenAddr}`)" />-->
<!--        <q-btn flat label="view Pair LP on BscScan" @click="openLink(`https://bscscan.com/token/${obj.pairAddr}`)" />-->
<!--      </div>-->
<!--    </div>-->



  </div>
</template>

<script>
import {defineComponent, inject, ref} from 'vue';
import {ethers} from "boot/ethers";
import { openURL } from 'quasar'
import {MAJOR_TOKEN_ADDR, pPairV2ABI, pRouterV2ABI} from "src/constants";

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
    name: "StoreDexTrades",
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

      const pCakeRouterInterface = new ethers.utils.Interface(pRouterV2ABI)
      const getPCakeRouterInterface = () => {
        return pCakeRouterInterface
      }

      const pCakePairInterface = new ethers.utils.Interface(pPairV2ABI)
      const getPCakePairInterface = () => {
        return pCakePairInterface
      }
      const pCakeRouterAddr = ethers.utils.getAddress('0x10ED43C718714eb63d5aA57B78B54704E256024E')
      const pcakeRouter =  new ethers.Contract(pCakeRouterAddr, RouterABI, localProvider);
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
        getPCakeRouterInterface,
        getPCakePairInterface,
        getPCakeFactory,
        getERC20Contract,
        getSigner,
        getLaunchPadContract,
        getConnectedAndPermissioned,
        connectedAccount,
        chainId,
        pCakeRouterAddr,
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
        tokenWithIndex: {}, // maps index of token and volume
        tokenAndVolume: [],
        currentBlockNumber: 0,
        provider: null,
        listeningDate: null,
        dbName: 'BlockchainData',
        objectStoreName: 'DexTrades',
      }
    },
    computed: {
      tokenAndVolumeSorted() {
        // smallest to greatest
        // return [...this.tokenAndVolume].sort(function (a, b) {
        //   return a.total - b.total;
        // });
        if (this.currentBlockNumber === 0) {}
        return [...this.tokenAndVolume].sort(function (a, b) {
          return b.net - a.net  ;
        }).slice(0, 100);
      }
    },
    methods: {
      openLink(url) {
        openURL(url)
      },

      async computeVolume() {
        const currentHourTimestamp = this.getCurrentHourTimestamp(true)
        console.log('currenthourtimestamp', currentHourTimestamp - 1)
        await this.$indexDBFactory.getNumberedIndexByRange(
          this.dbName,
          this.objectStoreName,
          'timestamp',
          currentHourTimestamp - 7201, // minus one second
          currentHourTimestamp + 3601,
          this.calculateAndPopulateData
        )
      },
      async computeVolumePaginated() {
        const currentHourTimestamp = this.getCurrentHourTimestamp(true)
        console.log('currenthourtimestamp', currentHourTimestamp - 1)
        await this.$indexDBFactory.getPaginatedNumberedIndexByRange(
          this.dbName,
          this.objectStoreName,
          'timestamp',
          // currentHourTimestamp - 7201, // minus one second
          1633741200,
          // currentHourTimestamp + 3601,
          1633748400,
          30,
          this.calculateAndPopulateAllData
        )
      },
      getCurrentHourTimestamp(inSeconds) {
        const d = new Date()
        d.setMinutes(0,0,0)
        console.log('time is', d.getTime())
        return inSeconds ? Math.floor(d.getTime()/1000) :  d.getTime()
      },
      async calculateAndPopulateData(data) {
        console.log('data is ')
        if (typeof this.tokenWithIndex[data.tokenAddr] === 'undefined') {
          this.tokenWithIndex[data.tokenAddr] = this.tokenAndVolume.push({
            tokenAddr: data.tokenAddr,
            buyVolume: ethers.BigNumber.from(0),
            sellVolume: ethers.BigNumber.from(0),
            total: ethers.BigNumber.from(0),
            net: ethers.BigNumber.from(0)
          }) - 1 // add index
        }

        const indOfToken = this.tokenWithIndex[data.tokenAddr]
        this.tokenAndVolume[indOfToken].sellVolume = this.tokenAndVolume[indOfToken].sellVolume.add(data.sellVolume)
        this.tokenAndVolume[indOfToken].buyVolume = this.tokenAndVolume[indOfToken].buyVolume.add(data.buyVolume)
        this.tokenAndVolume[indOfToken].total = this.tokenAndVolume[indOfToken].total.add(data.buyVolume).add(data.sellVolume)
        this.tokenAndVolume[indOfToken].net = this.tokenAndVolume[indOfToken].net.sub(data.sellVolume).add(data.buyVolume)

      },

      async calculateAndPopulateAllData(arrayOfData) {
        console.log('data is ', arrayOfData)
        for (let i = 0; i < arrayOfData.length - 1; i++) {
          const data = arrayOfData[i]
          if (typeof this.tokenWithIndex[data.tokenAddr] === 'undefined') {
            this.tokenWithIndex[data.tokenAddr] = this.tokenAndVolume.push({
              tokenAddr: data.tokenAddr,
              buyVolume: ethers.BigNumber.from(0),
              sellVolume: ethers.BigNumber.from(0),
              total: ethers.BigNumber.from(0),
              net: ethers.BigNumber.from(0)
            }) - 1 // add index
          }

          const indOfToken = this.tokenWithIndex[data.tokenAddr]
          this.tokenAndVolume[indOfToken].sellVolume = this.tokenAndVolume[indOfToken].sellVolume.add(data.sellVolume)
          this.tokenAndVolume[indOfToken].buyVolume = this.tokenAndVolume[indOfToken].buyVolume.add(data.buyVolume)
          this.tokenAndVolume[indOfToken].total = this.tokenAndVolume[indOfToken].total.add(data.buyVolume).add(data.sellVolume)
          this.tokenAndVolume[indOfToken].net = this.tokenAndVolume[indOfToken].net.sub(data.sellVolume).add(data.buyVolume)
        }

      },

      async listenAndFilterTransaction() {
        // const provider =  new this.$ethers.providers.JsonRpcProvider('https://bsc-dataseed.binance.org/');
        console.log('trying to listen')
        const provider = this.getLocalProvider()
        console.log('provider is', provider)
        provider.on("block", async (blockNumber) => {
          // console.log('block number', blockNumber)
          this.currentBlockNumber = blockNumber
          const blockWithTx = await provider.getBlockWithTransactions(blockNumber)

          this.getTxRouterAddress(blockWithTx)
        });
        this.listeningDate = new Date()
      },

      async getTxRouterAddress(blockWithTx) {
        const arrayOfTx = blockWithTx.transactions
        const blockTimestamp = blockWithTx.timestamp
        const formattedDataToAdd = []
        for (const tx of arrayOfTx) {
          // console.log(tx)
          if (tx.to === this.pCakeRouterAddr) {
            // console.log('tx is', await tx.wait())
            // deconde
            const anInterface = this.getPCakeRouterInterface()
            const decodedData = anInterface.parseTransaction(tx)
            // console.log('decoded data is',  decodedData.name)
            const funcName = decodedData.name
            switch (funcName) {
              case 'swapExactTokensForETH':
                // this.handleSwapExactTokensForETH(decodedData, blockTimestamp, formattedDataToAdd)
                await this.storeSwapExactTokensForETH(decodedData, blockTimestamp, formattedDataToAdd)
                break
              case 'swapExactTokensForETHSupportingFeeOnTransferTokens':
                await this.storeSwapExactTokensForETH(decodedData, blockTimestamp, formattedDataToAdd)
                break
              case 'swapETHForExactTokens':
                await this.storeSwapETHForExactTokens(decodedData,blockTimestamp, formattedDataToAdd)
                break
              case 'swapExactETHForTokens':
                // await this.storeSwapETHForExactTokens(decodedData,blockTimestamp, formattedDataToAdd)
                await this.storeSwapETHForExactTokens(decodedData,blockTimestamp, formattedDataToAdd)
                break
              case 'swapExactETHForTokensSupportingFeeOnTransferTokens':
                // console.log('****** swapExactETHForTokensSupportingFeeOnTransferTokens', decodedData)
                await this.storeSwapETHForExactTokens(decodedData,blockTimestamp, formattedDataToAdd)
                break
              default:
                console.log('it other', funcName, decodedData)
            }

          }
        }
        console.log('formated dat is', formattedDataToAdd)
        this.$indexDBFactory.addData(
          this.dbName,
          this.objectStoreName,
          formattedDataToAdd,
          (event) => { },
          (event) => { console.log("on error", event)}
        )
      },

      async storeSwapExactTokensForETH(decodedData, blockTimestamp, formattedDataToAdd) {
        const tokenAddr = decodedData.args.path[0]  // the sold token is always index o and bought token is always last index
        if(MAJOR_TOKEN_ADDR[tokenAddr]) {return}
          formattedDataToAdd.push({
            tokenAddr: tokenAddr,
            timestamp: blockTimestamp,
            buyVolume: ethers.BigNumber.from(0),
            sellVolume: decodedData.args.amountOutMin
            // total: decodedData.args.amountOutMin,
            // net: decodedData.args.amountOutMin.mul(-1)
          })

      },
      async storeSwapETHForExactTokens(decodedData, blockTimestamp, formattedDataToAdd) {
        const tokenAddr = decodedData.args.path[decodedData.args.path.length - 1]  // the sold token is always index o and bought token is always last index
        if(MAJOR_TOKEN_ADDR[tokenAddr]) {return}
          formattedDataToAdd.push({
            tokenAddr: tokenAddr,
            timestamp: blockTimestamp,
            buyVolume: decodedData.value,
            sellVolume: ethers.BigNumber.from(0)
            // total: decodedData.value,
            // net: decodedData.value
          })

      },

      async filterCakePairTx(arrayOfTx) {
        console.log(arrayOfTx)
        for (const tx of arrayOfTx) {
          // console.log(tx)

          if (tx.to !== this.pCakeRouterAddr) {
            console.log('tx is', tx)
            // console.log('tx is', await tx.wait())
            // deconde
            const anInterface = this.getPCakeRouterInterface()
            const decodedData = anInterface.parseTransaction(tx)
            console.log('decoded data is', decodedData)
            break
            // const name = await this.checkIfERC20(tx.creates)
            // this.arrayOfTxs.push(tx)
            // if (name) {
            //   this.arrayOfERC20.push({hash: tx.hash, tokenAddr: tx.creates, name: name})
            // }
          }
        }
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
      // setup db
      this.$indexDBFactory.setupDatabaseAndObjectStore(
        this.dbName,
        this.objectStoreName,
        null,
        [['tokenAddr', false], ['buyVolume', false], ['sellVolume', false], ['timestamp', false]]
      )

      // this.$indexDBFactory.deleteDatabase(this.dbName)
    }
  }
)
</script>

<style scoped>

</style>

