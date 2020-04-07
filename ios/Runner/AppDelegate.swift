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
        
        setupUM(launchOptions: launchOptions)
        
        if let userInfo = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] {
            msgPushAction(userInfo: userInfo as! [AnyHashable : Any])
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func printLog(_ log: String) {
        self.callChannel.invokeMethod("printLog", arguments: "\(log)")
    }
    
    private func msgPushAction(userInfo: [AnyHashable : Any]) {
        printLog("[Appdelegate] -->msgPushAction, notification:\(userInfo)")

        self.callChannel.invokeMethod("msgPush", arguments: userInfo)
    }
    
    private func flutterMethodCallHandler() {
        callChannel.setMethodCallHandler { (methodCall, result) in
            
            let wallet = self.walletPlugin.setMethodCallHandler(methodCall: methodCall, result: result)
            let encrytion = self.encrytionPlugin.setMethodCallHandler(methodCall: methodCall, result: result)
            if(!wallet && !encrytion) {
                switch methodCall.method {

                case "bluetoothEnable":
                    BluetoothSensor.share.initialize()
                    
                    var isEnable = BluetoothSensor.share.isEnable
                    if !isEnable {
                        Thread.sleep(forTimeInterval: 0.667)
                        isEnable = BluetoothSensor.share.isEnable
                        result(isEnable)
                    } else {
                        result(true)
                    }

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
    
    private func setupUM(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        
        // 1.init
        UMConfigure.initWithAppkey("5e4ca6d74ca3574666000287", channel: "App Store")
        UMConfigure.setLogEnabled(true)
        UMConfigure.setEncryptEnabled(false)
        
        // 2.Push组件基本功能配置
        let entity = UMessageRegisterEntity()
        entity.types = Int(
            UMessageAuthorizationOptions.badge.rawValue | UMessageAuthorizationOptions.sound.rawValue |
                UMessageAuthorizationOptions.alert.rawValue
        )
        
        UNUserNotificationCenter.current().delegate = self

        UMessage.registerForRemoteNotifications(launchOptions: launchOptions, entity: entity) { (granted: Bool, error: Error?) in
            self.printLog("[Appdelegate] --> setupUM, granted:\(granted), error:\(String(describing: error))")
            
            if granted {
                
            } else {
                
            }
        }
        
        // 3.log
        //UMCommonLogManager.setUp()
    }
    
    
     
    //MARK: UNUserNotificationCenterDelegate

        
    // The method will be called on the delegate only if the application is in the foreground. If the method is not implemented or the handler is not called in a timely manner then the notification will not be presented. The application can choose to have the notification presented as a sound, badge, alert and/or in the notification list. This decision should be based on whether the information in the notification is otherwise visible to the user.
    @available(iOS 10.0, *)
    override func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        printLog("[UNUserNotificationCenterDelegate] --> willPresent")
    }

        
    // The method will be called on the delegate when the user responded to the notification by opening the application, dismissing the notification or choosing a UNNotificationAction. The delegate must be set before the application returns from application:didFinishLaunchingWithOptions:.
    @available(iOS 10.0, *)
    override func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        //printLog("[UNUserNotificationCenterDelegate] --> didReceive, response:\(response)")
        
        let title = response.notification.request.content.title;
        let userInfoDict = response.notification.request.content.userInfo;
        printLog("[UNUserNotificationCenterDelegate] --> didReceive, userInfo:\(userInfoDict)")

        if let apsDict = userInfoDict["aps"] as? [AnyHashable : Any] {

            let url = apsDict["out_link"] ?? ""
            let content = apsDict["content"] ?? ""
            let userInfo:[AnyHashable : Any] = [
                "title": title,
                "out_link": url,
                "content": content,
            ]
            printLog("[UNUserNotificationCenterDelegate] --> didReceive, url:\(url)")

            msgPushAction(userInfo: userInfo)
        }

        completionHandler()
    }

        
    // The method will be called on the delegate when the application is launched in response to the user's request to view in-app notification settings. Add UNAuthorizationOptionProvidesAppNotificationSettings as an option in requestAuthorizationWithOptions:completionHandler: to add a button to inline notification settings view and the notification settings view in Settings. The notification will be nil when opened from Settings.
        @available(iOS 12.0, *)
    override func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
        printLog("[UNUserNotificationCenterDelegate] --> openSettingsFor")
    }
     
    //MARK: Appdelegate
    override func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        printLog("[Appdelegate] -->didFailToRegisterForRemoteNotifications, Error:\(error)")
    }
    
    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
           let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
           let token = tokenParts.joined()
        printLog("[Appdelegate] -->didRegisterForRemoteNotifications, DeviceToken:\(token)")

        UMessage.registerDeviceToken(deviceToken)
    }
    
    override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        printLog("[Appdelegate] -->didReceiveRemoteNotification:\(userInfo)")
        
        if application.applicationState == .active {
            printLog("[Appdelegate] -->fetchCompletionHandler， 前台")
        } else {
            UMessage.didReceiveRemoteNotification(userInfo);
            
            msgPushAction(userInfo: userInfo)
        }
    }

    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print("[Appdelegate] -->open url, url:\(url)")
        
        let urlString = url.absoluteString
        if urlString.hasPrefix("titan://contract/detail?") {
            if let detailComponentsLast = urlString.components(separatedBy: "?").last {
                let components = detailComponentsLast.components(separatedBy: "=")
                let mapValue: [String:Any] = [
                    "type": "contract",
                    "subType": "detail",
                    "content": [
                        components.first!: components.last
                    ]
                ]
                self.callChannel.invokeMethod("urlLauncher", arguments: mapValue)
            }
        }
        
        return true
    }
}


