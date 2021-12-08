<template>
  <div
    class="display-card accountDisplayCard q-py-lg col-11 col-md-7 col-lg-5 q-gutter-y-lg"
    style="min-height: 200px;"
  >
    <div class="text-center text-bold">
      What Action(s) Should Happen On A Trigger
    </div>
    <div class="row">
      <div class="col-6 col-lg-4">
        <q-checkbox v-model="actionTypes" val="notifySound" label="Notify Me With  An Alarm" />
      </div>

      <div class="col-12 q-mt-sm">
        <q-btn :disable="!actionTypes.length" label="Start Listening For Triggers" @click="this.$emit('startListening', actionTypes)" outline />
      </div>

    </div>
  </div>
</template>

<script>
export default {
  name: "ActionBox",
  data() {
    return {
      actionTypes: []
    }
  },
}
</script>

<style scoped>

</style>
