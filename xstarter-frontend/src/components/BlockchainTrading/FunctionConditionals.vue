<template>
  <div class="row q-gutter-y-md">
    <div class="col-12">
      Triggers For Function {{ functionInputObj.label }}
    </div>
    <q-separator />
    <div class="col-12">
      Your Trigger Statement:<br/> <span class="text-bold" v-html="triggerHumanReadable" />
    </div>
    <q-separator />
    <div class="col-12 row q-gutter-x-md">
      <div class="col-12 col-lg-3">
        <q-select v-model="baseCond" :options="baseCondArray" label="Select AND/OR" class="full-width"/>
      </div>
      <div class="col-12 col-lg-3">
        <q-btn label="add" @click="() => addTo(baseCond)"/>
      </div>
    </div>
    <div v-for="obj in inputs" class="col-12 row q-mt-lg q-gutter-x-xs" :key="obj.name">
      <div class="col-12 col-lg-3 row justify-center content-center">
        <div>
          {{ obj.name}}
        </div>
      </div>
      <div class="col-12 col-lg-3">
        <q-select v-model="form[obj.name].conditional" :options="addrCondArray" label="Select Conditional" class="full-width"/>
      </div>
      <div class="col-12 col-lg-3">
        <q-input  v-model="form[obj.name].value" :placeholder="obj.type" />
      </div>
      <div class="col-12 col-lg-2">
        <q-btn label="add" @click="() => addTo(form[obj.name])" />
      </div>
    </div>

  </div>

</template>

<script>
import {defineComponent, ref, toRefs} from "vue";

export default defineComponent( {
  name: "FunctionConditionals",
  setup(props) {
    // console.log('props is', props.functionInputObj.value.inputs)
    const { functionInputObj } =toRefs(props)
    let tmpForm = {}
    // console.log('value is', functionInputObj.value)

    for (const argument of functionInputObj.value.value.inputs) {
      tmpForm[argument.name] = {
        name: argument.name,
        conditional: '',
        value: ''
      }
    }
    return {
      form: ref(tmpForm),
      inputs: ref(functionInputObj.value.value.inputs)
    }
  },
  props: {
    functionInputObj: {
      type: Object,
      required: true
    }
  },
  data() {
    return {
      baseCond: '',
      triggerArray: []
    }
  },
  computed: {
    // inputs() {
    //   return this.functionInputObj.value.inputs
    // },
    triggerHumanReadable() {
      // [ { "name": "tokenA", "conditional": { "label": "equals to", "value": "===", "otherValue": "==" }, "value": "0xc326622fca914ca15fd44dd070232ce3cd358dde" }, { "label": "OR", "value": "||" } ]
      let tmpStr = ''
      for (const argument of this.triggerArray) {
        if (argument.base) {
          tmpStr = tmpStr + '<br/>' + argument.label
        }else {
          tmpStr = tmpStr + `<br/> ${argument.name} ${argument.conditional.label} ${argument.value}`
        }
      }

      return tmpStr
    },
    addrCondArray() {
      return [
        {
          label: 'equals to',
          value: '===',
          otherValue: '=='
        },
        {
          label: 'not equals to',
          value: '!==',
          otherValue: '!='
        }
      ]
    },
    baseCondArray() {
      return [
        {
          label: 'AND',
          value: '&&',
          base: true
        },
        {
          label: 'OR',
          value: '||',
          base: true
        },

      ]
    }
  },
  methods: {
    addTo(formObj){
      this.triggerArray.push(formObj)
    }
  },
  mounted() {}
})
</script>

<style scoped>

</style>
