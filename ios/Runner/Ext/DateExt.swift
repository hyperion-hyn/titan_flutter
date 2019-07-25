//
//  DateExt.swift
//  Runner
//
//  Created by moo on 2019/7/24.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

import Foundation

extension Date {
    
    /// 获取当前 秒级 时间戳 - 10位
    var timeStamp : Int {
        let timeInterval: TimeInterval = self.timeIntervalSince1970
        return Int(timeInterval)
    }
    
    /// 获取当前 毫秒级 时间戳 - 13位
    var milliStamp : Double {
        return self.timeIntervalSince1970
    }
}
