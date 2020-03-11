import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_echarts/flutter_echarts.dart';


class SignalChatsPage extends StatefulWidget {
  SignalChatsPage({Key key}) : super(key: key);

  @override
  _SignalChatsState createState() => _SignalChatsState();
}


class _SignalChatsState extends State<SignalChatsPage> {

  @override
  void initState() {
    super.initState();


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
