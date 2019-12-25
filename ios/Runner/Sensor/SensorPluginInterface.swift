//
//  SensorPluginInterface.swift
//  Runner
//
//  Created by naru.j on 2019/12/20.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

import Foundation
import Flutter

class SensorPluginInterface {
    
    var sensorManager: SensorManager!
     
    var sensorChannel: FlutterMethodChannel?
    
    func setMethodCallHandler(methodCall: FlutterMethodCall, result: FlutterResult) -> Bool {
                
        switch(methodCall.method) {
        
            case "sensor#init":
                
                sensorManager = SensorManager()
                sensorManager.onSensorChange = { (sensorType, values) in
                    guard let channel = self.sensorChannel else { return }
                    var arguments = values
                    arguments["sensorType"] = sensorType
                    //print("sensor#valueChange, values:\(values)")

                    channel.invokeMethod("sensor#valueChange", arguments: arguments)
                }
                sensorManager.initialize()
                print("sensor#init")
                return true
                
            case "sensor#startScan":
                
                sensorManager.startScan()
                //print("sensor#startScan")
                return true
            
            case "sensor#stopScan":
                
                sensorManager.stopScan()
                //print("sensor#stopScan")
                return true
            
            case "sensor#destory":
                
                sensorManager.destory()
                //print("sensor#destory")
                return true
            
            default:
                return false
            
        }
    }
}
 
