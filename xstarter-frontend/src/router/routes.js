
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
      { path: 'nft/gallery/:chainId/:contractAddress', name: 'nft_gallery', component: () => import('pages/NFTGallery.vue') },
      { path: 'tools', name: 'tools', component: () => import('pages/BlockchainWatcher/BlockChainTools.vue') },
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
