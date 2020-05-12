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
        
        /*
             若用户直接启动，lauchOptions内无数据;
             若由其他应用程序通过openURL:启动，则UIApplicationLaunchOptionsURLKey对应的对象为启动URL（NSURL）,UIApplicationLaunchOptionsSourceApplicationKey对应启动的源应用程序的bundle ID (NSString)；
             若由本地通知启动，则UIApplicationLaunchOptionsLocalNotificationKey对应的是为启动应用程序的的本地通知对象(UILocalNotification)；
             若由远程通知启动，则UIApplicationLaunchOptionsRemoteNotificationKey对应的是启动应用程序的的远程通知信息userInfo（NSDictionary）；
             其他key还有UIApplicationLaunchOptionsAnnotationKey,UIApplicationLaunchOptionsLocationKey,
             UIApplicationLaunchOptionsNewsstandDownloadsKey。
        */
        
        if let url = launchOptions?[UIApplication.LaunchOptionsKey.url] as? URL{
             urlLauncherAction(url: url)
        }
        
        let isLaunch = super.application(application, didFinishLaunchingWithOptions: launchOptions)

        return isLaunch
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
                    
                    /*
                    BluetoothSensor.share.initialize()
                    
                    var isEnable = BluetoothSensor.share.isEnable
                    if !isEnable {
                        Thread.sleep(forTimeInterval: 0.667)
                        isEnable = BluetoothSensor.share.isEnable
                        result(isEnable)
                    } else {
                        result(true)
                    }*/

                    result(true)

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
        urlLauncherAction(url: url)
        
        return true
    }
    
       private func urlLauncherAction(url: URL) {
    //        [Appdelegate] -->open url, url:starrich://contract/detail?contractId=9&key=eyJhIjoiMHg0MjNiMzQwRjgwMzE3NDAwYkE1NzFiMzY1Q2JGODM4NThlRmJiN0I0IiwiYiI6ImRldGFpbCIsImMiOmZhbHNlfQ==

    /*
      <key>CFBundleURLTypes</key>
      <array>
          <dict>
              <key>CFBundleTypeRole</key>
              <string>Editor</string>
              <key>CFBundleURLSchemes</key>
              <array>
                  <string>starrich</string>
              </array>
          </dict>
      </array>
    */
            
            var protocolStr : String = ""
            if let types = Bundle.main.object(forInfoDictionaryKey: "CFBundleURLTypes") as? Array<Any>, let dict = types.first as? [String:Any] {
                if let protocolHead = dict["CFBundleURLSchemes"] as? Array<String>, let value = protocolHead.first {
                    protocolStr = value
                }
            }
            

            print("[Appdelegate] -->protocolStr:\(protocolStr), open url, url:\(url)")


            // TODO: 特别注意！！！！！！！！
            let urlString = url.absoluteString
            if !urlString.hasPrefix("\(protocolStr)://") {
                return
            }
            let urlComponents = urlString.components(separatedBy: "?")
            if let protocolFirst = urlComponents.first, let detailLast = urlComponents.last {
            
                // e.g: starrich://contract/detail
                let protocolComponents = protocolFirst.components(separatedBy: "//").last!.components(separatedBy: "/")
                
                // e.g: contract
                let type = protocolComponents.first!
                
                // e.g: detail
                let subType = protocolComponents.last!
                
                // e.g: contractId=9&key=xxx
                let detailComponents = detailLast.components(separatedBy: "&")
                var content: [String:Any] = [:];
                for item in detailComponents {
                    let subcomponents = item.components(separatedBy: "=")
                    content[subcomponents.first!] = subcomponents.last!
                }
                
                let arguments: [String:Any] = [
                    "type": type,
                    "subType": subType,
                    "content": content
                ]
                print("[Appdelegate] -->open url, content:\(content), arguments:\(arguments)")

                self.callChannel.invokeMethod("urlLauncher", arguments: arguments)
            }
        }
    
}


