package org.hyn.titan.encryption

import android.content.Context
import io.reactivex.Flowable
import org.atlas.mobile_lib.Mobile_lib
import org.hyn.titan.ErrorCode
import org.hyn.titan.encryption.rsa.RsaEncryption
import org.hyn.titan.utils.Numeric
import org.hyn.titan.wallet.KeyStoreUtil
import timber.log.Timber
import wallet.core.jni.CoinType
import java.security.KeyStore
import java.security.cert.X509Certificate

class EthEncryptionService(private val context: Context) : EncryptionService {
    private val cipher = Mobile_lib.newCipher()
    private val rsaEncryption: RsaEncryption = RsaEncryption(1024)
    private var rsaEntry: KeyStore.PrivateKeyEntry? = null
    private val sharedPreferences = context.getSharedPreferences("eth_encryption", Context.MODE_PRIVATE)

    init {
        try {
            rsaEntry = rsaEncryption.keyEntry
        } catch (error: Exception) {
            Timber.i("There is no rsa key entry!")
        }
    }

    override fun generateKeyPairAndStore(): Flowable<Map<String, String>> {
        return Flowable.fromCallable {
            val pairs = cipher.genKeyPair().split(',')
            val prvStr = pairs[0]
            val pubStr = pairs[1]
            Timber.i("Eth public key is: $pubStr")

            return@fromCallable mapOf("publicKey" to pubStr, "privateKey" to prvStr)
        }
    }

    override val publicKey: String?
        get() = sharedPreferences.getString("public", null)

    override val expireTime: Long
        get() {
            if (rsaEntry != null) {
                val cert = (rsaEntry as KeyStore.PrivateKeyEntry).certificate as X509Certificate
                val expireDate = cert.notAfter
                return expireDate.time
            }
            return 0L
        }

    override fun encryptSync(publicKeyStr: String, message: String): String {
        val cipherText = cipher.encrypt(publicKeyStr, message)
        if (cipherText.isEmpty()) {
            throw Exception("encrypt error")
        }
        return cipherText
    }

    override fun encrypt(publicKeyStr: String, message: String): Flowable<String> {
        return Flowable.fromCallable {
            return@fromCallable encryptSync(publicKeyStr, message)
        }
    }

    override fun decrypt(privateKey: String, ciphertext: String): Flowable<String> {
        return Flowable.fromCallable {
            val message = cipher.decrypt(privateKey, ciphertext)
            if (message.isNotEmpty()) {
                return@fromCallable message
            }
//            }
            throw Exception("decrypt error")
        }
    }

    override fun trustActiveEncrypt(password: String, fileName: String): Flowable<String> {
        return Flowable.fromCallable {
            val privateKey = KeyStoreUtil.getPrvKeyEntity(KeyStoreUtil.getKeyStorePath(context, fileName), password, CoinType.ETHEREUM)
                    ?: throw Exception("password error")
            val publicKeyEntity = privateKey.getPublicKeySecp256k1(false)
            /*if(comPublicKey.isNotEmpty()){
                comPublicKey = "0x$comPublicKey"
            }*/
            return@fromCallable publicKeyEntity?.description() ?: ""
        }
    }

    override fun trustEncrypt(publicKeyStr: String?, message: String): Flowable<String> {
        return Flowable.fromCallable {
            /*var tempPublicKey = cipher.deCompressPubkey(publicKeyStr)
            if (tempPublicKey.isEmpty()) {
                throw Exception("encrypt error")
            }*/
            val cipherText = cipher.encrypt(publicKeyStr, message)
            if (cipherText.isEmpty()) {
                throw Exception("encrypt error")
            }
            return@fromCallable cipherText
        }
    }

    override fun trustDecrypt(cipherText: String, fileName: String, password: String): Flowable<String> {
        return Flowable.fromCallable {
            val privateKey = KeyStoreUtil.getPrvKeyEntity(KeyStoreUtil.getKeyStorePath(context, fileName), password, CoinType.ETHEREUM)
                    ?: throw Exception(ErrorCode.PASSWORD_WRONG)
            val privateKeyStr = Numeric.toHexString(privateKey.data(), false)
            val message = cipher.decrypt(privateKeyStr, cipherText)
            if (message.isNotEmpty()) {
                return@fromCallable message
            }
            throw Exception(ErrorCode.PARAMETERS_WRONG)
        }
    }

}