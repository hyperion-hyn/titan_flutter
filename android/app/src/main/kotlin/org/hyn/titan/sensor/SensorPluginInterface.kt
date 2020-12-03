package org.hyn.titan.sensor

import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import timber.log.Timber

class SensorPluginInterface() : FlutterPlugin {


    private var methodChannel: MethodChannel? = null
    private val sChannelName = "org.hyn.titan/sensor_call_channel"
    private var context: Context? = null

    /*
    val methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "org.hyn.titan/sensor_call_channel")

    init {
        methodChannel!!.setMethodCallHandler { call, result ->
            setMethodCallHandler(call, result);
        }
    }
    */

    lateinit var sensorManager: SensorManager;

    private val sensorValueChangeListener = object : OnSensorValueChangeListener {
        override fun onSensorChange(sensorType: Int, values: Map<String, Any>) {
            Timber.i("sensorType:$sensorType,values:$values")
            val mutableMap = values.toMutableMap()
            mutableMap.put("sensorType",sensorType)
            methodChannel!!.invokeMethod("sensor#valueChange", mutableMap)
        }
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel = MethodChannel(
                binding.flutterEngine.dartExecutor.binaryMessenger, sChannelName)
        context = binding.applicationContext
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

            "sensor#init" -> {
                sensorManager = SensorManager(this.context!!, sensorValueChangeListener);
                sensorManager.init()

                print("sensor#init")

                return true
            }
            "sensor#startScan" -> {
                sensorManager.startScan()
                print("sensor#startScan")
                return true
            }
            "sensor#stopScan" -> {
                sensorManager.stopScan()
                print("sensor#stopScan")
                return true
            }
            "sensor#destory" -> {
                sensorManager.destory()

                print("sensor#destory")
                return true
            }
            else -> false
        }
    }

}