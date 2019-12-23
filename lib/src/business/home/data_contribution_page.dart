import 'dart:async';
import 'dart:io';

import 'package:android_intent/android_intent.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/business/home/contribution_page.dart';
import 'package:titan/src/plugins/titan_plugin.dart';
import 'package:titan/src/utils/utils.dart';
import '../wallet/wallet_create_new_account_page.dart';
import 'package:titan/src/business/wallet/wallet_import_account_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/src/business/wallet/wallet_bloc/wallet_bloc.dart';
import 'package:titan/src/business/wallet/wallet_bloc/wallet_event.dart';
import 'package:titan/src/business/wallet/wallet_bloc/wallet_state.dart';
import 'package:titan/src/global.dart';
import '../wallet/wallet_manager/wallet_manager.dart';

class DataContributionPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _DataContributionState();
  }
}

class _DataContributionState extends State<DataContributionPage> {
  WalletBloc _walletBloc;

  StreamSubscription _eventbusSubcription;

  @override
  void initState() {
    _walletBloc = WalletBloc();
    _walletBloc.add(ScanWalletEvent());

    _eventbusSubcription = eventBus.on().listen((event) {
      if (event is ScanWalletEvent) {
        _walletBloc.add(ScanWalletEvent());
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          "数据贡献",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: _buildView(context),
    );
  }

  Widget _buildView(BuildContext context) {
    return BlocBuilder<WalletBloc, WalletState>(
      bloc: _walletBloc,
      builder: (BuildContext context, WalletState state) {
        if (state is WalletEmptyState) {
          return _walletTipsView();
        } else if (state is ShowWalletState) {
          currentWalletVo = state.wallet;
//          return _walletTipsView();
          return _listView();
        } else if (state is ScanWalletLoadingState) {
          return _buildLoading(context);
        } else {
          return Container();
        }
      },
    );
  }

  Widget _buildLoading(context) {
    return Center(
      child: SizedBox(
        height: 40,
        width: 40,
        child: CircularProgressIndicator(
          strokeWidth: 3,
        ),
      ),
    );
  }

  Widget _walletTipsView() {
    return Center(
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 39, 0, 26),
              child: Image.asset(
                'res/drawable/data_contribution_wallet_check.png',
                width: 110,
                height: 108,
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 34),
              width: 194,
              child: Text(
                '数据贡献需要有HYN地址，请先创建 或导入HYN钱包。',
                maxLines: 2,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: HexColor('#333333'),
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
              child: SizedBox(
//                height: 38,
//                width: 152,
                child: FlatButton(
                  shape: RoundedRectangleBorder(
                      side: BorderSide(color: Theme.of(context).primaryColor), borderRadius: BorderRadius.circular(38)),
                  onPressed: () {
                    createWalletPopUtilName = '/data_contribution_page';
                    Navigator.push(context, MaterialPageRoute(builder: (context) => CreateAccountPage()));
                  },
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 12.0),
                      child: Text(
                        S.of(context).create_wallet,
                        style:
                            TextStyle(fontSize: 14, color: Theme.of(context).primaryColor, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
              child: SizedBox(
//                height: 38,
//                width: 152,
                child: FlatButton(
                  shape: RoundedRectangleBorder(
                      side: BorderSide(color: Theme.of(context).primaryColor), borderRadius: BorderRadius.circular(38)),
                  onPressed: () {
                    createWalletPopUtilName = '/data_contribution_page';
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ImportAccountPage()));
                  },
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 12.0),
                      child: Text(
                        S.of(context).import_wallet,
                        style:
                            TextStyle(fontSize: 14, color: Theme.of(context).primaryColor, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _listView() {
    return ListView(
      children: <Widget>[
        _wallet(),
        _divider(),
        _buildItem('signal', '扫描附近信号数据', () async {
          bool status = await checkSignalPermission();
          if (status) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ContributionPage(),
              ),
            );
          }
        }, isOpen: true),
        _divider(),
        _buildItem('position', '添加地理位置信息', () {}),
        _divider(),
        _buildItem('check', '校验地理位置信息', () {}),
        _divider(),
      ],
    );
  }

  Widget _wallet() {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => WalletManagerPage(), settings: RouteSettings(name: "/wallet_manager_page")));
      },
      child: SizedBox(
        height: 64,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
                padding: const EdgeInsets.fromLTRB(15, 4, 10, 0),
                child: Image.asset(
                  'res/drawable/data_contribution_wallet.png',
                  width: 40,
                  height: 40,
                )),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  currentWalletVo.wallet.keystore.name,
                  textAlign: TextAlign.left,
                  style: TextStyle(fontWeight: FontWeight.w500, color: HexColor('#333333')),
                ),
                SizedBox(
                  height: 8,
                ),
                SizedBox(
                  width: 150,
                  child: Text(
                    shortEthAddress(currentWalletVo.wallet.getEthAccount().address),
                    style: TextStyle(fontWeight: FontWeight.normal, color: Color(0xFF9B9B9B), fontSize: 12),
                  ),
                )
              ],
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '切换地址',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: HexColor('#333333'),
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(String iconName, String title, Function ontap, {bool isOpen = false}) {
    return InkWell(
      onTap: ontap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
              padding: const EdgeInsets.fromLTRB(15, 12, 12, 12),
              child: Image.asset(
                'res/drawable/data_contribution_$iconName.png',
                width: 22,
                height: 22,
              )),
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14, color: HexColor('#333333')),
          ),
          Spacer(),
          _end(isOpen: isOpen),
        ],
      ),
    );
  }

  Widget _end({bool isOpen = false}) {
    if (isOpen) {
      return Padding(
        padding: const EdgeInsets.all(14),
        child: Icon(
          Icons.chevron_right,
          color: HexColor('#E9E9E9'),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Text(
          '即将开放',
          style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12, color: HexColor('#AAAAAA')),
        ),
      );
    }
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 0.5,
        color: HexColor('#E9E9E9'),
      ),
    );
  }

  @override
  void dispose() {
    _eventbusSubcription?.cancel();
    super.dispose();
  }

  Future<bool> checkSignalPermission() async {
    //1、检查定位的权限

    //check location service

    ServiceStatus serviceStatus = await PermissionHandler().checkServiceStatus(PermissionGroup.location);

    if (serviceStatus == ServiceStatus.disabled) {
      _showGoToOpenLocationServceDialog();
      return false;
    }
    PermissionStatus locationPermission = await PermissionHandler().checkPermissionStatus(PermissionGroup.location);
    if (locationPermission != PermissionStatus.granted) {
      Map<PermissionGroup, PermissionStatus> permissions =
          await PermissionHandler().requestPermissions([PermissionGroup.location]);
      if (permissions[PermissionGroup.location] != PermissionStatus.granted) {
        _showGoToOpenAppSettingsDialog();
        return false;
      }
    }

    PermissionStatus phonePermission = await PermissionHandler().checkPermissionStatus(PermissionGroup.phone);
    if (phonePermission != PermissionStatus.granted) {
      Map<PermissionGroup, PermissionStatus> permissions =
          await PermissionHandler().requestPermissions([PermissionGroup.phone]);
      if (permissions[PermissionGroup.phone] != PermissionStatus.granted) {
        _showGoToOpenCommonAppSettingsDialog("申请权限", "采集信号数据，需要获取电话权限", () {
          PermissionHandler().openAppSettings();
        });
        return false;
      }
    }

    //2. 检查蓝牙权限

    bool blueAvaiable = await TitanPlugin.bluetoothEnable();
    if (!blueAvaiable) {
      _showGoToOpenCommonAppSettingsDialog("开启蓝牙", "请开启蓝牙", () {
        AppSettings.openBluetoothSettings();
      });
      return false;
    }

    //3. 安卓增加判断wifi
    if (Platform.isAndroid) {
      bool wifiAvaiable = await TitanPlugin.wifiEnable();
      if (!wifiAvaiable) {
        _showGoToOpenCommonAppSettingsDialog("开启WIFI", "请开启WIFI", () {
          AppSettings.openWIFISettings();
        });
        return false;
      }
    }

    return true;
  }

  void _showGoToOpenCommonAppSettingsDialog(String title, String message, Function goToSetting) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Platform.isIOS
              ? CupertinoAlertDialog(
                  title: Text(title),
                  content: Text(message),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('取消'),
                      onPressed: () => Navigator.pop(context),
                    ),
                    FlatButton(
                      child: Text('设置'),
                      onPressed: () {
                        goToSetting();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                )
              : AlertDialog(
                  title: Text(title),
                  content: Text(message),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('取消'),
                      onPressed: () => Navigator.pop(context),
                    ),
                    FlatButton(
                      child: Text('设置'),
                      onPressed: () {
                        goToSetting();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                );
        });
  }

  void _showGoToOpenAppSettingsDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Platform.isIOS
              ? CupertinoAlertDialog(
                  title: Text('申请定位授权'),
                  content: Text('请你授权使用定位功能.'),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('取消'),
                      onPressed: () => Navigator.pop(context),
                    ),
                    FlatButton(
                      child: Text('设置'),
                      onPressed: () {
                        PermissionHandler().openAppSettings();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                )
              : AlertDialog(
                  title: Text('申请定位授权'),
                  content: Text('请你授权使用定位功能.'),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('取消'),
                      onPressed: () => Navigator.pop(context),
                    ),
                    FlatButton(
                      child: Text('设置'),
                      onPressed: () {
                        PermissionHandler().openAppSettings();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                );
        });
  }

  void _showGoToOpenLocationServceDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Platform.isIOS
              ? CupertinoAlertDialog(
                  title: Text('打开定位服务'),
                  content: Text('定位服务已关闭，请开启'),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('取消'),
                      onPressed: () => Navigator.pop(context),
                    ),
                    FlatButton(
                      child: Text('设置'),
                      onPressed: () {
                        PermissionHandler().openAppSettings();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                )
              : AlertDialog(
                  title: Text('打开定位服务'),
                  content: Text('定位服务已关闭，请开启'),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('取消'),
                      onPressed: () => Navigator.pop(context),
                    ),
                    FlatButton(
                      child: Text('设置'),
                      onPressed: () {
                        AndroidIntent intent = new AndroidIntent(
                          action: 'action_location_source_settings',
                        );
                        intent.launch();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                );
        });
  }
}
