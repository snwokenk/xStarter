
export const LAUNCHPAD_ADDRESS = '0xe9AE31a4e284A5f7572836a6086A813374b13CF5'
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
  77: 'POA Sokol Testnet',
  5: 'GOERLI Testnet'
  // 137: 'Polygon Matic'
}

export const  ACCEPTED_CHAINS = {
  31337: true,
  100: true,
  5: true
  // 137: true
}

export const ACCEPTED_CHAINS_CHOICES = [
  {label: 'xDai', value: 100 }
]

console.log('process env')
export const JSON_RPC_ENDPOINT = process.env.IS_NETWORK === 'xdai' ?
  'https://rpc.xdaichain.com/' :  process.env.IS_NETWORK === 'goerli' ? 'https://rpc.slock.it/goerli' : 'http://127.0.0.1:8545'

export const ILO_STATUS = {
  0: 'ILO PROPOSED',
  1: 'ILO HAS BEEN SET UP BY ADMIN',
  2: 'ILO HAS RECEIVED PROJECT FUNDS',
  3: 'ILO HAS BEEN VALIDATED',
  4: 'ILO TOKENS HAS BEEN APPROVED FOR LIQUIDITY POOL',
  5: 'ILO LIQUIDITY PAIR CREATED',
  6: 'ILO FINALIZED: LIQUIDITY POOL CREATED AND TIME LOCKS SET'
}


export const xStarter_ILO_Info = {
  about: {
    name: 'xStarter',
    logoURL: 'https://ipfs.io/ipfs/QmR9MLmwXTyXJ5J9eJQ2hXeY3oKzuwsvWqtuS6aFaszsBS',
    description: `xStarter is an ecosystem of smart contracts, that provides a decentralized way for businesses, of all sizes, to issue tokens and create a market for those tokens.`,
    socialMediaLinks: [
      {label: 'telegram', url: 'https://t.me/xStarterDev', icon: 'fab fa-telegram-plane' },
      {label: 'twitter', url: 'https://www.twitter.com/xStarterdev', icon: 'fab fa-twitter' },
      {label: 'discord', url: 'https://discord.com/invite/9rQCAkNy4e', icon: 'fab fa-discord' },
      {label: 'facebook', url: '', icon: 'fab fa-facebook'},
      {label: 'medium', url: 'https://medium.com/@xstarterdev', icon: 'fab fa-medium'},
    ]
    },
  ILOInfo: {
    access: 'Open to public',
  },
  tokenomics: {
    useCase: 'xStarter tokens are used for governance and early access of ILOs launched on the xStarter Platform. xStarter tokens can also be used as a funding token for ILOs.'
  }
}

export const xStarter_ILO_IPFS_CID = 'QmUEMTSMYwqXZZNGm4T6UVec9igJssgeKQpajJiCrTN9DF'
