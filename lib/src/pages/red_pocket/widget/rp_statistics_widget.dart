import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import 'package:titan/src/style/titan_sytle.dart';

class RPStatisticsWidget extends StatefulWidget {
  RPStatisticsWidget();

  @override
  State<StatefulWidget> createState() {
    return _RPStatisticsWidgetState();
  }
}

class _RPStatisticsWidgetState extends State<RPStatisticsWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '发行',
            style: TextStyle(fontSize: 11),
          ),
          _rpSupply(),
          Text(
            '空投',
            style: TextStyle(fontSize: 11),
          ),
          _rpAirdrop(),
          Text(
            '传导',
            style: TextStyle(fontSize: 11),
          ),
          _rpPool()
        ],
      ),
    );
  }

  _rpSupply() {
    var _chartOption = '''
    {
    series: [
        {
            type: 'pie',
            radius: ['40%', '90%'],
            silent: true,
            label: {
                formatter: '{b}',
                borderWidth: 1,
                borderRadius: 4,
                position: 'inner',
            },
            data: [
                {value: 335, name: '流通中'},
                {value: 310, name: '已燃烧'},
                {value: 234, name: '未发行'},
              
            ]
        }
    ]
}
  ''';
    return Row(
      children: [
        Container(
          width: 150,
          height: 150,
          child: Echarts(
            option: _chartOption,
            captureAllGestures: false,
          ),
        ),
        SizedBox(
          width: 16,
        ),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _dataText('流通中', '299'),
            _dataText('已燃烧', '299'),
            _dataText('未发行', '299'),
          ],
        ))
      ],
    );
  }

  _rpAirdrop() {
    var _chartOption = '''
 {
    series: [
        {
            type: 'pie',
            radius: ['40%', '90%'],
            silent: true,
            label: {
                formatter: '{b}',
                borderWidth: 1,
                borderRadius: 4,
                position: 'inner',
                
            },
            data: [
                {value: 800, name: '待空投'},
                {value: 50, name: '晋升红包'},
                {value: 100, name: '量级红包'},
                {value: 50, name: '幸运红包'}
            ],
            
        },
    ]
}
  ''';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: 150,
          width: 150,
          child: Echarts(
            option: _chartOption,
            captureAllGestures: false,
          ),
        ),
        SizedBox(
          width: 16,
        ),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _dataText('红包总量', '299'),
            _dataText('已发红包', '299'),
            _dataText('已发幸运红包', '299'),
            _dataText('已发量级红包', '299'),
            _dataText('已发晋升红包', '299'),
            _dataText('未领取燃烧', '299'),
          ],
        ))
      ],
    );
  }

  _rpPool() {
    var _chartOption = '''
    {
    series: [
        {
            type: 'pie',
            radius: ['40%', '90%'],
            silent: true,
            label: {
                formatter: '{b}',
                borderWidth: 1,
                borderRadius: 4,
                position: 'inner',
            },
            data: [
                {value: 90000, name: '已传导'},
                {value: 2000, name: '未传导'},
              
            ]
        }
    ]
}
  ''';
    return Row(
      children: [
        Container(
          width: 150,
          height: 150,
          child: Echarts(
            option: _chartOption,
            captureAllGestures: false,
          ),
        ),
        SizedBox(
          width: 16,
        ),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _dataText('传导总量', '299'),
            _dataText('已传导', '299'),
          ],
        ))
      ],
    );
  }

  _dataText(String name, String data) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: RichText(
          text: TextSpan(children: [
        TextSpan(
            text: name,
            style: TextStyle(
              color: DefaultColors.color999,
              fontSize: 12,
            )),
        TextSpan(
            text: ' $data',
            style: TextStyle(
              color: Colors.black,
              fontSize: 12,
            )),
      ])),
    );
  }
}
