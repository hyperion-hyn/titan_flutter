package org.hyn.titan.wallet

import android.content.Context
import com.fasterxml.jackson.core.JsonParser
import com.fasterxml.jackson.databind.DeserializationFeature
import com.fasterxml.jackson.databind.ObjectMapper
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.reactivex.Flowable
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import org.hyn.titan.ErrorCode
import org.hyn.titan.utils.md5
import org.hyn.titan.utils.toHex
import org.hyn.titan.utils.toHexByteArray
import org.hyn.titan.wallet.crypto.SecureRandomUtils
import org.hyn.titan.wallet.erc20.HyperionToken
import org.web3j.crypto.*
import org.web3j.protocol.Web3j
import org.web3j.protocol.core.DefaultBlockParameterName
import org.web3j.protocol.http.HttpService
import org.web3j.tx.ReadonlyTransactionManager
import org.web3j.tx.gas.DefaultGasProvider
import org.web3j.utils.Numeric
import timber.log.Timber
import wallet.core.jni.CoinType
import wallet.core.jni.StoredKey
import java.io.File
import java.io.IOException
import java.lang.Exception
import java.math.BigInteger

class WalletPluginInterface(private val context: Context, private val binaryMessenger: BinaryMessenger) {
    init {
        System.loadLibrary("TrustWalletCore")
    }

    //ropsten api
    private val ETH_ROPSTEN_API = "https://ropsten.infura.io/v3/23df5e05a6524e9abfd20fb6297ee226"
    //main net api
    private val ETH_MAIN_API = "https://mainnet.infura.io/v3/23df5e05a6524e9abfd20fb6297ee226"

    private val objectMapper by lazy {
        val om = ObjectMapper()
        om.configure(JsonParser.Feature.ALLOW_UNQUOTED_FIELD_NAMES, true)
        om.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false)
        om
    }
    private val secureRandom = SecureRandomUtils.secureRandom()

    fun setMethodCallHandler(call: MethodCall, result: MethodChannel.Result): Boolean {
        return when (call.method) {
            /*产生助记词*/
            "wallet_make_mnemonic" -> {
                val initialEntropy = ByteArray(16)
                secureRandom.nextBytes(initialEntropy)
                val mnemonic = MnemonicUtils.generateMnemonic(initialEntropy)
                result.success(mnemonic)
                true
            }
            /*通过助记词保存、导入*/
            "wallet_import_mnemonic" -> {
                val name = call.argument<String>("name")
                val password = call.argument<String>("password")
                val mnemonic = call.argument<String>("mnemonic")
                if (name != null && password != null && mnemonic != null) {
                    val path = saveMnemonic(mnemonic, name, password)
                    result.success(path)
                } else {
                    result.error(ErrorCode.UNKNOWN_ERROR, "parameters error", null)
                }
                true
            }
            /*通过私钥Hex导入*/
            "wallet_import_prvKey" -> {
                val name = call.argument<String>("name")
                val password = call.argument<String>("password")
                val prvKeyHex = call.argument<String>("prvKeyHex")
                if (name != null && password != null && prvKeyHex != null) {
                    val path = savePrvKey(prvKeyHex, name, password)
                    result.success(path)
                } else {
                    result.error(ErrorCode.UNKNOWN_ERROR, "parameters error", null)
                }
                true
            }
            /*通过Keystore Json导入*/
            "wallet_import_json" -> {
                val name = call.argument<String>("name")
                val password = call.argument<String>("password")
                val keyStoreJson = call.argument<String>("keyStoreJson")
                if (name != null && password != null && keyStoreJson != null) {
                    Flowable.fromCallable {
                        saveKeyStoreJson(keyStoreJson, name, password)
                    }
                            .subscribeOn(Schedulers.io())
                            .observeOn(AndroidSchedulers.mainThread())
                            .subscribe({
                                result.success(it)
                            }, {
                                it.printStackTrace()
                                result.error(ErrorCode.UNKNOWN_ERROR, it.message, null)
                            })
                } else {
                    result.error(ErrorCode.UNKNOWN_ERROR, "parameters error", null)
                }
                true
            }
            /*加载一个keystore*/
            "wallet_load_keystore" -> {
                val fileName = call.argument<String>("fileName")
                if (fileName == null) {
                    result.error(ErrorCode.UNKNOWN_ERROR, "fileName cannot be null", null)
                } else {
                    val map = loadKeyStore(fileName)
                    if (map != null) {
                        result.success(map)
                    } else {
                        result.error(ErrorCode.UNKNOWN_ERROR, "load keystore error", null)
                    }
                }
                true
            }
            /*删除钱包*/
            "wallet_delete" -> {
                val fileName = call.argument<String>("fileName")
                if (fileName != null) {
                    val ret = File(getKeyStorePath(fileName)).delete()
                    result.success(ret)
                } else {
                    result.error(ErrorCode.UNKNOWN_ERROR, "fileName cannot be null.", null)
                }
                true
            }
            /*获取本地keystore*/
            "wallet_all_keystore" -> {
                val listPath = getKeyStoreDir().list { dir, name -> isTrustWallet(name) || isV3KeyStore(name) }
                val ksList: ArrayList<Map<String, Any>> = ArrayList()
                for (path in listPath) {
//                    Timber.i("path $path")
                    val map = loadKeyStore(path)
                    if (map != null) {
                        ksList.add(map)
                    }
                }
                result.success(ksList)
                true
            }
            /*修改密码*/
            "wallet_change_password" -> {
                val oldPassword = call.argument<String>("oldPassword")
                val newPassword = call.argument<String>("newPassword")
                val fileName = call.argument<String>("fileName")
                if (oldPassword == null) {
                    result.error(ErrorCode.UNKNOWN_ERROR, "old password should not be null", null)
                    return true
                }
                if (newPassword == null) {
                    result.error(ErrorCode.UNKNOWN_ERROR, "new password should not be null", null)
                    return true
                }
                if (fileName == null) {
                    result.error(ErrorCode.UNKNOWN_ERROR, "fileName should not be null", null)
                    return true
                }

                //trust wallet's json
                if (isTrustWallet(fileName)) {
                    val storedKey = StoredKey.load(getKeyStorePath(fileName))
                    if (storedKey == null) {
                        result.error(ErrorCode.UNKNOWN_ERROR, "file not exist.", null)
                        return true
                    }
                    val name = call.argument<String>("name") ?: storedKey.name();

                    val wallet = storedKey.wallet(oldPassword)
                    if (wallet == null) {
                        result.error(ErrorCode.PASSWORD_WRONG, "old password error.", null)
                    } else {
                        if (storedKey.isMnemonic) {
                            val mnemonic = wallet.mnemonic()
                            if (mnemonic.isNullOrEmpty()) {
                                result.error(ErrorCode.PASSWORD_WRONG, "old password error.", null)
                                return true
                            }
                            val rename = saveMnemonic(mnemonic, name, newPassword)
                            //delete old file
                            File(getKeyStorePath(fileName)).delete()
                            result.success(rename)
                        } else {
                            val prvKey = wallet.getKeyForCoin(CoinType.ETHEREUM)
                            if (prvKey == null) {
                                result.error(ErrorCode.PASSWORD_WRONG, "old password error.", null)
                                return true
                            }
                            val rename = savePrvKey(prvKey.data().toHex(), name, newPassword)
                            //delete old file
                            File(getKeyStorePath(fileName)).delete()
                            result.success(rename)
                        }
                    }
                } else if (isV3KeyStore(fileName)) { //v3keystore json
                    try {
                        val credentials = WalletUtils.loadCredentials(oldPassword, getKeyStorePath(fileName))
                        val rename = WalletUtils.generateWalletFile(newPassword, credentials.ecKeyPair, getKeyStoreDir(), true)
                        //delete old file
                        File(getKeyStorePath(fileName)).delete()
                        result.success(rename)
                    } catch (e: IOException) {
                        e.printStackTrace()
                        result.error(ErrorCode.UNKNOWN_ERROR, e.message, null)
                        return true
                    } catch (e: CipherException) {
                        e.printStackTrace()
                        result.error(ErrorCode.UNKNOWN_ERROR, e.message, null)
                        return true
                    }

                } else {
                    result.error(ErrorCode.UNKNOWN_ERROR, "$fileName is not a keystore file", null)
                    return true
                }
                true
            }
            /*导出私钥*/
            "wallet_getPrivateKey" -> {
                val password = call.argument<String>("password")
                val fileName = call.argument<String>("fileName")
                if (fileName != null && password != null) {
                    val prvKeyHex = getPrvKey(fileName, password)
                    if (prvKeyHex != null) {
                        result.success(prvKeyHex)
                    } else {
                        result.error(ErrorCode.PASSWORD_WRONG, "password error.", null)
                    }
                } else {
                    result.error(ErrorCode.UNKNOWN_ERROR, "file not exist.", null)
                }
                true
            }
            /*导出助记词*/
            "wallet_getMnemonic" -> {
                val password = call.argument<String>("password")
                val fileName = call.argument<String>("fileName")
                if (fileName != null && password != null) {
                    if (isTrustWallet(fileName)) {
                        val storedKey = StoredKey.load(getKeyStorePath(fileName))
                        if (storedKey.isMnemonic) {
                            val wallet = storedKey.wallet(password)
                            if (wallet != null) {
                                val mnemonic = storedKey.decryptMnemonic(password)
                                result.success(mnemonic)
                                return true
                            } else {
                                result.error(ErrorCode.PASSWORD_WRONG, "wrong password.", null)
                                return true
                            }
                        }
                    }
                    result.error(ErrorCode.UNKNOWN_ERROR, "cannot get mnemonic.", null)
                } else {
                    result.error(ErrorCode.UNKNOWN_ERROR, "file not exist.", null)
                }
                true
            }
            /*获取余额*/
            "wallet_getBalance" -> {
                val address = call.argument<String>("address")
                val coinType = call.argument<Int>("coinType")
                val erc20ContractAddress = call.argument<String>("erc20ContractAddress")
                val isMainNet = call.argument<Boolean>("isMainNet") ?: true
                if (address == null || coinType == null) {
                    result.error(ErrorCode.UNKNOWN_ERROR, "parameters error", null)
                } else {
                    if (coinType == CoinType.ETHEREUM.value()) {
                        if (erc20ContractAddress != null) {
                            val erc20 = buildHyperionToken(erc20ContractAddress, isMainNet, fromAddress = address)
                            erc20.balanceOf(address).flowable()
                                    .subscribeOn(Schedulers.io())
                                    .observeOn(AndroidSchedulers.mainThread())
                                    .subscribe({
                                        result.success(Numeric.toHexStringNoPrefix(it))
                                    }, {
                                        it.printStackTrace()
                                        result.error(ErrorCode.UNKNOWN_ERROR, it.message, null)
                                    })
                        } else {
                            //get ethereum balance
                            val web3j = buildWeb3j(isMainNet)
                            web3j.ethGetBalance(address, DefaultBlockParameterName.LATEST).flowable()
                                    .subscribeOn(Schedulers.io())
                                    .observeOn(AndroidSchedulers.mainThread())
                                    .subscribe({
                                        result.success(Numeric.toHexStringNoPrefix(it.balance))
                                    }, {
                                        it.printStackTrace()
                                        result.error(ErrorCode.UNKNOWN_ERROR, it.message, null)
                                    })
                        }
                    } else {
                        //Other coin are not implements
                        result.error(ErrorCode.UNKNOWN_ERROR, "coinType $coinType are not implemented", null)
                    }
                }
                true
            }
            "wallet_ethGasPrice" -> {
                val isMainNet = call.argument<Boolean>("isMainNet") ?: true
                val web3j = buildWeb3j(isMainNet)
                web3j.ethGasPrice().flowable()
                        .subscribeOn(Schedulers.io())
                        .observeOn(AndroidSchedulers.mainThread())
                        .subscribe({
                            result.success(Numeric.toHexStringNoPrefix(it.gasPrice))
                        }, {
                            it.printStackTrace()
                            result.error(ErrorCode.UNKNOWN_ERROR, it.message, null)
                        })
                true
            }
            "wallet_transfer" -> {
                val password = call.argument<String>("password")
                val fileName = call.argument<String>("fileName")
                val fromAddress = call.argument<String>("fromAddress")
                val toAddress = call.argument<String>("toAddress")
                val amount = call.argument<String>("amount")
                val coinType = call.argument<Int>("coinType")
                val erc20ContractAddress = call.argument<String>("erc20ContractAddress")
                val isMainNet = call.argument<Boolean>("isMainNet") ?: true
                val data = call.argument<String>("data")

                if (password != null && fileName != null && fromAddress != null && toAddress != null && amount != null && coinType != null) {
                    if (coinType == CoinType.ETHEREUM.value()) {
                        val prvKeyHex = getPrvKey(fileName, password)
                        if (prvKeyHex != null) {
                            val web3j = buildWeb3j(isMainNet)
                            Flowable.fromCallable {
                                if (erc20ContractAddress.isNullOrEmpty()) {
                                    return@fromCallable EthHelper.transferETH(web3j, fromAddress, prvKeyHex, toAddress, BigInteger(amount, 16), data)
                                } else {
                                    return@fromCallable EthHelper.transferToken(web3j, prvKeyHex, fromAddress, toAddress, erc20ContractAddress, BigInteger(amount, 16))
                                }
                            }
                                    .subscribeOn(Schedulers.io())
                                    .observeOn(AndroidSchedulers.mainThread())
                                    .subscribe({ txHash ->
                                        result.success(txHash)
                                    }, {
                                        it.printStackTrace()
                                        result.error(ErrorCode.UNKNOWN_ERROR, it.message, null)
                                    })
                        } else {
                            result.error(ErrorCode.PASSWORD_WRONG, "password error", null)
                        }
                    } else {
                        result.error(ErrorCode.UNKNOWN_ERROR, "coinType $coinType are not implemented", null)
                    }
                }
                true
            }
            /*计算油费*/
            "wallet_estimateGas" -> {
                val fromAddress = call.argument<String>("fromAddress")
                val toAddress = call.argument<String>("toAddress")
                val amount = call.argument<String>("amount")
                val coinType = call.argument<Int>("coinType")
                val erc20ContractAddress = call.argument<String>("erc20ContractAddress")
                val isMainNet = call.argument<Boolean>("isMainNet") ?: true
                if (fromAddress != null && toAddress != null && amount != null && coinType != null) {
                    if (coinType == CoinType.ETHEREUM.value()) {
                        val web3j = buildWeb3j(isMainNet)
                        Flowable.fromCallable {
                            if (erc20ContractAddress.isNullOrEmpty()) {
                                return@fromCallable EthHelper.ethTransferEstimateGas(web3j, fromAddress, toAddress, BigInteger(amount, 16))
                            } else {
                                return@fromCallable EthHelper.tokenTransferEstimateGas(web3j, fromAddress, toAddress, erc20ContractAddress, BigInteger(amount, 16))
                            }
                        }
                                .subscribeOn(Schedulers.io())
                                .observeOn(AndroidSchedulers.mainThread())
                                .subscribe({
                                    result.success(Numeric.toHexStringNoPrefix(it))
                                }, {
                                    it.printStackTrace()
                                    result.error(ErrorCode.UNKNOWN_ERROR, it.message, null)
                                })
                    } else {
                        result.error(ErrorCode.UNKNOWN_ERROR, "coinType $coinType are not implemented", null)
                    }
                } else {
                    result.error(ErrorCode.UNKNOWN_ERROR, "coinType $coinType are not implemented", null)
                }
                true
            }
            else -> false
        }
    }

    /**
     * 保存助记词成为keystore
     */
    private fun saveMnemonic(mnemonic: String, name: String, password: String): String {
        val storedKey = StoredKey.importHDWallet(mnemonic, name, password, CoinType.ETHEREUM)
        Timber.i("saveMnemonic activeAccount count ${storedKey.accountCount()}")
        return saveStoredKeyToLocal(storedKey)
    }

    /**
     * 保存私钥成为keystore， 私钥格式: 私钥二进制的Hex String
     */
    private fun savePrvKey(prvKeyHex: String, name: String, password: String): String {
        val storedKey = StoredKey.importPrivateKey(prvKeyHex.toHexByteArray(), name, password, CoinType.ETHEREUM)
        Timber.i("storedKey activeAccount count ${storedKey.accountCount()}")
        return saveStoredKeyToLocal(storedKey)
    }

    /**
     * 保存keystore json
     */
    private fun saveKeyStoreJson(keyStoreJson: String, name: String, password: String): String {
        return if (keyStoreJson.contains("activeAccounts")) {   //Trust Wallet json
            val storedKey = StoredKey.importJSON(keyStoreJson.toByteArray())
            Timber.i("saveKeyStoreJson activeAccount count ${storedKey.accountCount()}")
            saveStoredKeyToLocal(storedKey)
        } else {    //Treat it as v3 eth json
            val walletFile = objectMapper.readValue<WalletFile>(keyStoreJson, WalletFile::class.java)
            val credentials = Credentials.create(Wallet.decrypt(password, walletFile))
            val savePrvKeyHex = Numeric.toHexStringNoPrefix(credentials.ecKeyPair.privateKey)
            savePrvKey(savePrvKeyHex, name, password)
//            WalletUtils.generateWalletFile(password, credentials.ecKeyPair, getKeyStoreDir(), true)
        }
    }


    private fun saveStoredKeyToLocal(storedKey: StoredKey): String {
        val saveName = "${storedKey.name()}${System.currentTimeMillis()}".md5() + ".keystore"
        val savePath = getKeyStoreDir().absolutePath + File.separator + saveName
        storedKey.store(savePath)
        return saveName
    }

    private fun getKeyStorePath(fileName: String? = null): String {
        val saveName = fileName ?: ("${System.currentTimeMillis()}".md5() + ".keystore")
        val savePath = getKeyStoreDir().absolutePath + File.separator + saveName
        return savePath
    }

    /**
     * only support eth now
     */
    private fun getPrvKey(fileName: String, password: String): String? {
        if (isTrustWallet(fileName)) {    //trust wallet ks
            val storedKey = StoredKey.load(getKeyStorePath(fileName))
            val wallet = storedKey?.wallet(password)
            val prvKeyBytes = wallet?.getKeyForCoin(CoinType.ETHEREUM)
            return prvKeyBytes?.data()?.toHex()
        } else if (isV3KeyStore(fileName)) {
            val credentials = WalletUtils.loadCredentials(password, getKeyStorePath(fileName))
            if (credentials?.ecKeyPair?.privateKey != null) {
                return Numeric.toHexStringWithPrefix(credentials.ecKeyPair.privateKey)
            }
        }

        return null
    }

    private fun loadKeyStore(fileName: String): Map<String, Any>? {
        if (isTrustWallet(fileName)) {
            val map = HashMap<String, Any>()
            map["type"] = 0
            val storedKey = StoredKey.load(getKeyStorePath(fileName))

            val accounts = ArrayList<HashMap<String, Any>>()
            val count = storedKey.accountCount()
            for (i in 0 until count) {
                val accountMap = HashMap<String, Any>()
                val account = storedKey.account(i)
                accountMap["address"] = account.address()
                accountMap["derivationPath"] = account.derivationPath()
                accountMap["coinType"] = account.coin().value()
                accounts.add(accountMap)
            }
            map["accounts"] = accounts

            map["name"] = storedKey.name()
            map["fileName"] = fileName
            map["isMnemonic"] = storedKey.isMnemonic
            map["identifier"] = storedKey.identifier()
            map["accountCount"] = storedKey.accountCount()
            return map
        } else if (isV3KeyStore(fileName)) {
            val map = HashMap<String, Any>()
            map["type"] = 1
            val walletFile = objectMapper.readValue<WalletFile>(getKeyStorePath(fileName), WalletFile::class.java)

            val accountMap = HashMap<String, Any>()
            accountMap["address"] = walletFile.address
            accountMap["derivationPath"] = CoinType.ETHEREUM.derivationPath()
            accountMap["coinType"] = CoinType.ETHEREUM.value()
            map["account"] = accountMap

            map["fileName"] = fileName
            map["version"] = walletFile.version
            map["id"] = walletFile.id
            return map
        }
        return null
    }

    private fun getKeyStoreDir(): File {
        return context.getDir("keystore", Context.MODE_PRIVATE)
    }

    private fun isTrustWallet(fileName: String): Boolean {
        return fileName.endsWith(".keystore")
    }

    private fun isV3KeyStore(fileName: String): Boolean {
        return fileName.endsWith(".json")
    }

    private fun buildWeb3j(isMainNet: Boolean): Web3j {
        val api = if (isMainNet) ETH_MAIN_API else ETH_ROPSTEN_API
        return Web3j.build(HttpService(api))
    }

    /**
     * warn: prvKeyHex or fromAddress cannot be null on the same time
     */
    private fun buildHyperionToken(contractAddress: String, isMainNet: Boolean, prvKeyHex: String? = null, fromAddress: String? = null): HyperionToken {
        val web3 = buildWeb3j(isMainNet)
        val credentials = if (prvKeyHex != null) Credentials.create(prvKeyHex) else null
        if (credentials != null) {
            //TODO set gas price
            return HyperionToken.load(contractAddress, web3, credentials, DefaultGasProvider())
        } else if (fromAddress != null) {
            return HyperionToken.load(contractAddress, web3, ReadonlyTransactionManager(web3, fromAddress), DefaultGasProvider())
        }
        throw Exception("prvKeyHex or fromAddress cannot be null on the same time!")
    }
}