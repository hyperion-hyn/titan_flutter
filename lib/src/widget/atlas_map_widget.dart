import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import 'package:titan/src/pages/global_data/echarts/world.dart';

class AtlasMapWidget extends StatefulWidget {
  AtlasMapWidget();

  @override
  State<StatefulWidget> createState() {
    return _AtlasMapWidgetState();
  }
}

class _AtlasMapWidgetState extends State<AtlasMapWidget> {
  var _eChartOption = '';
  Timer _timer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _setUpEChartOption();
    _setUpTimer();
  }

  _setUpTimer() {
//    _timer = Timer.periodic(Duration(milliseconds: 5000), (t) {
//      //print('_AtlasMapWidgetState ---tik');
//      //_getEChartOption();
//    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    if (_timer != null) {
      if (_timer.isActive) {
        _timer.cancel();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Echarts(
      option: _eChartOption,
      extensions: [worldScript],
      captureAllGestures: true,
    );
  }

  var _atlasNodes = [
    {
      "name": "Sydney",
      "value": [151.2002, -33.8591, 4, 4]
    },
    {
      "name": "Singapore",
      "value": [103.819836, 1.352083, 8, 8]
    },
    {
      "name": "Paris",
      "value": [2.35222, 48.8566, 10, 10]
    },
    {
      "name": "Jakarta",
      "value": [106.865, -6.17511, 1, 1]
    },
    {
      "name": "San Jose",
      "value": [-121.895, 37.3394, 2, 2]
    },
    {
      "name": "Ashburn",
      "value": [-77.4874, 39.0438, 114, 114]
    },
    {
      "name": "Mumbai",
      "value": [72.8777, 19.076, 6, 6]
    },
    {
      "name": "Seoul",
      "value": [126.978, 37.5665, 1, 1]
    },
    {
      "name": "Tokyo",
      "value": [139.692, 35.6895, 6, 6]
    },
    {
      "name": "Hong Kong",
      "value": [114.109, 22.3964, 9, 9]
    },
  ];

  _setUpEChartOption() {
    var _nodes = _atlasNodes;

    var lines = [];

    for (var i = 0; i < _nodes.length; i++) {
      for (var j = _nodes.length - 1 - i; j > 0; j--) {
        lines.add({
          'coords': [_nodes[i]['value'], _nodes[j]['value']]
        });
      }
    }
    _eChartOption = '''
{
    backgroundColor: '#313947',
    tooltip: {
      trigger: 'item',
      formatter: function (params) {
        return params.name + ' : ' + params.value[2];
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
        name: 'random atlas nodes',
        type: 'effectScatter',
        showEffectOn: 'render',
        zlevel:2,
        rippleEffect: {
              period: 10,
              scale: 6,
              brushType: 'fill'
              },
        hoverAnimation: true,
        coordinateSystem: 'geo',
        data: ${jsonEncode(_nodes)},
        symbolSize: 6,
        label: {
          normal: {
            show: false
          },
          emphasis: {
            show: false
          }
        },
        itemStyle: {
          color: '#cc1010',
          emphasis: {
            borderColor: '#fff',
            borderWidth: 1
          }
        }
      },
      {
        name: 'nodes trail',
        type: 'lines',
        zlevel: 3,
        effect: {
            show: true,
            period: 8, 
            trailLength: 0.1,
            color: '#cc1010',
            symbolSize: 2,
        },
        lineStyle: {
            normal: {
                color: '#00ffffff',
                width: 0,
                curveness: 0.2,
                opacity: 0.1
            }
        },
        coordinateSystem: 'geo',
        data: ${jsonEncode(lines)}
    },
   
    ]
}
    ''';

    setState(() {});
  }
}
