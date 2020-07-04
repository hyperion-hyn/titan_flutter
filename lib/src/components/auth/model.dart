import 'package:equatable/equatable.dart';
import 'package:local_auth/local_auth.dart';

class AuthConfigModel extends Equatable {
  String walletFileName;
  bool setBioAuthAsked = false;
  int lastBioAuthTime = 0;
  bool useFace = false;
  bool useFingerprint = false;
  List<BiometricType> availableBiometricTypes = List();

  AuthConfigModel({
    this.walletFileName,
    this.setBioAuthAsked,
    this.lastBioAuthTime,
    this.useFace,
    this.useFingerprint,
    this.availableBiometricTypes,
  });

  @override
  // TODO: implement props
  List<Object> get props => [lastBioAuthTime];

  factory AuthConfigModel.fromJson(Map<String, dynamic> json) {
    try {
      List<BiometricType> biometricTypes = List();
      (json['availableBiometricTypes'] as List).forEach((bioAuthType) {
        if (bioAuthType == BioAuthType.face) {
          biometricTypes.add(BiometricType.face);
        } else if (bioAuthType == BioAuthType.fingerprint) {
          biometricTypes.add(BiometricType.fingerprint);
        } else if (bioAuthType == BioAuthType.iris) {
          biometricTypes.add(BiometricType.iris);
        }
      });
      return AuthConfigModel(
        walletFileName: json['walletFileName'],
        setBioAuthAsked: json['setBioAuthAsked'],
        lastBioAuthTime: json['lastBioAuthTime'],
        useFace: json['useFace'],
        useFingerprint: json['useFingerprint'],
        availableBiometricTypes: biometricTypes,
      );
    } catch (e) {
      return AuthConfigModel(
        walletFileName: 'default',
        setBioAuthAsked: false,
        lastBioAuthTime: 0,
        useFace: false,
        useFingerprint: false,
        availableBiometricTypes: List(),
      );
    }
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> json = Map();
    json['walletFileName'] = this.walletFileName;
    json['setBioAuthAsked'] = this.setBioAuthAsked;
    json['lastBioAuthTime'] = this.lastBioAuthTime;
    json['useFace'] = this.useFace;
    json['useFingerprint'] = this.useFingerprint;
    List<int> bioAuthTypes = List();
    this.availableBiometricTypes.forEach((biometricType) {
      if (biometricType == BiometricType.face) {
        bioAuthTypes.add(BioAuthType.face);
      } else if (biometricType == BiometricType.fingerprint) {
        bioAuthTypes.add(BioAuthType.fingerprint);
      } else if (biometricType == BiometricType.iris) {
        bioAuthTypes.add(BioAuthType.iris);
      }
    });
    json['availableBiometricTypes'] = bioAuthTypes;
    return json;
  }
}

///Use BioAuthType to store BiometricType
class BioAuthType {
  static const int face = 0;
  static const int fingerprint = 1;
  static const int iris = 2;
}
