package org.hyn.titan.encryption

import android.content.Context
import io.reactivex.Flowable
import mobile.Cipher
import org.hyn.titan.encryption.rsa.RsaEncryption
import org.hyn.titan.utils.Numeric
import org.hyn.titan.utils.md5
import org.hyn.titan.utils.toHexByteArray
import org.hyn.titan.wallet.KeyStoreUtil
import timber.log.Timber
import wallet.core.jni.CoinType
import wallet.core.jni.StoredKey
import java.io.File
import java.security.KeyStore
import java.security.cert.X509Certificate

class EthEncryptionService(private val context: Context) : EncryptionService {
    private val cipher = Cipher()
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

    override fun generateKeyPairAndStore(expireAt: Long): Flowable<Boolean> {
        return Flowable.fromCallable {
            rsaEncryption.createKeys(context, expireAt)
            rsaEntry = rsaEncryption.keyEntry
            if (rsaEntry != null) {
                val pairs = cipher.genKeyPair().split(',')
                val prvStr = pairs[0]
                val pubStr = pairs[1]
                val encryptedPrivateStr = rsaEncryption.encrypt(prvStr)
                Timber.i("Eth public key is: $pubStr")
                sharedPreferences.edit()
                        .putString("public", pubStr)
                        .putString("private", encryptedPrivateStr)
                        .apply()

                return@fromCallable true
            }
            return@fromCallable false
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

    override fun encryptSync(comPublicKeyStr: String?, message: String, password: String, fileName: String): Map<String,String> {
        var tempPublicKey = ""
        var comPublicKey = ""
        if(comPublicKeyStr == null || comPublicKeyStr == "") {
            var privateKey = KeyStoreUtil.getPrvKeyEntity(getKeyStorePath(fileName),password,CoinType.ETHEREUM)
            var publicKeyEntity = privateKey?.getPublicKeySecp256k1(false)
            tempPublicKey = publicKeyEntity?.description() ?: ""
            comPublicKey = publicKeyEntity?.compressed()?.description() ?: ""
            if(comPublicKey.isNotEmpty()){
                comPublicKey = "0x$comPublicKey"
            }
        }else{
            tempPublicKey = cipher.deCompressPubkey(comPublicKeyStr)
            comPublicKey = comPublicKeyStr
        }
        var cipherText = cipher.encrypt(tempPublicKey, message)
            if (cipherText.isEmpty()) {
            throw Exception("encrypt error")
        }

        return mapOf("publicKey" to comPublicKey,"cipherText" to cipherText)
    }

    override fun encrypt(publicKeyStr: String?, message: String, password: String, fileName: String): Flowable<Map<String,String>> {
        return Flowable.fromCallable {
            return@fromCallable encryptSync(publicKeyStr, message, password, fileName)
        }
    }

    override fun decrypt(cipherText: String,fileName: String,password: String): Flowable<String> {
        return Flowable.fromCallable {
            var privateKey = KeyStoreUtil.getPrvKeyEntity(getKeyStorePath(fileName),password,CoinType.ETHEREUM)
            var privateKeyStr = Numeric.toHexString(privateKey?.data(),false)
//            val privateKeyStr = sharedPreferences.getString("private", null)
            if (privateKeyStr != null) {
//                val privateKeyECStr = rsaEncryption.decrypt(privateKeyStr)
                val message = cipher.decrypt(privateKeyStr, cipherText)
                if (message.isNotEmpty()) {
                    return@fromCallable message
                }
            }
            throw Exception("decrypt error")
        }
    }

    private fun getKeyStorePath(fileName: String? = null): String {
        val saveName = fileName ?: ("${System.currentTimeMillis()}".md5() + ".keystore")
        return getKeyStoreDir().absolutePath + File.separator + saveName
    }

    private fun getKeyStoreDir(): File {
        return context.getDir("keystore", Context.MODE_PRIVATE)
    }

}