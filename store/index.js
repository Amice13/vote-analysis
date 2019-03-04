export const state = () => ({
  sidebar: false,
  current: 'main'
})

export const getters = {
  current (state) {
    return state.current
  }
}

export const mutations = {
  toggleSidebar (state) {
    state.sidebar = !state.sidebar
  },
  setCurrent (state, payload) {
    state.current = payload
  }
}

export const actions = {
  setCurrent (context, payload) {
    context.commit('setCurrent', payload)
  }
}
