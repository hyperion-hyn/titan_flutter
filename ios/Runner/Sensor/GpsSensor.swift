//
//  GpsSensor.swift
//  Runner
//
//  Created by naru.j on 2019/12/20.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

import Foundation
import CoreLocation

class GpsSensor: NSObject, Sensor {
    
    var onSensorChange: OnSensorValueChangeListener!
        
    var _locationManager: CLLocationManager!

    var type = SensorType.GPS
    
    func initialize() {
        
        _locationManager = CLLocationManager()
        _locationManager.delegate = self
        _locationManager.requestWhenInUseAuthorization()
    }
    
    func startScan() {
        
        guard _locationManager != nil else {
            return
        }
        if CLLocationManager.locationServicesEnabled() {
            print("【定位】定位可用，✅")

            _locationManager.startUpdatingLocation()
            _locationManager.distanceFilter = kCLDistanceFilterNone
            _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        } else {
            print("【定位】定位不可用，❌")
        }
    }
    
    func stopScan() {
        _locationManager.stopUpdatingLocation()
    }
    
    func destory() {
        _locationManager = nil
    }
    
}


// MARK: - 定位
extension GpsSensor: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status != .denied {
            print("【定位】定位可用，✅")
        } else {
            print("【定位】定位不可用，❌")
        }
    }
    
//    【定位】获取定位成功，✅， location:[<+23.12097590,+113.32206639> +/- 65.00m (speed -1.00 mps / course -1.00) @ 2019/12/2, 5:14:24 PM China Standard Time]

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //print("【定位】获取定位成功，✅， location:\(locations)")
        
        guard let location = locations.first else { return }
        let values: [String : Any] = [
            "lat": location.coordinate.latitude,
            "lon": location.coordinate.longitude,
            "altitude": location.altitude,
            "horizontalAccuracy": location.horizontalAccuracy,
            "verticalAccuracy": location.verticalAccuracy,
            "course": location.course,
            "speed": location.speed,
            "time": location.timestamp.milliStamp
        ]
        if onSensorChange != nil {
            onSensorChange(type, values)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("【定位】获取定位失败，❌")
    }
    
    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        return true
    }
    
     
}
 
