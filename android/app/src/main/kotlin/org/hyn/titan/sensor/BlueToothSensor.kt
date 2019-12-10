package org.hyn.titan.sensor

import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter

class BlueToothSensor(val context: Context, val onSensorValueChangeListener: OnSensorValueChangeListener) : Sensor {


    companion object {
        const val SENSOR_TYPE = -2
    }

    lateinit var bluetoothAdapter: BluetoothAdapter;

    private val receiver = object : BroadcastReceiver() {

        override fun onReceive(context: Context, intent: Intent) {
            val action: String = intent.action
            when (action) {
                BluetoothDevice.ACTION_FOUND -> {
                    // Discovery has found a device. Get the BluetoothDevice
                    // object and its info from the Intent.
                    val device: BluetoothDevice =
                            intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE)
                    val deviceName = device.name
                    val deviceHardwareAddress = device.address // MAC address
                    val deviceType = device.type
                    val values = mutableMapOf<String, Any>()

                    values.put("name", deviceName)
                    values.put("mac", deviceHardwareAddress)
                    values.put("type", deviceType)

                    onSensorValueChangeListener?.onSensorChange(SENSOR_TYPE, values)

                }
            }
        }
    }

    override fun init() {
        bluetoothAdapter = BluetoothAdapter.getDefaultAdapter()
        val filter = IntentFilter(BluetoothDevice.ACTION_FOUND)
        context.registerReceiver(receiver, filter)

    }

    override fun startScan() {
        bluetoothAdapter?.startDiscovery();
    }

    override fun stopScan() {
        bluetoothAdapter?.cancelDiscovery();
        context.unregisterReceiver(receiver);
    }

    override fun destory() {

    }
}