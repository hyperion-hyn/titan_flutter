package org.maprich.app.encryption

import android.annotation.SuppressLint
import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import timber.log.Timber

class EncryptionPluginInterface(private val context: Context, private val binaryMessenger: BinaryMessenger) {
    private val keyPairChangeChannel by lazy { EventChannel(binaryMessenger, "org.hyn.titan/event_stream") }
    private val encryptionService by lazy { EncryptionProvider.getDefaultEncryption(context) }
    private var cipherEventSink: EventChannel.EventSink? = null

    init {
        keyPairChangeChannel.setStreamHandler(object : EventChannel.StreamHandler {
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
                result.success(encryptionService.expireTime)
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
        }
        return false
    }

    private fun initKeyPair(call: MethodCall, result: MethodChannel.Result) {
        val expired = if (call.arguments is Number) (call.arguments as Number).toLong() else 3600
        Timber.i("$expired ${call.arguments}")
        initOrCreateKeyPair(expired, result)
    }

    private fun genKeyPair(call: MethodCall, result: MethodChannel.Result) {
        val expired = if (call.arguments is Long) call.arguments as Long else 3600
        Timber.i("$expired ${call.arguments}")
        generateKey(expired, result)
    }

    private fun getPublicKey(call: MethodCall, result: MethodChannel.Result) {
        result.success(encryptionService.publicKey)
    }

    private fun initOrCreateKeyPair(expired: Long, result: MethodChannel.Result) {
        if (encryptionService.publicKey == null || System.currentTimeMillis() > encryptionService.expireTime) {
            generateKey(expired, result)
        }
    }

    private fun encrypt(call: MethodCall, result: MethodChannel.Result) {

        val pub = call.argument<String>("pub");
        val message = call.argument<String>("message");
        val ciphertext = encryptionService.encrypt(pub!!, message!!)
        ciphertext.subscribe({
            result.success(it);
        })
    }

    private fun decrypt(call: MethodCall, result: MethodChannel.Result) {
        val ciphertext = call.arguments as String;
        val message = encryptionService.decrypt(ciphertext)
        message.subscribe({
            Timber.i("message:$message")
            result.success(it);
        })
    }

    @SuppressLint("CheckResult")
    private fun generateKey(expired: Long, result: MethodChannel.Result) {
        Timber.i("生成密钥")
        encryptionService.generateKeyPairAndStore(expired)
                .subscribe({
                    encryptionService.publicKey?.let { pubKey ->
                        result.success(pubKey)
                        cipherEventSink?.success(pubKey)
                    }
                }, {
                    it.printStackTrace()
                    result.error(it.message, null, null)
                })
    }
}