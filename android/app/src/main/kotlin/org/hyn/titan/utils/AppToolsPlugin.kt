package org.hyn.titan.utils
import android.app.Activity
import android.content.ClipboardManager
import android.content.Context
import android.net.Uri
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

//import io.flutter.plugin.common.PluginRegistry
//import com.hyn.titan.tools.AppPrintInterface
//import com.hyn.titan.tools.AppPrintTools

class AppToolsPlugin() : FlutterPlugin {


    /*
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
                var contentMap:MutableMap<String,String> = mutableMapOf()
                data.queryParameterNames.mapIndexed { index, keyStr ->
                    contentMap.put(keyStr, data.getQueryParameter(keyStr) ?: "")
                }
                var mapValue = mapOf("type" to host,"subType" to params[0],"content" to contentMap)
                methodChannel.invokeMethod("p2fDeeplink",mapValue)
                /*var contractId = data.getQueryParameter("contractId")
                var key = data.getQueryParameter("key")
                var mapValue = mapOf("type" to host,"subType" to params[0],"content" to mapOf("contractId" to contractId,"key" to key))
                methodChannel.invokeMethod("urlLauncher",mapValue)*/
            }
//            }
        }
    }
    */


    private var methodChannel: MethodChannel? = null
    private val sChannelName = "org.hyn.titan/call_channel"
    private var context: Context? = null

    fun deepLinkStart(data : Uri?){
        if(data == null) {
            return
        }
        var host = data.host
        var params = data.pathSegments
        if(params.size == 1){
            var contentMap:MutableMap<String,String> = mutableMapOf()
            data.queryParameterNames.mapIndexed { index, keyStr ->
                contentMap.put(keyStr, data.getQueryParameter(keyStr) ?: "")
            }
            var mapValue = mapOf("type" to host,"subType" to params[0],"content" to contentMap)
            methodChannel?.invokeMethod("p2fDeeplink",mapValue)
        }
    }

    private fun getClipboardData() : String? {
        //获取系统剪贴板服务
        var clipboardManager = context!!.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
        if (null != clipboardManager) {
            // 获取剪贴板的剪贴数据集
            var clipData = clipboardManager.primaryClip
            if (null != clipData && clipData.itemCount > 0) {
                // 从数据集中获取（粘贴）第一条文本数据
                var item = clipData.getItemAt(0)
                return item?.text?.toString()

                /*for(i in 0 until clipData.itemCount){
                    var item = clipData.getItemAt(i)
                    if(item?.text?.contains("titan://contract/detail") == true){
                        var shareUser = item.text.split("key=")[1]

                        clipboardManager.text = null
                        var mapValue = mapOf("type" to "save","subType" to "shareUser","content" to mapOf("shareUserValue" to shareUser))
                        methodChannel?.invokeMethod("urlLauncher",mapValue)
                        return
                    }
                }*/
            }
        }
        return null
    }

    fun setMethodCallHandler(context: Context, call: MethodCall, result: MethodChannel.Result): Boolean {
        return when (call.method) {
            "clipboardData" -> {
                var clipData = getClipboardData()
                result.success(clipData)
                true
            }
            "f2pDeeplink" -> {
                var intent = (context as Activity).intent
                deepLinkStart(intent.data)
                result.success(true)
                true
            }
            else -> false
        }
    }


    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel = MethodChannel(
                binding.flutterEngine.dartExecutor.binaryMessenger, sChannelName)
        context = binding.applicationContext
        methodChannel?.setMethodCallHandler { call, result ->
            setMethodCallHandler(context!!,call, result);
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel?.setMethodCallHandler(null)
        methodChannel = null
    }

}