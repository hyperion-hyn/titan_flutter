package org.maprich.app.encryption

import io.reactivex.Flowable

interface EncryptionService {
    fun generateKeyPairAndStore(expireAt: Long): Flowable<Boolean>

    val publicKey: String?

    val expireTime: Long

    fun encrypt(publicKeyStr: String, message: String): Flowable<String>

    fun encryptSync(publicKeyStr: String, message: String): String

    fun decrypt(ciphertext: String): Flowable<String>
}