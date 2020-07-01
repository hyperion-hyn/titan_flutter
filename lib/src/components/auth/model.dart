import 'package:equatable/equatable.dart';
import 'package:local_auth/local_auth.dart';

class AuthConfigModel extends Equatable {
  bool setBioAuthAsked = false;
  bool bioAuthEnabled = false;
  int lastAuthDate = 0;
  bool useFace = false;
  bool useFingerprint = false;
  List<BiometricType> availableBiometricTypes = List();

  AuthConfigModel({
    this.setBioAuthAsked = false,
    this.lastAuthDate = 0,
    this.bioAuthEnabled = false,
    this.useFace = false,
    this.useFingerprint = false,
    this.availableBiometricTypes,
  });

  @override
  // TODO: implement props
  List<Object> get props => [bioAuthEnabled];

  factory AuthConfigModel.fromJson(Map<String, dynamic> json) {
    return AuthConfigModel();
  }
}
