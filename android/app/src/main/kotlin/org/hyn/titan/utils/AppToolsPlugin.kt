package org.hyn.titan.utils

import android.content.ClipboardManager
import android.content.Context
import android.net.Uri
import com.hyn.titan.tools.AppPrintInterface
import com.hyn.titan.tools.AppPrintTools
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import org.hyn.titan.TitanApp

class AppToolsPlugin(private val context: Context) : MethodChannel.MethodCallHandler {

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
//            if("contract" == host){
                var params = data.pathSegments
                if(params.size == 1){
                    var contentMap:Map<String,String> = mapOf()
                    data.queryParameterNames.mapIndexed { index, keyStr ->
                        contentMap.plus(mapOf(keyStr to data.getQueryParameter(keyStr)))
                    }
                    var mapValue = mapOf("type" to host,"subType" to params[0],"content" to contentMap)
                    methodChannel.invokeMethod("urlLauncher",mapValue)
                    /*var contractId = data.getQueryParameter("contractId")
                    var key = data.getQueryParameter("key")
                    var mapValue = mapOf("type" to host,"subType" to params[0],"content" to mapOf("contractId" to contractId,"key" to key))
                    methodChannel.invokeMethod("urlLauncher",mapValue)*/
                }
//            }
        }
    }

    fun setMethodCallHandler(call: MethodCall, result: MethodChannel.Result): Boolean {
        return when (call.method) {
            "clipboardData" -> {
                getClipboardData()
                result.success(true)
                true
            }
            else -> false
        }
    }

    fun getClipboardData(){
        //获取系统剪贴板服务
        var clipboardManager = context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
        if (null != clipboardManager) {
            // 获取剪贴板的剪贴数据集
            var clipData = clipboardManager.primaryClip
            if (null != clipData && clipData.itemCount > 0) {
                // 从数据集中获取（粘贴）第一条文本数据
                for(i in 0 until clipData.itemCount){
                    var item = clipData.getItemAt(0)
                    if(item?.text?.contains("titan://contract/detail") == true){
                        var shareUser = item.text.split("key=")[1]

                        clipboardManager.text = null
                        var mapValue = mapOf("type" to "save","subType" to "shareUser","content" to mapOf("shareUserValue" to shareUser))
                        methodChannel.invokeMethod("urlLauncher",mapValue)
                        return
                    }
                }
            }
        }
    }

}