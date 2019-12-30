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
  }

  Future<bool> changePassword({
    @required oldPassword,
    @required newPassword,
    name,
  }) async {
    try {
      var newName = await WalletChannel.changeKeyStorePassword(
        fileName: this.fileName,
        oldPassword: oldPassword,
        newPassword: newPassword,
        name: name,
      );
      this.fileName = newName;
      this.name = name;
      return true;
    } catch (e) {
      logger.e(e);
    }
    return false;
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
