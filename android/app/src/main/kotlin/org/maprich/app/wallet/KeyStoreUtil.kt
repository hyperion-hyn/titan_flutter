package org.maprich.app.wallet

import org.maprich.app.utils.toHex
import timber.log.Timber
import wallet.core.jni.CoinType
import wallet.core.jni.StoredKey

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

    fun isValidPassword(filePath: String, password: String, coinType: CoinType): Boolean {
        return getPrvKey(filePath, password, coinType) != null
    }

    fun isValidPassword(storedKey: StoredKey, password: String, coinType: CoinType): Boolean {
        return getPrvKey(storedKey, password, coinType) != null
    }

    fun getPrvKeyBytes(storedKey: StoredKey, password: String, coinType: CoinType): ByteArray? {
        return if (storedKey.isMnemonic) {
            val hdWallet = storedKey.wallet(password)
            val privateKey = hdWallet?.getKeyForCoin(coinType)
            privateKey?.data()
        } else {
            val prvKey = storedKey.privateKey(coinType, password)
            prvKey?.data()
        }
    }

}