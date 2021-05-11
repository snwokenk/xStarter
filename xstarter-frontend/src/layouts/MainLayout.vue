<template>
  <q-layout view="hHh lpR fFf">

    <q-header elevated class="text-white q-pt-sm"  :class="{'bg-dark': $q.dark.isActive, 'bg-light': !$q.dark.isActive}" height-hint="98">
      <q-toolbar>
        <q-toolbar-title style="width: 10%" >
          <div >
            <img v-if="$q.dark.isActive" class="logo-style" src="~assets/xstarter_dark_logo.webp">
            <img v-else class="logo-style" src="~assets/xstarter_light_logo.png">

          </div>
        </q-toolbar-title>
        <div class="q-gutter-x-sm">
          <q-btn rounded outline label="Connect" :color="darkLightText"/>
          <q-btn round flat :color="darkLightText" :icon="$q.dark.isActive ? 'light_mode' : 'dark_mode'" @click="setDarkMode"/>
        </div>
      </q-toolbar>

      <q-tabs align="center" :class="{'text-dark': !$q.dark.isActive, 'text-light': $q.dark.isActive}">
        <q-route-tab to="/" label="ILO"  />
        <q-route-tab to="/page2" label="Governance" />
        <q-route-tab to="/page3" label="NFT" />
      </q-tabs>
    </q-header>

    <q-page-container>
      <router-view />
    </q-page-container>

    <q-footer elevated class="text-white" :class="{'bg-dark': $q.dark.isActive, 'bg-light': !$q.dark.isActive}">
      <q-toolbar class="justify-center">
<!--        <q-toolbar-title>-->
<!--          <q-avatar>-->
<!--            <img src="https://cdn.quasar.dev/logo/svg/quasar-logo.svg">-->
<!--          </q-avatar>-->
<!--          <div>Title</div>-->
<!--        </q-toolbar-title>-->
        <div class="col-auto">
          <q-btn flat :color="darkLightText" label="About xStarter" target="_blank" icon-right="open_in_new" type="a" href="https://www.xstarter.org/" />
        </div>

      </q-toolbar>
    </q-footer>

  </q-layout>
</template>

<script>



import { defineComponent, ref, watch } from 'vue'
import { useQuasar } from 'quasar'

export default defineComponent({
  name: 'MainLayout',

  components: {
  },

  setup () {
    const $q = useQuasar()
    const setDarkMode = async () => {
      $q.dark.toggle()
    }
    return {
      setDarkMode
    }
  },
  computed: {
    darkLightText(){
      return this.$q.dark.isActive ? 'light' : 'dark'
    }
  }
})
</script>


