const IPFS = require('ipfs-core')
const commander = require('commander');
const chalk = require('chalk');
const fs = require("fs")
const path = require("path")
const { create } = require('ipfs-http-client')

module.exports = {
  async addFolder(
    folderPath,
    pin,
    quiet
  ) {
    const files = getAllFiles(folderPath);
    const ipfs  = create('http://127.0.0.1:5001')
    // const rootFolder = `/${path.relative(path.resolve(process.argv[2], ".."), process.argv[2])}`;
    // console.log('files are', files)
    const rootFolder = process.cwd()
    let result
    try {
      result = await ipfs.add(files, (pin ? { pin: true } : {}))
      console.log('result is ', result)
    } catch (e) {
      console.error(error)
    }

    return result
  }
}


function getAllFiles(
  dirPath,
  originalPath,
  arrayOfFiles
) {
  const files = fs.readdirSync(dirPath);

  arrayOfFiles = arrayOfFiles || [];
  originalPath = originalPath || path.resolve(dirPath, "..");

  const folder = path.relative(originalPath, path.join(dirPath, "/"));

  arrayOfFiles.push({
    path: folder.replace(/\\/g, "/"),
    mtime: fs.statSync(folder).mtime
  });

  files.forEach(function(file) {
    if (fs.statSync(dirPath + "/" + file).isDirectory()) {
      arrayOfFiles = getAllFiles(dirPath + "/" + file, originalPath, arrayOfFiles);
    } else {
      file = path.join(dirPath, "/", file);

      arrayOfFiles.push({
        path: path.relative(originalPath, file).replace(/\\/g, "/"),
        content: fs.readFileSync(file),
        mtime: fs.statSync(file).mtime
      });
    }
  });

  return arrayOfFiles;
}
