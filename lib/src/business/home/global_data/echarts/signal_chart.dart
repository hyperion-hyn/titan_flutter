import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter_echarts/flutter_echarts.dart';
import 'package:number_display/number_display.dart';

import '../echarts/liquid_script.dart' show liquidScript;
import '../echarts/gl_script.dart' show glScript;
import '../echarts/dark_theme_script.dart' show darkThemeScript;

final display = createDisplay(decimal: 2);

class SignalChatsPage extends StatefulWidget {
  SignalChatsPage({Key key}) : super(key: key);

  @override
  _SignalChatsState createState() => _SignalChatsState();
}

/*
class _SignalChatsStateOld extends State<SignalChatsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  List<Map<String, Object>> _data1 = [{ 'name': 'Please wait', 'value': 0 }];

  getData1() async {
    await Future.delayed(Duration(seconds: 4));

    const dataObj = [{
      'name': 'Jan',
      'value': 8726.2453,
    }, {
      'name': 'Feb',
      'value': 2445.2453,
    }, {
      'name': 'Mar',
      'value': 6636.2400,
    }, {
      'name': 'Apr',
      'value': 4774.2453,
    }, {
      'name': 'May',
      'value': 1066.2453,
    }, {
      'name': 'Jun',
      'value': 4576.9932,
    }, {
      'name': 'Jul',
      'value': 8926.9823,
    }];

    this.setState(() { this._data1 = dataObj;});
  }

  @override
  void initState() {
    super.initState();

    this.getData1();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: <Widget>[
            Padding(
              child: Text('Reactive updating and tap event', style: TextStyle(fontSize: 20)),
              padding: EdgeInsets.fromLTRB(0, 40, 0, 20),
            ),
            Text('- data will be fetched in a few seconds'),
            Text('- tap the bar and trigger the snack'),
            Container(
              child: Echarts(
                option: '''
                    {
                      dataset: {
                        dimensions: ['name', 'value'],
                        source: ${jsonEncode(_data1)},
                      },
                      color: ['#3398DB'],
                      legend: {
                        data: ['直接访问', '背景'],
                        show: false,
                      },
                      grid: {
                        left: '0%',
                        right: '0%',
                        bottom: '5%',
                        top: '7%',
                        height: '85%',
                        containLabel: true,
                        z: 22,
                      },
                      xAxis: [{
                        type: 'category',
                        gridIndex: 0,
                        axisTick: {
                          show: false,
                        },
                        axisLine: {
                          lineStyle: {
                            color: '#0c3b71',
                          },
                        },
                        axisLabel: {
                          show: true,
                          color: 'rgb(170,170,170)',
                          formatter: function xFormatter(value, index) {
                            if (index === 6) {
                              return `\${value}\\n*`;
                            }
                            return value;
                          },
                        },
                      }],
                      yAxis: {
                        type: 'value',
                        gridIndex: 0,
                        splitLine: {
                          show: false,
                        },
                        axisTick: {
                            show: false,
                        },
                        axisLine: {
                          lineStyle: {
                            color: '#0c3b71',
                          },
                        },
                        axisLabel: {
                          color: 'rgb(170,170,170)',
                        },
                        splitNumber: 12,
                        splitArea: {
                          show: true,
                          areaStyle: {
                            color: ['rgba(250,250,250,0.0)', 'rgba(250,250,250,0.05)'],
                          },
                        },
                      },
                      series: [{
                        name: '合格率',
                        type: 'bar',
                        barWidth: '50%',
                        xAxisIndex: 0,
                        yAxisIndex: 0,
                        itemStyle: {
                          normal: {
                            barBorderRadius: 5,
                            color: {
                              type: 'linear',
                              x: 0,
                              y: 0,
                              x2: 0,
                              y2: 1,
                              colorStops: [
                                {
                                  offset: 0, color: '#00feff',
                                },
                                {
                                  offset: 1, color: '#027eff',
                                },
                                {
                                  offset: 1, color: '#0286ff',
                                },
                              ],
                            },
                          },
                        },
                        zlevel: 11,
                      }],
                    }
                  ''',
                extraScript: '''
                    chart.on('click', (params) => {
                      if(params.componentType === 'series') {
                        Messager.postMessage(JSON.stringify({
                          type: 'select',
                          payload: params.dataIndex,
                        }));
                      }
                    });
                  ''',
                onMessage: (String message) {
                  Map<String, Object> messageAction = jsonDecode(message);
                  print(messageAction);
                  if (messageAction['type'] == 'select') {
                    final item = _data1[messageAction['payload']];
                    _scaffoldKey.currentState.showSnackBar(
                        SnackBar(
                          content: Text(item['name'].toString() + ': ' + display(item['value'])),
                          duration: Duration(seconds: 2),
                        ));
                  }
                },
              ),
              width: 300,
              height: 250,
            ),
            Padding(
              child: Text('Using WebGL for 3D charts', style: TextStyle(fontSize: 20)),
              padding: EdgeInsets.fromLTRB(0, 40, 0, 20),
            ),
            Text('- chart capture all gestures'),
            Container(
              child: Echarts(
                extensions: [glScript],
                captureAllGestures: true,
                option: '''
                    {
                        tooltip: {},
                        visualMap: {
                            max: 20,
                            inRange: {
                                color: ['#313695', '#4575b4', '#74add1', '#abd9e9', '#e0f3f8', '#ffffbf', '#fee090', '#fdae61', '#f46d43', '#d73027', '#a50026']
                            }
                        },
                        xAxis3D: {
                            type: 'category',
                            data: ['12a', '1a', '2a', '3a', '4a', '5a', '6a',
                              '7a', '8a', '9a','10a','11a',
                              '12p', '1p', '2p', '3p', '4p', '5p',
                              '6p', '7p', '8p', '9p', '10p', '11p'],
                        },
                        yAxis3D: {
                            type: 'category',
                            data: ['Saturday', 'Friday', 'Thursday',
                             'Wednesday', 'Tuesday', 'Monday', 'Sunday'],
                        },
                        zAxis3D: {
                            type: 'value'
                        },
                        grid3D: {
                            boxWidth: 200,
                            boxDepth: 80,
                            viewControl: {
                                // projection: 'orthographic'
                            },
                            light: {
                                main: {
                                    intensity: 1.2,
                                    shadow: true
                                },
                                ambient: {
                                    intensity: 0.3
                                }
                            }
                        },
                        series: [{
                            type: 'bar3D',
                            data: [[0,0,5],[0,1,1],[0,2,0],[0,3,0],[0,4,0],[0,5,0],[0,6,0],
                              [0,7,0],[0,8,0],[0,9,0],[0,10,0],[0,11,2],[0,12,4],[0,13,1],
                              [0,14,1],[0,15,3],[0,16,4],[0,17,6],[0,18,4],[0,19,4],[0,20,3],
                              [0,21,3],[0,22,2],[0,23,5],[1,0,7],[1,1,0],[1,2,0],[1,3,0],
                              [1,4,0],[1,5,0],[1,6,0],[1,7,0],[1,8,0],[1,9,0],[1,10,5],
                              [1,11,2],[1,12,2],[1,13,6],[1,14,9],[1,15,11],[1,16,6],[1,17,7],
                              [1,18,8],[1,19,12],[1,20,5],[1,21,5],[1,22,7],[1,23,2],[2,0,1],
                              [2,1,1],[2,2,0],[2,3,0],[2,4,0],[2,5,0],[2,6,0],[2,7,0],[2,8,0],
                              [2,9,0],[2,10,3],[2,11,2],[2,12,1],[2,13,9],[2,14,8],[2,15,10],
                              [2,16,6],[2,17,5],[2,18,5],[2,19,5],[2,20,7],[2,21,4],[2,22,2],
                              [2,23,4],[3,0,7],[3,1,3],[3,2,0],[3,3,0],[3,4,0],[3,5,0],[3,6,0],
                              [3,7,0],[3,8,1],[3,9,0],[3,10,5],[3,11,4],[3,12,7],[3,13,14],[3,14,13],
                              [3,15,12],[3,16,9],[3,17,5],[3,18,5],[3,19,10],[3,20,6],[3,21,4],[3,22,4],
                              [3,23,1],[4,0,1],[4,1,3],[4,2,0],[4,3,0],[4,4,0],[4,5,1],[4,6,0],[4,7,0],
                              [4,8,0],[4,9,2],[4,10,4],[4,11,4],[4,12,2],[4,13,4],[4,14,4],[4,15,14],
                              [4,16,12],[4,17,1],[4,18,8],[4,19,5],[4,20,3],[4,21,7],[4,22,3],[4,23,0],
                              [5,0,2],[5,1,1],[5,2,0],[5,3,3],[5,4,0],[5,5,0],[5,6,0],[5,7,0],[5,8,2],
                              [5,9,0],[5,10,4],[5,11,1],[5,12,5],[5,13,10],[5,14,5],[5,15,7],[5,16,11],
                              [5,17,6],[5,18,0],[5,19,5],[5,20,3],[5,21,4],[5,22,2],[5,23,0],[6,0,1],
                              [6,1,0],[6,2,0],[6,3,0],[6,4,0],[6,5,0],[6,6,0],[6,7,0],[6,8,0],[6,9,0],
                              [6,10,1],[6,11,0],[6,12,2],[6,13,1],[6,14,3],[6,15,4],[6,16,0],[6,17,0],
                              [6,18,0],[6,19,0],[6,20,1],[6,21,2],[6,22,2],[6,23,6]]
                                .map(function (item) {
                                return {
                                    value: [item[1], item[0], item[2]],
                                }
                            }),
                            shading: 'lambert',

                            label: {
                                textStyle: {
                                    fontSize: 16,
                                    borderWidth: 1
                                }
                            },

                            emphasis: {
                                label: {
                                    textStyle: {
                                        fontSize: 20,
                                        color: '#900'
                                    }
                                },
                                itemStyle: {
                                    color: '#900'
                                }
                            }
                        }]
                    }
                  ''',
              ),
              width: 300,
              height: 250,
            ),
            Padding(
              child: Text('Dark Theme', style: TextStyle(fontSize: 20)),
              padding: EdgeInsets.fromLTRB(0, 40, 0, 20),
            ),
            Container(
              child: Echarts(
                extensions: [darkThemeScript],
                theme: 'dark',
                option: '''
                    {
                      legend: {
                        data: ['Visit', 'Market', 'Ad', 'Video', 'Search']
                      },
                      grid: {
                        left: '3%',
                        right: '8%',
                        bottom: '3%',
                        containLabel: true
                      },
                      xAxis: {
                        type: 'value'
                      },
                      yAxis: {
                        type: 'category',
                        data: ['Day1', 'Day2', 'Day3', 'Day4', 'Day5', 'Day6', 'Day7']
                      },
                      series: [
                        {
                          name: 'Visit',
                          type: 'bar',
                          stack: 'total',
                          data: [320, 302, 301, 334, 390, 330, 320]
                        },
                        {
                          name: 'Market',
                          type: 'bar',
                          stack: 'total',
                          data: [120, 132, 101, 134, 90, 230, 210]
                        },
                        {
                          name: 'Ad',
                          type: 'bar',
                          stack: 'total',
                          data: [220, 182, 191, 234, 290, 330, 310]
                        },
                        {
                          name: 'Video',
                          type: 'bar',
                          stack: 'total',
                          data: [150, 212, 201, 154, 190, 330, 410]
                        },
                        {
                          name: 'Search',
                          type: 'bar',
                          stack: 'total',
                          data: [820, 832, 901, 934, 1290, 1330, 1320]
                        }
                      ]
                    }
                  ''',
              ),
              width: 300,
              height: 250,
            ),
            Padding(
              child: Text('Data zoom', style: TextStyle(fontSize: 20)),
              padding: EdgeInsets.fromLTRB(0, 40, 0, 20),
            ),
            Text('- chart capture all gestures'),
            Container(
              child: Echarts(
                captureAllGestures: true,
                extraScript: '''
                    var base = +new Date(1968, 9, 3);
                    var oneDay = 24 * 3600 * 1000;
                    var date = [];

                    var data = [Math.random() * 300];

                    for (var i = 1; i < 20000; i++) {
                        var now = new Date(base += oneDay);
                        date.push([now.getFullYear(), now.getMonth() + 1, now.getDate()].join('/'));
                        data.push(Math.round((Math.random() - 0.5) * 20 + data[i - 1]));
                    }
                  ''',
                option: '''
                    {
                      tooltip: {
                          trigger: 'axis',
                          position: function (pt) {
                              return [pt[0], '10%'];
                          }
                      },
                      toolbox: {
                          feature: {
                              dataZoom: {
                                  yAxisIndex: 'none'
                              },
                              restore: {},
                              saveAsImage: {}
                          }
                      },
                      xAxis: {
                          type: 'category',
                          boundaryGap: false,
                          data: date
                      },
                      yAxis: {
                          type: 'value',
                          boundaryGap: [0, '100%']
                      },
                      dataZoom: [{
                          type: 'inside',
                          start: 0,
                          end: 10
                      }, {
                          start: 0,
                          end: 10,
                          handleIcon: 'M10.7,11.9v-1.3H9.3v1.3c-4.9,0.3-8.8,4.4-8.8,9.4c0,5,3.9,9.1,8.8,9.4v1.3h1.3v-1.3c4.9-0.3,8.8-4.4,8.8-9.4C19.5,16.3,15.6,12.2,10.7,11.9z M13.3,24.4H6.7V23h6.6V24.4z M13.3,19.6H6.7v-1.4h6.6V19.6z',
                          handleSize: '80%',
                          handleStyle: {
                              color: '#fff',
                              shadowBlur: 3,
                              shadowColor: 'rgba(0, 0, 0, 0.6)',
                              shadowOffsetX: 2,
                              shadowOffsetY: 2
                          }
                      }],
                      series: [
                          {
                              name: 'data',
                              type: 'line',
                              smooth: true,
                              symbol: 'none',
                              sampling: 'average',
                              itemStyle: {
                                  color: 'rgb(255, 70, 131)'
                              },
                              areaStyle: {
                                  color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [{
                                      offset: 0,
                                      color: 'rgb(255, 158, 68)'
                                  }, {
                                      offset: 1,
                                      color: 'rgb(255, 70, 131)'
                                  }])
                              },
                              data: data
                          }
                      ]
                    }
                  ''',
              ),
              width: 300,
              height: 250,
            ),
            Padding(
              child: Text('Using extension', style: TextStyle(fontSize: 20)),
              padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
            ),
            Container(
              child: Echarts(
                extensions: [liquidScript],
                option: '''
                    {
                      grid: {
                        left: '0%',
                        right: '0%',
                        bottom: '0%',
                        top: '0%',
                      },
                      series: [{
                        type: 'liquidFill',
                        data: [0.9]
                      }]
                    }
                  ''',
              ),
              width: 300,
              height: 250,
            ),
          ],
        ),
      ),
    );
  }

}
*/

class _SignalChatsState extends State<SignalChatsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  List<Map<String, Object>> _data1 = [
    {'name': 'Please wait', 'value': 0}
  ];

  getData1() async {
    await Future.delayed(Duration(seconds: 4));

    const dataObj = [
      {
        'name': 'Jan',
        'value': 8726.2453,
      },
      {
        'name': 'Feb',
        'value': 2445.2453,
      },
      {
        'name': 'Mar',
        'value': 6636.2400,
      },
      {
        'name': 'Apr',
        'value': 4774.2453,
      },
      {
        'name': 'May',
        'value': 1066.2453,
      },
      {
        'name': 'Jun',
        'value': 4576.9932,
      },
      {
        'name': 'Jul',
        'value': 8926.9823,
      }
    ];

    this.setState(() {
      this._data1 = dataObj;
    });
  }

  @override
  void initState() {
    super.initState();

    //this.getData1();
  }

  @override
  Widget build(BuildContext context) {
    var _barOption = '''
 {
    /*title: {
      text: '某地区蒸发量和降水量',
      subtext: '纯属虚构'
    },*/
    tooltip: {
      trigger: 'axis'
    },
    legend: {
      data: ['蒸发量', '降水量'],
      bottom: '3%'
    },
    /*toolbox: {
      show: true,
      feature: {
            dataView: {show: true, readOnly: false},
            magicType: {show: true, type: ['line', 'bar']},
            restore: {show: true},
            saveAsImage: {show: true}
      }
    },*/
    calculable: true,
    xAxis: [
      {
            type: 'category',
            data: ['1月', '2月', '3月', '4月', '5月', '6月', '7月', '8月', '9月', '10月', '11月', '12月']
      }
    ],
    yAxis: [
      {
            type: 'value'
      }
    ],
    series: [
      {
            name: '蒸发量',
            type: 'bar',
            data: [2.0, 4.9, 7.0, 23.2, 25.6, 76.7, 135.6, 162.2, 32.6, 20.0, 6.4, 3.3],
            markPoint: {
                data: [
                    {type: 'max', name: '最大值'},
                    {type: 'min', name: '最小值'}
                ]
            },
            markLine: {
                data: [
                    {type: 'average', name: '平均值'}
                ]
            }
      },
      {
            name: '降水量',
            type: 'bar',
            data: [2.6, 5.9, 9.0, 26.4, 28.7, 70.7, 175.6, 182.2, 48.7, 18.8, 6.0, 2.3],
            markPoint: {
                data: [
                    {name: '年最高', value: 182.2, xAxis: 7, yAxis: 183},
                    {name: '年最低', value: 2.3, xAxis: 11, yAxis: 3}
                ]
            },
            markLine: {
                data: [
                    {type: 'average', name: '平均值'}
                ]
            }
      }
    ]
}
                  ''';
    var _lineOption = '''
 {
    xAxis: {
        type: 'category',
        data: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
    },
    yAxis: {
        type: 'value'
    },
    grid: {
       left: '15%',
    },
    series: [{
        data: [820, 932, 901, 934, 1290, 1330, 1320],
        type: 'line'
    }]
}
                  ''';
    var _size = MediaQuery.of(context).size;
    double _chartsWidth = _size.width-8;
    double _chartsHeight = 250;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            child: Text('总信号数据汇总：', style: TextStyle(fontSize: 16)),
            padding: EdgeInsets.fromLTRB(20, 20, 0, 20),
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
          Padding(
            child: Text('最近一个月蓝牙数据增量：', style: TextStyle(fontSize: 16)),
            padding: EdgeInsets.fromLTRB(20, 20, 0, 20),
          ),
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
      ),
    );
  }
}
