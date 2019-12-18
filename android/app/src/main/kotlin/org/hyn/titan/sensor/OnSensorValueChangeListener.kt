package org.hyn.titan.sensor

interface OnSensorValueChangeListener {

    fun onSensorChange(sensorType: Int, values: Map<String, Any>);
}