<template>

</template>

<script>
import {defineComponent, inject} from "vue";

export default defineComponent( {
  name: "AccountDisplay",
  setup() {
    const chainId = inject('$getProvider')
    return {
      chainId
    }
  }
})
</script>

<style scoped>

</style>
