//
//  Sensor.swift
//  Runner
//
//  Created by 蔡景松 on 2019/12/20.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

import Foundation

protocol Sensor: NSObjectProtocol {
    
    var onSensorChange: OnSensorValueChangeListener! { get set }

    func initialize()
    func startScan()
    func stopScan()
    func destory()
}


class SensorType {
    static let WIFI = -1
    static let BLUETOOTH = -2
    static let GPS = -3
    static let GNSS = -4
    static let CELLULAR = -5
}
