<template>
  <q-input  v-model="" :label="paramName"/>

</template>

<script>
import {defineComponent} from "vue";

export default defineComponent( {
  name: "AddressInput",
  setup() {
    return {}
  },
  props: {
    paramName: {
      type: String,
      required: true
    },
    abi: {
      type: Object,
      required: true
    },

    functionName: {
      type: String,
      required: true

    }
  }
} )
</script>

<style scoped>

</style>

