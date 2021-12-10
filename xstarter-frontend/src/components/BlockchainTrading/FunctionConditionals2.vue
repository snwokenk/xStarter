<template>
  <div class="row q-gutter-y-md">
    <div class="col-12 text-center text-bold text-h5">
      Create Trigger For Function {{ functionInputObj.label }}
    </div>
    <q-separator c />
    <div class="col-12">
     <span class="text-bold" v-html="triggerHumanReadable" />
    </div>
    <q-separator />

    <div v-if="showBase" class="col-12 row q-gutter-y-md">
      <div class="col-12">
        <q-select v-model="baseCond" :options="baseCondArray" label="Select AND/OR" class="full-width"/>
      </div>
      <div class="col-12 q-mt-sm">
        <q-btn label="add" @click="addBase" outline />
      </div>
    </div>

    <div v-else class="col-12 row q-gutter-y-md">
      <div class="col-12">
        <q-select v-model="inputObj" :options="inputOptions" label="Function Parameter To Add Conditional To" class="full-width"/>
      </div>
      <div v-if="inputObj" class="col-12">
        <q-select v-model="inputConditional" :options="computedConditionalOptions" label="Select Conditional" class="full-width"/>
      </div>
      <div v-if="inputConditional" class="col-12 col-lg-3">
        <q-input  v-model="inputText" placeholder="enter value" />
      </div>
      <div v-if="inputConditional && inputConditional.numberOfInputs" class="col-12 col-lg-3">
        <q-input  v-model="inputText2" placeholder="enter second value" />
      </div>

      <div class="col-12 q-mt-sm">
        <q-btn label="add" @click="addTo" outline />
      </div>
    </div>

    <div class="col-12 q-mt-sm">
      <q-btn label="Save Function Triggers" @click="saveAllTriggers" outline />
    </div>
  </div>

</template>

<script>
import {defineComponent, ref, toRefs} from "vue";

export default defineComponent( {
  name: "FunctionConditionals2",
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
      inputObj: null,
      inputConditional: null,
      inputText: '',
      inputText2: '',
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
        if (argument.isBase) {
          tmpStr = tmpStr + '<br/>' + argument.label
        }else {
          tmpStr = tmpStr + `<br/> ${argument.name} ${argument.conditional.label} ${argument.value}`
        }
      }

      return tmpStr
    },
    nonNumberCondArray() {
      return [
        {
          label: 'equals to',
          value: '===',
          otherValue: '==',
          checkConditional: (mainVal, val2) => {
            return mainVal === val2
          }
        },
        {
          label: 'not equals to',
          value: '!==',
          otherValue: '!=',
          checkConditional: (mainVal, val2) => {
            return mainVal !== val2
          }
        }
      ]
    },
    numberCondArray() {
      return [
        {
          label: 'greater than',
          value: '>',
          checkConditional: (mainVal, val2) => {
            return mainVal > val2
          }
        },
        {
          label: 'greater than or equals to',
          value: '>=',
          checkConditional: (mainVal, val2) => {
            return mainVal >= val2
          }
        },
        {
          label: 'less than',
          value: '<',
          checkConditional: (mainVal, val2) => {
            return mainVal < val2
          }
        },
        {
          label: 'less than or equals to',
          value: '<=',
          checkConditional: (mainVal, val2) => {
            return mainVal <= val2
          }
        },
        {
          label: 'between',
          value: '<>',
          numberOfInputs: 2,
          checkConditional: (mainVal, val2, val3) => {
            return mainVal > val2 && mainVal < val3
          }
        },
        ...this.nonNumberCondArray
      ]
    },
    showBase() {
      const trigLen = this.triggerArray.length
      return trigLen && !this.triggerArray[trigLen-1].isBase ? true : false
    },
    computedConditionalOptions() {
      if (!this.inputObj) { return  []}
      if (this.inputObj.type.includes('uint')) {
        return this.numberCondArray
      }
      return this.nonNumberCondArray
    },
    baseCondArray() {
      return [
        {
          label: 'AND',
          value: '&&',
          isBase: true
        },
        {
          label: 'OR',
          value: '||',
          isBase: true
        },

      ]
    },
    inputOptions() {
      return this.inputs.map(obj => {
        return {
          label: obj.name,
          type: obj.type,
          value: obj.name
        }
      })
    }
  },
  methods: {
    saveAllTriggers() {
      this.$emit('saveTrigger', { funcName: this.functionInputObj.label, triggers: this.triggerArray })
      this.resetForm()
    },
    addBase() {
      if (!this.baseCond) { return }
      this.triggerArray.push(this.baseCond)
      this.baseCond = null
    },
    resetForm() {
      this.inputObj = null
      this.inputConditional = null
      this.inputText = ''
      this.inputText2 = ''
      this.baseCond = ''
      this.triggerArray = []
    },
    addTo(){
      if (!this.inputObj || !this.inputConditional || !this.inputText) { return }
      this.triggerArray.push(
        {
          name: this.inputObj.label,
          type: this.inputObj.type,
          conditional: this.inputConditional,
          value: this.inputText,
          value2: this.inputText2
        }
      )
      this.inputObj = null
      this.inputConditional = null
      this.inputText = ''
      this.inputText2 = ''
    }
  },
  mounted() {}
})
</script>

<style scoped>

</style>
