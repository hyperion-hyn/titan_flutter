package org.maprich.app.sensor

interface OnSensorValueChangeListener {

    fun onSensorChange(sensorType: Int, values: Map<String, Any>);
}