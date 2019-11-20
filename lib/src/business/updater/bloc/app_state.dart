import 'package:meta/meta.dart';
import 'package:titan/src/model/update.dart';

AppData kAppData = AppData();

@immutable
abstract class AppState {
  AppData get appData => kAppData;
}

class InitialAppState extends AppState {}

class UpdateState extends AppState {
  final bool isManual;

  UpdateState({UpdateEntity updateEntity, bool isError, bool isChecking, this.isManual = false}) {
    appData.updateEntity = updateEntity;
    appData.isError = isError ?? appData.isError;
    appData.isChecking = isChecking ?? appData.isChecking;
  }

  @override
  String toString() {
    return 'UpdateState(isChecking: ${appData.isChecking}, isError: ${appData.isError}, versionModel: ${appData.updateEntity})';
  }
}

class AppData {
  //-------------
  //  update
  //-------------
  bool isChecking = false;
  UpdateEntity updateEntity;
  bool isError = false;

  AppData({
    this.updateEntity,
    this.isError,
    this.isChecking,
  });

  @override
  String toString() {
    return 'AppData(isChecking: $isChecking, isError: $isError,versionModel: $updateEntity)';
  }
}
