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
  String title;
  SignalChatsPage(this.title);
  @override
  _SignalChatsState createState() => _SignalChatsState();
}


class _SignalChatsState extends State<SignalChatsPage> {
  Api api = Api();

  SignalTotalVo totalVo;
  SignalDailyVo dailyVo;
  List<SignalWeeklyVo> weeklyVoList;

  @override
  void initState() {
    super.initState();

    _getSignalData();
  }

  @override
  Widget build(BuildContext context) {

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text(widget.title),
          ),
          _weeklyWidget(),
          _dailyWidget(type: SensorType.GPS),
          _dailyWidget(type: SensorType.WIFI),
          _dailyWidget(type: SensorType.BLUETOOTH),
          _dailyWidget(type: SensorType.CELLULAR),
        ],
      ),
    );
  }

  Widget _weeklyWidget() {
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
        'data': data[i],
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

  Widget _dailyWidget({int type}) {
    var _size = MediaQuery.of(context).size;
    double _chartsWidth = _size.width-8;
    double _chartsHeight = 250;

    var xAxisData = [];
    var seriesData = [];
    if (dailyVo != null) {
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
        //data: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
        data: ${jsonEncode(xAxisData)}
    },
    yAxis: {
        type: 'value'
    },
    grid: {
       left: '15%',
    },
    series: [{
        //data: [820, 932, 901, 934, 1290, 1330, 1320],
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

  _getSignalData() async {
    weeklyVoList = await api.getSignalWeekly();
    var dailyList = await api.getSignalDaily();
    dailyVo = dailyList[0];
    setState(() {

    });
  }

}
