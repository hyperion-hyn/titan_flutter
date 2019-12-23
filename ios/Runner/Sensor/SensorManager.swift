//
//  SensorManager.swift
//  Runner
//
//  Created by 蔡景松 on 2019/12/20.
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
        registerSensorList.append(gpsSensor)
        
        let cellularSensor = CellularSensor()
        cellularSensor.onSensorChange = onSensorChange
        registerSensorList.append(cellularSensor)

        for sensor in registerSensorList {
            sensor.initialize()
        }
    }
    
    func startScan() {
        for sensor in registerSensorList {
            sensor.startScan()
        }
    }

    func stopScan() {
        for sensor in registerSensorList {
            sensor.stopScan()
        }
    }

    func destory() {
        for sensor in registerSensorList {
            sensor.destory();
        }
        registerSensorList.removeAll()
    }
}
