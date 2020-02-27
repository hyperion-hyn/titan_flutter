package org.hyn.titan.push

import com.hyn.titan.tools.AppPrintInterface
import com.hyn.titan.tools.AppPrintTools
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry

class UmengPlugin : MethodChannel.MethodCallHandler {

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    }

    companion object {
        private lateinit var methodChannel :MethodChannel
        fun registerWith(pluginRegistry: PluginRegistry) {
            methodChannel = MethodChannel(pluginRegistry.registrarFor("org.hyn.titan.push.UmengPlugin").messenger()
                    , "org.hyn.titan/call_channel")
        }

        fun openWebView(title: String?, out_link: String?,text: String?){
            var map = mapOf("title" to title,"out_link" to out_link,"text" to text)
            methodChannel.invokeMethod("msgPush",map)
        }
    }

}