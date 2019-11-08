//
//  Crypto.swift
//  BIP39Demo
//
//  Created by 蔡景松 on 2019/11/3.
//  Copyright © 2019 VoiceChat. All rights reserved.
//

import Foundation

///
/// Implements a simplified API for calculating digests over single buffers
///
public protocol CryptoDigest {
    
    /// Calculates a message digest
    func digest(using algorithm: Digest.Algorithm) -> Self
}


///
/// Extension for Data to return an Data object containing the digest.
///
extension Data: CryptoDigest {
    ///
    /// Calculates the Message Digest for this data.
    ///
    /// - Parameter algorithm: The digest algorithm to use
    ///
    /// - Returns: An `Data` object containing the message digest
    ///
    public func digest(using algorithm: Digest.Algorithm) -> Data {
        
        // This force unwrap may look scary but for CommonCrypto this cannot fail.
        // The API allows for optionals to support the OpenSSL implementation which can.
        return self.withUnsafeBytes() { (buffer: UnsafePointer<UInt8>) -> Data in
            
            let result = (Digest(using: algorithm).update(from: buffer, byteCount: self.count)?.final())!
            let data = type(of: self).init(bytes: result, count: result.count)
            return data
        }
    }
}
