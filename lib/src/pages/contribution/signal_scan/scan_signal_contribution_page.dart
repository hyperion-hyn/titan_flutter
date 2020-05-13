import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/webview/webview.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/data/api/api.dart';
import 'package:titan/src/data/entity/converter/model_converter.dart';
import 'package:titan/src/plugins/sensor_plugin.dart';
import 'package:titan/src/plugins/sensor_type.dart';
import 'package:titan/src/plugins/wallet/token.dart';
import 'package:titan/src/utils/scan_util.dart';

import 'vo/latlng.dart' as contributionLatlng;
import 'vo/signal_collector.dart';

//const _default_map_location = LatLng(23.106541, 113.324827);

class ScanSignalContributionPage extends StatefulWidget {
  final LatLng initLocation;

  ScanSignalContributionPage({String latLng})
      : this.initLocation =
            (latLng != null && latLng != '') ? LocationConverter.latLngFromJson(json.decode(latLng)) : null;

  @override
  State<StatefulWidget> createState() {
    return _ContributionState();
  }
}

class _ContributionState extends State<ScanSignalContributionPage> {
  MapboxMapController mapController;

  Api _api = Api();

//  WalletService _walletService = WalletService();

  StreamSubscription subscription;

  LatLng _userPosition;
  double _defaultZoom = 18;

  StreamController<double> progressStreamController = StreamController.broadcast();

  double _minZoom = 13;

  SensorPlugin _sensorPlugin;

  Map<String, List> _collectData = new Map();

  SensorChangeCallBack _sensorChangeCallBack;

  List<Map<dynamic, dynamic>> wifiList = List();
  List<Map<dynamic, dynamic>> bluetoothList = List();
  List<Map<dynamic, dynamic>> gpsList = List();
  List<Map<dynamic, dynamic>> cellularList = List();
  var _currentIndex = -1;
  var _isFinishScan = false;
  bool _isOnPressed = false;

  int lastMoveTime = 0;
  int startTime = 0;
  int duration = 30000;
  double lastZoom;
  bool isVisibleWiFi = false;
  bool isVisibleToast = false;
  var _isAcceptSignalProtocol = true;
  var _themeColor = HexColor("#0F95B0");
  var _currentScanType = SensorType.GNSS;

  @override
  void initState() {
    super.initState();

    _userPosition = widget.initLocation ?? Application.recentlyLocation;

    _sensorPlugin = SensorPlugin();
    initSensorChangeCallBack();
    initScanner();
  }

  @override
  void dispose() {
    subscription?.cancel();
    progressStreamController.close();
    _sensorPlugin.destory();
    super.dispose();
  }

  void initSensorChangeCallBack() {
    _sensorChangeCallBack = (Map values) {
      _saveAllScanData(values);
    };
    _sensorPlugin.sensorChangeCallBack = _sensorChangeCallBack;
  }

  void _saveAllScanData(Map values) {
    var sensorType = values["sensorType"] as int;

    // 1.for upload
    var typeString = SensorType.getTypeString(sensorType);
    var dataList = _collectData[typeString];
    if (dataList == null) {
      dataList = List();
      _collectData[typeString] = dataList;
    }
    dataList.add(values);

    // 2.for ui
    switch (sensorType) {
      case SensorType.WIFI:
        {
          //print('[contribution] -->_blocBuild___wifi');

          if (Platform.isIOS) {
          } else {
            ScanUtils.addValuesToList(values, wifiList, "bssid");
          }
          break;
        }
      case SensorType.BLUETOOTH:
        {
          if (Platform.isIOS) {
            ScanUtils.addValuesToList(values, bluetoothList, "identifier");
          } else {
            ScanUtils.addValuesToList(values, bluetoothList, "mac");
          }

          break;
        }
      case SensorType.GPS:
        {
          var newLatLng = LatLng(values['lat'], values['lon']);
          if (_userPosition.distanceTo(newLatLng) > 5) {
            _userPosition = newLatLng;
            mapController?.animateCamera(CameraUpdate.newLatLng(_userPosition));
          }
          gpsList.add(values);

          break;
        }
      case SensorType.GNSS:
        {
          break;
        }
      case SensorType.CELLULAR:
        {
          cellularList.add(values);

          break;
        }
      default:
        {
          break;
        }
    }
  }

  void initScanner() async {
//    userPosition = widget.initLocation ?? _default_map_location;
    await _sensorPlugin.init();
  }

  void startScan() async {
    progressStreamController.add(0);

    duration = max<int>((_defaultZoom - _minZoom).toInt() * 3000, duration);
    var timeStep = duration / (_defaultZoom - _minZoom + 1);
    var timerObservable = Stream.periodic(Duration(milliseconds: 500), (x) => x);
    lastZoom = _defaultZoom;
    startTime = DateTime.now().millisecondsSinceEpoch;

//    if (userPosition != null) {
//      mapController.animateCamera(CameraUpdate.newLatLng(userPosition));
//    }

    subscription = timerObservable.listen((t) {
      var nowTime = DateTime.now().millisecondsSinceEpoch;
      var timeGap = nowTime - startTime;

      var progress = timeGap / duration.toDouble();
      progressStreamController.add(progress);
      _setCurrentScanType(progress);

      if (timeGap < duration) {
        //scan 30s
        if (nowTime - lastMoveTime > timeStep) {
          mapController.animateCameraWithTime(CameraUpdate.zoomTo(lastZoom--), 1000);
          lastMoveTime = DateTime.now().millisecondsSinceEpoch;
        }
      } else {
        subscription?.cancel();
        _isFinishScan = true;
        _sensorPlugin.stopScan();
      }
    });

    _sensorPlugin.startScan();
  }

  List _getCurrentScanList() {
    switch (_currentScanType) {
      case SensorType.WIFI:
        return wifiList;
        break;

      case SensorType.CELLULAR:
        return cellularList;
        break;

      case SensorType.BLUETOOTH:
        return bluetoothList;
        break;

      case SensorType.GPS:
        return gpsList;
        break;
    }

    return List();
  }

  void _setCurrentScanType(double currentValue) {
    var value = currentValue ?? 0.001;

    var item = 1.0 / 4.0;
    if (Platform.isIOS) {
      item = 1.0 / 2.0;

      if (value > 0 && value < 1.0 * item) {
        _currentScanType = SensorType.CELLULAR;
      }  else if (value >= 1.0 * item && value < 1.0) {
        _currentScanType = SensorType.GPS;
      }
    } else {
      item = 1.0 / 4.0;

      if (value > 0 && value < 1.0 * item) {
        _currentScanType = SensorType.WIFI;
      } else if (value >= 1.0 * item && value < 2.0 * item) {
        _currentScanType = SensorType.CELLULAR;
      } else if (value >= 2.0 * item && value < 3.0 * item) {
        _currentScanType = SensorType.BLUETOOTH;
      } else if (value >= 3.0 * item && value < 1.0) {
        _currentScanType = SensorType.GPS;
      }
    }
  }

  List _getStatusDataList() {
    var dataList = List();
    String signalName = S.of(context).scan_ing_func(SensorType.getScanName(context, _currentScanType));

    if (_isFinishScan) {
      signalName = S.of(context).scan_finish;
      dataList.add(signalName);

      var num = wifiList.length + bluetoothList.length + cellularList.length + gpsList.length;
      String allSignal = S.of(context).scan_collect_signal_func(num.toString());
      dataList.add(allSignal);
    } else {
      dataList.add(signalName);
    }

    var list = _getCurrentScanList();
    if (list.isEmpty || _isFinishScan) {
      return dataList;
    }

    _currentIndex += 1;
    if (_currentIndex >= list.length || _currentIndex <= -1) {
      _currentIndex = 0;
    }
    Map values = list[_currentIndex] as Map<dynamic, dynamic>;

    for (var key in values.keys) {
      var value = values[key].toString();
      if (value.length == 0 || value == null || key == "sensorType" || value == "" || value == "0") {
        continue;
      } else {
        value = key.toString().toUpperCase() + "：" + value;
        dataList.add(value);
      }
    }

    return dataList;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _showCloseDialog();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.close),
                onPressed: _showCloseDialog,
              );
            },
          ),
          elevation: 0,
          title: Text(
            S.of(context).scan_name_title,
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: IconThemeData(color: Colors.white),
          centerTitle: true,
        ),
        body: Stack(
          children: <Widget>[
            _mapView(),
            RadarScan(),
            StreamBuilder<double>(
                stream: progressStreamController.stream,
                builder: (context, snapshot) {
                  return Stack(
                    fit: StackFit.expand,
                    alignment: Alignment.center,
                    children: <Widget>[
                      _buildStatusListView(),
                      Positioned(
                        child: SizedBox(
                          height: 3,
                          child: LinearProgressIndicator(
                            backgroundColor: Theme.of(context).primaryColor,
                            value: snapshot?.data ?? 0.0,
                            valueColor: AlwaysStoppedAnimation<Color>(HexColor("#FFFFFF")),
                          ),
                        ),
                        top: 0,
                        left: 0,
                        right: 0,
                      ),
                      Image.asset(
                        'res/drawable/${SensorType.getScanImageName(_currentScanType)}_scan.png',
                        scale: 2,
                      ),
                      _confirmView(),
                    ],
                  );
                }),
          ],
        ),
      ),
    );
  }

  Future<void> _onPressed() async {
    var isFinish = await _uploadCollectData();
    //print('[Request] --> isFinish: ${isFinish}');
    if (isFinish) {
//      createWalletPopUtilName = '/data_contribution_page';
//      Navigator.push(context, MaterialPageRoute(builder: (context) => FinishUploadPage()));
      Application.router.navigateTo(context, Routes.contribute_done, replace: true);
    } else {
      Fluttertoast.showToast(msg: S.of(context).scan_upload_error);
      setState(() {
        _isOnPressed = false;
      });
    }
  }

  Widget _confirmView() {
    if (_isFinishScan) {
      return Positioned(
        bottom: 20,
        child: Column(
          children: <Widget>[
            RaisedButton(
              shape: StadiumBorder(),
              onPressed: _isOnPressed
                  ? null
                  : () {
                      setState(() {
                        _isOnPressed = true;
                      });

                      _onPressed();
                    },
              color: HexColor("#CC941E"),
              disabledColor: Colors.grey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 13),
                child: Text(
                  S.of(context).scan_confirm_upload,
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => WebViewContainer(
                              initUrl: Const.PRIVACY_POLICY,
                              title: S.of(context).scan_signal_upload_protocol,
                            )));
              },
              child: SizedBox(
                  width: 200,
                  height: 40,
                  child: Row(
                    children: <Widget>[
                      Checkbox(
                        value: _isAcceptSignalProtocol,
                        activeColor: _themeColor, //选中时的颜色
                        onChanged: (value) {
                          setState(() {
                            _isAcceptSignalProtocol = value;
                          });
                        },
                      ),
                      Text(
                        S.of(context).scan_signal_upload_protocol,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          decoration: TextDecoration.combine([
                            TextDecoration.underline, // 下划线
                          ]),
                          decorationStyle: TextDecorationStyle.solid,
                          // 装饰样式
                          decorationColor: Colors.white,
                        ),
                      ),
                    ],
                    mainAxisAlignment: MainAxisAlignment.center,
                  )),
            ),
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  Widget _buildFirstItem(String value) {
    return Container(
      child: Text(
        value,
        textAlign: TextAlign.left,
        style: TextStyle(color: HexColor("#FEFEFE"), fontSize: 16, fontWeight: FontWeight.w500),
      ),
      margin: EdgeInsets.only(
        bottom: 4,
      ),
    );
  }

  Widget _buildItem(String value) {
    return Container(
      child: Text(
        value,
        textAlign: TextAlign.left,
        style: TextStyle(color: HexColor("#FEFEFE"), fontSize: 12),
      ),
      margin: EdgeInsets.only(
        bottom: 4,
      ),
    );
  }

  Widget _buildStatusListView() {
    var list = _getStatusDataList();
    return Positioned(
      top: 21,
      left: 14,
      child: Container(
        height: 300,
        width: 250,
        child: ListView.separated(
          physics: new NeverScrollableScrollPhysics(),
          padding: EdgeInsets.only(top: 0, bottom: 0),
          itemBuilder: (context, index) {
            return index == 0 ? _buildFirstItem(list.first) : _buildItem(list[index]);
          },
          separatorBuilder: (context, index) {
            return Container(
              height: 6,
            );
          },
          itemCount: list.length,
        ),
      ),
    );
  }

  Widget _mapView() {
    var style =
        SettingInheritedModel.of(context).areaModel.isChinaMainland ? Const.kBlackMapStyleCn : Const.kBlackMapStyle;

    return MapboxMap(
      compassEnabled: false,
      initialCameraPosition: CameraPosition(
        target: _userPosition,
        zoom: _defaultZoom,
      ),
      styleString: style,
      myLocationTrackingMode: MyLocationTrackingMode.None,
      onMapCreated: (mapboxController) {
        mapController = mapboxController;
        Future.delayed(Duration(milliseconds: 1000)).then((v) {
          startScan();
        });
      },
      rotateGesturesEnabled: false,
      tiltGesturesEnabled: false,
      enableLogo: false,
      enableAttribution: false,
      minMaxZoomPreference: MinMaxZoomPreference(1.1, 21.0),
      myLocationEnabled: false,
    );
  }

  Future<bool> _uploadCollectData() async {
    var uploadPosition = _userPosition;
    contributionLatlng.LatLng _latlng = contributionLatlng.LatLng(uploadPosition.latitude, uploadPosition.longitude);
    SignalCollector _signalCollector = SignalCollector(_latlng, _collectData);

    var activatedWalletVo = WalletInheritedModel.of(context).activatedWallet;
    var hynAddress;
    if (activatedWalletVo != null) {
      for (var coin in activatedWalletVo?.coins) {
        if (coin.symbol == SupportedTokens.HYN.symbol) {
          hynAddress = coin.address;
          break;
        }
      }
    }

    if (hynAddress == null) {
      Fluttertoast.showToast(msg: S.of(context).scan_hyn_is_empty);
      return false;
    }

    var platform = Platform.isIOS ? "iOS" : "android";

    var uploadStatus = await _api.signalCollector(platform, hynAddress, _signalCollector);
    return uploadStatus;
  }

  void _showCloseDialog() {
    if (_isFinishScan) {
      Navigator.of(context).pop();
      return;
    }

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Platform.isIOS
              ? CupertinoAlertDialog(
                  content: Text(S.of(context).scan_exit_tips),
                  actions: <Widget>[
                    FlatButton(
                      child: Text(
                        S.of(context).cancel,
                        style: TextStyle(color: Colors.blue),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    FlatButton(
                      child: Text(
                        S.of(context).confirm,
                        style: TextStyle(color: Colors.blue),
                      ),
                      onPressed: () {
                        _sensorPlugin.stopScan();
                        Navigator.pop(context);
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                )
              : AlertDialog(
                  content: Text(S.of(context).scan_exit_tips),
                  actions: <Widget>[
                    FlatButton(
                      child: Text(S.of(context).cancel),
                      onPressed: () => Navigator.pop(context),
                    ),
                    FlatButton(
                      child: Text(S.of(context).confirm),
                      onPressed: () {
                        _sensorPlugin.stopScan();
                        Navigator.pop(context);
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
        });
  }
}

class RadarScan extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return RadarScanState();
  }
}

class RadarScanState extends State<RadarScan> with SingleTickerProviderStateMixin {
  AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 4),
    );

    animationController.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: Colors.transparent,
      child: AnimatedBuilder(
        animation: animationController,
        child: Container(
          child: Image.asset(
            'res/drawable/radar_scan.png',
            fit: BoxFit.cover,
          ),
        ),
        builder: (BuildContext context, Widget _widget) {
          return Transform.rotate(
            angle: animationController.value * 6.3,
            child: _widget,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}
