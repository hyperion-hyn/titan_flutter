package org.hyn.titan.encryption

import android.annotation.SuppressLint
import android.content.Context
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.hyn.titan.ErrorCode
import timber.log.Timber

class EncryptionPluginInterface(): FlutterPlugin {

    /*
    private val keyPairChangeChannel by lazy { EventChannel(flutterEngine.dartExecutor.binaryMessenger, "org.hyn.titan/event_stream") }

    init {
        keyPairChangeChannel!!.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, eventSink: EventChannel.EventSink) {
                Timber.i("onListen ${arguments?.toString()}")
                cipherEventSink = eventSink
            }

            override fun onCancel(arguments: Any?) {
                Timber.i("onCancel listener ${arguments?.toString()}")
                cipherEventSink = null
            }
        })
    }


    private val encryptionService by lazy { EncryptionProvider.getDefaultEncryption(context!!) }
    */

    private var encryptionService :EncryptionService? = null
    private var cipherEventSink: EventChannel.EventSink? = null

    private var keyPairChangeChannel: EventChannel? = null
    private val keyPairChangesChannelName = "org.hyn.titan/event_stream"

    private var methodChannel: MethodChannel? = null
    private val sChannelName = "org.hyn.titan/call_channel"
    private var context: Context? = null


    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel = MethodChannel(
                binding.flutterEngine.dartExecutor.binaryMessenger, sChannelName)
        context = binding.applicationContext

        methodChannel?.setMethodCallHandler { call, result ->
            setMethodCallHandler(call, result);
        }

        encryptionService = EncryptionProvider.getDefaultEncryption(context!!)

        keyPairChangeChannel = EventChannel(
                binding.flutterEngine.dartExecutor.binaryMessenger, keyPairChangesChannelName)
        keyPairChangeChannel?.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, eventSink: EventChannel.EventSink) {
                Timber.i("onListen ${arguments?.toString()}")
                cipherEventSink = eventSink
            }

            override fun onCancel(arguments: Any?) {
                Timber.i("onCancel listener ${arguments?.toString()}")
                cipherEventSink = null
            }
        })
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel?.setMethodCallHandler(null)
        methodChannel = null

        keyPairChangeChannel = null
    }

    fun setMethodCallHandler(call: MethodCall, result: MethodChannel.Result): Boolean {
        when (call.method) {
            "initKeyPair" -> {
                initKeyPair(call, result)
                return true
            }
            "genKeyPair" -> {
                genKeyPair(call, result)
                return true
            }
            "getPublicKey" -> {
                getPublicKey(call, result)
                return true
            }
            "getExpired" -> {
                result.success(encryptionService?.expireTime)
                return true
            }
            "encrypt" -> {
                encrypt(call, result)
                return true
            }
            "decrypt" -> {
                decrypt(call, result)
                return true
            }
            "trustActiveEncrypt" -> {
                trustActiveEncrypt(call, result)
                return true
            }
            "trustEncrypt" -> {
                trustEncrypt(call, result)
                return true
            }
            "trustDecrypt" -> {
                trustDecrypt(call, result)
                return true
            }
        }
        return false
    }

    private fun initKeyPair(call: MethodCall, result: MethodChannel.Result) {
        val expired = if (call.arguments is Number) (call.arguments as Number).toLong() else 3600
        Timber.i("$expired ${call.arguments}")
        initOrCreateKeyPair(result)
    }

    private fun genKeyPair(call: MethodCall, result: MethodChannel.Result) {
        generateKey(result)
    }

    private fun getPublicKey(call: MethodCall, result: MethodChannel.Result) {
        result.success(encryptionService?.publicKey)
    }

    private fun initOrCreateKeyPair(result: MethodChannel.Result) {
        if (encryptionService?.publicKey == null) {
            generateKey(result)
        }
    }

    private fun encrypt(call: MethodCall, result: MethodChannel.Result) {
        val pub = call.argument<String>("pub")
        val message = call.argument<String>("message")
        val ciphertext = encryptionService?.encrypt(pub!!, message!!)
        ciphertext?.subscribe({
            result.success(it)
        },{
            result.error(ErrorCode.PARAMETERS_WRONG, "encrypt error", null)
        })
    }

    private fun decrypt(call: MethodCall, result: MethodChannel.Result) {
        val privateKey = call.argument<String>("privateKey") ?: ""
        val cipherText = call.argument<String>("cipherText") ?: ""
        val message = encryptionService?.decrypt(privateKey, cipherText)
        message?.subscribe({
            Timber.i("message:$message")
            result.success(it)
        },{
            result.error(ErrorCode.PARAMETERS_WRONG, "decrypt error", null)
        })
    }

    @SuppressLint("CheckResult")
    private fun generateKey(result: MethodChannel.Result) {
        Timber.i("-生成密钥")
        encryptionService?.generateKeyPairAndStore()
                ?.subscribe({
                    result.success(it)
                    cipherEventSink?.success(it)
                }, {
                    it.printStackTrace()
                    result.error(null, it.message, null)
                })
    }

    private fun trustActiveEncrypt(call: MethodCall, result: MethodChannel.Result) {
        var password = call.argument<String>("password") ?: ""
        var fileName = call.argument<String>("fileName") ?: ""
        var resultMapFlowable = encryptionService?.trustActiveEncrypt(password, fileName)
        resultMapFlowable?.subscribe({
            result.success(it)
        }, {
            result.error(ErrorCode.PASSWORD_WRONG, it.message, null)
        })
    }

    private fun trustEncrypt(call: MethodCall, result: MethodChannel.Result) {
        var publicKey = call.argument<String>("publicKey")
        var message = call.argument<String>("message") ?: ""
        var resultMapFlowable = encryptionService?.trustEncrypt(publicKey, message)
        resultMapFlowable?.subscribe({
            result.success(it)
        }, {
            result.error(ErrorCode.PARAMETERS_WRONG, it.message, null)
        })
    }

    private fun trustDecrypt(call: MethodCall, result: MethodChannel.Result) {
        val cipherText = call.argument<String>("cipherText") ?: ""
        val password = call.argument<String>("password") ?: ""
        val fileName = call.argument<String>("fileName") ?: ""
        val messageFlowable = encryptionService?.trustDecrypt(cipherText,fileName,password)
        messageFlowable?.subscribe({
            result.success(it)
        }, {
            result.error(it.message, "decrypt error", null)
        })
    }

}