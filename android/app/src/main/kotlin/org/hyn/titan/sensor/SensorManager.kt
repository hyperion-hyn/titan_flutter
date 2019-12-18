package org.hyn.titan.sensor

import android.content.Context
import android.os.Build
import timber.log.Timber

class SensorManager(val context: Context, private val sensorValueChangeListener: OnSensorValueChangeListener) {


    var registerSensorList = mutableListOf<Sensor>()


//    var sensorValueChangeListener: OnSensorValueChangeListener = object : OnSensorValueChangeListener {
//        override fun onSensorChange(sensorType: Int, values: Map<String, Any>) {
//            Timber.i("sensorType:$sensorType,values:$values")
//        }
//    }

    fun init() {
        registerSensorList.clear()
        val wifiSensor = WifiSensor(context, sensorValueChangeListener);
        registerSensorList.add(wifiSensor)
        val blueToothSensor = BluetoothSensor(context, sensorValueChangeListener);
        registerSensorList.add(blueToothSensor)
        val gpsSensor = GpsSensor(context, sensorValueChangeListener);
        registerSensorList.add(gpsSensor)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            val gnssSensor = GnssSensor(context, sensorValueChangeListener);
            registerSensorList.add(gnssSensor)
        }

        val cellularSensor = CellularSensor(context, sensorValueChangeListener);

        registerSensorList.add(cellularSensor)

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
        registerSensorList.clear()
    }
}