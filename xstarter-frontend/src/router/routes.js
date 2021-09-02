
const routes = [
  {
    path: '/',
    component: () => import('layouts/MainLayout.vue'),
    children: [
      { path: '', component: () => import('pages/Index.vue') },
      { path: 'gov', component: () => import('pages/Governance.vue') },
      { path: 'nft', component: () => import('pages/NFT.vue') },
      { path: 'nft/:ipfs_string', name: 'nft_mint', component: () => import('pages/NFTMintingAndConversion.vue') },
    ]
  },

  // Always leave this as last one,
  // but you can also remove it
  {
    path: '/:catchAll(.*)*',
    component: () => import('pages/Error404.vue')
  }
]

export default routes
