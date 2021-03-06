package org.hyn.titan.wallet

import android.content.Context
import org.hyn.titan.utils.md5
import org.hyn.titan.utils.toHex
import org.hyn.titan.utils.toHexByteArray
import timber.log.Timber
import wallet.core.jni.CoinType
import wallet.core.jni.StoredKey
import wallet.core.jni.PrivateKey
import java.io.File

object KeyStoreUtil {
    fun parseCoinType(coinTypeValue: Int?, default: CoinType = CoinType.ETHEREUM): CoinType {
        if (coinTypeValue == null) {
            return default
        }
        return CoinType.createFromValue(coinTypeValue) ?: default
    }

    fun parseCoinTypes(coinValues: List<Int>?): List<CoinType> {
        val coins = mutableListOf<CoinType>()
        if (coinValues != null) {
            for (coinValue in coinValues) {
                val coinType = CoinType.createFromValue(coinValue)
                if (coinType != null) {
                    coins.add(coinType)
                }
            }

        }
        return coins
    }

    /**
     * only support eth now
     */
    fun getPrvKey(filePath: String, password: String, coinType: CoinType): String? {
        val storedKey = StoredKey.load(filePath) ?: return null

        return getPrvKey(storedKey, password, coinType)
    }

    fun getPrvKey(storedKey: StoredKey, password: String, coinType: CoinType): String? {
        val bytes = getPrvKeyBytes(storedKey, password, coinType)
        return bytes?.toHex()
    }

    fun getPrvKeyEntity(filePath: String, password: String, coinType: CoinType): PrivateKey? {
        val storedKey = StoredKey.load(filePath) ?: return null
        return getPrvKeyEntity(storedKey, password, coinType)
    }

    fun isValidPassword(filePath: String, password: String, coinType: CoinType): Boolean {
        return getPrvKey(filePath, password, coinType) != null
    }

    fun isValidPassword(storedKey: StoredKey, password: String, coinType: CoinType): Boolean {
        return getPrvKey(storedKey, password, coinType) != null
    }

    private fun getPrvKeyBytes(storedKey: StoredKey, password: String, coinType: CoinType): ByteArray? {
        return if (storedKey.isMnemonic) {
            var hdWallet = storedKey.wallet(password.toByteArray())
            if(hdWallet == null){
                hdWallet = storedKey.wallet(password.toHexByteArray())
            }
            val privateKey = hdWallet?.getKeyForCoin(coinType)
            privateKey?.data()
        } else {
            var prvKey = storedKey.privateKey(coinType, password.toByteArray())
            if(prvKey == null){
                prvKey = storedKey.privateKey(coinType, password.toHexByteArray())
            }
            prvKey?.data()
        }
    }

    private fun getPrvKeyEntity(storedKey: StoredKey, password: String, coinType: CoinType): PrivateKey? {
        return if (storedKey.isMnemonic) {
            var hdWallet = storedKey.wallet(password.toByteArray())
            if(hdWallet == null){
                hdWallet = storedKey.wallet(password.toHexByteArray())
            }
            val privateKey = hdWallet?.getKeyForCoin(coinType)
            privateKey
        } else {
            var prvKey = storedKey.privateKey(coinType, password.toByteArray())
            if(prvKey == null){
                prvKey = storedKey.privateKey(coinType, password.toHexByteArray())
            }
            prvKey
        }
    }

    fun getKeyStorePath(context: Context, fileName: String? = null): String {
        val saveName = fileName ?: ("${System.currentTimeMillis()}".md5() + ".keystore")
        return getKeyStoreDir(context).absolutePath + File.separator + saveName
    }

    fun getKeyStoreDir(context: Context): File {
        return context.getDir("keystore", Context.MODE_PRIVATE)
    }

}