
export const LAUNCHPAD_ADDRESS = '0x1613beB3B2C4f22Ee086B2b38C1476A3cE7f78E8'
// export const GOVERNANCE_ADDRESS = '0xaB7B4c595d3cE8C85e16DA86630f2fc223B05057'
export const ILO_ADDRESS = '0xAe2563b4315469bF6bdD41A6ea26157dE57Ed94e'

export const  CHAIN_ID = '31337'

export const SUPPORTED_FUNDING_TOKENS = {
  '0x0000000000000000000000000000000000000000': CHAIN_ID === '100' ? 'xDai' : 'ETH'
  // add xstarter token
}

export const CHAIN_ID_TO_NAME = {
  1: 'Ethereum Main Net',
  31337: 'Hardhat Localhost',
  100: 'xDai Layer 2',
  56: 'Binance Smart Chain'
}

export const  ACCEPTED_CHAINS = {
  31337: true,
  100: true
}

export const JSON_RPC_ENDPOINT = process.env.PROD ? 'https://rpc.xdaichain.com/' : 'http://127.0.0.1:8545'
