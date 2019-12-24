import UIKit
import Flutter
import Mobile
import RxSwift
import CoreBluetooth

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    private lazy var callChannel: FlutterMethodChannel = {
        let controller = window.rootViewController as! FlutterViewController
        return FlutterMethodChannel(name: "org.hyn.titan/call_channel", binaryMessenger: controller.binaryMessenger)
    }()
    
    private lazy var sensorChannel: FlutterMethodChannel = {
        let controller = window.rootViewController as! FlutterViewController
        return FlutterMethodChannel(name: "org.hyn.titan/sensor_call_channel", binaryMessenger: controller.binaryMessenger)
    }()
    
    private lazy var walletPlugin: WalletPluginInterface = WalletPluginInterface()
    
    private lazy var sensorPlugin: SensorPluginInterface = {
        let plugin = SensorPluginInterface()
        plugin.sensorChannel = sensorChannel
        return plugin
    }()

    private lazy var encrytionPlugin: EncrytionPluginInterface = EncrytionPluginInterface()

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        
        flutterMethodCallHandler()
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func flutterMethodCallHandler() {
        callChannel.setMethodCallHandler { (methodCall, result) in
            let wallet = self.walletPlugin.setMethodCallHandler(methodCall: methodCall, result: result)
            let encrytion = self.encrytionPlugin.setMethodCallHandler(methodCall: methodCall, result: result)
            if(!wallet && !encrytion) {
                switch methodCall.method {
//                case "wifiEnable":
//                    result(true)
//                    break
                    
                case "bluetoothEnable":
                    result(CBCentralManager().state == .poweredOn)
                    break
                    
                default:
                    result(FlutterMethodNotImplemented)
                }
                result(FlutterMethodNotImplemented)
            }
        }
        
        sensorChannel.setMethodCallHandler { (methodCall, result) in
            let sensor = self.sensorPlugin.setMethodCallHandler(methodCall: methodCall, result: result)
            if(!sensor) {
                result(FlutterMethodNotImplemented)
            }
        }
    }
    
    
}
