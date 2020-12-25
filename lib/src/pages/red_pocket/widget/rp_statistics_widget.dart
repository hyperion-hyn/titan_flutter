import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/pages/red_pocket/api/rp_api.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_stats.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_util.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';

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
  var _currentIndex = 0;

  var colorPalette = [
    '#FF5E5E',
    '#66A9FF',
    '#66F0CB',
    '#FBF463',
    '#FFC05C',
    '#4EECFA'
  ];

  var colorPaletteHex = [
    HexColor('#FF5E5E'),
    HexColor('#66A9FF'),
    HexColor('#66F0CB'),
    HexColor('#FBF463'),
    HexColor('#FFC05C'),
    HexColor('#4EECFA'),
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
    var items = [
      Wrap(
        children: [
          _title('发行'),
          _rpSupply(),
        ],
      ),
      Wrap(
        children: [
          _title('空投'),
          _rpAirdrop(),
        ],
      ),
      Wrap(
        children: [
          _title('传导'),
          _rpPool(),
        ],
      ),
      Wrap(
        children: [
          _title('晋升'),
          _rpPromotion(),
        ],
      )
    ];
    return Column(
      children: [
        CarouselSlider(
            items: items,
            options: CarouselOptions(
                aspectRatio: 1.1,
                initialPage: 0,
                viewportFraction: 1,
                enlargeCenterPage: false,
                enableInfiniteScroll: true,
                autoPlay: true,
                autoPlayInterval: Duration(seconds: 5),
                autoPlayAnimationDuration: Duration(milliseconds: 800),
                autoPlayCurve: Curves.fastOutSlowIn,
                scrollDirection: Axis.horizontal,
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentIndex = index;
                  });
                })),
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              items.length,
              (index) {
                return Container(
                  width: 8.0,
                  height: 8.0,
                  margin: EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 4.0,
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == index
                        ? Color.fromRGBO(0, 0, 0, 0.9)
                        : Color.fromRGBO(0, 0, 0, 0.4),
                  ),
                );
              },
            )),
      ],
    );
  }

  _title(String name) {
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          name,
          style: TextStyle(
            fontSize: 11,
            color: DefaultColors.color999,
          ),
        ),
      ),
    );
  }

  _rpSupply() {
    var totalCap = _rpStats?.global?.totalCap ?? '0';
    var totalSupply = _rpStats?.global?.totalSupply ?? '0';
    var totalBurn = _rpStats?.global?.totalBurning ?? '0';
    var unSupply = Decimal.fromInt(0);

    var totalSupplyEther = Decimal.zero;
    var totalBurnEther = Decimal.zero;
    var unSupplyEther = Decimal.zero;

    try {
      unSupply = (Decimal.tryParse('$totalCap') - Decimal.parse(totalSupply)) -
          Decimal.parse(totalBurn);
      totalSupplyEther = Decimal.parse(FormatUtil.weiToEtherStr(totalSupply));
      totalBurnEther = Decimal.parse(FormatUtil.weiToEtherStr(totalBurn));
      unSupplyEther = Decimal.parse(FormatUtil.weiToEtherStr('$unSupply'));
    } catch (e) {}

    var totalCapStr = bigIntToEtherWithFormat(totalCap);
    var totalSupplyStr = bigIntToEtherWithFormat(totalSupply);
    var totalBurningStr = bigIntToEtherWithFormat(totalBurn);
    var unSupplyStr = bigIntToEtherWithFormat("$unSupply");

    return Row(
      children: [
        SizedBox(
          width: 16,
        ),
        Container(
          width: 100,
          height: 100,
          child: _pieChart([
            totalSupplyEther,
            unSupplyEther,
            totalBurnEther,
          ]),
        ),
        SizedBox(
          width: 36,
        ),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
        )),
      ],
    );
  }

  _rpAirdrop() {
    var total = _rpStats?.airdrop?.total ?? '0';
    var totalAirdrop = _rpStats?.airdrop?.totalAirdrop ?? '0';
    var totalLucky = _rpStats?.airdrop?.luckyTotal ?? '0';
    var totalLevel = _rpStats?.airdrop?.levelTotal ?? '0';
    var totalPromotion = _rpStats?.airdrop?.promotionTotal ?? '0';

    var totalStr = bigIntToEtherWithFormat(total);
    var airdropLuckyTotalStr = bigIntToEtherWithFormat(totalLucky);
    var airdropLevelTotalStr = bigIntToEtherWithFormat(totalLevel);
    var airdropPromotionTotalStr = bigIntToEtherWithFormat(totalPromotion);

    var unAirdrop = Decimal.zero;
    var airdropTotalEther = Decimal.zero;
    var unAirdropEther = Decimal.zero;

    try {
      unAirdrop = Decimal.tryParse(total) - Decimal.tryParse(totalAirdrop);

      unAirdropEther = Decimal.parse(
        FormatUtil.weiToEtherStr('$unAirdrop'),
      );

      airdropTotalEther = Decimal.parse(
        FormatUtil.weiToEtherStr('$totalAirdrop'),
      );
    } catch (e) {}

    var totalAirdropStr = bigIntToEtherWithFormat("$totalAirdrop");
    var unAirdropStr = bigIntToEtherWithFormat("$unAirdrop");

    var airdropBurnTotalStr =
        bigIntToEtherWithFormat(_rpStats?.airdrop?.burningTotal);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            SizedBox(
              width: 16,
            ),
            Container(
              width: 100,
              height: 100,
              child: _pieChart([
                airdropTotalEther,
                unAirdropEther,
              ]),
            ),
            SizedBox(
              width: 36,
            ),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _dataText('已空投', totalAirdropStr, colorStr: colorPalette[0]),
                _dataText('未空投', unAirdropStr, colorStr: colorPalette[1]),
              ],
            ))
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
    var unTransmitRp = Decimal.zero;

    var transmitRpEther = Decimal.zero;
    var unTransmitRpEther = Decimal.zero;

    try {
      unTransmitRp = Decimal.tryParse(total) - Decimal.parse(transmitRp);

      unTransmitRpEther = Decimal.parse(
        FormatUtil.weiToEtherStr('$unTransmitRp'),
      );

      transmitRpEther = Decimal.parse(
        FormatUtil.weiToEtherStr('$transmitRp'),
      );
    } catch (e) {}

    var totalStr = bigIntToEtherWithFormat(total);
    var transmitRPStr = bigIntToEtherWithFormat(transmitRp);
    var unTransmitRpStr = bigIntToEtherWithFormat("$unTransmitRp");

    return Row(
      children: [
        SizedBox(
          width: 16,
        ),
        Container(
          width: 100,
          height: 100,
          child: _pieChart([
            transmitRpEther,
            unTransmitRpEther,
          ]),
        ),
        SizedBox(
          width: 36,
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

    var promotionTotalHoldingStr =
        bigIntToEtherWithFormat(promotionTotalHolding);
    var promotionTotalBurningStr =
        bigIntToEtherWithFormat(promotionTotalBurning);

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

  _pieChart(List<Decimal> dataList) {
    Map<String, double> dataMap = {};
    dataList.forEach((element) {
      double value = double.tryParse('$element') ?? 0;
      dataMap['${value}'] = value;
    });
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: PieChart(
        dataMap: dataMap,
        animationDuration: Duration(milliseconds: 800),
        chartRadius: MediaQuery.of(context).size.width / 3.2,
        colorList: colorPaletteHex,
        chartType: ChartType.ring,
        ringStrokeWidth: 30,
        legendOptions: LegendOptions(
          showLegends: false,
        ),
        chartValuesOptions: ChartValuesOptions(
          chartValueStyle: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
          showChartValueBackground: false,
          showChartValuesInPercentage: true,
          decimalPlaces: 2,
          showChartValuesOutside: true,
        ),
      ),
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
