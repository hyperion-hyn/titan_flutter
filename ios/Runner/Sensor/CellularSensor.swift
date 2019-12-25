//
//  CellularSensor.swift
//  Runner
//
//  Created by naru.j on 2019/12/20.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

import Foundation
import CoreTelephony

class CellularSensor: NSObject, Sensor {
    
    var onSensorChange: OnSensorValueChangeListener!

    var type = SensorType.CELLULAR
   
    
    func initialize() {
            
        // 获取运营商信息
        let info = CTTelephonyNetworkInfo()
        if #available(iOS 12.0, *) {
            let carrier = info.serviceSubscriberCellularProviders
            if #available(iOS 13.0, *) {
                //print("dataServiceIdentifier: \(info.dataServiceIdentifier), carried: \(carrier)")
                
                guard let carrier = carrier?.values.first else { return }
                let values: [String : Any] = [
                    "carrierName": carrier.carrierName ?? "",
                    "mcc": carrier.mobileCountryCode ?? "",
                    "mnc": carrier.mobileNetworkCode ?? "",
                    "icc": carrier.isoCountryCode ?? "",
                    "allowsVOIP": carrier.allowsVOIP,
                    "type": getMobileType(rat: info.currentRadioAccessTechnology)
                ]
                if onSensorChange != nil {
                    onSensorChange(type, values)
                }
            } else {
                // Fallback on earlier versions
            }
            
            // 如果运营商变化将更新运营商输出
            info.serviceSubscriberCellularProvidersDidUpdateNotifier = {(update: String) in
                print("update: \(update)")
            }
            
            // 输出手机的数据业务信息
//            let currentInfo = info.currentRadioAccessTechnology
//            print("currentInfo: \(currentInfo)")
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
    
    func getMobileType(rat: String? = "") -> String {
        guard let rat = rat else { return "2G"};
        
        switch rat {
        case CTRadioAccessTechnologyEdge,
             CTRadioAccessTechnologyGPRS,
             CTRadioAccessTechnologyCDMA1x:
            return "2G"
            
        case CTRadioAccessTechnologyHSDPA,
            CTRadioAccessTechnologyWCDMA,
            CTRadioAccessTechnologyHSUPA,
            CTRadioAccessTechnologyCDMAEVDORev0,
            CTRadioAccessTechnologyCDMAEVDORevA,
            CTRadioAccessTechnologyCDMAEVDORevB,
            CTRadioAccessTechnologyeHRPD:
            return "3G"
            
        case CTRadioAccessTechnologyLTE:
            return "4G"

        default:
            return rat
        }
    }
    
}

