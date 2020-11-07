import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:package_info/package_info.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/components/updater/bloc/bloc.dart';
import 'package:titan/src/data/entity/update.dart';
import 'package:titan/src/utils/utils.dart';

//const APK_NAME = 'titan.apk';

class UpdaterComponent extends StatefulWidget {
  final Widget child;

  UpdaterComponent({Key key, this.child}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _UpdaterComponentState();
  }
}

class _UpdaterComponentState extends State<UpdaterComponent> {
  StreamSubscription _appBlocSubscription;

//  String taskId;

  @override
  void initState() {
    super.initState();

    /*
    FlutterDownloader.registerCallback((id, status, progress) async {
      if (taskId == id) {
        print('download process $progress, $status');
        if (status == DownloadTaskStatus.complete) {
          var apkPath = await _getApkPath();
          _installApk(apkPath);
        }
      }
    });
    */
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_appBlocSubscription == null) {
      _appBlocSubscription = BlocProvider.of<UpdateBloc>(context)?.listen((UpdateState state) async {
        if (state is UpdateCheckState) {
          if (state.appData.updateEntity != null) {
            PackageInfo packageInfo = await PackageInfo.fromPlatform();
            if (int.parse(packageInfo.buildNumber) < state.appData.updateEntity.build) {
              _showUpdateDialog(state.appData.updateEntity);
            } else {
              print('[updater] 已经是最新版本');
              if (state.isManual) {
                Fluttertoast.showToast(msg: S.of(context).latest_version_tip);
              }
            }
          }
        }
      });
    }
  }

  void _showUpdateDialog(UpdateEntity updateEntity) async {
//    var hasDownloaded = await _hasDownloaded(updateEntity);
    await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        String title = S.of(context).new_update_available;
        String message = updateEntity.content;
//        String btnLabel = hasDownloaded ? S.of(context).install_now : S.of(context).update_now;
        String btnLabelCancel = S.of(context).later;
        return Platform.isIOS
            ? WillPopScope(
                onWillPop: () {
                  return;
                },
                child: CupertinoAlertDialog(
                  title: Text(title),
                  content: Text(message),
                  actions: <Widget>[
                    if (updateEntity.forceUpdate != 1)
                      FlatButton(
                        child: Text(btnLabelCancel),
                        onPressed: () => Navigator.pop(context),
                      ),
                    FlatButton(
                      child: Text(S.of(context).update_now),
                      onPressed: () => _launch(updateEntity),
                    ),
                  ],
                ),
              )
            : WillPopScope(
                onWillPop: () {
                  return;
                },
                child: new AlertDialog(
                  title: Text(title),
                  content: Text(message),
                  actions: <Widget>[
                    if (updateEntity.forceUpdate != 1)
                      FlatButton(
                        child: Text(btnLabelCancel),
                        onPressed: () => Navigator.pop(context),
                      ),
                    FlatButton(
                      child: Text(S.of(context).update_now),
                      onPressed: () => _launch(updateEntity),
                    ),
                  ],
                ),
              );
      },
    );
  }

  void _launch(UpdateEntity versionModel) async {
//    if (env.channel == BuildChannel.OFFICIAL) {
//      if (hasDownloaded) {
//        var apkPath = await _getApkPath();
//        _installApk(apkPath);
//      } else {
//        _downloadApk(versionModel);
//        Fluttertoast.showToast(msg: S.of(context).downloading_update_file);
//      }
//    } else {
//      TitanPlugin.openMarket();
//    }

//      AppPlugin.openMarket();

    Navigator.maybePop(context);

    launchUrl(versionModel.downloadUrl);

    if (versionModel.forceUpdate != 1) {
      Navigator.pop(context);
    }
  }

//  Future<bool> _hasDownloaded(UpdateEntity versionModel) async {
//    var apkPath = await _getApkPath();
//    try {
//      var localFileMd5 = await TitanPlugin.fileMd5(apkPath);
//      if (localFileMd5 == versionModel.md5) {
//        return true;
//      }
//    } catch (err) {
//      print(err);
//    }
//    return false;
//  }
//
//  Future<String> _getApkPath() async {
//    var tempDir = await getTemporaryDirectory();
//    var apkPath = '${tempDir.path}/$APK_NAME';
//    return apkPath;
//  }

  /*
  void _downloadApk(UpdateEntity versionModel) async {
    var tempDir = await getTemporaryDirectory();
    var apkPath = '${tempDir.path}/$APK_NAME';
    var file = File(apkPath);
    if (file.existsSync()) {
      file.deleteSync();
    }
    taskId = await FlutterDownloader.enqueue(
        url: versionModel.downloadUrl,
        savedDir: tempDir.path,
        fileName: APK_NAME,
        openFileFromNotification: true,
        showNotification: true // show download progress in status bar (for Android)
        );
  }
  */

//  void _installApk(String apkPath) async {
//    var hasPermission = await TitanPlugin.canRequestPackageInstalls();
//    if (!hasPermission) {
//      hasPermission = await TitanPlugin.requestInstallUnknownSourceSetting();
//      if (hasPermission) {
//        TitanPlugin.installApk(apkPath);
//      } else {
//        Fluttertoast.showToast(msg: S.of(context).installation_update_package_failed);
//      }
//    } else {
//      TitanPlugin.installApk(apkPath);
//    }
//  }

  void _checkUpdate() async {
    await Future.delayed(Duration(milliseconds: 3000));
//    await PermissionHandler().requestPermissions([PermissionGroup.storage]);
    BlocProvider.of<UpdateBloc>(context).add(CheckUpdate(lang: Localizations.localeOf(context).languageCode));
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void dispose() {
    _appBlocSubscription?.cancel();
//    FlutterDownloader.registerCallback(null);
    super.dispose();
  }
}
