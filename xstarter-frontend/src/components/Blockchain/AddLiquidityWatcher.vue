<template>
  <div class="row ">
    <div class="full-width justify-center col-12 row q-mt-md">
      <div class="col-9 row">
        <div class="col-12">
          <q-select
            v-model="selectedBlockChain"
            :options="arrayOfBlockChains"
            label="Select Blockchain To Use"
            class="full-width"
            @update:model-value="selectedDex = null"
          />
        </div>
        <div v-if="selectedBlockChain" class="col-12">
          <q-select v-model="selectedDex" :options="arrayOfAvailableDex" label="Select DEX" class="full-width"/>
        </div>
      </div>
      <div v-if="selectedDex" class="col-12 justify-center row q-mt-xl">
        <q-btn label="listen for AddLiquidity Transactions" outline @click="listenAndFilterTransaction" />
      </div>


      <div v-if="selectedDex" class="col-12 justify-center row">
        <div class="col-9">
          <q-input v-model="addressToAddOrDelete" label="Enter an address to add or delete" />
        </div>
        <div class="col-9 row">
          <q-btn label="add" @click="addAddress" /> <q-btn label="delete" @click="deleteAddress" />
        </div>

      </div>
<!--      <div class="col-12 row q-gutter-lg">-->
<!--        <q-input class="col-5" outlined v-model="symbolFilter" label="symbol to filter" />-->
<!--        <q-btn class="col-6" label="listen and find pair by symbol" outline @click="listenAndFilterPairCreatedBySymbol" />-->
<!--      </div>-->
    </div>
    <div class="col-12" v-if="listeningDate"> Started Listening {{ listeningDate  }}</div>
    <div v-if="addressToWatchArray.length" class="q-gutter-y-lg col-12">
      <div class="text-center" v-for="addr in addressToWatchArray" :key="addr">
        Token Address : {{ addr }} <br />
        Info: {{ addressesToWatch[addr] }} <br />
        <q-btn flat label="view on BscScan" @click="openLink(`https://bscscan.com/token/${addr}`)" />
        <q-btn flat label="view on Poocoin" @click="openLink(`https://poocoin.app/tokens/${addr}`)" />
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
import {openURL} from 'quasar'
import {
  ARRAY_OF_BLOCKCHAINS,
  BLOCKCHAIN_TO_DEX,
  CHAIN_INFO_OBJ,
  MAJOR_TOKEN_ADDR,
  pPairV2ABI,
  pRouterV2ABI
} from "src/constants";

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
    name: "AddLiquidityWatcher",
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
        selectedBlockChain: null,
        selectedDex: null,
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
        addressToAddOrDelete: '',
        addressesToWatch: {},
        notFoundStr: 'Not Found',
        played: false
      }
    },
    computed: {

      arrayOfBlockChains() {
        return [...ARRAY_OF_BLOCKCHAINS]
      },
      arrayOfAvailableDex() {
        if (!this.selectedBlockChain) {return null}
        return BLOCKCHAIN_TO_DEX[this.selectedBlockChain.value] ? BLOCKCHAIN_TO_DEX[this.selectedBlockChain.value] : []
      },
      addressToWatchArray() {
        return Object.keys(this.addressesToWatch)
      },
      selectedJsonEndpoint() {
        if (!this.selectedBlockChain) {return ''}
        return CHAIN_INFO_OBJ[this.selectedBlockChain.value].rpcUrls[0]
      },
      selectedRouterAddress() {
        if (!this.selectedDex) { return ''}
        return this.selectedDex.routerAddress
      },
      getComputedLocalProvider() {
        if (!this.selectedJsonEndpoint) {return null}
        const localProvider =  new ethers.providers.JsonRpcProvider(this.selectedJsonEndpoint);
        // needs to do like this to avoid some errors
        return  () => {
          return localProvider
        }

      },
      getComputedRouterInterface() {
        if (!this.selectedDex) { return null}
        const routerInterface = new ethers.utils.Interface(this.selectedDex.routerABI)
        return () => {
          return routerInterface
        }
      },
      validFunctionsObject() {
        return {
          'addLiquidity': 1,
          'addLiquidityETH': 2,
          'addLiquidityAVAX': 3
        }
      }
    },
    methods: {
      openLink(url) {
        openURL(url)
      },
      addAddress() {
        if (!this.addressToAddOrDelete) { return }
        if (!this.addressesToWatch[this.addressToAddOrDelete]) {
          this.addressesToWatch[this.addressToAddOrDelete.toLowerCase()] = this.notFoundStr
        }
      },
      deleteAddress() {
        if (!this.addressToAddOrDelete) { return }
        if (this.addressesToWatch[this.addressToAddOrDelete]) {
          delete this.addressesToWatch[this.addressToAddOrDelete.toLowerCase()]
        }
      },

      async listenAndFilterTransaction() {
        // const provider =  new this.$ethers.providers.JsonRpcProvider('https://bsc-dataseed.binance.org/');
        const provider = this.getComputedLocalProvider()
        provider.on("block", async (blockNumber) => {
          // console.log('block number', blockNumber)
          this.currentBlockNumber = blockNumber
          const blockWithTx = await provider.getBlockWithTransactions(blockNumber)

          this.getTxRouterAddress2(blockWithTx.transactions)
        });
        this.listeningDate = new Date()
      },

      async playAudio() {
        // if (this.played) {return }
        // this.played = true
        let alarmAudio = await new Audio('Alarm-Fast-High-Pitch-A1-www.fesliyanstudios.com.mp3')
        alarmAudio.play()
      },

      async getTxRouterAddress2(arrayOfTx) {

        for (const tx of arrayOfTx) {
          if (tx.to.toLowerCase() === this.selectedRouterAddress.toLowerCase()) {
            console.log(tx.to, this.selectedRouterAddress, this.selectedDex.label)
            const anInterface = this.getComputedRouterInterface()
            // parses transaaction
            const decodedData = anInterface.parseTransaction(tx)
            // console.log('decoded data is',  decodedData.name)
            const funcName = decodedData.name
            if (!this.validFunctionsObject[funcName] ) { continue }
            console.log(tx)
            console.log(`${funcName} func`, decodedData)
            console.log(decodedData.args)
            let quoteTokenAmt, aTokenAmt, rate;
            if (this.validFunctionsObject[funcName] === 1) {
              let tokenA = decodedData.args.tokenA
              let tokenB = decodedData.args.tokenB
              console.log(decodedData.args.amountAMin, decodedData.args.amountAMin.toString(), decodedData.args.amountBMin.toString())
              if (MAJOR_TOKEN_ADDR[decodedData.args.tokenA.toLowerCase()]) {
                quoteTokenAmt = decodedData.args.amountAMin
                aTokenAmt = decodedData.args.amountBMin
              }else if (MAJOR_TOKEN_ADDR[decodedData.args.tokenB.toLowerCase()]) {
                quoteTokenAmt = decodedData.args.amountBMin
                aTokenAmt =decodedData.args.amountAMin
              }else {
                continue
              }
              // multiply by 100 before dividing bigNumber doesn't support decimals
              rate = quoteTokenAmt.mul(100).div(aTokenAmt)
              console.log('rate is', rate, this.$helper.weiBigNumberToFloatEther(rate), rate.toString())

              if (this.addressesToWatch[tokenA.toLowerCase()] && this.addressesToWatch[tokenA.toLowerCase()] === this.notFoundStr ) {
                this.addressesToWatch[tokenA.toLowerCase()] = `Found on ${new Date()} | rate is ${rate.toNumber() / 100}`
                this.playAudio()

              }else if (this.addressesToWatch[tokenB.toLowerCase()] && this.addressesToWatch[tokenB.toLowerCase()] === this.notFoundStr) {
                this.addressesToWatch[tokenB.toLowerCase()] = `Found on ${new Date()} | rate is ${rate.toNumber() / 100}`
                this.playAudio()
              }
            } else {
              quoteTokenAmt = decodedData.args.amountETHMin
              aTokenAmt = decodedData.args.amountTokenMin
              let token = decodedData.args.token

              // multiply by 100 before dividing bigNumber doesn't support decimals
              rate = quoteTokenAmt.mul(100).div(aTokenAmt)
              console.log('rate is', rate, this.$helper.weiBigNumberToFloatEther(rate), rate.toString())

              if (this.addressesToWatch[token.toLowerCase()] && this.addressesToWatch[token.toLowerCase()] === this.notFoundStr ) {
                this.addressesToWatch[token.toLowerCase()] = `Found on ${new Date()} | rate is ${rate.toNumber() / 100}`
                this.playAudio()

              }

            }


          }
        }
      },


      async getTxRouterAddress(arrayOfTx) {
        const b1 = this.$ethers.BigNumber.from('13654621516305003672')
        const b2 = this.$ethers.BigNumber.from('265444534892806746708')

        console.log('test big number', b1.mul(100).div(b2), b1)
        for (const tx of arrayOfTx) {
          // console.log(tx)
          if (tx.to === this.pCakeRouterAddr) {
            // console.log('tx is', await tx.wait())
            // deconde
            const anInterface = this.getPCakeRouterInterface()
            // parses transaaction
            const decodedData = anInterface.parseTransaction(tx)
            // console.log('decoded data is',  decodedData.name)
            const funcName = decodedData.name
            if (!this.validFunctionsObject[funcName] ) { continue }
            console.log(tx)
            console.log(`${funcName} func`, decodedData)
            console.log(decodedData.args)
            let quoteTokenAmt, aTokenAmt, rate;
            if (this.validFunctionsObject[funcName] === 1) {
              let tokenA = decodedData.args.tokenA
              let tokenB = decodedData.args.tokenB
              console.log(decodedData.args.amountAMin, decodedData.args.amountAMin.toString(), decodedData.args.amountBMin.toString())
              if (MAJOR_TOKEN_ADDR[decodedData.args.tokenA.toLowerCase()]) {
                quoteTokenAmt = decodedData.args.amountAMin
                aTokenAmt = decodedData.args.amountBMin
              }else if (MAJOR_TOKEN_ADDR[decodedData.args.tokenB.toLowerCase()]) {
                quoteTokenAmt = decodedData.args.amountBMin
                aTokenAmt =decodedData.args.amountAMin
              }else {
                continue
              }
              // multiply by 100 before dividing bigNumber doesn't support decimals
              rate = quoteTokenAmt.mul(100).div(aTokenAmt)
              console.log('rate is', rate, this.$helper.weiBigNumberToFloatEther(rate), rate.toString())

              if (this.addressesToWatch[tokenA.toLowerCase()] && this.addressesToWatch[tokenA.toLowerCase()] === this.notFoundStr ) {
                this.addressesToWatch[tokenA.toLowerCase()] = `Found on ${new Date()} | rate is ${rate.toNumber() / 100}`
                this.playAudio()

              }else if (this.addressesToWatch[tokenB.toLowerCase()] && this.addressesToWatch[tokenB.toLowerCase()] === this.notFoundStr) {
                this.addressesToWatch[tokenB.toLowerCase()] = `Found on ${new Date()} | rate is ${rate.toNumber() / 100}`
                this.playAudio()
              }
            } else {
              quoteTokenAmt = decodedData.args.amountETHMin
              aTokenAmt = decodedData.args.amountTokenMin
              let token = decodedData.args.token

              // multiply by 100 before dividing bigNumber doesn't support decimals
              rate = quoteTokenAmt.mul(100).div(aTokenAmt)
              console.log('rate is', rate, this.$helper.weiBigNumberToFloatEther(rate), rate.toString())

              if (this.addressesToWatch[token.toLowerCase()] && this.addressesToWatch[token.toLowerCase()] === this.notFoundStr ) {
                this.addressesToWatch[token.toLowerCase()] = `Found on ${new Date()} | rate is ${rate.toNumber() / 100}`
                this.playAudio()

              }

            }


          }
        }
      },

      async handleSwapExactTokensForETH(decodedData) {
        const tokenAddr = decodedData.args.path[0]  // the sold token is always index o and bought token is always last index
        console.log('args is', decodedData.name, decodedData.args,)
        if(MAJOR_TOKEN_ADDR[tokenAddr]) {return}
        if (typeof this.tokenWithIndex[tokenAddr] === 'undefined' ) {
          this.tokenWithIndex[tokenAddr] = this.tokenAndVolume.push({
            tokenAddr: tokenAddr,
            buyVolume: ethers.BigNumber.from(0),
            sellVolume: decodedData.args.amountOutMin,
            total: decodedData.args.amountOutMin,
            net: decodedData.args.amountOutMin.mul(-1)
          }) - 1 // add index
        }else {
          const indOfToken = this.tokenWithIndex[tokenAddr]
          this.tokenAndVolume[indOfToken].sellVolume.add(decodedData.args.amountOutMin)
          this.tokenAndVolume[indOfToken].total.add(decodedData.args.amountOutMin)
          this.tokenAndVolume[indOfToken].net.sub(decodedData.args.amountOutMin) // sub for this
        }

      },
      async handleSwapETHForExactTokens(decodedData) {
        const tokenAddr = decodedData.args.path[decodedData.args.path.length - 1]  // the sold token is always index o and bought token is always last index
        if(MAJOR_TOKEN_ADDR[tokenAddr]) {return}
        if (typeof this.tokenWithIndex[tokenAddr] === 'undefined' ) {
          this.tokenWithIndex[tokenAddr] = this.tokenAndVolume.push({
            tokenAddr: tokenAddr,
            buyVolume: decodedData.value,
            sellVolume: ethers.BigNumber.from(0),
            total: decodedData.value,
            net: decodedData.value
          }) - 1 // add index
        }else {
          const indOfToken = this.tokenWithIndex[tokenAddr]
          this.tokenAndVolume[indOfToken].buyVolume.add(decodedData.value)
          this.tokenAndVolume[indOfToken].total.add(decodedData.value)
          this.tokenAndVolume[indOfToken].net.add(decodedData.value) // sub for this
        }

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
    }
  }
)
</script>

<style scoped>

</style>

