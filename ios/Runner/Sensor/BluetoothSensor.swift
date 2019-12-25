//
//  BluetoothSensor.swift
//  Runner
//
//  Created by 蔡景松 on 2019/12/20.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

import Foundation
import CoreBluetooth

class BluetoothSensor: NSObject, Sensor {
    
    var onSensorChange: OnSensorValueChangeListener!
    
    var bluetoothManager: CBCentralManager!

    var type = SensorType.BLUETOOTH
    
    var isEnable: Bool = false
    
    func initialize() {
        let queue = DispatchQueue(label: "centralQueue")
        let options: [String: Any] = [
            CBCentralManagerOptionShowPowerAlertKey: true,
            CBCentralManagerOptionRestoreIdentifierKey: "unique identifier",
        ]
        bluetoothManager = CBCentralManager(delegate: self, queue: queue, options: options)
    }
    
    func startScan() {
//        guard bluetoothManager.state == .poweredOn else {
//            return
//        }
        
        guard !bluetoothManager.isScanning else {
            return
        }
        let options: [String: Any] = [
            CBCentralManagerOptionShowPowerAlertKey: true,
            CBCentralManagerScanOptionAllowDuplicatesKey: false,
        ]
        bluetoothManager.scanForPeripherals(withServices: nil, options: options)
    }
    
    func stopScan() {
//        guard bluetoothManager.state == .poweredOn else {
//            return
//        }
        bluetoothManager.stopScan()
    }
    
    func destory() {
        bluetoothManager = nil
    }
    
}

// MARK: - Bluetooth
extension BluetoothSensor: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        isEnable = central.state == .poweredOn;
        
        if central.state == .poweredOn {
            print("【蓝牙】蓝牙设备开着，✅")
            
            startScan()
        } else {
            print("【蓝牙】蓝牙设备关闭，❌")
        }
    }
    
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        
        print("【蓝牙】willRestoreState，\(dict)")
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
  
        //print("\n【蓝牙】didDiscover，name: \(peripheral)，advertisementData: \(advertisementData) ，rssi: \(RSSI), \n")
        
        // Todo: jison_1222
        let values: [String : Any] = [
            "name": peripheral.name ?? "",
            "identifier": peripheral.identifier.uuidString,
            "rssi": RSSI,
            //"advertisementData": advertisementData
        ]
        onSensorChange(type, values)
    }
}

//Utils.addIfNonNull(values, "name", deviceName)
//Utils.addIfNonNull(values, "mac", deviceHardwareAddress)
//Utils.addIfNonNull(values, "type", deviceType)

/*
【蓝牙】didDiscover，
name: <CBPeripheral: 0x281675400,
identifier = 8B4D4011-EC16-51B8-B31E-FC4D006390A5,
name = 宝宝的BeatsX, state = disconnected>，

advertisementData: ["kCBAdvDataTimestamp": 596968823.778265, "kCBAdvDataIsConnectable": 0] ，

rssi: -38,
*/


/*
let CBAdvertisementDataLocalNameKey: String
The local name of a peripheral.
 
let CBAdvertisementDataManufacturerDataKey: String
The manufacturer data of a peripheral.
 
let CBAdvertisementDataServiceDataKey: String
A dictionary that contains service-specific advertisement data.
 
let CBAdvertisementDataServiceUUIDsKey: String
An array of service UUIDs.
 
let CBAdvertisementDataOverflowServiceUUIDsKey: String
An array of UUIDs found in the overflow area of the advertisement data.
 
let CBAdvertisementDataTxPowerLevelKey: String
The transmit power of a peripheral.
 
let CBAdvertisementDataIsConnectable: String
A Boolean value that indicates whether the advertising event type is connectable.
 
let CBAdvertisementDataSolicitedServiceUUIDsKey: String
An array of solicited service UUIDs.

【蓝牙】didDiscover，
 name: <CBPeripheral: 0x281675400,
 identifier = 8B4D4011-EC16-51B8-B31E-FC4D006390A5,
 name = 宝宝的BeatsX, state = disconnected>，
 
 advertisementData: ["kCBAdvDataTimestamp": 596968823.778265, "kCBAdvDataIsConnectable": 0] ，
 
 rssi: -38,
 
 Q:
 ** Terminating app due to uncaught exception 'NSInternalInconsistencyException', reason: 'State restoration of CBCentralManager is only allowed for applications that have specified the "bluetooth-central" background mode'
 
 A: Uses Bluetooth LE accessories    bluetooth-central    iPhone 作为蓝牙中心设备使用，也就是做为 server；需要在后台不断更新蓝牙状态的
*/
