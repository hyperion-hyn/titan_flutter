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

class EthEncryptionService: EncryptionService {
    
    private lazy var cipher = MobileNewCipher()
    
    private var _pubStr: String? = nil
    private var _expiredTime: Int64 = 0
    
    func generateKeyPairAndStore(expireAt: Double) -> Observable<Bool> {
        return Observable<Bool>.create { observer in
            if let pairs = self.cipher?.genKeyPair() {
                let ps = pairs.components(separatedBy: ",")
                if ps.count == 2 {
                    let extime = Int64(expireAt)
                    let isSaveSuccess: Bool = KeychainWrapper.standard.set("\(pairs),\(extime)", forKey: "savedKeyPair")
                    if isSaveSuccess {
                        self._pubStr = ps[1]
                        self._expiredTime = extime
                    }
                    observer.onNext(isSaveSuccess)
                    observer.onCompleted()
                    return Disposables.create()
                }
            }
            observer.onNext(false)
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
    
    func decrypt(ciphertext: String) -> Observable<String> {
        return Observable<String>.create { observer in
            if let savedKeyPair = KeychainWrapper.standard.string(forKey: "savedKeyPair") {
                let ps = savedKeyPair.components(separatedBy: ",")
                if ps.count == 3 {
                    let priStr = ps[0]
                    if let message = self.cipher?.decrypt(priStr, cipherText: ciphertext) {
                        if !message.isEmpty {
                            observer.onNext(message)
                            observer.onCompleted()
                            return Disposables.create()
                        }
                    }
                }
            }
            observer.onError(NSError(domain: "decrypt error", code: -1, userInfo: nil))
            return Disposables.create()
        }
    }
    
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
    
}
