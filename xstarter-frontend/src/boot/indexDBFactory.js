import { boot } from 'quasar/wrappers'
// import IPFS from "ipfs-core";

//https://github.com/ipfs/js-ipfs
const IPFS = require('ipfs-core')


class xStarterIndexDBFactory {
  constructor() {
    this.objectOfDbs = {};
  }

  async deleteDatabase(dbName) {
    const request = await indexedDB.deleteDatabase(dbName);
    return true
  }

  async setupDatabaseAndObjectStore(dbName, nameOfObjectStore, uniqueKeyInObject, arrayOfIndexOptions) {
    // if database already set up return
    if (this.objectOfDbs[dbName]) { return }

    this.objectOfDbs[dbName] = new xStarterIndexDB()
    await this.objectOfDbs[dbName].setupDatabaseAndObjectStore(dbName, nameOfObjectStore, uniqueKeyInObject, arrayOfIndexOptions);
    console.log('obj db is', this.objectOfDbs[dbName])
  }
  async addData(dbName, nameOfObjectStore, arrayOfDatas, onSuccessCallBack, onErrorCallback, onCompleteCallback) {
    if (!this.objectOfDbs[dbName]) {
      console.log('no database with that name created ');
      return;
    }
    await this.objectOfDbs[dbName].addData(nameOfObjectStore, arrayOfDatas, onSuccessCallBack, onErrorCallback, onCompleteCallback);
  }

  async getNumberedIndexByRange(dbName, nameOfObjectStore, nameOfIndex, startNum, endNum, callBackForEachData) {
    console.log('start num is', startNum)
    if (!this.objectOfDbs[dbName]) {
      console.log('no database with that name created ');
      return;
    }
    await this.objectOfDbs[dbName].getNumberedIndexByRange(nameOfObjectStore, nameOfIndex, startNum, endNum, callBackForEachData)
  }
  async getPaginatedNumberedIndexByRange(dbName, nameOfObjectStore, nameOfIndex, startNum, endNum, paginationLength, callBackForEachData) {
    console.log('start num is', startNum)
    if (!this.objectOfDbs[dbName]) {
      console.log('no database with that name created ');
      return;
    }

    await this.objectOfDbs[dbName].getPaginatedNumberedIndexByRange(nameOfObjectStore, nameOfIndex, startNum, endNum, paginationLength, callBackForEachData)
  }
}

class xStarterIndexDB {
  constructor() {
    this.db = null
    this.hasErrors = null
    this.objectStore = null
  }

  /* nameOfObjectStore = name of object store similar to name of table
  uniqueKeyInObject = unique value in object to be stored
  ie customer data [ {name: 'Sam', custId: 1212, created: 'Oct 2, 2020' }] we can assume custId would be unique for all data
  for example storing dex transactions, a suitable key would be token address

    */
   async setupDatabaseAndObjectStore(dbName, nameOfObjectStore, uniqueKeyInObject, arrayOfIndexOptions) {
     const dbRequest = window.indexedDB.open(dbName, 1)
     dbRequest.onerror = (event) => {
       console.log("errors", event);
       this.hasErrors = true
     };
     dbRequest.onsuccess = (event) => {
       // console.log('on success', event.target.result, this)
       this.db = event.target.result;
       this.db.error = function (event) {
         console.log('database error', event.target.errorCode)
       }
     }
     dbRequest.onupgradeneeded = (event) => {
       console.log('on upgradeneeded')
       this.db = event.target.result;
       this.db.error = function (event) {
         console.log('database error', event.target.errorCode)
       }
       if (uniqueKeyInObject) {
         this.objectStore = this.db.createObjectStore(nameOfObjectStore, { keyPath: uniqueKeyInObject });
       }else {
         this.objectStore = this.db.createObjectStore(nameOfObjectStore, { autoIncrement: true });
       }


       // [[indexName, isIndexValueUnique]] // indexName is one of the keys from the data being stored
       // ie index could be 'name' in customer data
       for (const arrayOfIndexOption of arrayOfIndexOptions) {
         this.objectStore.createIndex(arrayOfIndexOption[0], arrayOfIndexOption[0], { unique: arrayOfIndexOption[1] })
       }
     };
  }

  async addData(nameOfObjectStore, arrayOfDatas, onSuccessCallBack, onErrorCallback, onCompleteCallback) {
    const transaction = this.db.transaction([nameOfObjectStore], "readwrite");

    if (onErrorCallback) {
      transaction.onerror = onErrorCallback
    }
    if (onCompleteCallback) {
      transaction.oncomplete = onCompleteCallback
    }
    const objectStore = transaction.objectStore(nameOfObjectStore)

    for (const data of arrayOfDatas) {
      let request = objectStore.add(data)
      if (onSuccessCallBack) {
        request.onsuccess =  onSuccessCallBack
      }
    }
  }

  async removeData(nameOfObjectStore, keyToDelete, onSuccessCallBack) {
    const transaction = this.db.transaction([nameOfObjectStore], "readwrite").objectStore(nameOfObjectStore).delete(keyToDelete);
    transaction.onsuccess = onSuccessCallBack
  }
  async getDataByKey(nameOfObjectStore, keyToGet, onSuccessCallBack) {
    const transaction = this.db.transaction([nameOfObjectStore], "readwrite").objectStore(nameOfObjectStore).get(keyToGet);
    transaction.onsuccess = function (event) {
      onSuccessCallBack(event.target.result)
    }
  }
  async getALlDataFromObjectStore(nameOfObjectStore, onSuccessCallBack) {
    const objectStore = this.db.transaction([nameOfObjectStore], "readwrite").objectStore(nameOfObjectStore);
    objectStore.getAll().onsuccess = function (event) {
      onSuccessCallBack(event.target.result)
    }
  }

  async getNumberedIndexByRange(nameOfObjectStore, nameOfIndex, startNum, endNum, callBackForEachData) {
    // const objectStore = this.db.transaction([nameOfObjectStore], "readwrite").objectStore(nameOfObjectStore);
    // objectStore.getAll().onsuccess = function (event) {
    //   onSuccessCallBack(event.target.result)
    // }
    const objectStore = this.db.transaction([nameOfObjectStore], "readwrite").objectStore(nameOfObjectStore)
    const index = objectStore.index(nameOfIndex)
    const boundKeyRange = IDBKeyRange.bound(startNum, endNum, true, true);

    index.openCursor(boundKeyRange).onsuccess = async function(event) {
      const cursor = event.target.result;
      if (cursor) {
        // Do something with the matches.
        // console.log('in opened cursor',  cursor.key.primaryKey, cursor.key, cursor.value)
        callBackForEachData(cursor.value)
        cursor.continue();
      }
    };
  }
  // takes the start and end number and gets all in tranches
  async getPaginatedNumberedIndexByRange(nameOfObjectStore, nameOfIndex, startNum, endNum, paginationLength, callBackForEachData) {

    const objectStore = this.db.transaction([nameOfObjectStore], "readwrite").objectStore(nameOfObjectStore)
    const index = objectStore.index(nameOfIndex)
    // const boundKeyRange = IDBKeyRange.bound(startNum, endNum, true, true);

    let tmpStart = startNum
    let tmpEnd = startNum + paginationLength > endNum ? endNum : startNum + paginationLength
    while (true) {
      const boundKeyRange = IDBKeyRange.bound(tmpStart, tmpEnd, true, true);
      const req = index.getAll(boundKeyRange)
      req.onsuccess = function (event) {
        console.log('event result is', event.target.result)
        const result = event.target.result
        if (!result.length) { return }
        callBackForEachData(result)
        // for (let i = 0; i < result.length - 1; i++) {
        //   callBackForEachData(result[i])
        // }
      }
      tmpStart = tmpEnd
      tmpEnd = tmpEnd + paginationLength > endNum ? endNum : tmpEnd + paginationLength
      if (tmpStart >= endNum) {
        break
      }
    }



    // index.openCursor(boundKeyRange).onsuccess = async function(event) {
    //   const cursor = event.target.result;
    //   if (cursor) {
    //     // Do something with the matches.
    //     // console.log('in opened cursor',  cursor.key.primaryKey, cursor.key, cursor.value)
    //     callBackForEachData(cursor.value)
    //     cursor.continue();
    //   }
    // };
  }
}



const indexDBFactory = new xStarterIndexDBFactory()

export default boot(({ app }) => {
  // for use inside Vue files (Options API) through this.$ethers

  app.config.globalProperties.$indexDBFactory = indexDBFactory

})

export { indexDBFactory }
