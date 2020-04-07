package org.hyn.titan.utils

import android.net.Uri
import com.hyn.titan.tools.AppPrintInterface
import com.hyn.titan.tools.AppPrintTools
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import org.bouncycastle.asn1.x500.style.RFC4519Style.title

class AppToolsPlugin : MethodChannel.MethodCallHandler {

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    }

    companion object {
        private lateinit var methodChannel :MethodChannel
        fun registerWith(pluginRegistry: PluginRegistry) {
            methodChannel = MethodChannel(pluginRegistry.registrarFor("org.hyn.titan.utils.AppToolsPlugin").messenger(), "org.hyn.titan/call_channel")

            AppPrintTools.appPrintInterface = object : AppPrintInterface{
                override fun printLog(logMsg: String) {
                    methodChannel.invokeMethod("printLog",logMsg)
                }
            }
        }

        fun deeplinkStart(data : Uri?){
            if(data == null){
                return
            }
            var host = data.host
            if("contract" == host){
                var params = data.pathSegments
                if(params.size == 1){
                    var contractId = data.getQueryParameter("contractId")
                    var mapValue = mapOf("type" to host,"subType" to params[0],"content" to mapOf("contractId" to contractId))
                    methodChannel.invokeMethod("urlLauncher",mapValue)
                }
            }
        }
    }

}