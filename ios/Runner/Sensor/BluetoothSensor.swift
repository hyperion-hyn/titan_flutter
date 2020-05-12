//
//  BluetoothSensor.swift
//  Runner
//
//  Created by naru.j on 2019/12/20.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

import Foundation

/*
import CoreBluetooth

class BluetoothSensor: NSObject, Sensor {
    
    static let share = BluetoothSensor()
    
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
        //print("[BluetoothSensor] -->\(self), onSensorChange: \(onSensorChange)")
    }
    
    func startScan() {
        guard bluetoothManager.state == .poweredOn else {
            return
        }
        
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
        guard bluetoothManager.state == .poweredOn else {
            return
        }
        bluetoothManager.stopScan()
    }
    
    func destory() {
        bluetoothManager = nil
    }
    
}

// MARK: - Bluetooth
extension BluetoothSensor: CBCentralManagerDelegate {
//    2019-12-25 03:05:10.497944+0800 Runner[659:119163] [CoreBluetooth] API MISUSE: <CBCentralManager: 0x2815aeca0> can only accept this command while in the powered on state

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        isEnable = central.state == .poweredOn;
 
        if central.state == .poweredOn {
            print("【蓝牙】蓝牙设备开着，✅")
            if onSensorChange != nil {
                startScan()
            }
        }
        
        print("【蓝牙】蓝牙设备, state:\(central.state.rawValue)")        
    }
    
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        
        print("【蓝牙】willRestoreState，\(dict)")
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
  
        //print("\n【蓝牙】didDiscover，name: \(peripheral)，advertisementData: \(advertisementData) ，rssi: \(RSSI), \n self:\(self)")
        
        // Todo: jison_1222
        let values: [String : Any] = [
            "name": peripheral.name ?? "",
            "identifier": peripheral.identifier.uuidString,
            "rssi": RSSI,
            //"advertisementData": advertisementData
        ]
        if onSensorChange != nil {
            onSensorChange(type, values)
        }
    }
}
*/


class BluetoothSensor: NSObject {
    
    var isEnable: Bool = true

    func initialize() {
         
        //print("[BluetoothSensor] -->\(self), onSensorChange: \(onSensorChange)")
    }
    
    func startScan() {
         
    }
    
    func stopScan() {
         
    }
    
    func destory() {
         
    }
    
}
