import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/business/home/global_data/model/signal_daily_vo.dart';
import 'package:titan/src/business/home/global_data/model/signal_total_vo.dart';
import 'package:titan/src/business/home/global_data/model/signal_weekly_vo.dart';
import 'package:titan/src/data/api/api.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/plugins/sensor_type.dart';

class SignalChatsPage extends StatefulWidget {
  static const int POI = -1;
  static const int SIGNAL = -2;

  final int type;
  SignalChatsPage({this.type});
  @override
  _SignalChatsState createState() => _SignalChatsState();
}


class _SignalChatsState extends State<SignalChatsPage> {
  Api api = Api();

  SignalTotalVo totalVo;
  SignalDailyVo dailyVo;
  List<SignalWeeklyVo> weeklyVoList;
  var title = "";
  List<Signal> poiVoList;

  @override
  void initState() {
    super.initState();

    _getData();
  }

  @override
  Widget build(BuildContext context) {

    if (widget.type == SignalChatsPage.POI) {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Text(title),
            ),
            _dailySignalWidget(type: SensorType.POI),
          ],
        ),
      );
    }
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text(title),
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

  Widget _weeklySignalWidget() {
    var legendData = [
      S.of(globalContext).scan_name_gps,
      S.of(globalContext).scan_name_wifi,
      S.of(globalContext).scan_name_bluetooth,
      S.of(globalContext).scan_name_cellular,
    ];
    var data = [];
    if (weeklyVoList != null) {
      data = [];
      var gps = [];
      var wifi = [];
      var bluetooth = [];
      var cellular = [];
      for (var item in weeklyVoList) {
        gps.add(item.gpsCount);
        wifi.add(item.wifiCount);
        bluetooth.add(item.blueToothCount);
        cellular.add(item.cellularCount);
      }
      data = [gps, wifi, bluetooth, cellular];
    }

    var series = [];
    for (int i=0; i<legendData.length; i++) {
      var json = {
        'name': legendData[i],
        'smooth': true,
        'symbol':'circle',
        'type': 'line',
        'data': data.isNotEmpty?data[i]:[],
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
    double _chartsWidth = _size.width-8;
    double _chartsHeight = 250;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          child: Text('信号数据总量：', style: TextStyle(fontSize: 14)),
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
      ],
    );
  }

  Widget _dailySignalWidget({int type}) {
    var _size = MediaQuery.of(context).size;
    double _chartsWidth = _size.width-8;
    double _chartsHeight = 250;

    var xAxisData = [];
    var seriesData = [];
    if (dailyVo != null || poiVoList != null) {
      var list = [];
      switch (type) {
        case SensorType.WIFI:
          list = dailyVo.wifi;
          break;

        case SensorType.CELLULAR:
          list = dailyVo.cellular;
          break;

        case SensorType.BLUETOOTH:
          list = dailyVo.blueTooth;
          break;

        case SensorType.GPS:
          list = dailyVo.gps;
          break;

        case SensorType.POI:
          list = poiVoList;
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
        Padding(
          child: Text('最近一个月${SensorType.getScanName(type)}数据增量：', style: TextStyle(fontSize: 14)),
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
    );
  }

  _getData() async {

    title = '信号数据可用于建立三角定位，XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX介绍一番';
    if (widget.type == SignalChatsPage.POI) {
      title = 'POI数据是一个公共的位置兴趣点数据集合，XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX介绍一番';
      poiVoList = await api.getPoiDaily();
    }
    else {
      weeklyVoList = await api.getSignalWeekly();
      var dailyList = await api.getSignalDaily();
      dailyVo = dailyList[0];
    }

    setState(() {

    });
  }


}
