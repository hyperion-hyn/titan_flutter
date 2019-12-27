//
//  OnSensorValueChangeListener.swift
//  Runner
//
//  Created by naru.j on 2019/12/22.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

import Foundation

typealias OnSensorValueChangeListener = (_ sensorType: Int, _ values: Dictionary<String, Any>) -> ()
typealias BluetoothSensorBlock = (Bool) -> (Void)
