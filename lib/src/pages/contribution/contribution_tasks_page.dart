import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/components/account/account_component.dart';
import 'package:titan/src/components/account/bloc/bloc.dart';
import 'package:titan/src/pages/contribution/add_poi/add_position_page_v2.dart';
import 'package:titan/src/pages/contribution/add_poi/api/position_api.dart';
import 'package:titan/src/components/scaffold_map/map.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/contribution/signal_scan/vo/check_in_model.dart';
import 'package:titan/src/pages/contribution/verify_poi/verify_poi_page_v2.dart';
import 'package:titan/src/pages/contribution/verify_poi/verify_poi_page_v3.dart';
import 'package:titan/src/pages/mine/me_checkin_history_page.dart';
import 'package:titan/src/pages/wallet/wallet_manager/wallet_manager_page.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/data/entity/converter/model_converter.dart';
import 'package:titan/src/plugins/titan_plugin.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/utils/utils.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';

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

class _DataContributionState extends BaseState<ContributionTasksPage> with RouteAware {
  final int TAST_TIMES_ONE = 1;
  final int TAST_TIMES_TWICE = 2;

  @override
  void onCreated() async {
    super.onCreated();

    _checkInAction();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    Application.routeObserver.subscribe(this, ModalRoute.of(context));
    PositionApi().getEthAddress();
  }

  @override
  void didPopNext() {
    _checkInAction();
  }

  void _checkInAction() {
    var activeWalletVo = WalletInheritedModel.of(context).activatedWallet;
    var isLogged = activeWalletVo != null;
    if (isLogged) {
      if (mounted) {
        BlocProvider.of<AccountBloc>(context).add(UpdateCheckInInfoEvent());
      }
    } else {
      if (mounted) {
        BlocProvider.of<AccountBloc>(context).add(ClearDataEvent());
      }
    }
  }

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
      appBar: BaseAppBar(
        baseTitle: S.of(context).data_contribute,
        backgroundColor: Colors.white,
        actions: <Widget>[
          FlatButton(
            onPressed: _navToCheckInRecords,
            child: Text(
              '贡献记录',
              style: TextStyle(
                color: HexColor("#1F81FF"),
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
      body: _buildView(context),
    );
  }

  _navToCheckInRecords() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MeCheckInHistory(),
      ),
    );
  }

  Widget _buildView(BuildContext context) {
    var activeWalletVo = WalletInheritedModel.of(context).activatedWallet;
    if (activeWalletVo == null) {
      return _makeWalletGuideView();
    } else {
      return Container(
        color: Colors.white,
        child: _taskListView(),
      );
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
                        Routes.wallet_create + '?entryRouteName=${Uri.encodeComponent(Routes.contribute_tasks_list)}&isCreate=1');
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
                        Routes.wallet_create + '?entryRouteName=${Uri.encodeComponent(Routes.contribute_tasks_list)}');
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
    var checkInModel = AccountInheritedModel.of(context, aspect: AccountAspect.checkIn)?.checkInModel;
    var scanTimes = 0;
    var postPoiTimes = 0;
    var confirmPoiTimes = 0;
    var scanTimesReal = 0;
    var postPoiTimesReal = 0;
    var confirmPoiTimesReal = 0;

    if (checkInModel != null) {
      print("[Task] _taskListView, total:${checkInModel.total}, length:${checkInModel.detail.length}");

      CheckInModelState scanState = checkInModel.detail.firstWhere((element) {
        return element.action == ContributionTasksPage.scanSignal;
      }).state;
      scanTimes = scanState.total;

      scanTimesReal = scanState.real;

      CheckInModelState postPoiState = checkInModel.detail.firstWhere((element) {
        return element.action == ContributionTasksPage.postPOI;
      }).state;
      postPoiTimes = postPoiState.total;
      postPoiTimesReal = postPoiState.real;

      CheckInModelState confirmPoiState = checkInModel.detail.firstWhere((element) {
        return element.action == ContributionTasksPage.confirmPOI;
      }).state;
      confirmPoiTimes = confirmPoiState.total;
      confirmPoiTimesReal = confirmPoiState.real;
    }

    Widget _lineWidget({double height = 5}) {
      return Container(
        height: height,
        color: HexColor('#F8F8F8'),
      );
    }

    return ListView(
      children: <Widget>[
        _lineWidget(),
        _activatedWalletWidget(),
        _lineWidget(
          height: 8,
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
          //var latLng = await getLatlng();

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddPositionPageV2(
                userPosition: null,
              ),
            ),
          );
        }, isOpen: true, realTimes: postPoiTimesReal),
        _divider(),
        _buildTaskItem('check', S.of(context).check_poi_item_title, confirmPoiTimes ?? 0, () async {
          var latlng = await getLatlng();
          if (latlng != null) {
            // 注释：第0次，自检：图片， 后面，第N次，ta检查，都是第三方验证，多任务校验

            if (confirmPoiTimes == 0 /*|| env.buildType == BuildType.DEV*/) {
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

  _showCloseDialog() {
    UiUtil.showAlertView(
      context,
      title: S.of(context).tips,
      actions: [
        ClickOvalButton(
          S.of(context).confirm,
          () {
            Navigator.pop(context);
          },
          width: 115,
          height: 36,
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
      ],
      content: S.of(context).get_poi_fail_please_again,
    );
  }

  Future<LatLng> getLatlng() async {
    var latlng =
        await (Keys.mapContainerKey.currentState as MapContainerState)?.mapboxMapController?.lastKnownLocation();
    if (latlng == null) {
      _showCloseDialog();
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
        WalletManagerPage.jumpWalletManager(context);
        // Application.router.navigateTo(context, Routes.wallet_manager);
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
                    shortBlockChainAddress(
                        WalletUtil.ethAddressToBech32Address(activeWalletVo?.wallet?.getEthAccount()?.address ?? "")),
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
          Flexible(
            fit: FlexFit.tight,
            flex: 35,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                _end(todayTimes,
                    isOpen: isOpen,
                    taskTimes: iconName == "check" ? TAST_TIMES_TWICE : TAST_TIMES_ONE,
                    realTimes: realTimes),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _end(int todayTimes, {bool isOpen = false, int taskTimes = 1, int realTimes = 0}) {
    var activeWalletVo = WalletInheritedModel.of(context).activatedWallet;
    var isLogged = activeWalletVo != null;
    if (!isLogged) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
              ),
              child: Image.asset(
                'res/drawable/me_account_bind_arrow.png',
                width: 7,
                height: 12,
              ),
            ),
          ],
        ),
      );
    }

    if (isOpen) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            if (todayTimes < 0)
              Container()
            else
              Text(
                S.of(context).task_is_finished_func(todayTimes.toString(), taskTimes.toString()),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
              ),
              child: Image.asset(
                'res/drawable/me_account_bind_arrow.png',
                width: 7,
                height: 12,
              ),
            ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          S.of(context).coming_soon,
          style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12, color: HexColor('#AAAAAA')),
        ),
      );
    }
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
        UiUtil.showDialogs(
            context: context,
            title: S.of(context).open_bluetooth,
            content: S.of(context).please_open_bluetooth,
            func: () {
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
        UiUtil.showDialogs(
            context: context,
            title: S.of(context).open_wifi,
            content: S.of(context).please_open_wifi,
            func: () {
              AppSettings.openWIFISettings();
            });
        return false;
      }
    }

    return true;
  }
}
