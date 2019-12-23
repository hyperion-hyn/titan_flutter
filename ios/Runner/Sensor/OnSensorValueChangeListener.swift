//
//  OnSensorValueChangeListener.swift
//  Runner
//
//  Created by 蔡景松 on 2019/12/22.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

import Foundation

//protocol OnSensorValueChangeListener {
//    func onSensorChange(sensorType: Int, values: Dictionary<String, Any>)
//}

typealias OnSensorValueChangeListener = (_ sensorType: Int, _ values: Dictionary<String, Any>) -> ()
