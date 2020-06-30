import 'package:meta/meta.dart';

@immutable
abstract class AuthDialogState {}

class InitialAuthDialogState extends AuthDialogState {}

class CheckBioAuthState extends AuthDialogState {}

class ShowFaceAuthState extends AuthDialogState {
  final int remainCount;
  final int maxCount;

  ShowFaceAuthState({this.remainCount, this.maxCount});
}

class ShowFingerprintAuthState extends AuthDialogState {
  final int remainCount;
  final int maxCount;

  ShowFingerprintAuthState({this.remainCount, this.maxCount});
}

class ShowPasswordAuthState extends AuthDialogState {}

class BioAuthState extends AuthDialogState {}

class ShowBioAuthRemainCountState extends AuthDialogState {
  final int remainCount;

  ShowBioAuthRemainCountState(this.remainCount);
}

class AuthCompletedState extends AuthDialogState {}
