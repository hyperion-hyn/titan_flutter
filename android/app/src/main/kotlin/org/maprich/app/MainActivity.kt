package org.maprich.app

import android.app.Activity
import android.bluetooth.BluetoothAdapter
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.net.wifi.WifiManager
import androidx.core.content.FileProvider
import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import org.maprich.app.encryption.EncryptionPluginInterface
import org.maprich.app.push.UMengPluginInterface
import org.maprich.app.sensor.SensorPluginInterface
import org.maprich.app.wallet.WalletPluginInterface
import java.io.File

class MainActivity : FlutterActivity() {
    private val callChannel by lazy { MethodChannel(flutterView, "org.maprich.app/call_channel") }

    private val QRCODE_SCAN_REQUEST_CODE = 1
    private val MANAGE_UNKNOWN_APP_SOURCES = 2

    private var scanResult: MethodChannel.Result? = null
    private var requestInstallUnknownSourceResult: MethodChannel.Result? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)

        val encryptionPluginInterface = EncryptionPluginInterface(this, flutterView)
        val walletPluginInterface = WalletPluginInterface(this, flutterView)
        val sensorPluginInterface = SensorPluginInterface(this, flutterView)
        val umengPluginInterface = UMengPluginInterface(this, flutterView)

        callChannel.setMethodCallHandler { call, result ->
            var handled = encryptionPluginInterface.setMethodCallHandler(call, result)
            if (!handled) {
                handled = walletPluginInterface.setMethodCallHandler(call, result)
            }
            if (!handled) {
                when (call.method) {
                    "nativeGreet" -> {  // this is a test call
                        val m = mapOf("where" to "native", "name" to "moo", "age" to 19)
                        callChannel.invokeMethod("dartGreet", m, object : MethodChannel.Result {
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
                        val wifi = applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager;
                        result.success(wifi.isWifiEnabled)
                    }
                    "wifiEnable" -> {
                        val wifiManager: WifiManager = applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
                        result.success(wifiManager.isWifiEnabled)
                    }
                    "bluetoothEnable" -> {
                        val blueadapter: BluetoothAdapter = BluetoothAdapter.getDefaultAdapter()
                        result.success(blueadapter.isEnabled)
                    }
                    else -> {
                        result.notImplemented()
                    }
                }
            }
        }
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