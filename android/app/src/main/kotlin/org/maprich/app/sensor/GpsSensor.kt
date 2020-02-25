package org.maprich.app.sensor

import android.annotation.SuppressLint
import android.annotation.TargetApi
import android.content.Context
import android.location.*
import android.os.Build
import android.os.Bundle

class GpsSensor(val context: Context, val onSensorValueChangeListener: OnSensorValueChangeListener) : Sensor {

    companion object {
        const val SENSOR_TYPE = SensorType.GPS
    }

    lateinit var mLocationManager: LocationManager;


    var locationListener = object : LocationListener {
        override fun onLocationChanged(location: Location?) {

            if (location == null) {
                return
            }

            val lat = location.latitude
            val lon = location.longitude
            val altitude = location.altitude
            val accuracy = location.accuracy
            val bearing = location.bearing
            val speed = location.speed
            val time = location.time

            val values = mutableMapOf<String, Any>()

            Utils.addIfNonNull(values, "lat", lat)
            Utils.addIfNonNull(values, "lon", lon)
            Utils.addIfNonNull(values, "altitude", altitude)
            Utils.addIfNonNull(values, "accuracy", accuracy)
            Utils.addIfNonNull(values, "bearing", bearing)
            Utils.addIfNonNull(values, "speed", speed)
            Utils.addIfNonNull(values, "time", time)

            onSensorValueChangeListener.onSensorChange(SENSOR_TYPE, values)


        }

        override fun onStatusChanged(p0: String?, p1: Int, p2: Bundle?) {
            }

        override fun onProviderEnabled(p0: String?) {
            }

        override fun onProviderDisabled(p0: String?) {
           }

    }


    override fun init() {
        // 获取 LocationManager
        mLocationManager = context.getSystemService(Context.LOCATION_SERVICE) as LocationManager;

    }

    @SuppressLint("MissingPermission")
    override fun startScan() {
        mLocationManager.requestLocationUpdates(LocationManager.GPS_PROVIDER, 0, 0f, locationListener)
    }

    override fun stopScan() {
        mLocationManager.removeUpdates(locationListener)
    }

    override fun destory() {
    }
}