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

    func initialize() {
        registerSensorList.removeAll()

        var blueToothSensor = BluetoothSensor();
        registerSensorList.append(blueToothSensor)
        
        var gpsSensor = GpsSensor()
        registerSensorList.append(gpsSensor)
        
        var cellularSensor = CellularSensor()
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
