//
//  WalletPluginInterface.swift
//  Runner
//
//  Created by moo on 2019/10/22.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

import Foundation
import Flutter

class WalletPluginInterface {
    func setMethodCallHandler(call: FlutterMethodCall, result: FlutterResult) -> Bool {
        
        switch(methodCall.method) {
        //产生助记词
        case "wallet_make_mnemonic":
            print("hello")
            return true
        }
        return false
    }
}
