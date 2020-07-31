//
//  EncryptionService.swift
//  Runner
//
//  Created by moo on 2019/7/24.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

import Foundation
import RxSwift

protocol EncryptionService {
    var publicKey: String? {get}
    var expireTime: Int64 {get}
    func generateKeyPairAndStore(expireAt: Int64) -> Observable<[AnyHashable : Any]>
    func encrypt(publicKeyStr: String, message: String) -> Observable<String>
    func decrypt(privateKeyStr: String, ciphertext: String) -> Observable<String>
    func trustActiveEncrypt(password: String, fileName: String) -> Observable<String>
    func trustEncrypt(publicKeyStr: String?, message: String) -> Observable<String>
    func trustDecrypt(cipherText: String, fileName: String, password: String) -> Observable<String>
}
