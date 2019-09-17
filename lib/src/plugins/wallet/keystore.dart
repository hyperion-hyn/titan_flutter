import 'package:flutter/widgets.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/plugins/wallet/wallet_core.dart';

enum KeyStoreType { TrustWallet, V3 }

abstract class KeyStore {
  String fileName;
  final KeyStoreType type;

  KeyStore({this.fileName, this.type});

  Future<dynamic> load() async {
    //TODO
    var map = await WalletCore.loadKeyStore(this.fileName);
    print(map);
  }

  Future<bool> changePassword({
    @required oldPassword,
    @required newPassword,
    name,
  }) async {
    try {
      var newName = await WalletCore.changeKeyStorePassword(
          fileName: this.fileName,
          oldPassword: oldPassword,
          newPassword: newPassword,
          name: name);
      this.fileName = newName;
      return true;
    } catch (e) {
      logger.e(e);
    }
    return false;
  }
}

///https://ethereum.stackexchange.com/questions/37150/ethereum-wallet-v3-format
class V3KeyStore extends KeyStore {
//  Account account;
  int version;
  String id;

  V3KeyStore._({
    @required String fileName,
//    this.account,
    this.id,
    this.version,
  }) : super(fileName: fileName);

  V3KeyStore({@required String fileName})
      : super(fileName: fileName, type: KeyStoreType.V3);

  factory V3KeyStore.fromJson(Map<dynamic, dynamic> json) {
    return V3KeyStore._(
      fileName: json['fileName'],
      id: json['id'],
      version: json['version'],
//        account: Account.fromJson(json['account'])
    );
  }

  @override
  String toString() {
    return 'V3KeyStore{version: $version, id: $id}';
  }
}

class TrustWalletKeyStore extends KeyStore {
  String name;
  bool isMnemonic;
  String identifier;

//  int accountCount;
//  List<Account> accounts;

  TrustWalletKeyStore._(
      {@required String fileName,
      this.name,
//      this.accountCount,
//      this.accounts,
      this.identifier,
      this.isMnemonic})
      : super(fileName: fileName);

  TrustWalletKeyStore({@required String fileName})
      : super(fileName: fileName, type: KeyStoreType.TrustWallet);

  factory TrustWalletKeyStore.fromJson(Map<dynamic, dynamic> json) {
    return TrustWalletKeyStore._(
      fileName: json['fileName'],
//        accountCount: json['accountCount'],
      identifier: json['identifier'],
      isMnemonic: json['isMnemonic'],
      name: json['name'],
//        accounts: List<Account>.from(json['accounts']
//            .map((accountMap) => Account.fromJson(accountMap)))
    );
  }

  @override
  Future<bool> changePassword({oldPassword, newPassword, name}) async {
    var isSuccess = await super.changePassword(
        oldPassword: oldPassword, newPassword: newPassword, name: name);
    if (isSuccess) {
      this.name = name;
    }
    return isSuccess;
  }

  @override
  String toString() {
    return 'TrustWalletKetStore{name: $name, isMnemonic: $isMnemonic, identifier: $identifier}';
  }
}

//class KeyStoreUtil {
//  static Future<List<KeyStore>> scanAllKeystore() async {
//    var keyStoreMaps = await WalletCore.scanKeyStores();
//    var list = <KeyStore>[];
//    for (var map in keyStoreMaps) {
////      logger.i(map);
//      if (map['type'] == KeyStoreType.TrustWallet.index) {
//        list.add(TrustWalletKeyStore.fromJson(map));
//      } else if (map['type'] == KeyStoreType.V3.index) {
//        list.add(V3KeyStore.fromJson(map));
//      }
//    }
//
//    return list;
//  }
//
//  static Future<KeyStore> loadKeyStore(String fileName) async {
//    var map = await WalletCore.loadKeyStore(fileName);
//    if (map['type'] == KeyStoreType.TrustWallet.index) {
//      return TrustWalletKeyStore.fromJson(map);
//    } else if (map['type'] == KeyStoreType.V3.index) {
//      return V3KeyStore.fromJson(map);
//    }
//    return null;
//  }
//}
