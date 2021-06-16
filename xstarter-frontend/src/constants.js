
export const LAUNCHPAD_ADDRESS = '0xC0441b629f40526CAD6B3B23A568d488C7D6F508'
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
  56: 'Binance Smart Chain',
  // 137: 'Polygon Matic'
}

export const  ACCEPTED_CHAINS = {
  31337: true,
  100: true,
  // 137: true
}

export const ACCEPTED_CHAINS_CHOICES = [
  {label: 'xDai', value: 100 }
]

export const JSON_RPC_ENDPOINT = process.env.PROD ? 'https://rpc.xdaichain.com/' : 'http://127.0.0.1:8545'

export const ILO_STATUS = {
  0: 'ILO PROPOSED',
  1: 'ILO HAS BEEN SET UP BY ADMIN',
  2: 'ILO HAS RECEIVED PROJECT FUNDS',
  3: 'ILO HAS BEEN VALIDATED',
  4: 'ILO TOKENS HAS BEEN APPROVED FOR LIQUIDITY POOL',
  5: 'ILO LIQUIDITY PAIR CREATED',
  6: 'ILO FINALIZED: LIQUIDITY POOL CREATED AND TIME LOCKS SET'
}
