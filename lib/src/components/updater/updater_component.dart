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
import 'package:titan/src/data/entity/app_update_info.dart';
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

    if (_appBlocSubscription == null) {
      _appBlocSubscription = BlocProvider.of<UpdateBloc>(context)
          ?.listen((UpdateState state) async {
        if (state is UpdateCheckState) {
          if (state.appData.appUpdateInfo != null) {
            print('xxxxx');
            if (state.appData.appUpdateInfo.needUpdate == 1) {
              if (!_lastHaveVisible) {
                _showUpdateDialog(state.appData.appUpdateInfo);
              } else {
                // print(
                //     "_lastHaveVisible:$_lastHaveVisible, _lastCancelBuildNumber:$_lastCancelBuildNumber, newBuildNumber:$newBuildNumber");
              }
            } else {
              print('[updater] 已经是最新版本');
              if (state.isManual) {
                Fluttertoast.showToast(
                  msg: S.of(context).latest_version_tip,
                  gravity: ToastGravity.CENTER,
                );
              }
            }
          }
        }
      });
    }
  }

  void _showUpdateDialog(AppUpdateInfo updateEntity) async {
    _lastHaveVisible = true;

    await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        String title = S.of(context).new_update_available;
        String message = updateEntity.newVersion?.describe ?? '';
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
                                padding: const EdgeInsets.only(
                                    top: 15.0, bottom: 15),
                                child: Text(
                                  title,
                                  style: TextStyles.textC333S18,
                                ),
                              ),
                              Container(
                                height: 104,
                                width: double.infinity,
                                padding: const EdgeInsets.only(
                                    left: 24.0, right: 24),
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
                        if (updateEntity.newVersion?.force != 1)
                          InkWell(
                            onTap: () {
                              _lastCancelBuildNumber =
                                  updateEntity.newVersion?.versionCode;
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

  void _launch(AppUpdateInfo versionModel) async {
    _lastHaveVisible = false;

    Navigator.maybePop(context);

    launchUrl(versionModel.newVersion?.urlJump);

    if (versionModel.newVersion?.force != 1) {
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
