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
    func generateKeyPairAndStore(expireAt: Double) -> Observable<Bool>
    func encrypt(publicKeyStr: String, message: String) -> Observable<String>
    func decrypt(ciphertext: String) -> Observable<String>
    var publicKey: String? {get}
    var expireTime: Int64 {get}
}
