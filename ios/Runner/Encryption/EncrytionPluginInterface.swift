//
//  EncrytionPluginInterface.swift
//  Runner
//
//  Created by 蔡景松 on 2019/12/20.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

import Foundation
import RxSwift

class EncrytionPluginInterface {
    
    private lazy var encryptService: EncryptionService = EthEncryptionService()

    func setMethodCallHandler(methodCall: FlutterMethodCall, result: @escaping FlutterResult) -> Bool {
        switch(methodCall.method) {
            
        case "initKeyPair":
            if self.encryptService.publicKey == nil || Date().milliStamp > self.encryptService.expireTime {
                guard let expired = methodCall.arguments as? Int64 else { return true}
                self.generateKey(expired: expired, result: result)
            } else {
                result(self.encryptService.publicKey)
            }
            return true
            
        case "genKeyPair":
            let expired = methodCall.arguments as? Int64 ?? 3600
            self.generateKey(expired: expired, result: result)
            return true

        case "getPublicKey":
            result(self.encryptService.publicKey)
            return true

        case "getExpired":
            result(self.encryptService.expireTime)
            return true

        case "encrypt":
            guard let params = methodCall.arguments as? [String: String] else {
                result(FlutterError.init(code: "-1", message: "params is not [String: String]", details: nil))
                return true
            }
            guard let pub = params["pub"], let message = params["message"] else {
                result(FlutterError.init(code: "-1", message: "params can not find message", details: nil))
                return true
            }
            self.encryptService.encrypt(publicKeyStr: pub, message: message)
                .subscribe(onNext: { (ciphertext) in
                    result(ciphertext)
                }, onError: { error in
                    result(FlutterError.init(code: "-1", message: error.localizedDescription, details: nil))
                }, onCompleted: nil, onDisposed: nil)
            return true

        case "decrypt":
            guard let ciphertext = methodCall.arguments as? String else {
                result(FlutterError.init(code: "-1", message: "params is not String", details: nil))
                return true
            }
            self.encryptService.decrypt(ciphertext: ciphertext)
                .subscribe(onNext: { (message) in
                    result(message)
                }, onError: { error in
                    result(FlutterError.init(code: "-1", message: error.localizedDescription, details: nil))
                }, onCompleted: nil, onDisposed: nil)
            return true

        default:
            return false
        }
    }
    
    private func generateKey(expired: Int64, result: @escaping FlutterResult) {
        let disposeBag = DisposeBag()
        self.encryptService.generateKeyPairAndStore(expireAt: expired)
            .subscribe(onNext: { (isSuccess) in
                if let pub = self.encryptService.publicKey {
                    result(pub)
                }
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
    }
}
