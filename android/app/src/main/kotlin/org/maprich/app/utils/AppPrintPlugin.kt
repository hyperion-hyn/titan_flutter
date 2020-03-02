package org.hyn.titan.utils

import com.hyn.titan.tools.AppPrintInterface
import com.hyn.titan.tools.AppPrintTools
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry

class AppPrintPlugin : MethodChannel.MethodCallHandler {

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    }

    companion object {
        fun registerWith(pluginRegistry: PluginRegistry) {
            val methodChannel = MethodChannel(pluginRegistry.registrarFor("org.hyn.titan.utils.AppPrintPlugin").messenger(), "org.hyn.titan/call_channel")

            AppPrintTools.appPrintInterface = object : AppPrintInterface{
                override fun printLog(logMsg: String) {
                    methodChannel.invokeMethod("printLog",logMsg)
                }
            }
        }
    }

}