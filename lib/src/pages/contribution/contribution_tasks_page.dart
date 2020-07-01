import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/pages/contribution/verify_poi/verify_poi_page.dart';
import 'package:titan/src/components/scaffold_map/map.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/data/entity/converter/model_converter.dart';
import 'package:titan/src/plugins/titan_plugin.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/utils/utils.dart';
import 'package:titan/src/widget/enter_wallet_password.dart';

import 'add_poi/select_position_page.dart';

class ContributionTasksPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _DataContributionState();
  }
}

class _DataContributionState extends State<ContributionTasksPage>
    with RouteAware {
//  WalletBloc _walletBloc = WalletBloc();
//
//  StreamSubscription _eventbusSubcription;
//  WalletService _walletService = WalletService();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Application.routeObserver.subscribe(this, ModalRoute.of(context));
  }

  @override
  void didPopNext() {
    //print("didPopNext");
    doDidPopNext();
  }

  Future doDidPopNext() async {
//    if (currentWalletVo != null) {
//      String defaultWalletFileName = await _walletService.getDefaultWalletFileName();
//      //logger.i("defaultWalletFileName:$defaultWalletFileName");
//      logger.i("defaultWalletFileName:$defaultWalletFileName");
//      String updateWalletFileName = currentWalletVo.wallet.keystore.fileName;
//      //logger.i("updateWalletFileName:$updateWalletFileName");
//      if (defaultWalletFileName == updateWalletFileName) {
//        //logger.i("do UpdateWalletEvent");
//        _walletBloc.add(UpdateWalletEvent(currentWalletVo));
//      } else {
//        currentWalletVo = null;
//        //logger.i("do ScanWalletEvent");
//        _walletBloc.add(ScanWalletEvent());
//      }
//    } else {
//      _walletBloc.add(ScanWalletEvent());
//    }
  }

  @override
  void dispose() {
//    _eventbusSubcription?.cancel();
//    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void initState() {
//    _walletBloc.add(ScanWalletEvent());
//
//    _eventbusSubcription = eventBus.on().listen((event) {
//      if (event is ScanWalletEvent) {
//        _walletBloc.add(ScanWalletEvent());
//      }
//    });
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
//    return BlocBuilder<WalletBloc, WalletState>(
//      bloc: _walletBloc,
//      builder: (BuildContext context, WalletState state) {
//        if (state is WalletEmptyState) {
//          return _makeWalletGuideView();
////          return _listView();
//        } else if (state is ShowWalletState) {
//          currentWalletVo = state.wallet;
////          return _walletTipsView();
//          return _listView();
//        } else if (state is ScanWalletLoadingState) {
//          return _buildLoading(context);
//        } else {
//          return Container(
//            width: 0.0,
//            height: 0.0,
//          );
//        }
//      },
//    );
  }

//  Widget _buildLoading(context) {
//    return Center(
//      child: SizedBox(
//        height: 40,
//        width: 40,
//        child: CircularProgressIndicator(
//          strokeWidth: 3,
//        ),
//      ),
//    );
//  }

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
//                height: 38,
//                width: 152,
                child: FlatButton(
                  shape: RoundedRectangleBorder(
                      side: BorderSide(color: Theme.of(context).primaryColor),
                      borderRadius: BorderRadius.circular(38)),
                  onPressed: () {
                    Application.router.navigateTo(
                        context,
                        Routes.wallet_create +
                            '?entryRouteName=${Uri.encodeComponent(Routes.contribute_tasks_list)}');

//                    createWalletPopUtilName = '/data_contribution_page';
//                    Navigator.push(context, MaterialPageRoute(builder: (context) => CreateAccountPage()));
                  },
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40.0, vertical: 12.0),
                      child: Text(
                        S.of(context).create_wallet,
                        style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w600),
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
                      side: BorderSide(color: Theme.of(context).primaryColor),
                      borderRadius: BorderRadius.circular(38)),
                  onPressed: () {
                    Application.router.navigateTo(
                        context,
                        Routes.wallet_import +
                            '?entryRouteName=${Uri.encodeComponent(Routes.contribute_tasks_list)}');
//                    createWalletPopUtilName = '/data_contribution_page';
//                    Navigator.push(context, MaterialPageRoute(builder: (context) => ImportAccountPage()));
                  },
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40.0, vertical: 12.0),
                      child: Text(
                        S.of(context).import_wallet,
                        style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w600),
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
        _buildTaskItem('signal', S.of(context).scan_signal_item_title,
            () async {
          bool status = await checkSignalPermission();
          print('[Permission] -->status:$status');

          if (status) {
            var latLng = await getLatlng();
            if (latLng != null) {
              var latLngStr =
                  json.encode(LocationConverter.latLngToJson(latLng));
              Application.router.navigateTo(context,
                  Routes.contribute_scan_signal + '?latLng=$latLngStr');
//              Navigator.push(
//                context,
//                MaterialPageRoute(
//                  builder: (context) => ScanSignalContributionPage(initLocation: latLng),
//                ),
//              );
            }
          }
        }, isOpen: true),
        _divider(),
        _buildTaskItem('position', S.of(context).add_poi_item_title, () async {
          var latlng = await getLatlng();
          if (latlng != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SelectPositionPage(
                  initLocation: latlng,
                  type: SelectPositionPage.SELECT_PAGE_TYPE_POI,
                ),
              ),
            );
          }
        }, isOpen: true),
        _divider(),
        _buildTaskItem('check', S.of(context).check_poi_item_title, () async {
          var latlng = await getLatlng();
          if (latlng != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VerifyPoiPage(userPosition: latlng),
              ),
            );
          }
        }, isOpen: true),
        _divider(),
        if (Platform.isAndroid)
          _buildTaskItem('ncov', S.of(context).add_ncov_item_title, () async {
            var latlng = await getLatlng();
            if (latlng != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SelectPositionPage(
                    initLocation: latlng,
                    type: SelectPositionPage.SELECT_PAGE_TYPE_NCOV,
                  ),
                ),
              );
            }
          }, isOpen: true),
        if (Platform.isAndroid) _divider()
      ],
    );
  }

  Future<LatLng> getLatlng() async {
    var latlng = await (Keys.mapContainerKey.currentState as MapContainerState)
        ?.mapboxMapController
        ?.lastKnownLocation();
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
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).primaryColor),
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
                  style: TextStyle(
                      fontWeight: FontWeight.w500, color: HexColor('#333333')),
                ),
                SizedBox(
                  height: 8,
                ),
                SizedBox(
                  width: 150,
                  child: Text(
                    shortBlockChainAddress(
                            activeWalletVo?.wallet?.getEthAccount()?.address) ??
                        "",
                    style: TextStyle(
                        fontWeight: FontWeight.normal,
                        color: Color(0xFF9B9B9B),
                        fontSize: 12),
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

  Widget _buildTaskItem(String iconName, String title, Function ontap,
      {bool isOpen = false}) {
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
            style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 14,
                color: HexColor('#333333')),
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
          S.of(context).coming_soon,
          style: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 12,
              color: HexColor('#AAAAAA')),
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
        UiUtil.showDialogs(context, S.of(context).open_bluetooth,
            S.of(context).please_open_bluetooth, () {
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
            context, S.of(context).open_wifi, S.of(context).please_open_wifi,
            () {
          AppSettings.openWIFISettings();
        });
        return false;
      }
    }

    return true;
  }


}
