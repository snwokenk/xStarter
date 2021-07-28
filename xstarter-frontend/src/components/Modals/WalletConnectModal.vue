<template>
  <GeneralModal v-model="showDialog" >
    <div class="row full-height content-center justify-center">
      <div class="q-mb-xl segoe-bold text-h4 text-center">
        Connect To Start Using xStarter
      </div>
      <div class="row full-width content-center justify-center q-px-md q-gutter-x-md q-mt-lg">
        <q-btn
          outline
          size="md"
          :label="'Connect With Metamask'"
          :color="metamaskInstalled ? darkLightText: 'negative'"
          :disable="!metamaskInstalled"
          style="min-height: 50px; border-radius: 10px;"
          class="col-lg-4 col-12"
          @click="connectEthereum"
          icon="img:metamask.svg"
        />

        <q-btn
          outline
          size="md"
          :label="'Connect With WalletConnect'"
          :color="metamaskInstalled ? darkLightText: 'negative'"
          :disable="!metamaskInstalled"
          style="min-height: 50px; border-radius: 10px;"
          class="col-lg-5 col-12"
          @click="connectEthereumWalletConnect"
          icon="img:metamask.svg"
          v-close-popup
        />
      </div>
    </div>


  </GeneralModal>
</template>

<script>
import {defineComponent, inject, provide} from "vue";
import GeneralModal from "components/Modals/GeneralModal";

export default defineComponent(  {
  name: "WalletConnectModal",
  setup() {
    const connectEthereum = inject('$connectEthereum')
    const connectEthereumWalletConnect = inject('$connectEthereumWalletConnect')
    const metamaskInstalled = inject('$metamaskInstalled')

    return {
      connectEthereum,
      connectEthereumWalletConnect,
      metamaskInstalled
    }
  },
  components: {GeneralModal},
  props: {
    modelValue: {
      type: Boolean,
      required: true
    },
    persistent: {
      type: Boolean,
      default: false
    }
  },
  computed: {
    showDialog: {
      set: function (val) {
        this.$emit('update:modelValue', val)
      },
      get: function () {
        return this.modelValue
      }
    },
    darkLightText(){
      return this.$q.dark.isActive ? 'light' : 'dark'
    },
    darkLightTextReverse(){
      return this.$q.dark.isActive ? 'dark' : 'light'
    },
  }
})
</script>

<style scoped>

</style>
