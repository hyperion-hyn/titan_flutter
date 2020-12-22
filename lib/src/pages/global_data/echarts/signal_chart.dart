import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:loading/loading.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/api/api.dart';
import 'package:titan/src/widget/all_page_state/all_page_state.dart'
    as all_page_state;
import 'package:titan/src/pages/global_data/model/map3_node_vo.dart';
import 'package:titan/src/pages/global_data/model/signal_daily_vo.dart';
import 'package:titan/src/pages/global_data/model/signal_total_vo.dart';
import 'package:titan/src/pages/global_data/model/signal_weekly_vo.dart';
import 'package:titan/src/plugins/sensor_type.dart';
import 'package:titan/src/widget/all_page_state/all_page_state_container.dart';
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

class _SignalChatsState extends State<SignalChatsPage>
    with AutomaticKeepAliveClientMixin {
  Api _api = Api();
  SignalDailyVo _dailyVo;
  List<SignalWeeklyVo> _weeklyVoList;
  var _introduction = "";
  List<Signal> _poiVoList;
  Map3NodeVo _map3nodeVo;
  SignalTotalVo _signalTotalVo;
  all_page_state.AllPageState currentState = all_page_state.LoadingState();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    //print('[signal_chart] -->1 initState：${_introduction}');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _getData();

    //print('[signal_chart] -->2 initState：${_introduction}');
  }

  @override
  Widget build(BuildContext context) {
    if (currentState != null) {
      return AllPageStateContainer(currentState, () {
        setState(() {
          currentState = all_page_state.LoadingState();
        });

        _getData();
      });
    }

    if (widget.type == SignalChatsPage.NODE) {
      return SingleChildScrollView(
        child: _nodeWidget(),
      );
    } else if (widget.type == SignalChatsPage.SIGNAL) {
      return SingleChildScrollView(
        child: _signalWidget(),
      );
    } else if (widget.type == SignalChatsPage.POI) {
      return SingleChildScrollView(
        child: _poiWidget(),
      );
    } else {
      return Loading();
    }
  }

  Widget _nodeWidget() {
    if (_map3nodeVo == null) {
      return Loading();
    }

    var _size = MediaQuery.of(context).size;
    double _chartsWidth = _size.width - 16.0 * 2.0;
    double _chartsHeight = (299.3 * _chartsWidth) / 343;
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _introductionWidget(),
          _titleWidget(S.of(context).global_node_map_title),
          _clipRRectWidget(_nodeChartWidget(), _chartsWidth, _chartsHeight),
        ],
      ),
    );
  }

  Widget _signalWidget() {
    if (_dailyVo == null || _signalTotalVo == null) {
      return Loading();
    }

    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _introductionWidget(),
          _signalTotalChartWidget(),
          _dailySignalChartWidget(type: SensorType.GPS),
          _dailySignalChartWidget(type: SensorType.WIFI),
          _dailySignalChartWidget(type: SensorType.BLUETOOTH),
          _dailySignalChartWidget(type: SensorType.CELLULAR),
        ],
      ),
    );
  }

  Widget _poiWidget() {
    if (_poiVoList == null) {
      return Loading();
    }

    return Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          _introductionWidget(),
          _titleWidget(S.of(context).poi_total_data),
          _clipRRectWidget(FadeInImage.assetNetwork(
            image: "https://static.hyn.mobi/titan/images/mapmap.png",
            placeholder: 'res/drawable/signal_map.png',
            fit: BoxFit.fill,
          )),
          _dailySignalChartWidget(type: SensorType.POI),
        ],
      ),
    );
  }

  Widget _nodeChartWidget() {
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
    //313947
    //404a59
    var _barOption = '''
{
    backgroundColor: '#313947',
    tooltip: {
      trigger: 'item',
      formatter: function (params) {
        return params.name + ' : ' + params.value[2];
      }
    },
    legend: {
      orient: 'vertical',
      right: '5%',
      bottom: '5%',
      data:['map3 nodes'],
      textStyle: {
        color: '#fff'
      }
    },
    visualMap: {
      min: 0,
      max: 200,
      left: '2.5%',
      bottom: '2.5%',
      calculable: true,
      color: ['#d94e5d','#eac736','#50a3ba'],
      textStyle: {
        color: '#fff'
      }
    },
    geo: {
      top: '15%',
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

    return Echarts(
      option: _barOption,
      extensions: [worldScript],
      captureAllGestures: true,
      onMessage: (String message) {
        Map<String, Object> messageAction = jsonDecode(message);
        print(messageAction);
      },
    );
  }

  Widget _signalTotalChartWidget() {
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
                  value: ${jsonEncode(_signalTotalVo?.wifiTotal ?? 0)},
                name: 'Wifi'
              },
                {
                  value: ${jsonEncode(_signalTotalVo?.cellularTotal ?? 0)},
                  name: 'Cellular'
                },
                {
                  value: ${jsonEncode(_signalTotalVo?.blueToothTotal ?? 0)},
                  name: 'BlueTooth'
                },
                {
                  value: ${jsonEncode(_signalTotalVo?.gpsTotal ?? 0)},
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
        _titleWidget(S.of(context).signal_total_data),
        _clipRRectWidget(
            Echarts(
              option: _barOption,
              onMessage: (String message) {
                Map<String, Object> messageAction = jsonDecode(message);
                print(messageAction);
              },
            ),
            _chartsWidth,
            _chartsHeight),
      ],
    );
  }

  Widget _dailySignalChartWidget({int type}) {
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

        var dateText = date.month.toString() +
            S.of(context).month +
            date.day.toString() +
            S.of(context).day;
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

    return _clipRRectWidget(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 0, 0),
              child: SizedBox(
                  width: double.infinity,
                  child: Text(
                      S.of(context).signal_chart_last_month_numbers_func(
                          "${SensorType.getScanName(context, type)}"),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ))),
            )),
        Container(
          padding:
              EdgeInsets.fromLTRB(type == SensorType.GPS ? 0 : 20, 0, 0, 0),
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
      ],
    ));
  }

  Widget _clipRRectWidget1(Widget child, [double width, double height]) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        clipBehavior: Clip.antiAlias,
        shadowColor: Colors.black12,
        elevation: 5.0,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 0.05, color: Colors.black12),
          borderRadius: BorderRadius.all(
            Radius.circular(20.0),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(
              Radius.circular(20.0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8.0,
              ),
            ],
          ),
          child: Center(
            child: child,
          ),
          width: width,
          height: height,
        ),
      ),
    );
  }

  Widget _clipRRectWidget(Widget child, [double width, double height]) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        clipBehavior: Clip.antiAlias,
        //shadowColor: Colors.black12,
        elevation: 5.0,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 0.05, color: Colors.black12),
          borderRadius: BorderRadius.all(
            Radius.circular(20.0),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(
              Radius.circular(20.0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8.0,
              ),
            ],
          ),
          child: Center(
            child: child,
          ),
          width: width,
          height: height,
        ),
      ),
    );
  }

  Widget _introductionWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: HtmlWidget(_introduction),
    );
  }

  Widget _titleWidget(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: SizedBox(
          width: double.infinity,
          child: Text(title,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
    );
  }

  Future _getData() async {
    var languageCode = Localizations.localeOf(context).languageCode;
    print("[signal_chart] _getData, widget.type:${widget.type}");

    switch (widget.type) {
      case SignalChatsPage.NODE:
        {
          try {
            _introduction = S.of(context).signal_chart_desc_map3;
            _map3nodeVo = await _api.getMap3NodeData();

            Future.delayed(Duration(milliseconds: 500)).then((_) {
              if (widget.type == SignalChatsPage.NODE) {
                if (mounted) {
                  setState(() {
                    print(
                        "[signal_chart] _getData, 2-1 widget.type:${widget.type}");
                    currentState = null;
                  });
                }
              }
            });
          } catch (e) {
            print(e);
            if (widget.type == SignalChatsPage.NODE) {
              if (mounted) {
                setState(() {
                  print(
                      "[signal_chart] _getData, 2-2 widget.type:${widget.type}");
                  currentState = all_page_state.LoadFailState();
                });
              }
            }
          }
        }
        break;

      case SignalChatsPage.SIGNAL:
        {
          try {
            _introduction = S.of(context).signal_chart_desc_signal;
            _signalTotalVo = await _api.getSignalTotal();
            //_weeklyVoList = await _api.getSignalWeekly(language: languageCode);
            var dailyList = await _api.getSignalDaily(language: languageCode);
            _dailyVo = dailyList[0];

            if (widget.type == SignalChatsPage.SIGNAL) {
              if (mounted) {
                setState(() {
                  print(
                      "[signal_chart] _getData, 2-1 widget.type:${widget.type}");
                  currentState = null;
                });
              }
            }
          } catch (e) {
            print(e);

            if (widget.type == SignalChatsPage.SIGNAL) {
              if (mounted) {
                setState(() {
                  print(
                      "[signal_chart] _getData, 2-2 widget.type:${widget.type}");
                  currentState = all_page_state.LoadFailState();
                });
              }
            }
          }
        }
        break;

      case SignalChatsPage.POI:
        {
          try {
            _introduction = S.of(context).signal_chart_desc_poi;
            _poiVoList = await _api.getPoiDaily(language: languageCode);

            if (widget.type == SignalChatsPage.POI) {
              if (mounted) {
                setState(() {
                  print(
                      "[signal_chart] _getData, 2-1 widget.type:${widget.type}");
                  currentState = null;
                });
              }
            }
          } catch (e) {
            print(e);

            if (widget.type == SignalChatsPage.POI) {
              if (mounted) {
                setState(() {
                  print(
                      "[signal_chart] _getData, 2-2 widget.type:${widget.type}");
                  currentState = all_page_state.LoadFailState();
                });
              }
            }
          }
        }
        break;
    }
  }
}
