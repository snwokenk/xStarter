import { boot } from 'quasar/wrappers'
import gtm from 'src/components/gtm';


// "async" is optional;
// more info on params: https://v2.quasar.dev/quasar-cli/boot-files
export default boot(async ({ router }) => {
  router.afterEach((to, from) => {
    if (window.location.hostname !== 'www.xstarter.app' || window.location.hostname !== 'xstarter.app') {
      console.log('please get a google analytics and tag manager account and update the required files including update src/boot/gtm-plugin.js')
      return
    }
    gtm.logPage(to.path);
  })
})
