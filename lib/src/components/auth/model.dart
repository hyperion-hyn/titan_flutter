import 'package:equatable/equatable.dart';
import 'package:local_auth/local_auth.dart';

class AuthConfigModel extends Equatable {
  final bool requestedAlready;
  final bool bioAuthEnabled;
  final bool useFace;
  final bool useFingerprint;
  final List<BiometricType> availableBiometricTypes;

  AuthConfigModel({
    this.requestedAlready,
    this.bioAuthEnabled,
    this.useFace,
    this.useFingerprint,
    this.availableBiometricTypes,
  });

  @override
  // TODO: implement props
  List<Object> get props => [bioAuthEnabled];

  factory AuthConfigModel.fromJson(Map<String, dynamic> json) {
    return AuthConfigModel(
      bioAuthEnabled: json['bioAuthEnabled'],
    );
  }
}
