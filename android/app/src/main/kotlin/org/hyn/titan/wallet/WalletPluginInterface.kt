package org.hyn.titan.wallet

import android.content.Context
import com.google.gson.Gson
import com.google.protobuf.ByteString
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.reactivex.Flowable
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import org.hyn.titan.ErrorCode
import org.hyn.titan.utils.md5
import org.hyn.titan.utils.toHex
import org.hyn.titan.utils.toHexByteArray
import org.hyn.titan.wallet.bitcoin.BitNumeric
import org.hyn.titan.wallet.bitcoin.BitcoinTransEntity
import org.hyn.titan.wallet.crypto.SecureRandomUtils
import timber.log.Timber
import wallet.core.java.AnySigner
import wallet.core.jni.*
import wallet.core.jni.proto.Bitcoin
import java.io.File


class WalletPluginInterface(): FlutterPlugin {
    //val HYNDerivationPath = "m/44'/546'/0'/0"
    //private val secureRandom by lazy { SecureRandomUtils.secureRandom() }

    init {
        System.loadLibrary("TrustWalletCore")
    }

    private var methodChannel: MethodChannel? = null
    private val sChannelName = "org.hyn.titan/wallet_call_channel"
    private var context: Context? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel = MethodChannel(
                binding.flutterEngine.dartExecutor.binaryMessenger, sChannelName)
        context = binding.applicationContext
        methodChannel!!.setMethodCallHandler { call, result ->
            setMethodCallHandler(call, result)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel?.setMethodCallHandler(null)
        methodChannel = null
    }

//    //ropsten api
//    private val ETH_ROPSTEN_API = "https://ropsten.infura.io/v3/23df5e05a6524e9abfd20fb6297ee226"
//    //main net api
//    private val ETH_MAIN_API = "https://mainnet.infura.io/v3/23df5e05a6524e9abfd20fb6297ee226"

//    private val objectMapper by lazy {
//        val om = ObjectMapper()
//        om.configure(JsonParser.Feature.ALLOW_UNQUOTED_FIELD_NAMES, true)
//        om.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false)
//        om
//    }


    fun setMethodCallHandler(call: MethodCall, result: MethodChannel.Result): Boolean {
        return when (call.method) {
            /*产生助记词*/
//            "wallet_make_mnemonic" -> {
//                val initialEntropy = ByteArray(16)
//                secureRandom.nextBytes(initialEntropy)
//                val mnemonic = MnemonicUtils.generateMnemonic(initialEntropy)
//                result.success(mnemonic)
//                true
//            }
            /*通过助记词保存、导入*/
            "wallet_import_mnemonic" -> {
                val name = call.argument<String>("name")
                val password = call.argument<String>("password")
                val mnemonic = call.argument<String>("mnemonic")
                val activeCoins = call.argument<List<Int>>("activeCoins")
                if (name != null && password != null && mnemonic != null) {
                    val path = importByMnemonic(mnemonic, name, password, KeyStoreUtil.parseCoinTypes(activeCoins))
                    result.success(path)
                } else {
                    result.error(ErrorCode.PARAMETERS_WRONG, "parameters error", null)
                }
                true
            }
            /*通过私钥Hex导入， 导入具体的token*/
            "wallet_import_prvKey" -> {
                val name = call.argument<String>("name")
                val password = call.argument<String>("password")
                val prvKeyHex = call.argument<String>("prvKeyHex")
                val coinTypeValue = call.argument<Int?>("coinTypeValue")

                val coinType = KeyStoreUtil.parseCoinType(coinTypeValue)

                if (name != null && password != null && prvKeyHex != null) {
                    val path = importByPrvKey(prvKeyHex, name, password, coinType)
                    result.success(path)
                } else {
                    result.error(ErrorCode.PARAMETERS_WRONG, "parameters error", null)
                }
                true
            }
            /*通过Keystore Json导入*/
            "wallet_import_json" -> {
                val name = call.argument<String>("name")
                val password = call.argument<String>("password")
                val newPassword = call.argument<String>("newPassword")
                val keyStoreJson = call.argument<String>("keyStoreJson")
                val activeCoins = call.argument<List<Int>>("activeCoins")

                if (name != null && password != null && keyStoreJson != null && newPassword != null) {
                    Flowable.fromCallable {
                        saveKeyStoreJson(keyStoreJson, name, password, newPassword, KeyStoreUtil.parseCoinTypes(activeCoins))
                    }
                            .subscribeOn(Schedulers.io())
                            .observeOn(AndroidSchedulers.mainThread())
                            .subscribe({
                                result.success(it)
                            }, {
                                it.printStackTrace()
                                result.error(ErrorCode.PASSWORD_WRONG, it.message, null)
                            })
                } else {
                    result.error(ErrorCode.PARAMETERS_WRONG, "parameters error", null)
                }
                true
            }
            /*加载一个keystore*/
            "wallet_load_keystore" -> {
                val fileName = call.argument<String>("fileName")
                if (fileName == null) {
                    result.error(ErrorCode.PARAMETERS_WRONG, "fileName cannot be null", null)
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
                val password = call.argument<String>("password")
                val coinTypeValue = call.argument<Int?>("coinTypeValue")

                val coinType = KeyStoreUtil.parseCoinType(coinTypeValue)
                if (fileName == null) {
                    result.error(ErrorCode.PARAMETERS_WRONG, "fileName cannot be null", null)
                    return true
                }
                if (password == null) {
                    result.error(ErrorCode.PARAMETERS_WRONG, "password cannot be null", null)
                    return true
                }

                val prvKeyHex = KeyStoreUtil.getPrvKey(KeyStoreUtil.getKeyStorePath(context!!, fileName), password, coinType)
                if (prvKeyHex == null) {
                    result.error(ErrorCode.PASSWORD_WRONG, "password is wrong", null)
                    return true
                }

                val ret = File(KeyStoreUtil.getKeyStorePath(context!!, fileName)).delete()
                result.success(ret)

                true
            }
            /*获取本地keystore*/
            "wallet_all_keystore" -> {
                val listPath = KeyStoreUtil.getKeyStoreDir(context!!).list { dir, name -> isTrustWallet(name)/* || isV3KeyStore(name)*/ }
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
            "wallet_update" -> {
                val oldPassword = call.argument<String>("oldPassword")
                val newPassword = call.argument<String>("newPassword")
                val fileName = call.argument<String>("fileName")
                val activeCoins = call.argument<List<Int>>("activeCoins")

                if (oldPassword == null) {
                    result.error(ErrorCode.PARAMETERS_WRONG, "old password should not be null", null)
                    return true
                }
                if (newPassword == null) {
                    result.error(ErrorCode.PARAMETERS_WRONG, "new password should not be null", null)
                    return true
                }
                if (fileName == null) {
                    result.error(ErrorCode.PARAMETERS_WRONG, "fileName should not be null", null)
                    return true
                }

                //trust wallet's json
                if (isTrustWallet(fileName)) {
                    val storedKey = StoredKey.load(KeyStoreUtil.getKeyStorePath(context!!, fileName))
                    if (storedKey == null) {
                        result.error(ErrorCode.UNKNOWN_ERROR, "file not exist.", null)
                        return true
                    }
                    val name = call.argument<String>("name") ?: storedKey.name()

                    val coins = KeyStoreUtil.parseCoinTypes(activeCoins)
                    val firstCoin = if (coins.isNotEmpty()) coins[0] else CoinType.ETHEREUM

                    val prvKey = KeyStoreUtil.getPrvKey(storedKey, oldPassword, firstCoin)
                    if (prvKey == null) {
                        result.error(ErrorCode.PASSWORD_WRONG, "old password error.", null)
                    } else {
                        if (storedKey.isMnemonic) {
                            var mnemonic = storedKey.decryptMnemonic(oldPassword.toByteArray());
                            if (mnemonic == null) {
                                mnemonic = storedKey.decryptMnemonic(oldPassword.toHexByteArray())
                            }
                            if (mnemonic.isNullOrEmpty()) {
                                result.error(ErrorCode.PASSWORD_WRONG, "old password error.", null)
                                return true
                            }
                            importByMnemonicOverwriteSave(mnemonic, name, newPassword, coins, fileName)
                            //delete old file
                            result.success(fileName)
                        } else {
                            importByPrvKeyOverwriteSave(prvKey, name, newPassword, firstCoin, fileName)
                            //delete old file
                            result.success(fileName)
                        }
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
                val coinTypeValue = call.argument<Int?>("coinTypeValue")

                val coinType = KeyStoreUtil.parseCoinType(coinTypeValue)

                if (fileName != null && password != null) {
                    val prvKeyHex = KeyStoreUtil.getPrvKey(KeyStoreUtil.getKeyStorePath(context!!, fileName), password, coinType)
                    if (prvKeyHex != null) {
                        result.success(prvKeyHex)
                    } else {
                        result.error(ErrorCode.PASSWORD_WRONG, "password error.", null)
                    }
                } else {
                    result.error(ErrorCode.PASSWORD_WRONG, "file not exist.", null)
                }
                true
            }
            /*导出助记词*/
            "wallet_getMnemonic" -> {
                val password = call.argument<String>("password")
                val fileName = call.argument<String>("fileName")
                if (fileName != null && password != null) {
                    if (isTrustWallet(fileName)) {
                        Timber.i("-加载keystore文件 ${KeyStoreUtil.getKeyStorePath(context!!, fileName)}")
                        val storedKey = StoredKey.load(KeyStoreUtil.getKeyStorePath(context!!, fileName))
                        if (storedKey.isMnemonic) {
                            var mnemonic = storedKey.decryptMnemonic(password.toByteArray())
                            if (mnemonic == null) {
                                mnemonic = storedKey.decryptMnemonic(password.toHexByteArray())
                            }
                            if (mnemonic.isNullOrEmpty()) {
                                result.error(ErrorCode.PASSWORD_WRONG, "wrong password.", null)
                            } else {
                                result.success(mnemonic)
                            }
                            return true
                        }
                    }
                    result.error(ErrorCode.UNKNOWN_ERROR, "cannot get mnemonic.", null)
                } else {
                    result.error(ErrorCode.PARAMETERS_WRONG, "file not exist.", null)
                }
                true
            }
            /*比特币签名*/
            "bitcoinSign" -> {
                val transJson = call.argument<String>("transJson")
                val bitcoinTransEntity: BitcoinTransEntity = Gson().fromJson(transJson, BitcoinTransEntity::class.java)
                signBitcoin(bitcoinTransEntity, result)
                true
            }
            /*比特币激活*/
            "bitcoinActive" -> {
                val password = call.argument<String>("password")
                val fileName = call.argument<String>("fileName")
                if (fileName != null && password != null) {
                    if (isTrustWallet(fileName)) {
                        Timber.i("-加载keystore文件 ${KeyStoreUtil.getKeyStorePath(context!!, fileName)}")
                        val storedKey = StoredKey.load(KeyStoreUtil.getKeyStorePath(context!!, fileName))
                        if (storedKey.isMnemonic) {
                            var mnemonic = storedKey.decryptMnemonic(password.toByteArray())
                            if (mnemonic == null) {
                                mnemonic = storedKey.decryptMnemonic(password.toHexByteArray())
                            }
                            if (mnemonic.isNullOrEmpty()) {
                                result.error(ErrorCode.PASSWORD_WRONG, "wrong password.", null)
                            } else {
                                val hdWallet = HDWallet(mnemonic, "")
                                storedKey.accountForCoin(CoinType.BITCOIN, hdWallet)
                                val savePath = KeyStoreUtil.getKeyStoreDir(context!!).absolutePath + File.separator + fileName
                                Timber.i("-保存keystore文件 $fileName")
                                storedKey.store(savePath)

                                result.success(fileName)
                            }
                            return true
                        }
                    }
                    result.error(ErrorCode.UNKNOWN_ERROR, "cannot get mnemonic.", null)
                } else {
                    result.error(ErrorCode.PARAMETERS_WRONG, "file not exist.", null)
                }
                true
            }
            else -> false
        }
    }

    private fun signBitcoin(bitcoinTransEntity: BitcoinTransEntity, result: MethodChannel.Result) {
        val storedKey = StoredKey.load(KeyStoreUtil.getKeyStorePath(context!!, bitcoinTransEntity.fileName))
        if (storedKey.isMnemonic) {
            var mnemonic = storedKey.decryptMnemonic(bitcoinTransEntity.password.toByteArray())
            if (mnemonic == null) {
                mnemonic = storedKey.decryptMnemonic(bitcoinTransEntity.password.toHexByteArray())
            }
            if (mnemonic.isNullOrEmpty()) {
                result.error(ErrorCode.PASSWORD_WRONG, "wrong password.", null)
            } else {
                val wallet = HDWallet(mnemonic, "")
                val coinBtc: CoinType = CoinType.BITCOIN
                val toAddress = bitcoinTransEntity.toAddress
                val changeAddress = bitcoinTransEntity.change.address

                val input = Bitcoin.SigningInput.newBuilder().apply {
                    this.amount = bitcoinTransEntity.amount
                    this.hashType = BitcoinSigHashType.ALL.value()
                    this.toAddress = toAddress
                    this.changeAddress = changeAddress
                    this.byteFee = bitcoinTransEntity.fee
                    this.coinType = coinBtc.value()
                }

                bitcoinTransEntity.utxo.forEach {
                    //common
                    val secretPrivateKeyBtc = wallet.getKey("m/84'/0'/0'/${it.sub}/${it.index}")
                    val script = BitcoinScript.buildForAddress(it.address, coinBtc)
                    val scriptHash = script.matchPayToWitnessPublicKeyHash()

                    //utxo
                    val utxoTxId = BitNumeric.hexStringToByteArray(it.txHash)
                    utxoTxId.reverse()
                    val outPoint = Bitcoin.OutPoint.newBuilder().apply {
                        this.hash = ByteString.copyFrom(utxoTxId)
                        this.index = it.txOutputN
                        this.sequence = Long.MAX_VALUE.toInt()
                    }.build()
                    val utxo = Bitcoin.UnspentTransaction.newBuilder().apply {
                        this.amount = it.value
                        this.outPoint = outPoint
                        this.script = ByteString.copyFrom(script.data())
                    }.build()
                    input.addUtxo(utxo)

                    //input
                    input.addPrivateKey(ByteString.copyFrom(secretPrivateKeyBtc.data()))
                    input.putScripts(BitNumeric.toHexString(scriptHash), ByteString.copyFrom(BitcoinScript.buildPayToPublicKeyHash(scriptHash).data()))
                }

                val plan = AnySigner.plan(input.build(), CoinType.BITCOIN, Bitcoin.TransactionPlan.parser())
                input.plan = plan
                val output = AnySigner.sign(input.build(), CoinType.BITCOIN, Bitcoin.SigningOutput.parser())

                val signedTransaction = output.encoded?.toByteArray()
                result.success(BitNumeric.cleanHexPrefix(BitNumeric.toHexString(signedTransaction)))
                return
            }
            result.error(ErrorCode.UNKNOWN_ERROR, "sign raw error", null)
        } else {
            result.error(ErrorCode.UNKNOWN_ERROR, "cannot get mnemonic.", null)
        }
    }

    /**
     * 保存助记词成为keystore
     */
    private fun importByMnemonic(mnemonic: String, name: String, password: String, coins: List<CoinType>): String {
        val firstCoin = if (coins.isNotEmpty()) coins[0] else CoinType.ETHEREUM
        var storedKey = StoredKey.importHDWallet(mnemonic, name, password.toByteArray(), firstCoin)
        if (storedKey == null) {
            storedKey = StoredKey.importHDWallet(mnemonic, name, password.toHexByteArray(), firstCoin)
        }
        //active coins
        var hdWallet = storedKey.wallet(password.toByteArray())
        if (hdWallet == null) {
            hdWallet = storedKey.wallet(password.toHexByteArray())
        }
        if (hdWallet != null) {
            for (coin in coins) {
                storedKey.accountForCoin(coin, hdWallet)
            }

            //add hyn coin base info to local
//            val privateKey = hdWallet.getKey(HYNDerivationPath)
//            val pubKey = privateKey.getPublicKeySecp256k1(false)
//            val harmonyAddress = CoinType.HARMONY.deriveAddressFromPublicKey(pubKey)
//            val addressLib = Mobile_lib.newAddressLib()
//            val hynAddress = addressLib.publicKeyToHynAddress(pubKey.description(), true);
//            Timber.i("HYN address is : %s, harmony address %s", hynAddress, harmonyAddress)
        }

        return saveStoredKeyToLocal(storedKey)
    }

    /**
     * 保存助记词成为keystore
     */
    private fun importByMnemonicOverwriteSave(mnemonic: String, name: String, password: String, coins: List<CoinType>, fileName: String): String {
        val firstCoin = if (coins.isNotEmpty()) coins[0] else CoinType.ETHEREUM
        var storedKey = StoredKey.importHDWallet(mnemonic, name, password.toByteArray(), firstCoin)
        if (storedKey == null) {
            storedKey = StoredKey.importHDWallet(mnemonic, name, password.toHexByteArray(), firstCoin)
        }
        //active coins
        var hdWallet = storedKey.wallet(password.toByteArray())
        if (hdWallet == null) {
            hdWallet = storedKey.wallet(password.toHexByteArray())
        }
        if (hdWallet != null) {
            for (coin in coins) {
                storedKey.accountForCoin(coin, hdWallet)
            }
        }

        val path = overwriteSaveStoredKeyToLocal(storedKey, fileName)
        return path
    }

    /**
     * 保存私钥成为keystore， 私钥格式: 私钥二进制的Hex String
     */
    private fun importByPrvKey(prvKeyHex: String, name: String, password: String, coinType: CoinType): String {
        return importByPrvKey(prvKeyHex.toByteArray(), name, password, coinType)
    }

    private fun importByPrvKey(bytes: ByteArray, name: String, password: String, coinType: CoinType): String {
        var storedKey = StoredKey.importPrivateKey(bytes, name, password.toByteArray(), coinType)
        if (storedKey == null) {
            storedKey = StoredKey.importPrivateKey(bytes, name, password.toHexByteArray(), coinType)
        }
        Timber.i("storedKey activeAccount count ${storedKey.accountCount()}, 密码: $password, 私钥: ${bytes.toHex()}")
        return saveStoredKeyToLocal(storedKey)
    }

    /**
     * 保存keystore json
     */
    private fun saveKeyStoreJson(keyStoreJson: String, name: String, password: String, newPassword: String, coins: List<CoinType>): String {
        var storedKey = StoredKey.importJSON(keyStoreJson.toByteArray())
        if (storedKey == null) {
            storedKey = StoredKey.importJSON(keyStoreJson.toHexByteArray())
        }
        try {
            //hack here, storedKey.decryptPrivateKey crash when password is wrong???
            val firstCoin = if (coins.isNotEmpty()) coins[0] else CoinType.ETHEREUM
            var tokenPrvKey = storedKey.privateKey(firstCoin, password.toByteArray())
            if (tokenPrvKey == null) {
                tokenPrvKey = storedKey.privateKey(firstCoin, password.toHexByteArray())
            }
            if (tokenPrvKey != null) {   //the password is right
                var prvKeyBytes = storedKey.decryptPrivateKey(password.toByteArray())
                if (prvKeyBytes == null) {
                    prvKeyBytes = storedKey.decryptPrivateKey(password.toHexByteArray())
                }
                if (prvKeyBytes != null) {
                    val mnemonic = String(prvKeyBytes, Charsets.US_ASCII)
                    val isMnemonic = HDWallet.isValid(mnemonic)
                    return if (isMnemonic) {
                        importByMnemonic(mnemonic, name, newPassword, coins)
                    } else {
                        importByPrvKey(prvKeyBytes, name, newPassword, firstCoin)
                    }
                }
            }
        } catch (e: Error) {
            e.printStackTrace()
        }
        throw Exception("Invalid password")
    }


    private fun saveStoredKeyToLocal(storedKey: StoredKey): String {
        val saveName = "${storedKey.name()}${System.currentTimeMillis()}".md5() + ".keystore"
        val savePath = KeyStoreUtil.getKeyStoreDir(context!!).absolutePath + File.separator + saveName
        Timber.i("-保存keystore文件 $saveName")
        storedKey.store(savePath)
        return saveName
    }

    private fun importByPrvKeyOverwriteSave(prvKeyHex: String, name: String, password: String, coinType: CoinType, fileName: String): String {
        var storedKey = StoredKey.importPrivateKey(prvKeyHex.toByteArray(), name, password.toByteArray(), coinType)
        if (storedKey == null) {
            storedKey = StoredKey.importPrivateKey(prvKeyHex.toByteArray(), name, password.toHexByteArray(), coinType)
        }
        Timber.i("storedKey activeAccount count ${storedKey.accountCount()}, 密码: $password, 私钥: ${prvKeyHex.toByteArray().toHex()}")
        val path = overwriteSaveStoredKeyToLocal(storedKey, fileName)
        return path
    }

    private fun overwriteSaveStoredKeyToLocal(storedKey: StoredKey, fileName: String): String {
        val savePath = KeyStoreUtil.getKeyStoreDir(context!!).absolutePath + File.separator + fileName
        Timber.i("-保存keystore文件 $fileName")
        storedKey.store(savePath)
        return fileName
    }

    private fun loadKeyStore(fileName: String): Map<String, Any>? {
        val storedKey = StoredKey.load(KeyStoreUtil.getKeyStorePath(context!!, fileName))

        if (storedKey != null) {
            val map = HashMap<String, Any>()
            val accounts = ArrayList<HashMap<String, Any>>()
            val count = storedKey.accountCount()
            for (i in 0 until count) {
                val accountMap = HashMap<String, Any>()
                val account = storedKey.account(i)
                accountMap["address"] = account.address()
                accountMap["derivationPath"] = account.derivationPath()
                accountMap["coinType"] = account.coin().value()
                if (accountMap["coinType"] == CoinType.BITCOIN.value()) {
                    accountMap["extendedPublicKey"] = account.extendedPublicKey()
                }
                accounts.add(accountMap)
            }
            //因为trust wallet还没有支持hyn主链币，这里手动加
            //TODO add hyn mainnet coin

            map["accounts"] = accounts

            map["name"] = storedKey.name()
            map["fileName"] = fileName
            map["isMnemonic"] = storedKey.isMnemonic
            map["identifier"] = storedKey.identifier()
            map["accountCount"] = storedKey.accountCount()
            return map
        }
        return null
    }

    private fun isTrustWallet(fileName: String): Boolean {
        return fileName.endsWith(".keystore")
    }
}