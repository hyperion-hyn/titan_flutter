import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/business/discover/dmap_define.dart';
import 'package:titan/src/business/home/global_data/model/map3_node_vo.dart';
import 'package:titan/src/business/home/global_data/model/signal_daily_vo.dart';
import 'package:titan/src/business/home/global_data/model/signal_weekly_vo.dart';
import 'package:titan/src/business/my/app_area.dart';
import 'package:titan/src/business/scaffold_map/map.dart';
import 'package:titan/src/consts/consts.dart';
import 'package:titan/src/data/api/api.dart';
import 'package:titan/src/global.dart';
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

    _getData();

    print('[signal_chart] --> initState：${_title}');
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
                      child: SizedBox(width: double.infinity, child: Text('POI数据分布：', style: TextStyle(fontSize: 14))),
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
    if (currentAppArea.key == AppArea.MAINLAND_CHINA_AREA.key) {
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
          target: LatLng(23.13246724,113.36946487),// 天河公园-学院附近
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
      S.of(globalContext).scan_name_gps,
      S.of(globalContext).scan_name_wifi,
      S.of(globalContext).scan_name_bluetooth,
      S.of(globalContext).scan_name_cellular,
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
          child: Text('信号数据总量：', style: TextStyle(fontSize: 14)),
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
    double _chartsHeight = type != SensorType.POI ? 250:180;

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
        var dateText = date.month.toString() + '月' + date.day.toString() + '日';
        if (appLocale.languageCode != 'zh') {
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
                  child: Text('最近一个月${SensorType.getScanName(type)}数据增量：', style: TextStyle(fontSize: 14))),
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
    switch (widget.type) {
      case SignalChatsPage.NODE:
        {
          _title =
              '''Map3节点网络启用全新的空间数据模型，旨在大规模、高性能及低成本地将基础设施提升1000倍。Map3是由One Map算法技术支撑的去中心化地图/位置服务PaaS, 旨在支持构建Map3去中心化节点的大型网络。''';
          _map3nodeVo = await _api.getMap3NodeData();
        }
        break;

      case SignalChatsPage.SIGNAL:
        {
          _title = '''信号数据将有效提升去中心化地图的定位精准度，只要有GPS，蓝牙，基站或WIFI信号的地区就能提供有效的应急救援、精准导航等定位功能，适用于户外徒步或探险等多场景应用。''';
          _weeklyVoList = await _api.getSignalWeekly();
          var dailyList = await _api.getSignalDaily();
          _dailyVo = dailyList[0];
        }
        break;

      case SignalChatsPage.POI:
        {
          _title =
              '''POI贡献基于众包、众治的去中心化理念，以去中心化的最有效方式鼓励用户贡献真实详细的位置详情。为避免POI信息有误，同时推出博弈系统配合网络验证，开放给所有地图用户查验POI数据真实性。未来想要搜索附近好吃好玩的目的地，只需在App首页输入关键字，如美食、酒店、商场、景点等，即可查看该位置点详情。''';
          _poiVoList = await _api.getPoiDaily();
        }
        break;
    }

    setState(() {});
  }
}
