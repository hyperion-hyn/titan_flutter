package org.maprich.app.sensor

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.net.wifi.WifiManager

class WifiSensor(val context: Context, val onSensorValueChangeListener: OnSensorValueChangeListener) : Sensor {

    companion object {
        const val SENSOR_TYPE = SensorType.WIFI
    }


    lateinit var wifiManager: WifiManager;

    val wifiScanReceiver = object : BroadcastReceiver() {

        override fun onReceive(context: Context, intent: Intent) {
            val success = intent.getBooleanExtra(WifiManager.EXTRA_RESULTS_UPDATED, false)
            if (success) {
                scanSuccess()
            } else {
                scanFailure()
            }
        }
    }

    private fun scanSuccess() {
        val results = wifiManager.scanResults
        for (result in results) {
            val values = mutableMapOf<String, Any>()
            val bssid = result.BSSID
            val ssid = result.SSID
            val capabilities = result.capabilities
            val level = result.level
            val timestamp = result.timestamp

            Utils.addIfNonNull(values, "bssid", bssid)
            Utils.addIfNonNull(values, "ssid", ssid)
            Utils.addIfNonNull(values, "capabilities", capabilities)
            Utils.addIfNonNull(values, "level", level)
            Utils.addIfNonNull(values, "timestamp", timestamp)
            onSensorValueChangeListener?.onSensorChange(SENSOR_TYPE, values)
        }
    }

    private fun scanFailure() {
        // handle failure: new scan did NOT succeed
        // consider using old scan results: these are the OLD results!
        val results = wifiManager.scanResults
        val values = mutableMapOf<String, Any>()

        for (result in results) {
            val bssid = result.BSSID
            val ssid = result.SSID
            val capabilities = result.capabilities
            val level = result.level
            val timestamp = result.timestamp
            Utils.addIfNonNull(values, "bssid", bssid)
            Utils.addIfNonNull(values, "ssid", ssid)
            Utils.addIfNonNull(values, "capabilities", capabilities)
            Utils.addIfNonNull(values, "level", level)
            Utils.addIfNonNull(values, "timestamp", timestamp)
            onSensorValueChangeListener?.onSensorChange(SENSOR_TYPE, values)
        }

    }


    override fun init() {

        wifiManager = context.getApplicationContext().getSystemService(Context.WIFI_SERVICE) as WifiManager
        val intentFilter = IntentFilter()
        intentFilter.addAction(WifiManager.SCAN_RESULTS_AVAILABLE_ACTION)
        context.registerReceiver(wifiScanReceiver, intentFilter)
    }

    override fun startScan() {
        val success = wifiManager.startScan()
        if (!success) {
            // scan failure handling
            scanFailure()
        }

    }

    override fun stopScan() {
        context.unregisterReceiver(wifiScanReceiver);
    }

    override fun destory() {
    }

}