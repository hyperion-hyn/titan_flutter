package org.maprich.app.sensor

import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import timber.log.Timber

class SensorPluginInterface(private val context: Context, private val binaryMessenger: BinaryMessenger) {


    val methodChannel = MethodChannel(binaryMessenger, "org.hyn.titan/sensor_call_channel")

    init {
        methodChannel.setMethodCallHandler { call, result ->
            setMethodCallHandler(call, result);
        }
    }

    lateinit var sensorManager: SensorManager;


    fun setMethodCallHandler(call: MethodCall, result: MethodChannel.Result): Boolean {
        return when (call.method) {

            "sensor#init" -> {
                sensorManager = SensorManager(context, sensorValueChangeListener);
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


    private val sensorValueChangeListener = object : OnSensorValueChangeListener {
        override fun onSensorChange(sensorType: Int, values: Map<String, Any>) {
            Timber.i("sensorType:$sensorType,values:$values")
            val mutableMap = values.toMutableMap()
            mutableMap.put("sensorType",sensorType)
            methodChannel.invokeMethod("sensor#valueChange", mutableMap)
        }
    }

}