
export function mutateProvider(state, value) {
  state.provider = value
}

export function mutateSigner(state, value) {
  state.Signer = value
}

export function mutateEthereumProvider(state, value) {
  return state.ethereumProvider = value
}

export function mutateConnectedAccounts(state, value) {
  return state.connectedAccounts = value
}

export function mutateConnectedAndPermissioned(state, value) {
  return state.connectedAndPermissioned = value
}

