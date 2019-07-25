import UIKit
import Flutter
import Mobile
import RxSwift

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    private lazy var callChannel: FlutterMethodChannel = {
        let controller = window.rootViewController as! FlutterViewController
        return FlutterMethodChannel(name: "org.hyn.titan/call_channel", binaryMessenger: controller)
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
                NSLog("## 111")
                guard let expired = methodCall.arguments as? Double else { return }
                if self.encryptService.publicKey == nil || Int64(Date().milliStamp) > self.encryptService.expireTime {
                    NSLog("## 222")
                    self.generateKey(expired: expired, result: result)
                }
            case "genKeyPair":
                let expired = methodCall.arguments as? Double ?? 3600
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
        
        //        let encryptService: EncryptionService = EthEncryptionService()
        //        let disposeBag = DisposeBag()
        //        encryptService.generateKeyPairAndStore(expireAt: 3600)
        //            //        .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
        //            //        .observeOn(MainScheduler.instance)
        //            .flatMap({ isSuuccess -> Observable<String> in
        //                if isSuuccess, let pub = encryptService.publicKey {
        //                    return encryptService.encrypt(publicKeyStr: pub, message: "this is message11")
        //                }
        //                throw NSError(domain: "some thing wrong", code: -1, userInfo: nil)
        //            })
        //            .flatMap({ (ciphertext) -> Observable<String> in
        //                NSLog("ciphertext text is: \(ciphertext)")
        //                return encryptService.decrypt(ciphertext: ciphertext)
        //            })
        //            .subscribe(onNext: { text in
        //                NSLog("finally text is: \(text)")
        //            }, onError: { error in
        //                NSLog("error ----------->>")
        //                print(error)
        //                NSLog("<<----------- error")
        //            }, onCompleted: nil, onDisposed: nil)
        //            .disposed(by: disposeBag)
    }
    
    private func generateKey(expired: Double, result: @escaping FlutterResult) {
        let disposeBag = DisposeBag()
        NSLog("##&& 111")
        self.encryptService.generateKeyPairAndStore(expireAt: expired)
            .subscribe(onNext: { (isSuccess) in
                if let pub = self.encryptService.publicKey {
                    NSLog("##&& 222")
                    result(pub)
                }
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
    }
}
