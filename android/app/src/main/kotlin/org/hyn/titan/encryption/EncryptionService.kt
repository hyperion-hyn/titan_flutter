package org.hyn.titan.encryption

import io.reactivex.Flowable

interface EncryptionService {
    fun generateKeyPairAndStore(expireAt: Long): Flowable<Boolean>

    val publicKey: String?

    val expireTime: Long

    fun encrypt(publicKeyStr: String?, message: String, password: String, fileName: String): Flowable<Map<String,String>>

    fun encryptSync(publicKeyStr: String?, message: String, password: String, fileName: String): Map<String,String>

    fun decrypt(cipherText: String,fileName: String,password: String): Flowable<String>
}