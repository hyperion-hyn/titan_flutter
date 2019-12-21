//
//  CellularSensor.swift
//  Runner
//
//  Created by 蔡景松 on 2019/12/20.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

import Foundation
import CoreTelephony

class CellularSensor: NSObject, Sensor {
    
 
    var type = SensorType.CELLULAR
    
    func initialize() {
        // 获取运营商信息
        let info = CTTelephonyNetworkInfo()
        if #available(iOS 12.0, *) {
            let carrier = info.serviceSubscriberCellularProviders
            if #available(iOS 13.0, *) {
                print("dataServiceIdentifier: \(info.dataServiceIdentifier), carried: \(carrier)")
            } else {
                // Fallback on earlier versions
            }
            
            // 如果运营商变化将更新运营商输出
            info.serviceSubscriberCellularProvidersDidUpdateNotifier = {(update: String) in
                print("update: \(update)")
            }
            
            // 输出手机的数据业务信息
            let currentInfo = info.serviceCurrentRadioAccessTechnology
            print("currentInfo: \(currentInfo)")
        } else {
            // Fallback on earlier versions
        }
    }
    
    func startScan() {
        
    }
    
    func stopScan() {
        
    }
    
    func destory() {
        
    }
    
}



/*
NSArray *typeStrings2G = @[CTRadioAccessTechnologyEdge,
                           CTRadioAccessTechnologyGPRS,
                           CTRadioAccessTechnologyCDMA1x];

NSArray *typeStrings3G = @[CTRadioAccessTechnologyHSDPA,
                           CTRadioAccessTechnologyWCDMA,
                           CTRadioAccessTechnologyHSUPA,
                           CTRadioAccessTechnologyCDMAEVDORev0,
                           CTRadioAccessTechnologyCDMAEVDORevA,
                           CTRadioAccessTechnologyCDMAEVDORevB,
                           CTRadioAccessTechnologyeHRPD];

NSArray *typeStrings4G = @[CTRadioAccessTechnologyLTE];

arried: Optional(["0000000100000001": CTCarrier (0x283d99110) {
    Carrier name: [中国联通]
    Mobile Country Code: [460] --> MCC
    Mobile Network Code:[01]   --> MNC
    ISO Country Code:[cn]
    Allows VOIP? [YES]
}
])
currentInfo: Optional(["0000000100000001": "CTRadioAccessTechnologyHSDPA"])
*/

