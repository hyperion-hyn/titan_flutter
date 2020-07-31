//
//  EncrytionPluginInterface.swift
//  Runner
//
//  Created by naru.j on 2019/12/20.
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
            guard let params = methodCall.arguments as? [String: String] else {
                result(FlutterError.init(code: "-1", message: "params is not [String: String]", details: nil))
                return true
            }
            guard let privateKey = params["privateKey"], let cipherText = params["cipherText"] else {
                result(FlutterError.init(code: "-1", message: "params can not find message", details: nil))
                return true
            }
            self.encryptService.decrypt(privateKeyStr: privateKey, ciphertext: cipherText)
                .subscribe(onNext: { (message) in
                    result(message)
                }, onError: { error in
                    result(FlutterError.init(code: "-1", message: error.localizedDescription, details: nil))
                }, onCompleted: nil, onDisposed: nil)
            return true
            
        case "trustActiveEncrypt":
            guard let params = methodCall.arguments as? [String: String] else {
                result(FlutterError.init(code: "-1", message: "params is not [String: String]", details: nil))
                return true
            }
            guard let fileName = params["fileName"], let password = params["password"] else {
                result(FlutterError.init(code: ErrorCode.PARAMETERS_WRONG, message: "params can not find message", details: nil))
                return true
            }
            
            self.encryptService.trustActiveEncrypt(password: password, fileName: fileName)
                .subscribe(onNext: { (message) in
                    result(message)
                }, onError: { error in
                    result(FlutterError.init(code: "-1", message: error.localizedDescription, details: nil))
                }, onCompleted: nil, onDisposed: nil)
            return true
            
            case "trustEncrypt":
                guard let params = methodCall.arguments as? [String: String] else {
                    result(FlutterError.init(code: "-1", message: "params is not [String: String]", details: nil))
                    return true
                }
                guard let pub = params["publicKey"], let message = params["message"] else {
                    result(FlutterError.init(code: "-1", message: "params can not find message", details: nil))
                    return true
                }
                self.encryptService.trustEncrypt(publicKeyStr: pub, message: message)
                    .subscribe(onNext: { (ciphertext) in
                        result(ciphertext)
                    }, onError: { error in
                        result(FlutterError.init(code: "-1", message: error.localizedDescription, details: nil))
                    }, onCompleted: nil, onDisposed: nil)
                return true
                
            case "trustDecrypt":
                guard let params = methodCall.arguments as? [String: String] else {
                    result(FlutterError.init(code: "-1", message: "params is not [String: String]", details: nil))
                    return true
                }
                guard let fileName = params["fileName"], let password = params["password"], let cipherText = params["cipherText"] else {
                    result(FlutterError.init(code: "-1", message: "params can not find message", details: nil))
                    return true
                }
                self.encryptService.trustDecrypt(cipherText: cipherText, fileName: fileName, password: password)
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
            .subscribe(onNext: { (pair:[AnyHashable : Any]) in
                result(pair)
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
    }
}
