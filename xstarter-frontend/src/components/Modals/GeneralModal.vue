<template>
  <q-dialog v-model="showDialog" :persistent="persistent">
    <div
      class="dark-light-background q-py-xl justify-center content-center modal-size"
      style="border-radius: 15px;"
    >
      <slot>

      </slot>

    </div>
  </q-dialog>

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
