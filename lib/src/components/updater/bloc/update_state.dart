import 'package:meta/meta.dart';
import 'package:titan/src/data/entity/app_update_info.dart';
import 'package:titan/src/data/entity/update.dart';

AppData kAppData = AppData();

@immutable
abstract class UpdateState {
  AppData get appData => kAppData;
}

class InitialAppState extends UpdateState {}

class UpdateCheckState extends UpdateState {
  final bool isManual;

  UpdateCheckState({
    AppUpdateInfo appUpdateInfo,
    bool isError,
    bool isChecking,
    this.isManual = false,
  }) {
    appData.appUpdateInfo = appUpdateInfo;
    appData.isError = isError ?? appData.isError;
    appData.isChecking = isChecking ?? appData.isChecking;
  }

  @override
  String toString() {
    return 'UpdateState(isChecking: ${appData.isChecking}, isError: ${appData.isError}, versionModel: ${appData.appUpdateInfo})';
  }
}

class AppData {
  //-------------
  //  update
  //-------------
  bool isChecking = false;
  AppUpdateInfo appUpdateInfo;
  bool isError = false;

  AppData({
    this.appUpdateInfo,
    this.isError,
    this.isChecking,
  });

  @override
  String toString() {
    return 'AppData(isChecking: $isChecking, isError: $isError,versionModel: $appUpdateInfo)';
  }
}
