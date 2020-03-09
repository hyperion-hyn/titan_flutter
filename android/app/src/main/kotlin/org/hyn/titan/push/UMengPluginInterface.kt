package org.hyn.titan.push

import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.hyn.titan.TitanApp

class UMengPluginInterface(private val context: Context, private val binaryMessenger: BinaryMessenger) {
    val methodChannel = MethodChannel(binaryMessenger, "org.hyn.titan/push_call_channel")
    val iUMengPush = (context.applicationContext as TitanApp).iUMengPush

    init {
        methodChannel.setMethodCallHandler { call, result ->
            setMethodCallHandler(call, result)
        }
    }

    fun setMethodCallHandler(call: MethodCall, result: MethodChannel.Result): Boolean {
        return when (call.method) {

            "push#getUMengToken" -> {

                print("push#getUMengToken")
                var token = iUMengPush.getUMengToken()
                result.success(token)
//                iUMengPush.initUMeng(context.applicationContext,onPushChangeListener)

                return true
            }
            else -> false
        }
    }

    /*private val onPushChangeListener = object : OnPushChangeListener{
        override fun onTokenSuccess(deviceToken: String) {
            context.runOnUiThread {
                methodChannel.invokeMethod("push#umengToken", deviceToken)
            }
        }

        override fun onTokenFail(s: String, s1: String) {
            print("push#onTokenFail")
        }

    }*/
}