//
//  WalletPluginInterface.swift
//  Runner
//
//  Created by moo on 2019/10/22.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

import Foundation
import Flutter
import TrustWalletCore

class WalletPluginInterface {
    
    //    private lazy var keyStoreDir: URL = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("keystore")
    
    private lazy var keyStoreDir: URL = {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let cachesDir = paths[0]
        let keyStore = NSString(string: cachesDir).appendingPathComponent("keystore")
        print("KeyStore: \(keyStore)")
        
        //ensure the path is exist
        var isExist = FileManager.default.fileExists(atPath: keyStore)
        print("before_isExist: \(isExist)")
        
        if !isExist {
            do {
                try FileManager.default.createDirectory(atPath: keyStore, withIntermediateDirectories: false, attributes: nil)
                isExist = FileManager.default.fileExists(atPath: keyStore)
                print("after_isExist: \(isExist)")
            } catch let error as NSError {
                print(error.localizedDescription);
            }
        }
        
        return URL(fileURLWithPath: keyStore)
    }()
    
    private lazy var keyStore: KeyStore = try! KeyStore(keyDirectory: keyStoreDir)
    
    func setMethodCallHandler(methodCall: FlutterMethodCall, result: FlutterResult) -> Bool {
        switch(methodCall.method) {
            //        case "wallet_make_mnemonic":
            //            //产生助记词
            //            let mnemonics = Mnemonics(entropySize: .b128, language: .english)
            //            result(mnemonics.string)
        //            return true
        case "wallet_import_mnemonic":
            /*通过助记词保存、导入*/
            guard let params = methodCall.arguments as? [String: Any] else {
                result(FlutterError.init(code: ErrorCode.PARAMETERS_WRONG, message: "params is not [String: String]", details: nil))
                return true
            }
            guard let name = params["name"] as? String, let password = params["password"] as? String, let mnemonic = params["mnemonic"] as? String, let activeCoins = params["activeCoins"] as? [UInt32] else {
                result(FlutterError.init(code: ErrorCode.PARAMETERS_WRONG, message: "params can not find message", details: nil))
                return true
            }
            
            let coins = parseCoinTypes(pCoinValues: activeCoins)
            guard let wallet = try? keyStore.import(mnemonic: mnemonic, name: name, encryptPassword: password, coins: coins) else {
                result(FlutterError.init(code: ErrorCode.UNKNOWN_ERROR, message: "import error", details: nil))
                return true
            }
            
            let path = wallet.keyURL.lastPathComponent
            print("last path component is: \(path)")
            result(path)
            
            return true
            
        case "wallet_import_prvKey":
            //通过私钥Hex导入
            guard let params = methodCall.arguments as? [String: Any] else {
                result(FlutterError.init(code: ErrorCode.PARAMETERS_WRONG, message: "params is not [String: String]", details: nil))
                return true
            }
            guard let name = params["name"] as? String, let password = params["password"] as? String, let prvKeyHex = params["prvKeyHex"] as? String, let coinTypeValue = params["coinTypeValue"] as? UInt32 else {
                result(FlutterError.init(code: ErrorCode.PARAMETERS_WRONG, message: "params can not find message", details: nil))
                return true
            }
            
            guard let data = Data(hexString: prvKeyHex), let privateKey = PrivateKey(data: data) else {
                result(FlutterError.init(code: ErrorCode.UNKNOWN_ERROR, message: "invalide private key hex", details: nil))
                return true
            }
            
            let coin = parseCoinType(coinTypeValue: coinTypeValue)
            guard let wallet = try? keyStore.import(privateKey: privateKey, name: name, password: password, coin: coin) else {
                result(FlutterError.init(code: ErrorCode.UNKNOWN_ERROR, message: "cannot import private key", details: nil))
                return true
            }
            
            result(wallet.keyURL.lastPathComponent)
            
            return true
            
        case "wallet_import_json":
            //通过Keystore Json导入
            guard let params = methodCall.arguments as? [String: Any] else {
                result(FlutterError.init(code: ErrorCode.PARAMETERS_WRONG, message: "params is not [String: String]", details: nil))
                return true
            }
            guard let name = params["name"] as? String, let password = params["password"] as? String, let newPassword = params["newPassword"] as? String, let keyStoreJson = params["keyStoreJson"] as? String, let activeCoins = params["activeCoins"] as? [UInt32] else {
                result(FlutterError.init(code: ErrorCode.PARAMETERS_WRONG, message: "params can not find message", details: nil))
                return true
            }
            
            let coins = parseCoinTypes(pCoinValues: activeCoins)
            let data = Data(keyStoreJson.utf8)
            guard let wallet = try? keyStore.import(json: data, name: name, password: password, newPassword: newPassword, coins: coins) else {
                result(FlutterError.init(code: ErrorCode.UNKNOWN_ERROR, message: "import json wallet error", details: nil))
                return true
            }
            
            result(wallet.keyURL.lastPathComponent)
            return true
            
        case "wallet_load_keystore":
            //加载一个keystore
            guard let params = methodCall.arguments as? [String: String] else {
                result(FlutterError.init(code: ErrorCode.PARAMETERS_WRONG, message: "params is not [String: String]", details: nil))
                return true
            }
            guard let fileName = params["fileName"] else {
                result(FlutterError.init(code: ErrorCode.PARAMETERS_WRONG, message: "params can not find message", details: nil))
                return true
            }
            
            var wallet: Wallet?
            for w in keyStore.wallets {
                if(w.keyURL.lastPathComponent == fileName) {
                    wallet = w
                    break
                }
            }
            
            guard let strongWallet = wallet else {
                result(FlutterError.init(code: ErrorCode.UNKNOWN_ERROR, message: "load keystore error", details: nil))
                return true
            }
            
            let map: [String: Any] = walletToReturnMap(wallet: strongWallet)
            result(map)
            
            return true
            
        case "wallet_delete":
            //删除钱包
            guard let params = methodCall.arguments as? [String: Any] else {
                result(FlutterError.init(code: ErrorCode.PARAMETERS_WRONG, message: "params is not [String: String]", details: nil))
                return true
            }
            guard let fileName = params["fileName"] as? String, let password = params["password"] as? String else {
                result(FlutterError.init(code: ErrorCode.PARAMETERS_WRONG, message: "params can not find message", details: nil))
                return true
            }
            
            for w in keyStore.wallets {
                if(w.keyURL.lastPathComponent == fileName) {
                    do {
                        try keyStore.delete(wallet: w, password: password)
                        result(true)
                    } catch {
                        print("Delete error： \(error)")
                        result(false)
                    }
                    return true
                }
            }
            
            result(false)
            return true
        case "wallet_all_keystore":
            //获取本地所有keystore
            var ksList: [[String: Any]] = []
            for w in keyStore.wallets {
                let map: [String: Any] = walletToReturnMap(wallet: w)
                ksList.append(map)
            }
            result(ksList)
            return true
            
        case "wallet_update":
            //修改密码
            guard let params = methodCall.arguments as? [String: Any] else {
                result(FlutterError.init(code: ErrorCode.PARAMETERS_WRONG, message: "params is not [String: String]", details: nil))
                return true
            }
            guard let fileName = params["fileName"] as? String, let newPassword = params["newPassword"] as? String, let oldPassword = params["oldPassword"] as? String else {
                result(FlutterError.init(code: ErrorCode.PARAMETERS_WRONG, message: "params can not find message", details: nil))
                return true
            }
            
            let name = params["name"] as? String
            
            for w in keyStore.wallets {
                if(w.keyURL.lastPathComponent == fileName) {
                    do {
                        try updateKeyStor(name: name ?? w.key.name, wallet: w, password: oldPassword, newPassword: newPassword)
                        //                        try keyStore.update(wallet: w, password: oldPassword, newPassword: newPassword)
                        let success = w.key.store(path: w.keyURL.path)
                        print("is store success \(success)")
                        result(w.keyURL.lastPathComponent)
                    } catch {
                        print("export private key error: \(error)")
                        result(FlutterError.init(code: ErrorCode.PASSWORD_WRONG, message: "password error", details: "invalidPassword"))
                    }
                    return true
                }
            }
            
            result(FlutterMethodNotImplemented)
            return true
            
        case "wallet_getPrivateKey":
            //导出私钥  这里只导出eth私钥
            guard let params = methodCall.arguments as? [String: Any] else {
                result(FlutterError.init(code: ErrorCode.PARAMETERS_WRONG, message: "params is not [String: String]", details: nil))
                return true
            }
            guard let fileName = params["fileName"] as? String, let password = params["password"] as? String, let coinTypeValue = params["coinTypeValue"] as? UInt32 else {
                result(FlutterError.init(code: ErrorCode.PARAMETERS_WRONG, message: "params can not find message", details: nil))
                return true
            }
            
            let coin = parseCoinType(coinTypeValue: coinTypeValue)
            for w in keyStore.wallets {
                if(w.keyURL.lastPathComponent == fileName) {
                    do {
                        let privateKey = try w.privateKey(password: password, coin: coin)
                        //                        let prvData = try keyStore.exportPrivateKey(wallet: w, password: password)
                        result(privateKey.data.hexString)
                    } catch {
                        print("export private key error: \(error)")
                        result(FlutterError.init(code: ErrorCode.PASSWORD_WRONG, message: "invalidPassword", details: "invalidPassword"))
                    }
                    return true
                }
            }
            
            result(FlutterError.init(code: ErrorCode.UNKNOWN_ERROR, message: "can't find wallet", details: nil))
            return true
            
        case "wallet_getMnemonic":
            //导出助记词
            guard let params = methodCall.arguments as? [String: String] else {
                result(FlutterError.init(code: ErrorCode.PARAMETERS_WRONG, message: "params is not [String: String]", details: nil))
                return true
            }
            guard let fileName = params["fileName"], let password = params["password"] else {
                result(FlutterError.init(code: ErrorCode.PARAMETERS_WRONG, message: "params can not find message", details: nil))
                return true
            }
            
            for w in keyStore.wallets {
                if(w.keyURL.lastPathComponent == fileName) {
                    do {
                        let mnemonic = try keyStore.exportMnemonic(wallet: w, password: password)
                        result(mnemonic)
                    } catch {
                        print("export mnemonic error: \(error)")
                        result(FlutterError.init(code: ErrorCode.PASSWORD_WRONG, message: "password error", details: "invalidPassword"))
                    }
                    return true
                }
            }
            
            result(FlutterError.init(code: ErrorCode.UNKNOWN_ERROR, message: "can't find wallet", details: nil))
            return true
            
        case "bitcoinSign":
            //比特币签名
            guard let params = methodCall.arguments as? [String: Any] else {
                result(FlutterError.init(code: ErrorCode.PARAMETERS_WRONG, message: "params is not [String: Any]", details: nil))
                return true
            }
            
            guard let transJsonStr = params["transJson"] as? String else {
                result(FlutterError.init(code: ErrorCode.PARAMETERS_WRONG, message: "params can not find message", details: nil))
                return true
            }
            
            guard let transJson = transJsonStr.convertToDictionary() else {
                result(FlutterError.init(code: ErrorCode.PARAMETERS_WRONG, message: "params can not find message", details: nil))
                return true
            }
            
            //print("[Wallet] transJson:\(transJson)")
            
            let bitcoinTransEntity = BitcoinTransEntity.fromJson(map: transJson)
            
            for w in keyStore.wallets {
                if(w.keyURL.lastPathComponent == bitcoinTransEntity.fileName) {
                    do {
                        let mnemonic = try keyStore.exportMnemonic(wallet: w, password: bitcoinTransEntity.password)
                        if mnemonic.isEmpty {
                            result(FlutterError.init(code: ErrorCode.PASSWORD_WRONG, message: "password error", details: "invalidPassword"))
                        } else {
                            // 1.Getting key
                            let wallet = HDWallet(mnemonic: mnemonic, passphrase: "")
                            let coinBtc: CoinType = CoinType.bitcoin
                            let toAddress = bitcoinTransEntity.toAddress
                            let changeAddress = bitcoinTransEntity.change.address
                            
                            // 2.Signing Input
                            var input = BitcoinSigningInput.with {
                                $0.amount = bitcoinTransEntity.amount
                                $0.hashType = BitcoinSigHashType.all.rawValue
                                $0.toAddress = toAddress
                                $0.changeAddress = changeAddress
                                $0.byteFee = bitcoinTransEntity.fee
                                $0.coinType = coinBtc.rawValue
                                //$0.utxo = utxos
                                //$0.privateKey = [privateKey.data]
                            }
                            
                            // 3.
                            bitcoinTransEntity.utxo.forEach { (it: Utxo) in
                                //common
                                let pathStr = "m/84'/0'/0'/\(it.sub)/\(it.index)"
                                guard let path = DerivationPath(pathStr) else {
                                    result(FlutterError.init(code: ErrorCode.UNKNOWN_ERROR, message: "path error", details: "path parse error, path:\(pathStr)"))
                                    return
                                }
                                let secretPrivateKeyBtc = wallet.getKey(at:path)
                                let script = BitcoinScript.buildForAddress(address: it.address, coin: coinBtc) // utxo address
                                let scriptHash = script.matchPayToWitnessPublicKeyHash()
                                
                                //utxo
                                let utxoTxId = Data(hexString: it.txHash)
                                guard let reverUtxoTxId = utxoTxId?.reversed() else {
                                    result(FlutterError.init(code: ErrorCode.UNKNOWN_ERROR, message: "reversed error", details: "txHash reversed error, txHash:\(it.txHash)"))
                                    return
                                }
                                
                                let outPoint = BitcoinOutPoint.with {
                                    $0.hash = Data(reverUtxoTxId)
                                    //print("[Wallet]  it.txHash:\(it.txHash), utxoTxId:\(utxoTxId), reverUtxoTxId:\(reverUtxoTxId)")
                                    
                                    $0.index = UInt32(it.txOutputN)
                                    //$0.sequence = 4294967293
                                    $0.sequence = UINT32_MAX
                                }
                                
                                let utxo = BitcoinUnspentTransaction.with {
                                    $0.amount = it.value // value of this UTXO
                                    $0.outPoint = outPoint // reverse of UTXO tx id, Bitcoin internal expects network byte order
                                    $0.script = script.data
                                }
                                input.utxo.append(utxo)
                                
                                
                                //input
                                input.privateKey.append(secretPrivateKeyBtc.data)
                                
                                if let hash = scriptHash {
                                    input.scripts[hash.hexString] = BitcoinScript.buildPayToPublicKeyHash(hash: hash).data
                                }
                            }
                            
                            
                            let output: BitcoinSigningOutput = AnySigner.sign(input: input, coin: coinBtc)
                            let signedTransaction = output.encoded.hexString
                            result(signedTransaction)
                        }
                    } catch {
                        //print("export mnemonic error: \(error)")
                        result(FlutterError.init(code: ErrorCode.PASSWORD_WRONG, message: "password error", details: "invalidPassword"))
                    }
                    return true
                }
            }
            
            result(FlutterError.init(code: ErrorCode.UNKNOWN_ERROR, message: "can't find wallet", details: nil))
            return true
            
        case "bitcoinActive":
            //比特币激活
            guard let params = methodCall.arguments as? [String: Any] else {
                result(FlutterError.init(code: ErrorCode.PARAMETERS_WRONG, message: "params is not [String: Any]", details: nil))
                return true
            }
            
            guard let fileName = params["fileName"] as? NSString, let password = params["password"] as? NSString else {
                result(FlutterError.init(code: ErrorCode.PARAMETERS_WRONG, message: "params can not find message", details: nil))
                return true
            }
            
            for w in keyStore.wallets {
                if(w.keyURL.lastPathComponent == fileName as String) {
                    do {
                        let account = try w.getAccount(password: password as String, coin: CoinType.bitcoin)
                        let path = w.keyURL.path
                        let success = w.key.store(path: path)
                        //print("is store success \(success), account: \(account.address)")
                        if (success) {
                            print("is store path: \(path)")
                            result(path)
                        } else {
                            result(FlutterError.init(code: ErrorCode.PARAMETERS_WRONG, message: "bitcoin active is fail", details: nil))
                        }
                    } catch {
                        //print("export mnemonic error: \(error)")
                        result(FlutterError.init(code: ErrorCode.PASSWORD_WRONG, message: "password error", details: "invalidPassword"))
                    }
                    return true
                }
            }
            
            result(FlutterError.init(code: ErrorCode.UNKNOWN_ERROR, message: "can't find wallet", details: nil))
            return true
            
        default:
            return false
        }
    }
    
    
    func walletToReturnMap(wallet: Wallet) -> [String: Any] {
        var map: [String: Any] = [:]
        map["type"] = 0
        var accounts: [[String: Any]] = []
        for account in wallet.accounts {
            var accountMap: [String: Any] = [:]
            accountMap["address"] = account.address
            accountMap["derivationPath"] = account.derivationPath
            accountMap["coinType"] = account.coin.rawValue
            if account.coin.rawValue == CoinType.bitcoin.rawValue {
                accountMap["extendedPublicKey"] = account.extendedPublicKey
            }
            accounts.append(accountMap)
        }
        map["accounts"] = accounts
        map["name"] = wallet.key.name
        map["fileName"] = wallet.keyURL.lastPathComponent
        map["isMnemonic"] = wallet.key.isMnemonic
        map["identifier"] = wallet.key.identifier
        map["accountCount"] = wallet.key.accountCount
        print("[Wallet] walletToReturnMap, map:\(map)")
        
        return map
    }
    
    private func parseCoinType(coinTypeValue: UInt32) -> CoinType {
        if let coin = CoinType.init(rawValue: coinTypeValue) {
            return coin
        }
        return CoinType.ethereum
    }
    
    private func parseCoinTypes(pCoinValues: [UInt32]?) -> [CoinType] {
        guard let coinValues = pCoinValues else {
            return []
        }
        
        var coins: [CoinType] = []
        for coinValue in coinValues {
            if let coin = CoinType.init(rawValue: coinValue) {
                coins.append(coin)
            }
        }
        return coins
    }
    
    private func updateKeyStor(name: String, wallet: Wallet, password: String, newPassword: String) throws {
        guard let index = keyStore.wallets.firstIndex(of: wallet) else {
            fatalError("Missing wallet")
        }
        
        guard let psw = password.data(using: .utf8), var privateKeyData = wallet.key.decryptPrivateKey(password: psw) else {
            throw KeyStore.Error.invalidPassword
        }
        defer {
            privateKeyData.resetBytes(in: 0 ..< privateKeyData.count)
        }
        
        guard let coin = wallet.key.account(index: 0)?.coin else {
            throw KeyStore.Error.accountNotFound
        }
        
        if let mnemonic = checkMnemonic(privateKeyData), let psw = newPassword.data(using: .utf8) {
            if let value = StoredKey.importHDWallet(mnemonic: mnemonic, name: name, password: psw, coin: coin) {
                keyStore.wallets[index].key = value
            }
        } else {
            if let psw = newPassword.data(using: .utf8), let value = StoredKey.importPrivateKey(privateKey: privateKeyData, name: name, password: psw, coin: coin) {
                keyStore.wallets[index].key = value
            }
        }
    }
    
    private func checkMnemonic(_ data: Data) -> String? {
        guard let mnemonic = String(data: data, encoding: .ascii), HDWallet.isValid(mnemonic: mnemonic) else {
            return nil
        }
        return mnemonic
    }
}


class BitcoinTransEntity{
    var fileName: String = ""
    var password: String = ""
    var fromAddress: String = ""
    var toAddress: String = ""
    var fee: Int64 = 0
    var amount: Int64 = 0
    var utxo: Array<Utxo> = []
    var change: Change = Change()
    
    static func fromJson(map: [String:Any]) -> BitcoinTransEntity {
        let model = BitcoinTransEntity()
        model.fileName = map["fileName"] as? String ?? ""
        model.password = map["password"] as? String ?? ""
        model.fromAddress = map["fromAddress"] as? String ?? ""
        model.toAddress = map["toAddress"] as? String ?? ""
        model.fee = map["fee"] as? Int64 ?? 0
        model.amount = map["amount"] as? Int64 ?? 0
        
        if let utxoArr = map["utxo"] as? [Any] {
            var utxo:[Utxo] = []
            for item in utxoArr {
                if let utxoDict = item as? [String:Any] {
                    let model = Utxo.fromJson(map: utxoDict)
                    utxo.append(model)
                }
            }
            model.utxo = utxo
        }
        
        if let changeDict = map["change"] as? [String:Any] {
            model.change = Change.fromJson(map: changeDict)
        }
        
        return model
    }
}

class Utxo {
    var sub: Int = 0
    var index: Int = 0
    var txHash: String = ""
    var address: String = ""
    var txOutputN: Int = 0
    var value: Int64 = 0
    
    static func fromJson(map: [String:Any]) -> Utxo {
        let model = Utxo()
        model.sub = map["sub"] as? Int ?? 0
        model.index = map["index"] as? Int ?? 0
        model.txHash = map["txHash"] as? String ?? ""
        model.address = map["address"] as? String ?? ""
        model.txOutputN = map["txOutputN"] as? Int ?? 0
        model.value = map["value"] as? Int64 ?? 0
        return model
    }
}

class Change {
    var address: String = ""
    var value: Int = 0
    
    static func fromJson(map: [String:Any]) -> Change {
        let model = Change()
        model.address = map["address"] as? String ?? ""
        model.value = map["value"] as? Int ?? 0
        return model
    }
}

extension String {
    func convertToDictionary() -> [String: Any]? {
        if let data = data(using: .utf8) {
            return try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        }
        return nil
    }
}
