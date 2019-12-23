import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:titan/src/business/home/sensor/bloc.dart';
import 'package:titan/src/business/scaffold_map/map.dart';
import 'package:titan/src/consts/consts.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/plugins/sensor_plugin.dart';
import '../webview/webview.dart';
import 'sensor/bloc.dart';

class ContributionPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ContributionState();
  }
}

class _ContributionState extends State<ContributionPage> {
  MapboxMapController mapController;

  ScrollController scrollController = ScrollController();

  StreamSubscription subscription;

  LatLng userPosition;
  double defaultZoom = 18;

  StreamController<double> progressStreamController =
      StreamController.broadcast();

  double minZoom = 13;
  int maxMeter = 5000;

  SensorPlugin sensorPlugin;

  @override
  void initState() {
    super.initState();
    _bloc = SensorBloc();
    sensorPlugin = SensorPlugin(_bloc);
    initPosition();
  }

  void initPosition() async {
    userPosition =
        await (Keys.mapContainerKey.currentState as MapContainerState)
            .mapboxMapController
            ?.lastKnownLocation();
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
  SensorBloc _bloc;
  Map<dynamic, dynamic> _wifiValues;
  Map<dynamic, dynamic> _bluetoothValues;
  Map<dynamic, dynamic> _gpsValues;
  Map<dynamic, dynamic> _cellularValues;


  void startScan() async {
    progressStreamController.add(0);
    duration = max<int>((defaultZoom - minZoom).toInt() * 3000, duration);
    var timeStep = duration / (defaultZoom - minZoom + 1);
    var timerObservable =
        Observable.periodic(Duration(milliseconds: 500), (x) => x);
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
          mapController.animateCameraWithTime(
              CameraUpdate.zoomTo(lastZoom--), 1000);
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
              return Container();
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
                // todo: 模拟数据
                var angleValue = 360 * value;
                String status = value > 1.0 ? "扫描完成" : "正在扫描中...";
                var signalValue = "信号源:${value}";
                String signalName = '正在$_currentScanType信号扫描';

                // todo: test
                if (value > 1.0) {
                  sensorPlugin.stopScan();
                }

                return BlocBuilder<SensorBloc, SensorState>(
                  bloc: _bloc,
                  builder: (context,state) {

                    if (state is ValueChangeListenerState) {
                      //print('[contribution] -->build, values:${state.values}');

                      var values = state.values;
                      int sensorType = values["sensorType"];
                      switch (sensorType) {
                        case -1:
                          print('[sensor] --> WIFI');
                          _wifiValues = values;
                          break;

                        case -2:
                          print('[sensor] --> BLUETOOTH');
                          _bluetoothValues = values;
                          break;

                        case -3:
                          print('[sensor] --> GPS');
                          _gpsValues = values;
                          break;

                        case -5:
                          print('[sensor] --> CELLULAR');
                          _cellularValues = values;
                          break;
                      }
                      return Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              child: Text(
                                status,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    color: HexColor("#FEFEFE"), fontSize: 14),
                              ),
                              margin: EdgeInsets.only(
                                bottom: 6,
                              ),
                            ),
                            Container(
                              child: Text(
                                signalName,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    color: HexColor("#FEFEFE"), fontSize: 14),
                              ),
                              margin: EdgeInsets.only(
                                bottom: 6,
                              ),
                            ),
                            Container(
                              child: Text(
                                signalValue,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    color: HexColor("#FEFEFE"), fontSize: 11),
                              ),
                              margin: EdgeInsets.only(
                                bottom: 6,
                              ),
                            ),
                            Container(
                              child: Text(
                                '强度：$angleValue',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    color: HexColor("#FEFEFE"), fontSize: 11),
                              ),
                              margin: EdgeInsets.only(
                                bottom: 6,
                              ),
                            ),
                            Container(
                              child: Text(
                                '角度：$angleValue',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    color: HexColor("#FEFEFE"), fontSize: 11),
                              ),
                              margin: EdgeInsets.only(
                                bottom: 6,
                              ),
                            ),
                            Container(
                              child: Text(
                                '距离：$angleValue',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    color: HexColor("#FEFEFE"), fontSize: 11),
                              ),
                              margin: EdgeInsets.only(
                                bottom: 6,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return Container();
                  }
                );
              },
            ),
          ),
//          Positioned(
//            top: 21,
//            right: 15,
//            child: Container(
//              child: Column(
//                crossAxisAlignment: CrossAxisAlignment.end,
//                children: <Widget>[
//                  Container(
//                    child: Text(
//                      '最大范围约：$maxMeter 米',
//                      textAlign: TextAlign.center,
//                      style:
//                          TextStyle(color: HexColor("#FEFEFE"), fontSize: 11),
//                    ),
//                    padding: EdgeInsets.symmetric(vertical: 3, horizontal: 13),
//                    margin: EdgeInsets.only(
//                      top: 8,
//                    ),
//                    decoration: BoxDecoration(
//                        color: _themeColor,
//                        borderRadius: BorderRadius.circular(30)),
//                  ),
//                ],
//              ),
//            ),
//          ),
          Positioned(
            child: SizedBox(
              height: 3,
              child: StreamBuilder<double>(
                stream: progressStreamController.stream,
                builder: (ctx, snap) {
                  return LinearProgressIndicator(
                    backgroundColor: _themeColor,
                    value: snap?.data ?? 0.0,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(HexColor("#FFFFFF")),
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
                  return Container();
                }
                return Column(
                  children: <Widget>[
                    RaisedButton(
                      shape: StadiumBorder(),
                      onPressed: () {
                        Navigator.pop(context);
                      },
//                    color: Theme.of(context).primaryColor,
                      color: HexColor("#CC941E"),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 48, vertical: 13),
                        child: Text(
                          '确认上传',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: (){
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
                                style:
                                    TextStyle(color: Colors.white, fontSize: 11),
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
}

class RadarScan extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return RadarScanState();
  }
}

class RadarScanState extends State<RadarScan>
    with SingleTickerProviderStateMixin {
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
