package org.hyn.titan.push

import android.content.Context
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.hyn.titan.TitanApp

class UMengPluginInterface(context: Context): FlutterPlugin {

    private var methodChannel: MethodChannel? = null
    private val sChannelName = "org.hyn.titan/push_call_channel"
    val iUMengPush = (context.applicationContext as TitanApp).iUMengPush

    /*
    val methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "org.hyn.titan/push_call_channel")

    init {
        methodChannel!!.setMethodCallHandler { call, result ->
            setMethodCallHandler(call, result)
        }
    }
    */

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel = MethodChannel(
                binding.flutterEngine.dartExecutor.binaryMessenger, sChannelName)
        //context = binding.applicationContext
        methodChannel!!.setMethodCallHandler { call, result ->
            setMethodCallHandler(call, result);
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel?.setMethodCallHandler(null)
        methodChannel = null
    }

    private fun setMethodCallHandler(call: MethodCall, result: MethodChannel.Result): Boolean {
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

}