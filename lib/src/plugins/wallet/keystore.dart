import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/plugins/wallet/wallet_channel.dart';

part 'keystore.g.dart';

@JsonSerializable()
class KeyStore {
  String name;
  bool isMnemonic;
  String identifier;
  String fileName;

  Future<dynamic> load() async {
    var map = await WalletChannel.loadKeyStore(this.fileName);
    print(map);
    return map;
  }

  Future<bool> updateWallet({
    @required password,
    newPassword,
    name,
  }) async {
    if (newPassword == null) {
      newPassword = password;
    }
    await WalletChannel.updateWallet(
      fileName: this.fileName,
      oldPassword: password,
      newPassword: newPassword,
      name: name,
    );
    this.name = name;
    return true;
  }

  KeyStore._({
    @required this.fileName,
    this.name,
    this.identifier,
    this.isMnemonic,
  });

  KeyStore({@required this.fileName});

  factory KeyStore.fromDynamicMap(Map<dynamic, dynamic> json) {
    return KeyStore._(
      fileName: json['fileName'],
      identifier: json['identifier'],
      isMnemonic: json['isMnemonic'],
      name: json['name'],
    );
  }

  factory KeyStore.fromJson(Map<String, dynamic> json) => _$KeyStoreFromJson(json);

  Map<String, dynamic> toJson() => _$KeyStoreToJson(this);

  @override
  String toString() {
    return 'TrustWalletKetStore{name: $name, isMnemonic: $isMnemonic, identifier: $identifier}';
  }
}
