<template>
  <q-form class="full-width">
    <div :class="title.class" :style="title.style">
      {{ title.name}}
    </div>

    <div class="full-width">
      <div v-for="(obj, ind) in funcABI.inputs" :key="ind" >
        <q-input v-model="formFields[obj.name]" :label="!displayNames[obj.name] ? obj.name : displayNames[obj.name]"  />
      </div>


    </div>


  </q-form>

</template>

<script>
import {defineComponent} from "vue";
import { abiUtils } from "boot/abiGenerator";

export default defineComponent( {
  name: "ABIGeneratedForm",
  setup() {

    return {}
  },
  data() {
    return {
      formFields: {},
      funcABI: {inputs: []}
    }
  },
  props: {
    title: {
      type: Object, // fields = 'name', 'class', 'style'
      default: () => {return {name: '', class: '', style: ''}}
    },
    functionType: {
      type: String,
      default: 'function' // can be 'function', 'constructor'
    },
    abi: {
      type: Object,
      required: true
    },

    functionName: {
      type: String,
      required: true

    },
    displayNames: {
      type: Object,
      default: () => {return {}}  // {functionParameter: 'Display names'}
    },
    connectedContract: {
      type: Object,
      required: false
    },
  },
  mounted() {
    const funcABI = abiUtils.getFunctionObj(this.abi, this.functionName, this.functionType)
    console.log('abi func is', funcABI)
    if (funcABI) {
      this.funcABI = {...funcABI}
    }

    console.log('func abi', funcABI)
  }
} )
</script>

<style scoped>

</style>
