//
//  SensorManager.swift
//  Runner
//
//  Created by naru.j on 2019/12/20.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

import Foundation

class SensorManager {
    
    var registerSensorList = Array<Sensor>()
    var onSensorChange: OnSensorValueChangeListener!

    func initialize() {
        registerSensorList.removeAll()

        let blueToothSensor = BluetoothSensor();
        blueToothSensor.onSensorChange = onSensorChange
        registerSensorList.append(blueToothSensor)
        
        let gpsSensor = GpsSensor()
        gpsSensor.onSensorChange = onSensorChange
//        registerSensorList.append(gpsSensor)
        
        let cellularSensor = CellularSensor()
        cellularSensor.onSensorChange = onSensorChange
//        registerSensorList.append(cellularSensor)

        for sensor in registerSensorList {
            sensor.initialize()
        }
    }
    
    func startScan() {
        for sensor in registerSensorList {
            sensor.startScan()
        }
        print("[ios] --> startScan")
    }

    func stopScan() {
        for sensor in registerSensorList {
            sensor.stopScan()
        }
        print("[ios] --> stopScan")
    }

    func destory() {
        for sensor in registerSensorList {
            sensor.destory();
        }
        registerSensorList.removeAll()
        
        print("[ios] --> destory")
    }
}
