import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import 'package:titan/src/pages/global_data/echarts/world.dart';

class AtlasMapWidget extends StatefulWidget {
  final dynamic _atlasNodes;

  AtlasMapWidget(this._atlasNodes);

  @override
  State<StatefulWidget> createState() {
    return _AtlasMapWidgetState();
  }
}

class _AtlasMapWidgetState extends State<AtlasMapWidget> {
  var _eChartOption = '';
  Timer _timer;
  var lines = [];
  var _addCount = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _updateEChartOption();
    _setUpTimer();
  }

  _setUpTimer() {
    _timer = Timer.periodic(Duration(seconds: 15), (t) {
      _updateEChartOption();
    });
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
      onLoad: () {},
      option: _eChartOption,
      extensions: [worldScript],
      captureAllGestures: true,
    );
  }

  ///pick [two] random nodes to draw lines
  ///
  _updateEChartOption() {
    var _randomIndex = widget._atlasNodes.length > 0
        ? Random().nextInt(widget._atlasNodes.length - 1)
        : 0;

    for (var i = 0; i < widget._atlasNodes.length; i++) {
      if (i != _randomIndex) {
        lines.add({
          'coords': [
            widget._atlasNodes[_randomIndex]['value'],
            widget._atlasNodes[i]['value']
          ]
        });
      }
    }

    _addCount++;

    ///Remove first group of lines
    if (_addCount > 2) {
      lines.removeRange(0, widget._atlasNodes.length - 1);
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
              scale: 7,
              brushType: 'fill'
              },
        hoverAnimation: true,
        coordinateSystem: 'geo',
        data: ${jsonEncode(widget._atlasNodes)},
        symbolSize: 3,
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
            period: 6, 
            trailLength: 0.1,
            color: '#cc1010',
            symbolSize: 1,
        },
        lineStyle: {
            normal: {
                color: '#00ffffff',
                width: 0,
                curveness: 0.2,
                opacity: 0
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
