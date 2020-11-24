import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:package_info/package_info.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/components/updater/bloc/bloc.dart';
import 'package:titan/src/data/entity/update.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/utils.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';

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
  int _lastCancelBuildNumber = 0;
  bool _lastHaveVisible = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    /*var updateStr =
        "{\"build\":2013,\"version_name\":\"4.0.13\",\"content\":\"更新项1、去除7纪元\\n就暂停推荐抵押设定asasdasdfasfdsadfsdf。\",\"force_update\":1,\"md5\":\"25fb76ef90a43b617facdec0467999f7\",\"download_url\":\"https://static.hyn.mobi/titan/apps/titan_2013_v4.0.13.apk\"}";
    UpdateEntity updateEntity = UpdateEntity.fromJson(json.decode(updateStr));
//    UpdateEntity updateEntity = UpdateEntity(build: 100,versionName: '111',content: '111\n333\nr4343',forceUpdate: 0,downloadUrl: 'jttialsdjflj');
    Future.delayed(Duration(milliseconds: 2000), () {
      _showUpdateDialog(updateEntity);
    });*/
    if (_appBlocSubscription == null) {
      _appBlocSubscription = BlocProvider.of<UpdateBloc>(context)?.listen((UpdateState state) async {
        if (state is UpdateCheckState) {
          var newBuildNumber = state?.appData?.updateEntity?.build ?? 0;
          if (state.appData.updateEntity != null) {
            PackageInfo packageInfo = await PackageInfo.fromPlatform();
            if (int.parse(packageInfo.buildNumber) < newBuildNumber) {
              if (_lastCancelBuildNumber != newBuildNumber && !_lastHaveVisible) {
                _showUpdateDialog(state.appData.updateEntity);
              } else {
                print(
                    "_lastHaveVisible:$_lastHaveVisible, _lastCancelBuildNumber:$_lastCancelBuildNumber, newBuildNumber:$newBuildNumber");
              }
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
    _lastHaveVisible = true;

    await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        String title = S.of(context).new_update_available;
        String message = updateEntity.content;
        String btnLabelCancel = S.of(context).later;
        return Material(
          color: Colors.transparent,
          child: WillPopScope(
            onWillPop: () {
              return;
            },
            child: Container(
              child: Padding(
                padding: const EdgeInsets.only(top: 159.0),
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Container(
                          width: 300,
                          height: 336,
                          margin: const EdgeInsets.only(top: 56.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                          ),
                          child: Column(
                            children: <Widget>[
                              Image.asset(
                                "res/drawable/ic_update_dialog_top_bg.png",
                                width: 300,
                                height: 88,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 15.0, bottom: 15),
                                child: Text(
                                  title,
                                  style: TextStyles.textC333S18,
                                ),
                              ),
                              Container(
                                height: 104,
                                width: double.infinity,
                                padding: const EdgeInsets.only(left: 24.0, right: 24),
                                child: SingleChildScrollView(
                                  child: Text(
                                    message,
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: DefaultColors.color333,
                                        fontWeight: FontWeight.normal,
                                        decoration: TextDecoration.none),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 26.0),
                                child: ClickOvalButton(
                                  "立即体验",
                                  () {
                                    _launch(updateEntity);
                                  },
                                  width: 200,
                                  height: 38,
                                  fontSize: 16,
                                ),
                              )
                            ],
                          ),
                        ),
                        if (updateEntity.forceUpdate != 1)
                          InkWell(
                            onTap: () {
                              _lastCancelBuildNumber = updateEntity.build;
                              _lastHaveVisible = false;
                              Navigator.pop(context);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(17.0),
                              child: Image.asset(
                                "res/drawable/ic_dialog_close.png",
                                width: 30,
                                height: 30,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    Image.asset(
                      "res/drawable/ic_update_dialog_top_image.png",
                      width: 227,
                      height: 138,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _launch(UpdateEntity versionModel) async {
    _lastHaveVisible = false;

    Navigator.maybePop(context);

    launchUrl(versionModel.downloadUrl);

    if (versionModel.forceUpdate != 1) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void dispose() {
    _appBlocSubscription?.cancel();
    super.dispose();
  }
}
