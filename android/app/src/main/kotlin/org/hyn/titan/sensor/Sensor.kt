package org.hyn.titan.sensor

interface Sensor {

    fun init()
    fun startScan()
    fun stopScan()
    fun destory()
}