<template>
  <GeneralModal v-model="showDialog">

  </GeneralModal>

</template>

<script>
import {defineComponent} from "vue";

export default defineComponent(  {
  name: "GeneralModal",
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
    }
  }
})
</script>

<style scoped>

</style>
