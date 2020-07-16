import 'package:meta/meta.dart';

@immutable
abstract class BioAuthDialogState {}

class InitialAuthDialogState extends BioAuthDialogState {}

class CheckBioAuthState extends BioAuthDialogState {}

class ShowFaceAuthState extends BioAuthDialogState {
  final int remainCount;
  final int maxCount;

  ShowFaceAuthState({this.remainCount, this.maxCount});
}

class ShowFingerprintAuthState extends BioAuthDialogState {
  final int remainCount;
  final int maxCount;

  ShowFingerprintAuthState({this.remainCount, this.maxCount});
}

class ShowPasswordAuthState extends BioAuthDialogState {}

class BioAuthState extends BioAuthDialogState {}

class ShowBioAuthRemainCountState extends BioAuthDialogState {
  final int remainCount;

  ShowBioAuthRemainCountState(this.remainCount);
}

class AuthCompletedState extends BioAuthDialogState {
  final bool result;

  AuthCompletedState(this.result);
}
