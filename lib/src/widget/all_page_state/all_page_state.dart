import 'package:meta/meta.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/config/consts.dart';

@immutable
abstract class AllPageState {}

class LoadingState extends AllPageState {}

class LoadEmptyState extends AllPageState {}

class LoadFailState extends AllPageState {
  String message = S.of(Keys.rootKey.currentContext).failed_to_load;

  LoadFailState({String messageStr}){
    if(messageStr != null) {
      this.message = messageStr;
    }
  }
}