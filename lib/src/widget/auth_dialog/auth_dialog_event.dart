import 'package:meta/meta.dart';
import 'package:titan/src/components/auth/bloc/auth_event.dart';

@immutable
abstract class AuthDialogEvent {}

class ShowFaceAuthEvent extends AuthDialogEvent {
  final int remainCount;
  final int maxCount;

  ShowFaceAuthEvent({this.remainCount, this.maxCount});
}

class ShowFingerprintAuthEvent extends AuthDialogEvent {
  final int remainCount;
  final int maxCount;

  ShowFingerprintAuthEvent({this.remainCount, this.maxCount});
}

class ShowPasswordAuthEvent extends AuthDialogEvent {}

class CheckAuthConfigEvent extends AuthDialogEvent {}

class CheckBioAuthEvent extends AuthDialogEvent {}

class BioAuthStartEvent extends AuthDialogEvent {}

class ShowBioAuthRemainCountEvent extends AuthDialogEvent {
  final int remainCount;

  ShowBioAuthRemainCountEvent(this.remainCount);
}

class AuthCompletedEvent extends AuthDialogEvent {}
