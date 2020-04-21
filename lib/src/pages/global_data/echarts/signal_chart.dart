import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/api/api.dart';
import 'package:titan/src/pages/discover/dmap_define.dart';
import 'package:titan/src/pages/global_data/model/map3_node_vo.dart';
import 'package:titan/src/pages/global_data/model/signal_daily_vo.dart';
import 'package:titan/src/pages/global_data/model/signal_weekly_vo.dart';
import 'package:titan/src/plugins/sensor_type.dart';
import 'world.dart' show worldScript;

class SignalChatsPage extends StatefulWidget {
  static const int POI = -1;
  static const int SIGNAL = -2;
  static const int NODE = -3;

  final int type;

  SignalChatsPage({this.type});

  @override
  _SignalChatsState createState() => _SignalChatsState();
}

class _SignalChatsState extends State<SignalChatsPage> with AutomaticKeepAliveClientMixin {
  Api _api = Api();
  SignalDailyVo _dailyVo;
  List<SignalWeeklyVo> _weeklyVoList;
  var _title = "";
  List<Signal> _poiVoList;
  Map3NodeVo _map3nodeVo;

  @override
  bool get wantKeepAlive => true;
  MapboxMapController _mapboxMapController;

  @override
  void initState() {
    super.initState();

    print('[signal_chart] --> initState：${_title}');
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();

    _getData();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.type == SignalChatsPage.NODE) {
      return SingleChildScrollView(
        child: _nodeWidget(),
      );
    } else if (widget.type == SignalChatsPage.POI) {
      return Stack(fit: StackFit.expand, children: <Widget>[
        _mapView(),
        Positioned(
            left: 0,
            right: 0,
            top: 0,
            //bottom: 16,
            child: Column(
              children: <Widget>[
                Container(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(_title),
                    )),
                Container(
                    color: Colors.white,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 0, 0, 8),
                      child: SizedBox(width: double.infinity, child: Text(S.of(context).poi_total_data, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
                    )),
              ],
            )),
        Positioned(left: 0, right: 0, bottom: 0, child: _dailySignalWidget(type: SensorType.POI)),
      ]);
    } else {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Text(_title),
            ),
            _weeklySignalWidget(),
            _dailySignalWidget(type: SensorType.GPS),
            _dailySignalWidget(type: SensorType.WIFI),
            _dailySignalWidget(type: SensorType.BLUETOOTH),
            _dailySignalWidget(type: SensorType.CELLULAR),
          ],
        ),
      );
    }
  }

  Widget _mapView() {
    var style;

    if (SettingInheritedModel.of(context).areaModel.isChinaMainland) {
      style = Const.kWhiteMapStyleCn;
    } else {
      style = Const.kWhiteMapStyle;
    }

    var languageCode = Localizations.localeOf(context).languageCode;
    DMapCreationModel model = DMapDefine.kMapList["poi"];
    var models = model.dMapConfigModel.heavenDataModelList;
    print('[signal] --> _mapView, models.length:${models.length}, name:${models[0].sourceLayer}');

    return MapboxMapParent(
      key: Keys.mapHeatKey,
      controller: _mapboxMapController,
      child: MapboxMap(
        compassEnabled: false,
        initialCameraPosition: CameraPosition(
          target: LatLng(23.13246724, 113.36946487), // 天河公园-学院附近
          zoom: 12,
        ),
        styleString: style,
        onMapCreated: onMapCreated,
        myLocationTrackingMode: MyLocationTrackingMode.None,
        rotateGesturesEnabled: false,
        tiltGesturesEnabled: false,
        enableLogo: false,
        enableAttribution: false,
        minMaxZoomPreference: MinMaxZoomPreference(1.1, 21.0),
        myLocationEnabled: false,
        languageCode: languageCode,
        children: <Widget>[
          ///active plugins
          HeavenPlugin(models: models),
        ],
      ),
    );
  }

  void onMapCreated(MapboxMapController controller) {
    print('[signal] --> onMapCreated, controller:${controller}');
    _mapboxMapController = controller;
  }

  Widget _nodeWidget() {
    var data = [];

    if (_map3nodeVo != null && _map3nodeVo.tiles.length > 0) {
      var geoCoordCounts = [];
      var geoCoordMap = {};

      for (var i = 0; i < _map3nodeVo.tiles.length; i++) {
        var item = _map3nodeVo.tiles[i];
        geoCoordMap[item.id.city] = item.id.location;
        var dict = {'name': item.id.city, 'value': item.count};
        geoCoordCounts.add(dict);
      }
      //print('[item] --> geoCoordMap:${geoCoordMap}');

      for (var i = 0; i < geoCoordCounts.length; i++) {
        var item = geoCoordCounts[i];

        var geoCoord = geoCoordMap[item['name']];
        var value = double.parse(item['value'].toString());
        if (geoCoord is List) {
          geoCoord.add(value);
        }
        if (geoCoord != null) {
          var dict = {'name': item['name'], 'value': geoCoord};
          //print('[item] --> dict:${dict}');

          data.add(dict);
        }
      }
    }
    //print('[node] --> geoCoordMap:${data.length}');

    var _barOption = '''
{
    backgroundColor: '#404a59',
    title: {
      text: 'Hyperion map3 nodes',
      subtext: 'Nodes for hyperion map3',
      sublink: 'https://www.map3.metwork',
      x:'left',
      textStyle: {
        color: '#fff'
      }
    },
    tooltip: {
      trigger: 'item',
      formatter: function (params) {
        return params.name + ' : ' + params.value[2];
      }
    },
    legend: {
      orient: 'vertical',
      y: 'bottom',
      x:'right',
      data:['map3 nodes'],
      textStyle: {
        color: '#fff'
      }
    },
    visualMap: {
      min: 0,
      max: 200,
      calculable: true,
      color: ['#d94e5d','#eac736','#50a3ba'],
      textStyle: {
        color: '#fff'
      }
    },
    geo: {
      //top: '15%',
      map: 'world',
      label: {
        emphasis: {
          show: false
        }
      },
      itemStyle: {
        normal: {
          areaColor: '#323c48',
          borderColor: '#111'
        },
        emphasis: {
          areaColor: '#2a333d'
        }
      }
    },
    series: [
      {
        name: 'map3 nodes',
        type: 'scatter',
        coordinateSystem: 'geo',
        data: ${jsonEncode(data)},
        symbolSize: 10,
        label: {
          normal: {
            show: false
          },
          emphasis: {
            show: false
          }
        },
        itemStyle: {
          emphasis: {
            borderColor: '#fff',
            borderWidth: 1
          }
        }
      }
    ]
}
    ''';

    var _size = MediaQuery.of(context).size;
    double _chartsWidth = _size.width - 8.0;
    double _chartsHeight = 300;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
            padding: const EdgeInsets.all(16.0),
            //color: HexColor('#404a59'),
            //color: Colors.w,
            child: Text(_title, style: TextStyle(color: Colors.black))),
        Center(
          child: Container(
            child: Echarts(
              option: _barOption,
              extensions: [worldScript],
              captureAllGestures: true,
              onMessage: (String message) {
                Map<String, Object> messageAction = jsonDecode(message);
                print(messageAction);
              },
            ),
            width: _chartsWidth,
            height: _chartsHeight,
          ),
        ),
      ],
    );
  }

  Widget _weeklySignalWidget() {
    var legendData = [
      S.of(context).scan_name_gps,
      S.of(context).scan_name_wifi,
      S.of(context).scan_name_bluetooth,
      S.of(context).scan_name_cellular,
    ];
    var data = [];
    if (_weeklyVoList != null) {
      data = [];
      var gps = [];
      var wifi = [];
      var bluetooth = [];
      var cellular = [];
      for (var item in _weeklyVoList) {
        gps.add(item.gpsCount);
        wifi.add(item.wifiCount);
        bluetooth.add(item.blueToothCount);
        cellular.add(item.cellularCount);
      }
      data = [gps, wifi, bluetooth, cellular];
    }

    var series = [];
    for (int i = 0; i < legendData.length; i++) {
      var json = {
        'name': legendData[i],
        'smooth': true,
        'symbol': 'circle',
        'type': 'line',
        'data': data.isNotEmpty ? data[i] : [],
      };
      series.add(json);
    }

    var _barOption = '''
 {
    tooltip: {
      trigger: 'axis'
    },
    legend: {
      data: ${jsonEncode(legendData)},
      bottom: '3%'
    },
    calculable: true,
    xAxis: [
      {
            type: 'category',
      }
    ],
    yAxis: [
      {
            type: 'value'
      }
    ],
    grid: {
       left: '20%',
       right: '5%',
    },
    series: ${jsonEncode(series)}
}
                  ''';

    var _size = MediaQuery.of(context).size;
    double _chartsWidth = _size.width - 8;
    double _chartsHeight = 250;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          child: Text(S.of(context).signal_total_data, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          padding: EdgeInsets.fromLTRB(20, 16, 0, 8),
        ),
        Center(
          child: Container(
            child: Echarts(
              option: _barOption,
              onMessage: (String message) {
                Map<String, Object> messageAction = jsonDecode(message);
                print(messageAction);
              },
            ),
            width: _chartsWidth,
            height: _chartsHeight,
          ),
        ),
      ],
    );
  }

  Widget _dailySignalWidget({int type}) {
    var _size = MediaQuery.of(context).size;
    double _chartsWidth = _size.width - 0;
    double _chartsHeight = type != SensorType.POI ? 250 : 180;

    var xAxisData = [];
    var seriesData = [];
    if (_dailyVo != null || _poiVoList != null) {
      var list = [];
      switch (type) {
        case SensorType.WIFI:
          list = _dailyVo.wifi;
          break;

        case SensorType.CELLULAR:
          list = _dailyVo.cellular;
          break;

        case SensorType.BLUETOOTH:
          list = _dailyVo.blueTooth;
          break;

        case SensorType.GPS:
          list = _dailyVo.gps;
          break;

        case SensorType.POI:
          list = _poiVoList;
          break;
      }

      for (var item in list) {
        var date = DateTime.parse(item.day);
        var languageCode = Localizations.localeOf(context).languageCode;

        var dateText = date.month.toString() + S.of(context).month + date.day.toString() + S.of(context).day;
        if (languageCode != 'zh') {
          dateText = date.month.toString() + '-' + date.day.toString();
        }
        xAxisData.add(dateText);
        seriesData.add(item.count);
      }
    }

    var _lineOption = '''
 {
    xAxis: {
        type: 'category',
        data: ${jsonEncode(xAxisData)}
    },
    yAxis: {
        type: 'value'
    },
    grid: {
       left: '15%',
       top: '10%',
       bottom: '20%',
    },
    series: [{
        data: ${jsonEncode(seriesData)},
        smooth: true,
        symbol:'circle',
        type: 'line'
    }]
}
                  ''';

    //print('[signal] --> _lineOption:${_lineOption}');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 0, 0),
              child: SizedBox(
                  width: double.infinity,
                  child: Text(S.of(context).signal_chart_last_month_numbers_func("${SensorType.getScanName(context, type)}"),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ))),
            )),
        Center(
          child: Container(
            child: Echarts(
              option: _lineOption,
              onMessage: (String message) {
                Map<String, Object> messageAction = jsonDecode(message);
                print(messageAction);
              },
            ),
            width: _chartsWidth,
            height: _chartsHeight,
          ),
        ),
      ],
    );
  }

  _getData() async {
    var languageCode = Localizations.localeOf(context).languageCode;

    switch (widget.type) {
      case SignalChatsPage.NODE:
        {
          _title =
              S.of(context).signal_chart_desc_map3;
          _map3nodeVo = await _api.getMap3NodeData();
        }
        break;

      case SignalChatsPage.SIGNAL:
        {
          _title = S.of(context).signal_chart_desc_signal;
          _weeklyVoList = await _api.getSignalWeekly(language: languageCode);
          var dailyList = await _api.getSignalDaily(language: languageCode);
          _dailyVo = dailyList[0];
        }
        break;

      case SignalChatsPage.POI:
        {
          _title =
              S.of(context).signal_chart_desc_poi;
          _poiVoList = await _api.getPoiDaily(language: languageCode);
        }
        break;
    }

    setState(() {});
  }
}
