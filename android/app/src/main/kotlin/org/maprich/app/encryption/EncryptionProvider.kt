package org.maprich.app.encryption

import android.content.Context

object EncryptionProvider {
    private lateinit var service: EncryptionService

//    init {
//        Security.addProvider(BouncyCastleProvider())
//    }

    fun getDefaultEncryption(context: Context): EncryptionService {
        if (!this::service.isInitialized) {
//            this.service = ECEncryptionService(context)
            this.service = EthEncryptionService(context)
        }
        return this.service
    }
}