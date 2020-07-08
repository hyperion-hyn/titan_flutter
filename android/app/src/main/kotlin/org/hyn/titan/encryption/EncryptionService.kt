package org.hyn.titan.encryption

import io.reactivex.Flowable

interface EncryptionService {
    fun generateKeyPairAndStore(): Flowable<Map<String,String>>

    val publicKey: String?

    val expireTime: Long

    fun encrypt(publicKeyStr: String, message: String): Flowable<String>

    fun encryptSync(publicKeyStr: String, message: String): String

    fun decrypt(privateKey: String, ciphertext: String): Flowable<String>

    fun trustActiveEncrypt(password: String, fileName: String): Flowable<String>

    fun trustEncrypt(publicKeyStr: String?, message: String): Flowable<String>

    fun trustDecrypt(cipherText: String,fileName: String,password: String): Flowable<String>

}