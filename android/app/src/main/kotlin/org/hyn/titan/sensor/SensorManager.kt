package org.hyn.titan.sensor

import android.content.Context
import timber.log.Timber

class SensorManager(val context: Context) {


    var registerSensorList = mutableListOf<Sensor>()


    var sensorValueChangeListener: OnSensorValueChangeListener = object : OnSensorValueChangeListener {
        override fun onSensorChange(sensorType: Int, values: Map<String, Any>) {
            Timber.i("sensorType:$sensorType,values:$values")
        }
    }

    fun init() {
        val wifiSensor = WifiSensor(context, sensorValueChangeListener);
        val blueToothSensor = BlueToothSensor(context, sensorValueChangeListener);
        registerSensorList.add(wifiSensor)
        registerSensorList.add(blueToothSensor)
    }


    fun startScan() {
        for (sensor in registerSensorList) {
            sensor.startScan();
        }
    }

    fun stopScan() {
        for (sensor in registerSensorList) {
            sensor.stopScan();
        }
    }

    fun destory() {
        for (sensor in registerSensorList) {
            sensor.destory();
        }
    }
}