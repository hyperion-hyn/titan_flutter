import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import 'package:titan/src/pages/global_data/echarts/world.dart';

class Map3NodesWidget extends StatefulWidget {
  Map3NodesWidget();

  @override
  State<StatefulWidget> createState() {
    return _Map3NodesWidgetState();
  }
}

class _Map3NodesWidgetState extends State<Map3NodesWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 250,
      child: Echarts(
        option: _eChartOption,
        extensions: [worldScript],
        captureAllGestures: true,
      ),
    );
  }
}

var nodes = [
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
  }
];

var _eChartOption = '''
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
        name: 'map3 nodes',
        type: 'effectScatter',
        showEffectOn: 'render',
        zlevel:1,
        rippleEffect: {
              period: 10,
              scale: 4,
              brushType: 'fill'
              },
        hoverAnimation: true,
        coordinateSystem: 'geo',
        data: ${jsonEncode(nodes)},
        symbolSize: 4,
        label: {
          normal: {
            show: false
          },
          emphasis: {
            show: false
          }
        },
        itemStyle: {
          color: '#0ca8ad',
          emphasis: {
            borderColor: '#fff',
            borderWidth: 1
          }
        }
      }
    ]
}
    ''';
