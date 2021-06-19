import { boot } from 'quasar/wrappers'
// import IPFS from "ipfs-core";

//https://github.com/ipfs/js-ipfs
const IPFS = require('ipfs-core')


class IPFS_UTILS {
  constructor() {
    this.ipfsNode = null
    this.isSet = false
    this.currentILO = '' //
  }
  async setUpIPFS() {
    if (this.isSet) {return true}
    this.ipfsNode = await IPFS.create()
    this.isSet = !!this.ipfsNode
    return this.isSet
  }
  // dataObj = {about: obj, ILOInfo: obj, tokenomics: obj, iconUrl: obj }
  async saveILOInfo(dataObj) {
    await this.setUpIPFS();
    const jsonTmpObj = JSON.stringify(dataObj)
    const results = await this.ipfsNode.add(jsonTmpObj)
    console.log('results is', results)
    return results
  }
  async getILOInfo(cid) {
    await this.setUpIPFS()
    const stream = await this.ipfsNode.cat(cid)
    let data = ''
    for await (const chunk of stream) {
      // chunks of data are returned as a Buffer, convert it back to a string
      data += chunk.toString()
    }
    data = JSON.parse(data)
    console.log('data is', data)
    return data
  }



}

const ipfs_utils = new IPFS_UTILS()
// const ipfs_utils = {
//   async addILOAbout(name, description, socialMediaLinks) {
//     const tmpObj = {name, description, socialMediaLinks}
//     const jsonTmpObj = JSON.stringify(tmpObj)
//     // const ipfs =  await IPFS.create()
//     // const results = await ipfs.add(jsonTmpObj)
//
//     console.log('results is', results)
//
//
//     // return jsonTmpObj
//   }
// }

export default boot(({ app }) => {
  // for use inside Vue files (Options API) through this.$ethers

  app.config.globalProperties.$ipfs_utils = ipfs_utils

})

export { ipfs_utils }
