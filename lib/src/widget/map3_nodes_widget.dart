import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import 'package:titan/src/pages/global_data/echarts/world.dart';

class Map3NodesWidget extends StatefulWidget {
  Map3NodesWidget(this.points);

  final String points;

  @override
  State<StatefulWidget> createState() {
    return _Map3NodesWidgetState();
  }
}

class _Map3NodesWidgetState extends State<Map3NodesWidget> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('[Map3NodesWidget] points: ${widget.points}');
  }

  @override
  Widget build(BuildContext context) {
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
              scale: 9,
              brushType: 'fill'
              },
        hoverAnimation: true,
        coordinateSystem: 'geo',
        data: ${widget.points != null ? (widget.points.isNotEmpty ? widget.points : json.encode('[]')) : json.encode('[]')},
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
    return Container(
      width: double.infinity,
      height: 250,
      child: Echarts(
        option: _eChartOption,
        extensions: [worldScript],
        captureAllGestures: false,
      ),
    );
  }
}
