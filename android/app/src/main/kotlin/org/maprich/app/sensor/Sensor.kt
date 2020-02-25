package org.maprich.app.sensor

interface Sensor {

    fun init()
    fun startScan()
    fun stopScan()
    fun destory()
}