package org.maprich.app.sensor

import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import timber.log.Timber

class BluetoothSensor(val context: Context, val onSensorValueChangeListener: OnSensorValueChangeListener) : Sensor {


    companion object {
        const val SENSOR_TYPE = SensorType.BLUETOOTH
    }

    lateinit var bluetoothAdapter: BluetoothAdapter;

    private val receiver = object : BroadcastReceiver() {

        override fun onReceive(context: Context, intent: Intent) {
            val action: String = intent.action ?: return

            Timber.i("action:$action")

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

                    Utils.addIfNonNull(values, "name", deviceName)
                    Utils.addIfNonNull(values, "mac", deviceHardwareAddress)
                    Utils.addIfNonNull(values, "type", deviceType)

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
        bluetoothAdapter.startDiscovery();
    }

    override fun stopScan() {
        bluetoothAdapter.cancelDiscovery();
        context.unregisterReceiver(receiver);
    }

    override fun destory() {

    }
}