package org.maprich.app.push

import android.content.Context
import android.util.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.maprich.app.TitanApp
import org.hyn.titan.umenglib.interfaces.OnPushChangeListener
import org.hyn.titan.umenglib.push.UMengPushImpl
import org.jetbrains.anko.runOnUiThread

class UMengPluginInterface(private val context: Context, private val binaryMessenger: BinaryMessenger) {
    val methodChannel = MethodChannel(binaryMessenger, "org.maprich.app/push_call_channel")
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