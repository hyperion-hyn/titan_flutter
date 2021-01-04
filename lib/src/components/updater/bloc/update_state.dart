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

  /*
  UpdateCheckStateNew({AppUpdateInfo appUpdateInfo, bool isError, bool isChecking, this.isManual = false}) {
    appData.appUpdateInfo = appUpdateInfo;
    appData.isError = isError ?? appData.isError;
    appData.isChecking = isChecking ?? appData.isChecking;
  }
  */

  UpdateCheckState({UpdateEntity updateEntity, bool isError, bool isChecking, this.isManual = false}) {
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

/*
class AppDataNew {
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
*/