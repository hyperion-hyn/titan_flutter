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
import 'package:titan/src/pages/global_data/model/signal_total_vo.dart';
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
  SignalTotalVo _signalTotalVo;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    print('[signal_chart] --> initState：${_title}');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _getData();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.type == SignalChatsPage.NODE) {
      return SingleChildScrollView(
        child: _nodeWidget(),
      );
    } else if (widget.type == SignalChatsPage.SIGNAL){
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Text(_title),
            ),
            _weeklyTotalWidget(),
            _dailySignalWidget(type: SensorType.GPS),
            _dailySignalWidget(type: SensorType.WIFI),
            _dailySignalWidget(type: SensorType.BLUETOOTH),
            _dailySignalWidget(type: SensorType.CELLULAR),
          ],
        ),
      );
    } else if (widget.type == SignalChatsPage.POI) {
      return SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(_title),
                )),
            _poiWidget(),
            _dailySignalWidget(type: SensorType.POI),
          ],
        ),
      );
    } else {
    }
  }


  Widget _poiWidget() {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: SizedBox(width: double.infinity, child: Text(S.of(context).poi_total_data, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: FadeInImage.assetNetwork(
              image: "xxx",
              placeholder: 'res/drawable/signal_map.png',
//            width: 112,
//            height: 84,
              fit: BoxFit.fill,
            ),
          ),
        ),
      ],
    );
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
      x:'right',
      y: 'bottom',
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
    double _chartsWidth = _size.width - 16.0 * 2.0;
    double _chartsHeight = (299.3 * _chartsWidth) / 343 ;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
            padding: const EdgeInsets.all(16.0),
            //color: HexColor('#404a59'),
            //color: Colors.w,
            child: Text(_title, style: TextStyle(color: Colors.black))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
//                padding: const EdgeInsets.all(8),
              child: Center(
                child: Echarts(
                  option: _barOption,
                  extensions: [worldScript],
                  captureAllGestures: true,
                  onMessage: (String message) {
                    Map<String, Object> messageAction = jsonDecode(message);
                    print(messageAction);
                  },
                ),
              ),
              width: _chartsWidth,
              height: _chartsHeight,
            ),
          ),
        ),
      ],
    );
  }

  Widget _weeklyTotalWidget() {
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
            backgroundColor: "#0B1837",
            width: 360,
            color: ["#906BF9", "#FE5656", "#3DD1F9", "#FFAD05"],
            title: {
              text: 'Hyperion map3 signal',
              subtext: 'Signal stat for hyperion map3',
              x: "left",
              textStyle: {
                color: '#fff',
                fontSize: 14,
                fontWeight: 0
              }
            },
            grid: {
              left: -100,
              top: 50,
              bottom: 10,
              right: 10,
              containLabel: true
            },
            tooltip: {
              trigger: 'item',
              formatter: "{b} : {c} ({d}%)"
            },
            legend: {
              type: "scroll",
              orient: "vartical",
              top: 420,
              bottom: "0%",
              itemWidth: 16,
              itemHeight: 8,
              itemGap: 16,
              textStyle: {
                color: '#A3E2F4',
                fontSize: 12,
                fontWeight: 0
              },
              data: ['Wifi', 'Cellular', 'BlueTooth', 'GPS']
            },
            polar: {},
            angleAxis: {
              interval: 1,
              type: 'category',
              data: [],
              z: 10,
              axisLine: {
                show: false,
                lineStyle: {
                  color: "#0B4A6B",
                  width: 1,
                  type: "solid"
                },
              },
              axisLabel: {
                interval: 0,
                show: true,
                color: "#0B4A6B",
                margin: 8,
                fontSize: 16
              },
            },
            radiusAxis: {
              min: 40,
              max: 120,
              interval: 20,
              axisLine: {
                show: false,
                lineStyle: {
                  color: "#0B3E5E",
                  width: 1,
                  type: "solid"
                },
              },
              axisLabel: {
                formatter: '{value} %',
                show: false,
                padding: [0, 0, 20, 0],
                color: "#0B3E5E",
                fontSize: 16
              },
              splitLine: {
                lineStyle: {
                  color: "#0B3E5E",
                  width: 2,
                  type: "solid"
                }
              }
            },
            calculable: true,
            series: [{
              type: 'pie',
              radius: ["5%", "10%"],
              hoverAnimation: false,
              labelLine: {
                normal: {
                  show: false,
                  length: 30,
                  length2: 55
                },
                emphasis: {
                  show: false
                }
              },
              data: [{
                name: '',
                value: 0,
                itemStyle: {
                  normal: {
                    color: "#0B4A6B"
                  }
                }
              }]
            }, {
              type: 'pie',
              radius: ["90%", "95%"],
              hoverAnimation: false,
              labelLine: {
                normal: {
                  show: false,
                  length: 30,
                  length2: 55
                },
                emphasis: {
                  show: false
                }
              },
              name: "",
              data: [{
                name: '',
                value: 0,
                itemStyle: {
                  normal: {
                    color: "#0B4A6B"
                  }
                }
              }]
            }, {
              stack: 'a',
              type: 'pie',
              radius: ['20%', '80%'],
              roseType: 'area',
              zlevel: 10,
              label: {
                normal: {
                  show: true,
                  formatter: "{c}",
                  textStyle: {
                    fontSize: 12,
                  },
                  position: 'inside'
                },
                emphasis: {
                  show: true
                }
              },
              labelLine: {
                normal: {
                  show: true,
                  length: 20,
                  length2: 55
                },
                emphasis: {
                  show: false
                }
              },
              data: [{
                  value: ${jsonEncode(_signalTotalVo?.wifiTotal??0)},
                name: 'Wifi'
              },
                {
                  value: ${jsonEncode(_signalTotalVo?.cellularTotal??0)},
                  name: 'Cellular'
                },
                {
                  value: ${jsonEncode(_signalTotalVo?.blueToothTotal??0)},
                  name: 'BlueTooth'
                },
                {
                  value: ${jsonEncode(_signalTotalVo?.gpsTotal??0)},
                  name: 'GPS'
                }
              ]
            },
            ]
          }                  ''';

    var _size = MediaQuery.of(context).size;
    double _chartsWidth = _size.width - 8;
    double _chartsHeight = 300;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        /*Padding(
          child: Text(S.of(context).signal_total_data, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          padding: EdgeInsets.fromLTRB(20, 16, 0, 8),
        ),*/
        Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8.0,
                    ),
                  ],
                ),
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
          ),
        ),
      ],
    );
  }

  Widget _dailySignalWidget({int type}) {
    var _size = MediaQuery.of(context).size;
    double _chartsWidth = _size.width - 0;
    double _chartsHeight = type != SensorType.POI ? 250 : 180;
    var left = "15%";
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

          left = "25%";
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
       left: ${jsonEncode(left)},
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

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),

        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8.0,
              ),
            ],
          ),
          child: Column(
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
                  padding: EdgeInsets.fromLTRB(type == SensorType.GPS?0:20, 0, 0, 0),
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
          ),
        ),
      ),
    );
  }

  Future _getData() async {
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
          _signalTotalVo = await _api.getSignalTotal();
          //_weeklyVoList = await _api.getSignalWeekly(language: languageCode);
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

    if (mounted) {setState(() {});}
  }

}
