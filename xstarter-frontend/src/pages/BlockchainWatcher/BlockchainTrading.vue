<template>
  <q-page class="q-pt-md">
    <div class="row justify-center q-mb-xl">
      <div>
        Use this tool to watch the supported blockchains and add conditions which can trigger an action
        (notification, buy/sell token on dex, transfer token, call a function on a contract)
      </div>
    </div>
    <div class="row full-width justify-center q-my-xl">
      <div class="col-12 col-md-3">
        <q-btn rounded label="Create A Trigger" outline class="full-width" @click="toggleForm" />
      </div>
    </div>

    <div class="row full-width justify-center q-my-xl">
    <TriggerForm v-if="showTriggerForm" @saveTrigger="onSaveTrigger"/>
    </div>
    <div v-if="blockChainTriggers" class="row full-width justify-center q-my-xl">
      <ActionBox @startListening="onStartListening" />
    </div>
  </q-page>

</template>

<script>
import {defineComponent} from "vue";
import TriggerForm from "components/BlockchainTrading/TriggerForm";
import ActionBox from "components/BlockchainTrading/ActionBox";
import {CHAIN_INFO_OBJ} from "src/constants";
import {ethers} from "boot/ethers";
/*** this page will allow users to
 * 1, Start listening for transactions on a blockchain
 * 2, watch the blockchain for a type of transaction, and filter by address, native token amount
 * 3, add an action buy/sell a token from a dex, send a token, send native token
 *
 * ***/

export default defineComponent( {
  name: "BlockchainTrading",
  components: {ActionBox, TriggerForm},
  setup() {
    return {}
  },
  data() {
    return {
      showTriggerForm: false,
      blockChainTriggers: null,
      // stores provider of each blockchain as a function, so to get provider for bina
      // you do this.blockChainProviders[label of blockchain].getProvider() // this done because vue3 uses proxies
      blockChainProviders: {

      },
      // stores anon functions which filter the triggers
      blockChainTriggerFunctions: {

      }
    }
  },
  methods: {
    toggleForm() {
      this.showTriggerForm = !this.showTriggerForm
    },
    onSaveTrigger(value) {
      this.blockChainTriggers = value
    },
    populateBlockChainListeners() {
      if (!this.blockChainTriggers) {return }
      for (const key of Object.keys(this.blockChainTriggers)) {
        if (this.blockChainProviders[key]) { continue }
        const blockchainDetails = CHAIN_INFO_OBJ[this.blockChainTriggers[key].details.value]
        const rpcUrl = blockchainDetails.rpcUrls[0]
        const localProvider =  new ethers.providers.JsonRpcProvider(rpcUrl);

        const bt = blockchainDetails.avgBlockTime
        const blockChainTime = bt && bt < 5000  ?  blockchainDetails.avgBlockTime: 5000
        localProvider.pollingInterval = blockChainTime / 2
        this.blockChainProviders[key] = {
          getProvider: () => {
          return localProvider
        },
          isListening: false,
          blockNumber: 0
        }
      }
    },
    listenForBlockTransactions() {
      for (const key of Object.keys(this.blockChainProviders)) {
        if (this.blockChainProviders[key].isListening) { continue }
        this.blockChainProviders[key].isListening = true

        // create anon function which gets a list of all contract address and watches them with triggers
        const watchForTrigger = async (arrayOfTx) => {
          const contractInterfaces = []
          for (const contractAddress of Object.keys(this.blockChainTriggers[key])) {
            if (contractAddress === 'details') { continue }
            const functNTrig = {...this.blockChainTriggers[key][contractAddress]}
            delete functNTrig.contractABI
            contractInterfaces.push([new ethers.utils.Interface(this.blockChainTriggers[key][contractAddress].contractABI), functNTrig, contractAddress ])

          }
          console.log('contract interfaces', contractInterfaces, key)
          for (const contractInterface of contractInterfaces) {
            // do this so it's not waiting
            (async () => {
              // ointerface is first element, second element
              for (const tx of arrayOfTx) {
                // todo: once tx is found with function check triggers
                if (tx.to && tx.to.toLowerCase() === contractInterface[2].toLowerCase()) {
                  const decodedData = contractInterface[0].parseTransaction(tx)
                  const funcName = decodedData.name
                  if (funcName in contractInterface[1]) {
                    console.log(key, ' funcName is ', funcName, ' tx ', tx )
                  }
                }

              }

            })()
          }
        }
        this.blockChainProviders[key].getProvider().on("block", async (blockNumber) => {
          if (this.blockChainProviders[key].blockNumber !== blockNumber) {
            console.log('current | new', this.this.blockChainProviders[key].blockNumber, blockNumber)
            this.blockChainProviders[key].blockNumber = blockNumber
            const blockWithTx = await (this.blockChainProviders[key].getProvider()).getBlockWithTransactions(blockNumber)
            watchForTrigger(blockWithTx.transactions)
            // this.getTxRouterAddress2(blockWithTx.transactions)
          }
        })
      }
    },
// {"Binance Smart Chain":{"details":{"label":"Binance Smart Chain","value":56},"0x10ED43C718714eb63d5aA57B78B54704E256024E":{"addLiquidityETH":[{"name":"token","conditional":{"label":"equals to","value":"===","otherValue":"=="},"value":"0xc326622FcA914CA15fD44DD070232cE3cd358Dde","value2":""}]}}}

    onStartListening(actionValues) {

      console.log('should start listening', actionValues, this.blockChainTriggers)
      this.populateBlockChainListeners()
      this.listenForBlockTransactions()
    }
  }

})
</script>

<style scoped>

</style>
