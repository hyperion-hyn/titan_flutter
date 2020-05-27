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
            
            guard (wallet != nil) else {
                result(FlutterError.init(code: ErrorCode.UNKNOWN_ERROR, message: "load keystore error", details: nil))
                return true
            }
            
            let map: [String: Any] = walletToReturnMap(wallet: wallet!)
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
            accounts.append(accountMap)
        }
        map["accounts"] = accounts
        map["name"] = wallet.key.name
        map["fileName"] = wallet.keyURL.lastPathComponent
        map["isMnemonic"] = wallet.key.isMnemonic
        map["identifier"] = wallet.key.identifier
        map["accountCount"] = wallet.key.accountCount
        
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

        guard var privateKeyData = wallet.key.decryptPrivateKey(password: password) else {
            throw KeyStore.Error.invalidPassword
        }
        defer {
            privateKeyData.resetBytes(in: 0 ..< privateKeyData.count)
        }

        guard let coin = wallet.key.account(index: 0)?.coin else {
            throw KeyStore.Error.accountNotFound
        }

        if let mnemonic = checkMnemonic(privateKeyData) {
            keyStore.wallets[index].key = StoredKey.importHDWallet(mnemonic: mnemonic, name: name, password: newPassword, coin: coin)
        } else {
            keyStore.wallets[index].key = StoredKey.importPrivateKey(privateKey: privateKeyData, name: name, password: newPassword, coin: coin)
        }
    }
    
    private func checkMnemonic(_ data: Data) -> String? {
        guard let mnemonic = String(data: data, encoding: .ascii), HDWallet.isValid(mnemonic: mnemonic) else {
            return nil
        }
        return mnemonic
    }
}
