import Vue from 'vue'
import Vuetify from 'vuetify'

Vue.use(Vuetify)

if (process.client) {
  Vue.use(require('vue-chartist'))
}
