import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/business/home/sensor/bloc.dart';
import 'package:titan/src/business/scaffold_map/map.dart';
import 'package:titan/src/business/wallet/model/wallet_vo.dart';
import 'package:titan/src/business/wallet/service/wallet_service.dart';
import 'package:titan/src/consts/consts.dart';
import 'package:titan/src/data/api/api.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/plugins/sensor_plugin.dart';
import 'package:titan/src/plugins/sensor_type.dart';
import '../webview/webview.dart';
import 'package:titan/src/business/contribution/vo/signal_collector.dart';
import 'package:titan/src/business/contribution/vo/latlng.dart' as contributionLatlng;

class ContributionPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ContributionState();
  }
}

class _ContributionState extends State<ContributionPage> {
  MapboxMapController mapController;

//  ScrollController scrollController = ScrollController();

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

  //SensorChangeCallBack _sensorChangeCallBack;
  SensorBloc _bloc;

  List<Map<dynamic, dynamic>> _wifiList;

  @override
  void initState() {
    super.initState();

    _bloc = SensorBloc();
    sensorPlugin = SensorPlugin(_bloc);
    //initSensorChangeCallBack();

    _wifiList = List();
    initPosition();
  }

  /*
  void initSensorChangeCallBack() {
    _sensorChangeCallBack = (Map values) {
      _saveData(values);
    };

    sensorPlugin.sensorChangeCallBack = _sensorChangeCallBack;
  }


  void _saveData(Map values) {
    var type = values["sensorType"] as int;

    var typeString = SensorType.getTypeString(type);

    var dataList = collectData[typeString];
    if (dataList == null) {
      dataList = List();
      collectData[typeString] = dataList;
    }
    dataList.add(values);
  }
 */

  void initPosition() async {
    userPosition =
        await (Keys.mapContainerKey.currentState as MapContainerState).mapboxMapController?.lastKnownLocation();
    await sensorPlugin.init();
  }

  int lastMoveTime = 0;
  int startTime = 0;
  int duration = 30000;
  double lastZoom;
  bool isVisibleWiFi = false;
  bool isVisibleToast = false;
  var _isAcceptSignalProtocol = true;
  var _themeColor = HexColor("#0F95B0");

  var _currentScanType = "WiFi";

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
      progressStreamController.add(timeGap / duration.toDouble());
      if (timeGap < duration) {
        //scan 30s
        if (nowTime - lastMoveTime > timeStep) {
          mapController.animateCameraWithTime(CameraUpdate.zoomTo(lastZoom--), 1000);
          lastMoveTime = DateTime.now().millisecondsSinceEpoch;
        }
      } else {
        subscription?.cancel();
      }
    });
    sensorPlugin.startScan();
  }

  @override
  void dispose() {
    subscription?.cancel();
    progressStreamController.close();
    super.dispose();
    sensorPlugin.destory();
  }

  String _getImageName() {
    var _imageName = "wifi";

    switch (_currentScanType) {
      case "WiFi":
        _imageName = "wifi";
        break;

      case "基站":
        _imageName = "basestation";
        break;

      case "蓝牙":
        _imageName = "bluetooth";
        break;

      case "GPS":
        _imageName = "gps";
        break;
    }

//    print('[me] --> _imageName:$_imageName');
    return _imageName;
  }

  void _setCurrentScanType(double currentValue) {
    var value = currentValue ?? 0.001;
    if (value > 0 && value < 0.25) {
      _currentScanType = "WiFi";
    } else if (value >= 0.25 && value < 0.5) {
      _currentScanType = "基站";
    } else if (value >= 0.5 && value < 0.75) {
      _currentScanType = "蓝牙";
    } else if (value >= 0.75 && value < 1.0) {
      _currentScanType = "GPS";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          "地图AI校验",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: <Widget>[
          mapView(),
          StreamBuilder<double>(
            stream: progressStreamController.stream,
            builder: (ctx, snap) {
              if (snap?.data != null && snap.data >= 0) {
                return RadarScan();
              }
              return Container(width: 0.0, height: 0.0);
            },
          ),
          Positioned(
            top: 21,
            left: 14,
            child: StreamBuilder(
              stream: progressStreamController.stream,
              builder: (ctx, snap) {
//                print('[scan] --> value: ${snap.data}');

                var value = snap.data ?? 0.001;
                if (value > 1.0) {
                  sensorPlugin.stopScan();
                }

                return BlocBuilder(
                  bloc: _bloc,
                  builder: (context, state) {
                    return _blocBuild(context, snap, state);
                  },
                );
              },
            ),
          ),
          /*
          Positioned(
            top: 21,
            right: 15,
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Container(
                    child: Text(
                      '最大范围约：$maxMeter 米',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(color: HexColor("#FEFEFE"), fontSize: 11),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 3, horizontal: 13),
                    margin: EdgeInsets.only(
                      top: 8,
                    ),
                    decoration: BoxDecoration(
                        color: _themeColor,
                        borderRadius: BorderRadius.circular(30)),
                  ),
                ],
              ),
            ),
          ),
          */
          Positioned(
            child: SizedBox(
              height: 3,
              child: StreamBuilder<double>(
                stream: progressStreamController.stream,
                builder: (ctx, snap) {
                  return LinearProgressIndicator(
                    backgroundColor: _themeColor,
                    value: snap?.data ?? 0.0,
                    valueColor: AlwaysStoppedAnimation<Color>(HexColor("#FFFFFF")),
                  );
                },
              ),
            ),
            top: 0,
            left: 0,
            right: 0,
          ),
          StreamBuilder<double>(
            stream: progressStreamController.stream,
            builder: (ctx, snap) {
              // todo: 模拟数据
              _setCurrentScanType(snap.data);

              return Image.asset(
                'res/drawable/${_getImageName()}_scan.png',
                scale: 2,
              );
            },
          ),
          Positioned(
            bottom: 48,
            child: StreamBuilder<double>(
              stream: progressStreamController.stream,
              builder: (ctx, snap) {
                if (snap.data == 1.0) {
                  return Container(width: 0.0, height: 0.0);
                }
                return Column(
                  children: <Widget>[
                    RaisedButton(
                      shape: StadiumBorder(),
                      onPressed: () {
                        uploadCollectData();
                        Navigator.pop(context);
                      },
//                    color: Theme.of(context).primaryColor,
                      color: HexColor("#CC941E"),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 13),
                        child: Text(
                          '确认上传',
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
                                      title: "信号上传协议",
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
                                "信号上传协议",
                                style: TextStyle(color: Colors.white, fontSize: 11),
                              ),
                            ],
                            mainAxisAlignment: MainAxisAlignment.center,
                          )),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFirstItem(String value) {
    print('[contribution] --> _buildFirstItem:${value}');

    return Container(
      child: Text(
        value,
        textAlign: TextAlign.left,
        style: TextStyle(color: HexColor("#FEFEFE"), fontSize: 14),
      ),
      margin: EdgeInsets.only(
        bottom: 6,
      ),
    );
  }

  Widget _buildItem(String value) {
    print('[contribution] --> _buildItem:${value}');

    return Container(
      child: Text(
        value,
        textAlign: TextAlign.left,
        style: TextStyle(color: HexColor("#FEFEFE"), fontSize: 11),
      ),
      margin: EdgeInsets.only(
        bottom: 6,
      ),
    );
  }

  Widget _buildListView(List list) {
    if (list.length == 0) {
      return Container(width: 0.0, height: 0.0);
    }

    return Container(
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
    );
  }

  Widget _blocBuild(BuildContext context, AsyncSnapshot snap, SensorState state) {
    if (snap.data == null) {
      return Container(width: 0.0, height: 0.0);
    }

    //print('[contribution] -->_blocBuild___1, value: ${snap.data}');

    String signalName = '正在$_currentScanType信号扫描';

    var newDataList = List();
    newDataList.add(signalName);

    if (state is ValueChangeListenerState) {
      var values = state.values;
      var sensorType = values["sensorType"] as int;
      print('[contribution] -->_blocBuild___2, sensorType: ${sensorType}, values: ${values}');

      // 1.sava data
      var typeString = SensorType.getTypeString(sensorType);
      var dataList = collectData[typeString];
      if (dataList == null) {
        dataList = List();
        collectData[typeString] = dataList;
      }
      dataList.add(values);
      print('[contribution] -->_blocBuild___3');

      // 2.update ui
      switch (sensorType) {
        case SensorType.WIFI:
          {
            print('[contribution] -->_blocBuild___wifi');

            if (TargetPlatform.iOS == TargetPlatform.values) {

            } else {
              print('[contribution] -->_blocBuild___wifi__android');

              var ssid = values["ssid"] ?? "";
              ssid = "ssid：${ssid}";
              newDataList.add(ssid);

              var bssid = values["bssid"] ?? "";
              bssid = "bssid：${bssid}";
              newDataList.add(bssid);

              var level = values["level"].toString() ?? "0";
              level = "level：${level}";
              newDataList.add(level);

              var _isExist = false;
              for (var item in _wifiList) {
                var _oldBssid = values["bssid"] ?? "";
                _oldBssid = "bssid：${_oldBssid}";
                if (_oldBssid == bssid) {
                  _isExist = true;
                  break;
                }
              }
              if (!_isExist) {
                _wifiList.add(values);
              }
            }
            break;
          }
        case SensorType.BLUETOOTH:
          {
            if (TargetPlatform.iOS == TargetPlatform.values) {
              var name = values["name"] ?? "";
              newDataList.add(name);

              var identifier = values["identifier"] ?? "";
              newDataList.add(identifier);

              var rssi = values["rssi"].toString() ?? "";
              newDataList.add(rssi);
            } else {
              var mac = values["mac"] ?? "";
              newDataList.add(mac);

              var name = values["name"] ?? "";
              newDataList.add(name);
            }
            break;
          }
        case SensorType.GPS:
          {
            var lat = values["lat"].toString() ?? "0";
            newDataList.add(lat);

            var lon = values["lon"].toString() ?? "0";
            newDataList.add(lon);

            var altitude = values["altitude"].toString() ?? "0";
            newDataList.add(altitude);

            var speed = values["speed"].toString() ?? "0";
            newDataList.add(speed);

            if (TargetPlatform.iOS == TargetPlatform.values) {
              var horizontalAccuracy = values["horizontalAccuracy"].toString() ?? "0";
              newDataList.add(horizontalAccuracy);

              var verticalAccuracy = values["verticalAccuracy"].toString() ?? "0";
              newDataList.add(verticalAccuracy);

              var course = values["course"].toString() ?? "0";
              newDataList.add(course);
            } else {
              var accuracy = values["accuracy"].toString() ?? "0";
              newDataList.add(accuracy);

              var bearing = values["bearing"].toString() ?? "0";
              newDataList.add(bearing);
            }
            break;
          }
        case SensorType.GNSS:
          {
            break;
          }
        case SensorType.CELLULAR:
          {
            if (TargetPlatform.iOS == TargetPlatform.values) {
//              var horizontalAccuracy =
//                  values["horizontalAccuracy"].toString() ?? "0";
//              newDataList.add(horizontalAccuracy);

            } else {
              var mobileType = values["type"].toString() ?? "";
              mobileType = "type：${mobileType}";
              newDataList.add(mobileType);

              switch (mobileType) {
                case "GSM":
//                  Utils.addIfNonNull(values, "type", "GSM")
//                  Utils.addIfNonNull(values, "cid", cid)
//                  Utils.addIfNonNull(values, "lac", lac)
//                  Utils.addIfNonNull(values, "mcc", mcc)
//                  Utils.addIfNonNull(values, "mnc", mnc)
//                  Utils.addIfNonNull(values, "asu", asu)
//                  Utils.addIfNonNull(values, "dbm", dbm)
//                  Utils.addIfNonNull(values, "level", level)
                  break;

                case "WCDMA":
//                  Utils.addIfNonNull(values, "type", "WCDMA")

                  var cid = values["cid"].toString() ?? "";
                  cid = "cid：${cid}";
                  newDataList.add(cid);
//                  Utils.addIfNonNull(values, "cid", cid)

//                  Utils.addIfNonNull(values, "lac", lac)

                  var mcc = values["mcc"].toString() ?? "";
                  mcc = "mcc：${mcc}";
                  newDataList.add(mcc);
//                  Utils.addIfNonNull(values, "mcc", mcc)

                  var mnc = values["mnc"].toString() ?? "";
                  mnc = "mnc：${mnc}";
                  newDataList.add(mnc);
//                  Utils.addIfNonNull(values, "mnc", mnc)

//                  Utils.addIfNonNull(values, "psc", psc)
//                  Utils.addIfNonNull(values, "asu", asu)
//                  Utils.addIfNonNull(values, "dbm", dbm)

                  var level = values["level"].toString() ?? "";
                  level = "level：${level}";
                  newDataList.add(level);
//                  Utils.addIfNonNull(values, "level", level)

                  break;

                case "CDMA":
//                  Utils.addIfNonNull(values, "type", "CDMA")
//                  Utils.addIfNonNull(values, "basestationId", basestationId)
//                  Utils.addIfNonNull(values, "latitude", latitude)
//                  Utils.addIfNonNull(values, "longitude", longitude)
//                  Utils.addIfNonNull(values, "networkId", networkId)
//                  Utils.addIfNonNull(values, "systemId", systemId)
//                  Utils.addIfNonNull(values, "asu", asu)
//                  Utils.addIfNonNull(values, "cdmaDbm", cdmaDbm)
//                  Utils.addIfNonNull(values, "cdmaEcio", cdmaEcio)
//                  Utils.addIfNonNull(values, "cdmaLevel", cdmaLevel)
//                  Utils.addIfNonNull(values, "dbm", dbm)
//                  Utils.addIfNonNull(values, "evdoDbm", evdoDbm)
//                  Utils.addIfNonNull(values, "evdoEcio", evdoEcio)
//                  Utils.addIfNonNull(values, "evdoLevel", evdoLevel)
//                  Utils.addIfNonNull(values, "evdoSnr", evdoSnr)
//                  Utils.addIfNonNull(values, "level", level)

                  break;

                case "LTE":
//                  Utils.addIfNonNull(values, "type", "LTE")
//                  Utils.addIfNonNull(values, "ci", ci)
//                  Utils.addIfNonNull(values, "mcc", mcc)
//                  Utils.addIfNonNull(values, "mnc", mnc)
//                  Utils.addIfNonNull(values, "pci", pci)
//                  Utils.addIfNonNull(values, "tac", tac)
//                  Utils.addIfNonNull(values, "asu", asu)
//                  Utils.addIfNonNull(values, "dbm", dbm)
//                  Utils.addIfNonNull(values, "level", level)
//                  Utils.addIfNonNull(values, "timingAdvance", timingAdvance)
                  break;
              }
            }
            break;
          }
        default:
          {
            break;
          }
      }
    }

    print('[contribution] -->_blocBuild___4, count:${newDataList.length}');

    return _buildListView(newDataList);
  }

  Widget mapView() {
    return MapboxMap(
      compassEnabled: false,
      initialCameraPosition: CameraPosition(
        target: userPosition ?? LatLng(23.12076, 113.322058),
        zoom: defaultZoom,
      ),
      styleString: 'https://cn.tile.map3.network/fiord-color.json',
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

  Future<void> uploadCollectData() async {
    var uploadPosition = userPosition ?? LatLng(23.12076, 113.322058);
    contributionLatlng.LatLng _latlng = contributionLatlng.LatLng(uploadPosition.latitude, uploadPosition.longitude);
    SignalCollector _signalCollector = SignalCollector(_latlng, collectData);
    WalletVo _walletVo = await _walletService.getDefaultWalletVo();
    if (_walletVo == null) {
      Fluttertoast.showToast(msg: "HYN wallet 为空");
      return;
    }

    var uuid = _walletVo.accountList[0].account.address;
    var platform = Platform.isIOS ? "iOS" : "android";

    await _api.signalCollector(platform, uuid, _signalCollector);
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
