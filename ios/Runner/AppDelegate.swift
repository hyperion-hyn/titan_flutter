import UIKit
import Flutter
import Mobile
import RxSwift

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    private lazy var callChannel: FlutterMethodChannel = {
        let controller = window.rootViewController as! FlutterViewController
        return FlutterMethodChannel(name: "org.hyn.titan/call_channel", binaryMessenger: controller.binaryMessenger)
    }()
    
    private lazy var encryptService: EncryptionService = EthEncryptionService()
    
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
            switch(methodCall.method) {
            case "initKeyPair":
                if self.encryptService.publicKey == nil || Date().milliStamp > self.encryptService.expireTime {
                    guard let expired = methodCall.arguments as? Int64 else { return }
                    self.generateKey(expired: expired, result: result)
                } else {
                    result(self.encryptService.publicKey)
                }
            case "genKeyPair":
                let expired = methodCall.arguments as? Int64 ?? 3600
                self.generateKey(expired: expired, result: result)
            case "getPublicKey":
                result(self.encryptService.publicKey)
            case "getExpired":
                result(self.encryptService.expireTime)
            case "encrypt":
                guard let params = methodCall.arguments as? [String: String] else {
                    result(FlutterError.init(code: "-1", message: "params is not [String: String]", details: nil))
                    return
                }
                guard let pub = params["pub"], let message = params["message"] else {
                    result(FlutterError.init(code: "-1", message: "params can not find message", details: nil))
                    return
                }
                self.encryptService.encrypt(publicKeyStr: pub, message: message)
                    .subscribe(onNext: { (ciphertext) in
                        result(ciphertext)
                    }, onError: { error in
                        result(FlutterError.init(code: "-1", message: error.localizedDescription, details: nil))
                    }, onCompleted: nil, onDisposed: nil)
            case "decrypt":
                guard let ciphertext = methodCall.arguments as? String else {
                    result(FlutterError.init(code: "-1", message: "params is not String", details: nil))
                    return
                }
                self.encryptService.decrypt(ciphertext: ciphertext)
                    .subscribe(onNext: { (message) in
                        result(message)
                    }, onError: { error in
                        result(FlutterError.init(code: "-1", message: error.localizedDescription, details: nil))
                    }, onCompleted: nil, onDisposed: nil)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }
    
    private func generateKey(expired: Int64, result: @escaping FlutterResult) {
        let disposeBag = DisposeBag()
        self.encryptService.generateKeyPairAndStore(expireAt: expired)
            .subscribe(onNext: { (isSuccess) in
                if let pub = self.encryptService.publicKey {
                    result(pub)
                }
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
    }
}
