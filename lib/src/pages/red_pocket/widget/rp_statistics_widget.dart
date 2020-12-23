import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/pages/red_pocket/api/rp_api.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_stats.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_util.dart';
import 'package:titan/src/style/titan_sytle.dart';

class RPStatisticsWidget extends StatefulWidget {
  RPStatisticsWidget();

  @override
  State<StatefulWidget> createState() {
    return _RPStatisticsWidgetState();
  }
}

class _RPStatisticsWidgetState extends State<RPStatisticsWidget> {
  RpStats _rpStats;
  RPApi _rpApi = RPApi();

  var colorPalette = [
    '#FF5E5E',
    '#66A9FF',
    '#66F0CB',
    '#FBF463',
    '#FFC05C',
    '#4EECFA'
  ];

  @override
  void initState() {
    _getData();
    super.initState();
  }

  _getData() async {
    try {
      _rpStats = await _rpApi.getRPStats();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {}
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
          _title('发行'),
          _rpSupply(),
          _title('空投'),
          _rpAirdrop(),
          _title('传导'),
          _rpPool(),
          _title('晋升'),
          _rpPromotion()
        ],
      ),
    );
  }

  _title(String name) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        name,
        style: TextStyle(
          fontSize: 11,
          color: DefaultColors.color999,
        ),
      ),
    );
  }

  _rpSupply() {
    var totalCap = _rpStats?.global?.totalCap ?? '0';
    var totalSupply = _rpStats?.global?.totalSupply ?? '0';
    var totalBurn = _rpStats?.global?.totalBurning ?? '0';
    var unSupply =
        (Decimal.tryParse('$totalCap') - Decimal.parse(totalSupply)) -
            Decimal.parse(totalBurn);

    var totalCapStr = bigIntToEther(totalCap);
    var totalSupplyStr = bigIntToEther(totalSupply);
    var totalBurningStr = bigIntToEther(totalBurn);
    var unSupplyStr = bigIntToEther("$unSupply");

    var _chartOption = '''
   {
    series: [
        {
            type: 'pie',
            radius: ['40%', '90%'],
            silent: true,
            label: {
                formatter: '{d}%',
                borderWidth: 1,
                borderRadius: 4,
                position: 'inner',
            },
            color: ${jsonEncode(colorPalette)},
            data: [
                {value: $totalSupply, name: '流通中'},
                {value: $unSupply, name: '未发行'}, 
                {value: $totalBurn, name: '总燃烧'},
                 
            ]
        }
    ]
}
  ''';
    return Row(
      children: [
        Container(
          width: 130,
          height: 130,
          child: Echarts(
            option: _chartOption,
            captureAllGestures: false,
          ),
        ),
        SizedBox(
          width: 24,
        ),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /*_dataText(
              '总发行',
              totalCapStr,
              isHighLight: true,
            ),*/
            Row(
              children: [
                Expanded(
                  child: _dataText(
                    '总发行',
                    totalCapStr,
                    isHighLight: true,
                  ),
                ),
                SizedBox(
                  width: 16,
                )
              ],
            ),
            _dataText('流通中', totalSupplyStr, colorStr: colorPalette[0]),
            _dataText('总燃烧', totalBurningStr, colorStr: colorPalette[2]),
            _dataText(
              '未发行',
              unSupplyStr,
              colorStr: colorPalette[1],
            ),
          ],
        ))
      ],
    );
  }

  _rpAirdrop() {
    var total = _rpStats?.airdrop?.total ?? '0';
    var totalAirdrop = _rpStats?.airdrop?.totalAirdrop ?? '0';
    var totalLucky = _rpStats?.airdrop?.luckyTotal ?? '0';
    var totalLevel = _rpStats?.airdrop?.levelTotal ?? '0';
    var totalPromotion = _rpStats?.airdrop?.promotionTotal ?? '0';

    var totalStr = bigIntToEther(total);

    var airdropLuckyTotalStr = bigIntToEther(totalLucky);
    var airdropLevelTotalStr = bigIntToEther(totalLevel);
    var airdropPromotionTotalStr = bigIntToEther(totalPromotion);

    var unAirdrop = Decimal.tryParse(total) - Decimal.tryParse(totalAirdrop);
    var totalAirdropStr = bigIntToEther("$totalAirdrop");
    var unAirdropStr = bigIntToEther("$unAirdrop");

    var airdropBurnTotalStr = bigIntToEther(_rpStats?.airdrop?.burningTotal);

    var _airdropChartOption = '''
 {
    series: [
        {
            type: 'pie',
            radius: ['40%', '90%'],
            silent: true,
            label: {
                formatter: '{d}%',
                borderWidth: 1,
                borderRadius: 4,
                position: 'inner',
                
            },
            color: ${jsonEncode(colorPalette)},
            data: [
                {value: $totalAirdrop, name: '已空投'},
                {value: $unAirdrop, name: '待空投'},
            ],
            
        },
    ]
}
  ''';
    var _redPocketChartOption = '''
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
                {value: $totalPromotion, name: '晋升红包'},
                {value: $totalLevel, name: '量级红包'},
                {value: $totalLucky, name: '幸运红包'}
            ],
            
        },
    ]
}
  ''';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            Container(
              width: 130,
              height: 130,
              child: Echarts(
                option: _airdropChartOption,
                captureAllGestures: false,
              ),
            ),
            SizedBox(
              width: 24,
            ),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _dataText('已空投', totalAirdropStr, colorStr: colorPalette[0]),
                _dataText('未空投', unAirdropStr, colorStr: colorPalette[1]),
              ],
            ))
            // Expanded(
            //   child: Container(
            //     height: 130,
            //     child: Echarts(
            //       option: _redPocketChartOption,
            //       captureAllGestures: false,
            //     ),
            //   ),
            // ),
          ],
        ),
        SizedBox(
          height: 16,
        ),
        Column(
          children: [
            Row(
              children: [
                _dataText('红包总量', totalStr,
                    isHighLight: true, isExpanded: false),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _dataText('已发幸运红包', airdropLuckyTotalStr),
                ),
                SizedBox(
                  width: 4,
                ),
                Expanded(
                  child: _dataText('已发量级红包', airdropLevelTotalStr),
                )
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _dataText('已发晋升红包', airdropPromotionTotalStr),
                ),
                SizedBox(
                  width: 4,
                ),
                Expanded(
                  child: _dataText('未领取燃烧', airdropBurnTotalStr),
                )
              ],
            )
          ],
        )
      ],
    );
  }

  _rpPool() {
    var total = _rpStats?.transmit?.total ?? '0';
    var transmitRp = _rpStats?.transmit?.transmitRp ?? '0';
    var unTransmitRp = Decimal.tryParse(total) - Decimal.parse(transmitRp);

    var totalStr = bigIntToEther(total);
    var transmitRPStr = bigIntToEther(transmitRp);
    var unTransmitRpStr = bigIntToEther("$unTransmitRp");

    var _chartOption = '''
    {
    series: [
        {
            type: 'pie',
            radius: ['40%', '90%'],
            silent: true,
            label: {
                formatter: '{d}%',
                borderWidth: 1,
                borderRadius: 4,
                position: 'inner',
            },
            color: ${jsonEncode(colorPalette)},
            data: [
                {value: $transmitRp, name: '已传导'},
                {value: $unTransmitRp, name: '未传导'},
            ]
        }
    ]
}
  ''';
    return Row(
      children: [
        Container(
          width: 130,
          height: 130,
          child: Echarts(
            option: _chartOption,
            captureAllGestures: false,
            onMessage: (String message) {
              Map<String, Object> messageAction = jsonDecode(message);
              print("[$runtimeType] messageAction:$messageAction");
            },
          ),
        ),
        SizedBox(
          width: 24,
        ),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _dataText('传导总量', totalStr),
            _dataText('已传导', transmitRPStr, colorStr: colorPalette[0]),
            _dataText('未传导', unTransmitRpStr, colorStr: colorPalette[1]),
          ],
        ))
      ],
    );
  }

  _rpPromotion() {
    var promotionTotalHolding = _rpStats?.promotion?.totalHolding ?? '0';
    var promotionTotalBurning = _rpStats?.promotion?.totalBurning ?? '0';

    var promotionTotalHoldingStr = bigIntToEther(promotionTotalHolding);
    var promotionTotalBurningStr = bigIntToEther(promotionTotalBurning);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _dataText('晋升持币', promotionTotalHoldingStr),
        ),
        SizedBox(
          width: 4,
        ),
        Expanded(
          child: _dataText('晋升燃烧', promotionTotalBurningStr),
        )
      ],
    );
  }

  _dataText(
    String name,
    String data, {
    String colorStr,
    bool isHighLight = false,
    bool isExpanded = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        color: isHighLight ? HexColor('#FFFFF5F5') : null,
        padding: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (colorStr != null)
              Container(
                width: 10,
                height: 10,
                color: HexColor(colorStr),
              ),
            SizedBox(
              width: 5,
            ),
            if (isExpanded)
              Expanded(
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
              ),
            if (!isExpanded)
              RichText(
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
          ],
        ),
      ),
    );
  }
}
