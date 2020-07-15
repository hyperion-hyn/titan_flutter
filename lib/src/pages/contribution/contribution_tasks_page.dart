import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/pages/contribution/add_poi/add_position_page_v2.dart';
import 'package:titan/src/pages/contribution/add_poi/api/position_api.dart';
import 'package:titan/src/components/scaffold_map/map.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/contribution/verify_poi/verify_poi_page_v2.dart';
import 'package:titan/src/pages/contribution/verify_poi/verify_poi_page_v3.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/data/entity/converter/model_converter.dart';
import 'package:titan/src/plugins/titan_plugin.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/utils/utils.dart';

class ContributionTasksPage extends StatefulWidget {
  static var scanSignal = "scanSignal";
  static var confirmPOI = "confirmPOI";
  static var confirmPOI2 = "confirmPOI2";
  static var postPOI = "postPOI";

  @override
  State<StatefulWidget> createState() {
    return _DataContributionState();
  }
}

class _DataContributionState extends State<ContributionTasksPage> with RouteAware {
  final int TAST_TIMES_ONE = 1;
  final int TAST_TIMES_TWICE = 2;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    Application.routeObserver.subscribe(this, ModalRoute.of(context));
    PositionApi().updateEthAddress();
  }

  @override
  void didPopNext() {}

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          S.of(context).data_contribute,
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: _buildView(context),
    );
  }

  Widget _buildView(BuildContext context) {
    var activeWalletVo = WalletInheritedModel.of(context).activatedWallet;
    if (activeWalletVo == null) {
      return _makeWalletGuideView();
    } else {
      return _taskListView();
    }
  }

  Widget _makeWalletGuideView() {
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
                color: Theme.of(context).primaryColor,
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 34),
              width: 194,
              child: Text(
                S.of(context).data_contribution_with_hyn_wallet_tips,
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
                child: FlatButton(
                  shape: RoundedRectangleBorder(
                      side: BorderSide(color: Theme.of(context).primaryColor), borderRadius: BorderRadius.circular(38)),
                  onPressed: () {
                    Application.router.navigateTo(context,
                        Routes.wallet_create + '?entryRouteName=${Uri.encodeComponent(Routes.contribute_tasks_list)}');
                  },
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 12.0),
                      child: Text(
                        S.of(context).create_wallet,
                        style:
                            TextStyle(fontSize: 14, color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600),
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
                child: FlatButton(
                  shape: RoundedRectangleBorder(
                      side: BorderSide(color: Theme.of(context).primaryColor), borderRadius: BorderRadius.circular(38)),
                  onPressed: () {
                    Application.router.navigateTo(context,
                        Routes.wallet_import + '?entryRouteName=${Uri.encodeComponent(Routes.contribute_tasks_list)}');
                  },
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 12.0),
                      child: Text(
                        S.of(context).import_wallet,
                        style:
                            TextStyle(fontSize: 14, color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600),
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

  Widget _taskListView() {
    var scanTimes = 0;
    var postPoiTimes = 0;
    var confirmPoiTimes = Random().nextInt(10);
    var scanTimesReal = 0;
    var postPoiTimesReal = 0;
    var confirmPoiTimesReal = 0;

    return ListView(
      children: <Widget>[
        Container(
          height: 8,
          color: Colors.grey[200],
        ),
        _activatedWalletWidget(),
        Container(
          height: 8,
          color: Colors.grey[200],
        ),
        _buildTaskItem('signal', S.of(context).scan_signal_item_title, scanTimes ?? 0, () async {
          bool status = await checkSignalPermission();
          print('[Permission] -->status:$status');

          if (status) {
            var latLng = await getLatlng();
            if (latLng != null) {
              var latLngStr = json.encode(LocationConverter.latLngToJson(latLng));
              Application.router.navigateTo(context, Routes.contribute_scan_signal + '?latLng=$latLngStr');
            }
          }
        }, isOpen: true, realTimes: scanTimesReal),
        _divider(),
        _buildTaskItem('position', S.of(context).add_poi_item_title, postPoiTimes ?? 0, () async {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddPositionPageV2(),
            ),
          );
        }, isOpen: true, realTimes: postPoiTimesReal),
        _divider(),
        _buildTaskItem('check', S.of(context).check_poi_item_title, confirmPoiTimes ?? 0, () async {
          var latlng = await getLatlng();
          if (latlng != null) {
            // 注释：第0次，自检：图片， 后面，第N次，ta检查，都是第三方验证，多任务校验
            SharedPreferences prefs = await SharedPreferences.getInstance();
            var lastDate = prefs.getInt(PrefsKey.VERIFY_DATE) ?? 0;
            var duration = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(lastDate));
            print("[Radion] confirmPoiTimes:$confirmPoiTimes, lastDate:$lastDate, day:${duration.inDays}, inHours:${duration.inHours}");


            if (lastDate == 0 || (lastDate > 0 && duration.inDays > 0)) {
              prefs.setInt(PrefsKey.VERIFY_DATE, DateTime.now().millisecondsSinceEpoch);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VerifyPoiPageV2(userPosition: latlng),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VerifyPoiPageV3(userPosition: latlng),
                ),
              );
            }
          }
        }, isOpen: true, realTimes: confirmPoiTimesReal),
        _divider(),
      ],
    );
  }

  Future<LatLng> getLatlng() async {
    var latlng =
        await (Keys.mapContainerKey.currentState as MapContainerState)?.mapboxMapController?.lastKnownLocation();
    if (latlng == null) {
      UiUtil.showConfirmDialog(
        context,
        content: S.of(context).get_poi_fail_please_again,
      );
    }
    return latlng;
  }

  Widget _activatedWalletWidget() {
    var activeWalletVo = WalletInheritedModel.of(context).activatedWallet;
    if (activeWalletVo == null) {
      return Container();
    }

    return InkWell(
      onTap: () {
        Application.router.navigateTo(context, Routes.wallet_manager);
      },
      child: SizedBox(
        height: 64,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.center,
              width: 40,
              height: 40,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).primaryColor),
              child: Stack(
                children: <Widget>[
                  Align(
                      alignment: Alignment.center,
                      child: Image.asset(
                        "res/drawable/hyn_wallet.png",
                        width: 20,
                        height: 20,
                      )),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  activeWalletVo?.wallet?.keystore?.name ?? "",
                  textAlign: TextAlign.left,
                  style: TextStyle(fontWeight: FontWeight.w500, color: HexColor('#333333')),
                ),
                SizedBox(
                  height: 8,
                ),
                SizedBox(
                  width: 150,
                  child: Text(
                    shortBlockChainAddress(activeWalletVo?.wallet?.getEthAccount()?.address) ?? "",
                    style: TextStyle(fontWeight: FontWeight.normal, color: Color(0xFF9B9B9B), fontSize: 12),
                  ),
                )
              ],
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                S.of(context).switch_contribute_address,
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

  Widget _buildTaskItem(String iconName, String title, int todayTimes, Function ontap,
      {bool isOpen = false, int realTimes = 0}) {
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
        ],
      ),
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 8,
        color: HexColor('#E9E9E9'),
      ),
    );
  }

  Future<bool> checkSignalPermission() async {
    //1、检查定位的权限
    //check location service
    if (!(await Permission.location.serviceStatus.isEnabled)) {
      UiUtil.showRequestLocationAuthDialog(context, true);
      return false;
    }

    var status = await Permission.location.status;
    if (!status.isGranted) {
      PermissionStatus ret = await Permission.location.request();
      if (!ret.isGranted) {
        UiUtil.toast(S.of(context).get_position_error_cant_contribution);
      }
    }

    status = await Permission.storage.status;
    if (!status.isGranted) {
      PermissionStatus ret = await Permission.location.request();
      if (!ret.isGranted) {
        UiUtil.toast(S.of(context).get_local_file_fail_cant_contribution);
      }
    }

    //2. 检查电话权限
    if (Platform.isAndroid) {
      status = await Permission.phone.status;
      if (!status.isGranted) {
        PermissionStatus ret = await Permission.location.request();
        if (!ret.isGranted) {
          UiUtil.toast(S.of(context).get_device_fail_cant_contribution);
        }
      }
    }

    //3. 检查蓝牙权限
    bool blueAvailable = await TitanPlugin.bluetoothEnable();
    if (Platform.isAndroid) {
      if (!blueAvailable) {
        UiUtil.showDialogs(context, S.of(context).open_bluetooth, S.of(context).please_open_bluetooth, () {
          AppSettings.openBluetoothSettings();
        });
        return false;
      }
    } else {
      if (!blueAvailable) {
        return false;
      }
    }

    //4. 安卓增加判断wifi
    if (Platform.isAndroid) {
      bool wifiAvailable = await TitanPlugin.wifiEnable();
      if (!wifiAvailable) {
        UiUtil.showDialogs(context, S.of(context).open_wifi, S.of(context).please_open_wifi, () {
          AppSettings.openWIFISettings();
        });
        return false;
      }
    }

    return true;
  }
}
