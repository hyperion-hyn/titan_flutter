import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/business/home/contribution_finish_page.dart';
import 'package:titan/src/business/my/app_area.dart';
import 'package:titan/src/business/scaffold_map/map.dart';
import 'package:titan/src/business/wallet/model/wallet_vo.dart';
import 'package:titan/src/business/wallet/service/wallet_service.dart';
import 'package:titan/src/consts/consts.dart';
import 'package:titan/src/data/api/api.dart';
import 'package:titan/src/plugins/sensor_plugin.dart';
import 'package:titan/src/plugins/sensor_type.dart';
import 'package:titan/src/utils/scan_util.dart';
import '../../global.dart';
import '../webview/webview.dart';
import 'package:titan/src/business/contribution/vo/signal_collector.dart';
import 'package:titan/src/business/contribution/vo/latlng.dart' as contributionLatlng;
import 'contribution_finish_page.dart';

class ContributionPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ContributionState();
  }
}

class _ContributionState extends State<ContributionPage> {
  MapboxMapController mapController;

  Api _api = Api();

  WalletService _walletService = WalletService();

  StreamSubscription subscription;

  LatLng userPosition;
  double defaultZoom = 18;

  StreamController<double> progressStreamController = StreamController.broadcast();

  double minZoom = 13;
  int maxMeter = 5000;

  SensorPlugin sensorPlugin;

  Map<String, List> collectData = new Map();

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

    sensorPlugin = SensorPlugin();
    initSensorChangeCallBack();
    initPosition();
  }

  @override
  void dispose() {
    super.dispose();

    subscription?.cancel();
    progressStreamController.close();
    sensorPlugin.destory();
  }

  void initSensorChangeCallBack() {
    _sensorChangeCallBack = (Map values) {
      _saveAllScanData(values);
    };
    sensorPlugin.sensorChangeCallBack = _sensorChangeCallBack;
  }

  void _saveAllScanData(Map values) {
    var sensorType = values["sensorType"] as int;

    // 1.for upload
    var typeString = SensorType.getTypeString(sensorType);
    var dataList = collectData[typeString];
    if (dataList == null) {
      dataList = List();
      collectData[typeString] = dataList;
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

  void initPosition() async {
    userPosition =
        await (Keys.mapContainerKey.currentState as MapContainerState).mapboxMapController?.lastKnownLocation();
    await sensorPlugin.init();
  }

  void startScan() async {
    progressStreamController.add(0);

    duration = max<int>((defaultZoom - minZoom).toInt() * 3000, duration);
    var timeStep = duration / (defaultZoom - minZoom + 1);
    var timerObservable = Observable.periodic(Duration(milliseconds: 500), (x) => x);
    lastZoom = defaultZoom;
    startTime = DateTime.now().millisecondsSinceEpoch;

    if (userPosition != null) {
      mapController.animateCamera(CameraUpdate.newLatLng(userPosition));
    }

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
        sensorPlugin.stopScan();
      }
    });

    sensorPlugin.startScan();
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
      item = 1.0 / 3.0;

      if (value > 0 && value < 1.0 * item) {
        _currentScanType = SensorType.CELLULAR;
      } else if (value >= 1.0 * item && value < 2.0 * item) {
        _currentScanType = SensorType.BLUETOOTH;
      } else if (value >= 2.0 * item && value < 1.0) {
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
    String signalName = S.of(context).scan_ing_func(SensorType.getScanName(_currentScanType));

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
    return Scaffold(
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
      body: StreamBuilder<double>(
          stream: progressStreamController.stream,
          builder: (context, snapshot) {
            return Center(
              child: Stack(
                fit: StackFit.expand,
                alignment: Alignment.center,
                children: <Widget>[
                  _mapView(),
                  RadarScan(),
                  _buildStatusListView(),
                  Positioned(
                    child: SizedBox(
                      height: 3,
                      child: LinearProgressIndicator(
                        backgroundColor: _themeColor,
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
              ),
            );
          }),
    );
  }

  Future<void> _onPressed() async {
    var isFinish = await uploadCollectData();
    //print('[Request] --> isFinish: ${isFinish}');
    if (isFinish) {
      createWalletPopUtilName = '/data_contribution_page';
      Navigator.push(context, MaterialPageRoute(builder: (context) => FinishUploadPage()));
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
                              initUrl: 'https://api.hyn.space/map-collector/upload/privacy-policy',
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
    var style;
    if (currentAppArea.key == AppArea.MAINLAND_CHINA_AREA.key) {
      style = "https://cn.tile.map3.network/fiord-color.json";
    } else {
      style = "https://static.hyn.space/maptiles/fiord-color.json";
    }

    return MapboxMap(
      compassEnabled: false,
      initialCameraPosition: CameraPosition(
        target: userPosition ?? LatLng(23.12076, 113.322058),
        zoom: defaultZoom,
      ),
      styleString: style,
      onStyleLoaded: (mapboxController) {
        mapController = mapboxController;
        Future.delayed(Duration(milliseconds: 1000)).then((v) {
          startScan();
        });
      },
      myLocationTrackingMode: MyLocationTrackingMode.None,
      rotateGesturesEnabled: false,
      tiltGesturesEnabled: false,
      enableLogo: false,
      enableAttribution: false,
      minMaxZoomPreference: MinMaxZoomPreference(1.1, 19.0),
      myLocationEnabled: false,
    );
  }

  Future<bool> uploadCollectData() async {
    var uploadPosition = userPosition ?? LatLng(23.12076, 113.322058);
    contributionLatlng.LatLng _latlng = contributionLatlng.LatLng(uploadPosition.latitude, uploadPosition.longitude);
    SignalCollector _signalCollector = SignalCollector(_latlng, collectData);
    WalletVo _walletVo = await _walletService.getDefaultWalletVo();
    if (_walletVo == null) {
      Fluttertoast.showToast(msg: S.of(context).scan_hyn_is_empty);
      return false;
    }

    var address = _walletVo.accountList[0].account.address;
    var platform = Platform.isIOS ? "iOS" : "android";

    var uploadStatus = await _api.signalCollector(platform, address, _signalCollector);
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
                        sensorPlugin.stopScan();
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
                        sensorPlugin.stopScan();
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
