
// https://medium.com/cladular/using-a-node-js-script-to-upload-a-folder-to-a-remote-ipfs-node-255fa9e3b766
const IPFS = require('ipfs-core')
const fs = require('fs')
const process = require('process')
const Stream = require('stream')
const {addFolder} = require("./ipfs-add-folder-custom");

const readableStream = new Stream.Readable({
  read() {}
})


folder_name = 'github_pages_dir'
// console.log('curr dir', process.cwd())
// const contents = fs.opendir(folder_name, (e, b) => { console.log(b)})
// console.log(contents)
addFolder(folder_name, true, true)
