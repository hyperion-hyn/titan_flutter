package org.hyn.titan

import android.app.Activity
import android.bluetooth.BluetoothAdapter
import android.content.Intent
import android.net.Uri
import android.net.wifi.WifiManager
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import androidx.core.content.FileProvider
import com.hyn.titan.tools.AppPrintTools
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import org.hyn.titan.encryption.EncryptionPluginInterface
import org.hyn.titan.push.UMengPluginInterface
import org.hyn.titan.sensor.SensorPluginInterface
import org.hyn.titan.umenglib.push.UMengPushImpl
import org.hyn.titan.utils.AppToolsPlugin
import org.hyn.titan.wallet.WalletPluginInterface
import java.io.File
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant;
import androidx.annotation.NonNull;

class MainActivity : FlutterActivity() {

    private val callChannelName = "org.hyn.titan/call_channel"

    private val QRCODE_SCAN_REQUEST_CODE = 1
    private val MANAGE_UNKNOWN_APP_SOURCES = 2

    private var scanResult: MethodChannel.Result? = null
    private var requestInstallUnknownSourceResult: MethodChannel.Result? = null
    private var callChannel: MethodChannel? = null;

    private val appToolsPlugin = AppToolsPlugin()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        //GeneratedPluginRegistrant.registerWith(this)
        //AppToolsPlugin.registerWith(this)
        //UmengPlugin.registerWith(this)

        GlobalScope.launch {
            /*Thread.sleep(2000)
            withContext(Dispatchers.Main) {
                var data = intent.data
                if(data != null){
                    AppToolsPlugin.deeplinkStart(data)
                }
            }*/

            Thread.sleep(10000)
            withContext(Dispatchers.Main) {
                AppPrintTools.printLog(UMengPushImpl.umengToken)
            }
        }
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)

        val sensorPluginInterface = SensorPluginInterface()
        flutterEngine.plugins.add(sensorPluginInterface)

        val umPluginInterface = UMengPluginInterface()
        flutterEngine.plugins.add(umPluginInterface)

        val encryptionPluginInterface = EncryptionPluginInterface()
        flutterEngine.plugins.add(encryptionPluginInterface)

        flutterEngine.plugins.add(appToolsPlugin)

        val walletPluginInterface = WalletPluginInterface()
        flutterEngine.plugins.add(walletPluginInterface)

        callChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, callChannelName);

        callChannel?.setMethodCallHandler { call, result ->
            var handled = encryptionPluginInterface.setMethodCallHandler(call, result)
            if (!handled) {
                handled = appToolsPlugin.setMethodCallHandler(this@MainActivity, call, result)
            }
            if (!handled) {
                handled = walletPluginInterface.setMethodCallHandler(call, result)
            }
            if (!handled) {
                when (call.method) {
                    "nativeGreet" -> {  // this is a test call
                        val m = mapOf("where" to "native", "name" to "moo", "age" to 19)
                        callChannel?.invokeMethod("dartGreet", m, object : MethodChannel.Result {
                            override fun notImplemented() {
                                result.notImplemented()
                            }

                            override fun error(p0: String?, p1: String?, p2: Any?) {
                                result.error(p0, p1, p2)
                            }

                            override fun success(p0: Any?) {
                                result.success(p0)
                            }

                        })
                    }
                    "canRequestPackageInstalls" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            result.success(packageManager.canRequestPackageInstalls())
                        } else {
                            result.success(true)
                        }
                    }
                    "requestInstallUnknownSourceSetting" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            if (packageManager.canRequestPackageInstalls()) {
                                result.success(true)
                            } else {
                                val intent = Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES, Uri.parse("package:$packageName"))
                                startActivityForResult(intent, MANAGE_UNKNOWN_APP_SOURCES)
                                requestInstallUnknownSourceResult = result
                            }
                        } else {
                            result.success(true)
                        }
                    }
                    "shareImage" -> {
                        val params: Map<String, String> = call.arguments as Map<String, String>
                        val path = params.getValue("path")
                        val title = params.getValue("title")
                        val file = File(cacheDir, path)
                        val uri = FileProvider.getUriForFile(this, "${BuildConfig.APPLICATION_ID}.fileprovider", file)
                        val shareIntent: Intent = Intent().apply {
                            action = Intent.ACTION_SEND
                            putExtra(Intent.EXTRA_STREAM, uri)
                            type = "image/jpg"
                        }
                        startActivity(Intent.createChooser(shareIntent, title))
                    }
                    "shareText" -> {
                        val params: Map<String, String> = call.arguments as Map<String, String>
                        val text = params.getValue("text")
                        val title = params.getValue("title")
                        val sendIntent: Intent = Intent().apply {
                            action = Intent.ACTION_SEND
                            putExtra(Intent.EXTRA_TEXT, text)
                            type = "text/plain"
                        }
                        startActivity(Intent.createChooser(sendIntent, title))
                    }
                    "requestWiFiIsOpenedSetting" -> {
                        val wifi = applicationContext.getSystemService(WIFI_SERVICE) as WifiManager;
                        result.success(wifi.isWifiEnabled)
                    }
                    "wifiEnable" -> {
                        val wifiManager: WifiManager = applicationContext.getSystemService(WIFI_SERVICE) as WifiManager
                        result.success(wifiManager.isWifiEnabled)
                    }
                    "bluetoothEnable" -> {
                        val blueadapter: BluetoothAdapter = BluetoothAdapter.getDefaultAdapter()
                        result.success(blueadapter.isEnabled)
                    }
                    "jumpToBioAuthSetting" -> {
                        startActivity(Intent(Settings.ACTION_SECURITY_SETTINGS))
                    }
                    else -> {
                        result.notImplemented()
                    }
                }
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)

        var data = intent?.data
        appToolsPlugin.deepLinkStart(data)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == QRCODE_SCAN_REQUEST_CODE) {
            if (resultCode == Activity.RESULT_OK) {
                val code = data?.getStringExtra("code")
                if (!code.isNullOrEmpty()) {
                    scanResult?.success(code)
                    return
                }
            }
            scanResult?.error("scan error", null, null)
            scanResult = null
        } else if (requestCode == MANAGE_UNKNOWN_APP_SOURCES) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                requestInstallUnknownSourceResult?.success(packageManager.canRequestPackageInstalls())
            } else {
                requestInstallUnknownSourceResult?.success(false)
            }
            requestInstallUnknownSourceResult = null
        }
    }
}
