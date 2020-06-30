package org.hyn.titan.encryption

import io.reactivex.Flowable

interface EncryptionService {
    fun generateKeyPairAndStore(expireAt: Long): Flowable<Boolean>

    val publicKey: String?

    val expireTime: Long

    fun trustActiveEncrypt(message: String, password: String, fileName: String): Flowable<String>

    fun encrypt(publicKeyStr: String?, message: String, isCompress:Boolean): Flowable<String>

    fun encryptSync(publicKeyStr: String?, message: String, password: String, fileName: String): Map<String,String>

    fun decrypt(cipherText: String): Flowable<String>

    fun trustDecrypt(cipherText: String,fileName: String,password: String): Flowable<String>
}