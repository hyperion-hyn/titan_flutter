//
//  EthEncryptionService.swift
//  Runner
//
//  Created by moo on 2019/7/24.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

import Foundation
import Mobile
import RxSwift
import SwiftKeychainWrapper
import TrustWalletCore

class EthEncryptionService: EncryptionService {
    
    
    private lazy var cipher = MobileNewCipher()
    
    private var _pubStr: String? = nil
    private var _expiredTime: Int64 = 0
    
    
    var publicKey: String? {
        get {
            if _pubStr == nil, let savedKeyPair = KeychainWrapper.standard.string(forKey: "savedKeyPair") {
                let ps = savedKeyPair.components(separatedBy: ",")
                if ps.count == 3 {
                    _pubStr = ps[1]
                }
            }
            return _pubStr
        }
    }
    
    var expireTime: Int64 {
        get {
            if _expiredTime == 0, let savedKeyPair = KeychainWrapper.standard.string(forKey: "savedKeyPair") {
                let ps = savedKeyPair.components(separatedBy: ",")
                if ps.count == 3 {
                    _expiredTime = Int64(ps[2]) ?? 0
                }
            }
            return _expiredTime
        }
    }
    
    
    func generateKeyPairAndStore(expireAt: Int64) -> Observable<[AnyHashable : Any]> {
        return Observable<[AnyHashable : Any]>.create { observer in
            
            var map: Dictionary<String, Any> = [:]
            
            if let pairs = self.cipher?.genKeyPair() {
                let ps = pairs.components(separatedBy: ",")
                if ps.count == 2 {
                    let prvStr = ps[0]
                    let pubStr = ps[1]
                    map = ["publicKey": pubStr, "privateKey": prvStr]
                }
            }
            observer.onNext(map)
            observer.onCompleted()
            return Disposables.create()
        }
    }
    
    func encrypt(publicKeyStr: String, message: String) -> Observable<String> {
        return Observable<String>.create { observer in
            if let cipherText = self.cipher?.encrypt(publicKeyStr, message: message) {
                observer.onNext(cipherText)
                observer.onCompleted()
                return Disposables.create()
            }
            observer.onError(NSError(domain: "encrypt error", code: -1, userInfo: nil))
            return Disposables.create()
        }
    }
    
    func decrypt(privateKeyStr: String, ciphertext: String) -> Observable<String> {
        return Observable<String>.create { observer in
            let priStr = privateKeyStr
            if let message = self.cipher?.decrypt(priStr, cipherText: ciphertext) {
                if !message.isEmpty {
                    observer.onNext(message)
                    observer.onCompleted()
                    return Disposables.create()
                }
            }
            observer.onError(NSError(domain: "decrypt error", code: -1, userInfo: nil))
            return Disposables.create()
        }
    }
    
    func trustActiveEncrypt(password: String, fileName: String) -> Observable<String> {
        return Observable<String>.create { observer in
            
            for w in WalletPluginInterface().keyStore.wallets {
                if(w.keyURL.lastPathComponent == fileName) {
                    do {
                        let privateKey = try w.privateKey(password: password, coin: CoinType.ethereum)
                        var comPublicKey = privateKey.getPublicKeySecp256k1(compressed: true).description
                        if !comPublicKey.isEmpty {
                            comPublicKey = "0x\(comPublicKey)"
                            //print("[EthEncryption] -->trustActiveEncrypt, comPublicKey:\(comPublicKey)")
                            observer.onNext(comPublicKey)
                        }
                    } catch {
                        observer.onError(NSError(domain: "encrypt error", code: -1, userInfo: nil))
                    }
                    return Disposables.create()
                }
            }
            observer.onError(NSError(domain: "encrypt error", code: -1, userInfo: nil))
            return Disposables.create()
        }
    }
    
    func trustEncrypt(publicKeyStr: String?, message: String) -> Observable<String> {
        return Observable<String>.create { observer in
            guard let tempPublicKey = self.cipher?.deCompressPubkey(publicKeyStr) else {
                observer.onError(NSError(domain: "encrypt error", code: -1, userInfo: nil))
                return Disposables.create()
            }
            
            if let cipherText = self.cipher?.encrypt(tempPublicKey, message: message) {
                if !cipherText.isEmpty {
                    observer.onNext(cipherText)
                    //print("[EthEncryption] --> trustEncrypt:\(cipherText)")
                    observer.onCompleted()
                    return Disposables.create()
                }
            } 
            
            observer.onError(NSError(domain: "encrypt error", code: -1, userInfo: nil))
            return Disposables.create()
        }
    }
    
    func trustDecrypt(cipherText: String, fileName: String, password: String) -> Observable<String> {
        return Observable<String>.create { observer in
            
            for w in WalletPluginInterface().keyStore.wallets {
                if(w.keyURL.lastPathComponent == fileName) {
                    do {
                        let privateKey = try w.privateKey(password: password, coin: CoinType.ethereum)
                        let priStr = privateKey.data.hexString
                        guard let message = self.cipher?.decrypt(priStr, cipherText: cipherText) else {
                            observer.onError(NSError(domain: "decrypt error", code: -1, userInfo: nil))
                            return Disposables.create()
                        }
                        //print("[EthEncryption] --> trustDecrypt, message:\(message)")

                        if !message.isEmpty {
                            observer.onNext(message)
                            observer.onCompleted()
                            return Disposables.create()
                        }
                        observer.onError(NSError(domain: "decrypt error", code: -1, userInfo: nil))
                    } catch {
                        observer.onError(NSError(domain: "decrypt error", code: -1, userInfo: nil))
                    }
                    return Disposables.create()
                }
            }
            
            
            observer.onError(NSError(domain: "decrypt error", code: -1, userInfo: nil))
            return Disposables.create()
        }
    }
    
}
