package org.hyn.titan.sensor

import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import timber.log.Timber

class SensorPluginInterface(private val context: Context, private val binaryMessenger: BinaryMessenger, val methodChannel: MethodChannel) {


    lateinit var sensorManager: SensorManager;


    fun setMethodCallHandler(call: MethodCall, result: MethodChannel.Result): Boolean {
        return when (call.method) {

            "sensor#init" -> {
                sensorManager = SensorManager(context, sensorValueChangeListener);
                sensorManager.init()

                return true
            }
            "sensor#startScan" -> {
                sensorManager.startScan()
                return true
            }
            "sensor#stopScan" -> {
                sensorManager.stopScan()
                return true
            }
            "sensor#destory" -> {
                sensorManager.destory()
                return true
            }
            else -> false
        }
    }


    private val sensorValueChangeListener = object : OnSensorValueChangeListener {
        override fun onSensorChange(sensorType: Int, values: Map<String, Any>) {
            Timber.i("sensorType:$sensorType,values:$values")
        }
    }

}