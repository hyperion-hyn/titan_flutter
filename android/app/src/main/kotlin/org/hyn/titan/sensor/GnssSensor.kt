package org.hyn.titan.sensor

import android.annotation.SuppressLint
import android.annotation.TargetApi
import android.content.Context
import android.location.GnssStatus
import android.location.GpsStatus
import android.location.LocationManager
import android.os.Build
import androidx.annotation.RequiresApi


class GnssSensor(val context: Context, val onSensorValueChangeListener: OnSensorValueChangeListener) : Sensor {

    companion object {
        const val SENSOR_TYPE = SensorType.GNSS
    }

    lateinit var mLocationManager: LocationManager;


    var gnssStatusCallback = @TargetApi(Build.VERSION_CODES.N) object : GnssStatus.Callback() {

        override fun onSatelliteStatusChanged(status: GnssStatus?) {


            if (status == null) {
                return;
            }

            val satelliteCount = status.satelliteCount;

            for (index in 0..satelliteCount - 1) {
                val azimuth = status.getAzimuthDegrees(index)
                val frequency = status.getCarrierFrequencyHz(index)
                val noise = status.getCn0DbHz(index)
                val constellation = status.getConstellationType(index)
                val elevation = status.getElevationDegrees(index)
                val svid = status.getSvid(index)

                val values = mutableMapOf<String, Any>()

                Utils.addIfNonNull(values, "azimuth", azimuth);
                Utils.addIfNonNull(values, "frequency", frequency);
                Utils.addIfNonNull(values, "noise", noise);
                Utils.addIfNonNull(values, "constellation", constellation);
                Utils.addIfNonNull(values, "elevation", elevation);
                Utils.addIfNonNull(values, "svid", svid);
                onSensorValueChangeListener.onSensorChange(SENSOR_TYPE, values)

            }

        }
    }


    @SuppressLint("MissingPermission")
    override fun init() {
        // 获取 LocationManager
        mLocationManager = context.getSystemService(Context.LOCATION_SERVICE) as LocationManager;


    }

    @SuppressLint("MissingPermission")
    override fun startScan() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            mLocationManager.registerGnssStatusCallback(gnssStatusCallback)
        };
    }

    override fun stopScan() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            mLocationManager.unregisterGnssStatusCallback(gnssStatusCallback)
        };

    }

    override fun destory() {
    }
}