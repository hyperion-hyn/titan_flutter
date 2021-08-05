const addressHex = "%1$s";
const rpcURL = "%2$s";
const chainID = "%3$s";

function executeCallback (id, error, value) {
  AlphaWallet.executeCallback(id, error, value)
}

window.AlphaWallet.init(rpcURL, {
  getAccounts: function (cb) { cb(null, [addressHex]) },
  processSignTransaction: function (tx, cb){
       console.log('processSignTransaction', tx);
       const { id = 8888 } = tx;
       AlphaWallet.addCallback(id, cb);

       var gasLimit = tx.gasLimit || tx.gas || null;
       var gasPrice = tx.gasPrice || null;
       var data = tx.data || null;
       var nonce = tx.nonce || -1;
       flutter_inappwebview.dappCallHandler('processSignTransaction', id, JSON.stringify([id, tx.to || null, tx.value, nonce, gasLimit, gasPrice, data]));
    //    alpha.signTransaction(id, tx.to || null, tx.value, nonce, gasLimit, gasPrice, data);
  },
  processTransaction: function (tx, cb){
    console.log('processTransaction', tx);
    const { id = 8888 } = tx;
    AlphaWallet.addCallback(id, cb);

    var gasLimit = tx.gasLimit || tx.gas || null;
    var gasPrice = tx.gasPrice || null;
    var data = tx.data || null;
    var nonce = tx.nonce || -1;
    flutter_inappwebview.dappCallHandler('processTransaction', id, JSON.stringify([id, tx.to || null, tx.value, nonce, gasLimit, gasPrice, data]));
//    alpha.signTransaction(id, tx.to || null, tx.value, nonce, gasLimit, gasPrice, data);
  },
  signMessage: function (msgParams, cb) {
      console.log('signMessage', msgParams)
      const { data, chainType } = msgParams
      const { id = 8888 } = msgParams
    AlphaWallet.addCallback(id, cb)
    flutter_inappwebview.dappCallHandler('signMessage', id, JSON.stringify([id, msgParams.data]));
//    alpha.signMessage(id, data);
  },
  signPersonalMessage: function (msgParams, cb) {
      console.log('signPersonalMessage', msgParams)
      const { data, chainType } = msgParams
      const { id = 8888 } = msgParams
    AlphaWallet.addCallback(id, cb)
    flutter_inappwebview.dappCallHandler('signPersonalMessage', id, JSON.stringify([id, msgParams.data]));
//    alpha.signPersonalMessage(id, data);
  },
  signTypedMessage: function (msgParams, cb) {
    console.log('signTypedMessage ', msgParams)
    const { data } = msgParams
    const { id = 8888 } = msgParams
    AlphaWallet.addCallback(id, cb)
    flutter_inappwebview.dappCallHandler('signTypedMessage', id, JSON.stringify([id, msgParams.data]));
//    alpha.signTypedMessage(id, JSON.stringify(msgParams))
  },
  ethCall: function (msgParams, cb) {
    console.log("eth_call", msgParams)
    const data = msgParams
    const { id = Math.floor((Math.random() * 100000) + 1) } = msgParams
    AlphaWallet.addCallback(id, cb)
    //alpha.ethCall(id, JSON.stringify(msgParams));
    flutter_inappwebview.dappCallHandler('ethCall', id, JSON.stringify([id, msgParams.to, msgParams.data]));
//    alpha.ethCall(id, msgParams.to, msgParams.data);
  },
  enable: function() {
      return new Promise(function(resolve, reject) {
          //send back the coinbase account as an array of one
          resolve([addressHex]);
      })
  },
}, {
    address: addressHex,
    networkVersion: chainID
})

window.web3.setProvider = function () {
  console.debug('Alpha Wallet - overrode web3.setProvider')
}

window.web3.version.getNetwork = function(cb) {
    cb(null, chainID)
}
window.web3.eth.getCoinbase = function(cb) {
    return cb(null, addressHex)
}
window.web3.eth.defaultAccount = addressHex

window.ethereum = web3.currentProvider
window.ethereum.address = addressHex
window.ethereum.networkVersion = chainID