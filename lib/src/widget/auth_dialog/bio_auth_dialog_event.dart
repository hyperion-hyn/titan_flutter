import 'package:meta/meta.dart';
import 'package:titan/src/components/auth/bloc/auth_event.dart';

@immutable
abstract class BioAuthDialogEvent {}

class ShowFaceAuthEvent extends BioAuthDialogEvent {
  final int remainCount;
  final int maxCount;

  ShowFaceAuthEvent({this.remainCount, this.maxCount});
}

class ShowFingerprintAuthEvent extends BioAuthDialogEvent {
  final int remainCount;
  final int maxCount;

  ShowFingerprintAuthEvent({this.remainCount, this.maxCount});
}

class ShowPasswordAuthEvent extends BioAuthDialogEvent {}

class CheckAuthConfigEvent extends BioAuthDialogEvent {}

class CheckBioAuthEvent extends BioAuthDialogEvent {}

class BioAuthStartEvent extends BioAuthDialogEvent {}

class ShowBioAuthRemainCountEvent extends BioAuthDialogEvent {
  final int remainCount;

  ShowBioAuthRemainCountEvent(this.remainCount);
}

class AuthCompletedEvent extends BioAuthDialogEvent {
  final bool result;

  AuthCompletedEvent(this.result);
}
