package org.hyn.titan.sensor

import android.annotation.SuppressLint
import android.annotation.TargetApi
import android.content.Context
import android.location.*
import android.os.Build
import android.os.Bundle

class GpsSensor(val context: Context, val onSensorValueChangeListener: OnSensorValueChangeListener) : Sensor {

    companion object {
        const val SENSOR_TYPE = -3
    }

    lateinit var mLocationManager: LocationManager;


    var locationListener = object : LocationListener {
        override fun onLocationChanged(location: Location?) {

            if (location == null) {
                return
            }


            var lat = location.latitude
            var lon = location.longitude
            var altitude = location.altitude
            var accuracy = location.accuracy
            var bearing = location.bearing
            var speed = location.speed
            var time = location.time


        }

        override fun onStatusChanged(p0: String?, p1: Int, p2: Bundle?) {
            TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
        }

        override fun onProviderEnabled(p0: String?) {
            TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
        }

        override fun onProviderDisabled(p0: String?) {
            TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
        }

    }

    var gnssStatusCallback = @TargetApi(Build.VERSION_CODES.N) object : GnssStatus.Callback() {

        override fun onSatelliteStatusChanged(status: GnssStatus?) {
            super.onSatelliteStatusChanged(status)
        }
    }


    var gpsStatusCallBack = object:GpsStatus.Listener{
        override fun onGpsStatusChanged(action: Int) {
            TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
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