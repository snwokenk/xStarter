
export function getProvider(state) {
  return state.provider
  // return JSON.parse(JSON.stringify(state.provider))
}

export function getSigner(state) {
  return state.signer
}

export function getEthereumProvider(state) {
  return state.ethereumProvider
}

export function getConnectedAccounts(state) {
  return state.connectedAccounts
}

export function getConnectedAndPermissioned(state) {
  return state.connectedAndPermissioned
}

