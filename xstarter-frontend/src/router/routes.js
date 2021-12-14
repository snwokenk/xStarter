
const routes = [
  {
    path: '/',
    component: () => import('layouts/MainLayout.vue'),
    children: [
      { path: '', name: 'index', component: () => import('pages/Index.vue') },
      { path: 'ilo', name: 'ilo_main', component: () => import('pages/ILO.vue') },
      { path: 'gov', name: 'gov_main', component: () => import('pages/Governance.vue') },
      { path: 'nft', name: 'nft_main', component: () => import('pages/NFT.vue') },
      { path: 'nft/mint/:ipfs_cid', name: 'nft_mint', component: () => import('pages/NFTPages/NFTMintingAndConversion.vue') },
      { path: 'nft/deploy', name: 'nft_deploy', component: () => import('pages/NFTPages/NFTDeploymentPage.vue') },
      { path: 'nft/gen_mint_page', name: 'nft_generate_mint_page', component: () => import('pages/NFTPages/NFTMintPageGenerator.vue') },
      { path: 'nft/gallery/:chainId/:contractAddress', name: 'nft_gallery', component: () => import('pages/NFTGallery.vue') },
      { path: 'tools', name: 'tools', component: () => import('pages/BlockchainWatcher/BlockChainTools.vue') },
      { path: 'blockchain', name: 'blockchain', component: () => import('pages/BlockchainWatcher/BlockchainTrading.vue')},
      { path: 'order-manage', name: 'order_manage', component: () => import('pages/BlockchainWatcher/DexConditionalAndPeriodic.vue')},
      { path: 'trading_tools', name: 'trading_tools', component: () => import('pages/BlockchainWatcher/TradingTools.vue') }
    ]
  },

  // Always leave this as last one,
  // but you can also remove it
  {
    path: '/:catchAll(.*)*',
    component: () => import('pages/Error404.vue')
  }
  // {
  //   path: '/nft/:catchAll(.*)*',
  //   component: () => import('pages/NFT.vue')
  // }
]

export default routes
