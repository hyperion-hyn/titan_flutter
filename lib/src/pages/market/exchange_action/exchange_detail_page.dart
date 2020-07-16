import 'package:flutter/material.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/pages/market/model/exc_detail_chart.dart';
import 'package:titan/src/pages/market/order/entity/order_entity.dart';

class ExchangeDetailPage extends StatefulWidget {
//  final String symbol;
//  final int type;

  @override
  State<StatefulWidget> createState() {
    return _ExchangeDetailPageState();
  }
}

class _ExchangeDetailPageState extends State<ExchangeDetailPage> {
//  List<ExcDetailChart> chartList = [];

  @override
  void initState() {
//    chartList.add(ExcDetailChart(4, 0, 10));
//    chartList.add(ExcDetailChart(4, 3, 7));
//    chartList.add(ExcDetailChart(4, 4, 6));
//    chartList.add(ExcDetailChart(4, 5, 5));
//    chartList.add(ExcDetailChart(4, 6, 4));
//    chartList.add(ExcDetailChart(2, 6, 4));
//    chartList.add(ExcDetailChart(2, 5, 5));
//    chartList.add(ExcDetailChart(2, 4, 6));
//    chartList.add(ExcDetailChart(2, 3, 7));
//    chartList.add(ExcDetailChart(2, 0, 10));

    super.initState();
  }
@override
  Widget build(BuildContext context) {
    print("!!!!");
    return Scaffold(
      appBar: AppBar(
        title: Text("Wallet Demo111"),
      ),
      body: Container(),
    );
  }
  /*@override
  Widget build(BuildContext context) {
    print("!!!!");
    return Scaffold(
      appBar: AppBar(
        title: Text("Wallet Demo1"),
      ),
      body: Column(
        children: <Widget>[
      _appBar(),
      Row(
        children: <Widget>[
          Expanded(flex: 6, child: _exchangeOptions()),
          Expanded(flex: 4, child: _depthChart()),
        ],
      ),
      _consignList()
        ],
      ),
    );
  }*/

  Widget _appBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          IconButton(
            icon: Icon(
              Icons.arrow_back,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          Icon(Icons.format_align_center),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
//              'HYN/${widget.symbol}',
              'HYN/',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          Container(
            padding: EdgeInsets.all(2.0),
            child: Text(
              '+13.0%',
              style: TextStyle(
//                color: widget.type == ExchangeType.BUY ? Colors.red[400] : Colors.green[400],
                fontSize: 13.0,
              ),
            ),
            decoration: BoxDecoration(
//                color: widget.type == ExchangeType.BUY ? Colors.red[50] : Colors.green[200],
                borderRadius: BorderRadius.circular(4.0)),
          ),
          Spacer(),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.equalizer),
          )
        ],
      ),
    );
  }

  Widget _exchangeOptions() {
    return Container(
      width: double.infinity,
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 104,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.white,
                  image: DecorationImage(
                      image: AssetImage("res/drawable/ic_exchange_bg_left_buy.png"),
                      fit: BoxFit.fill
                  ),
                ),
                alignment: Alignment.center,
                child: Text('买入'),
              ),Container(
                width: 104,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.white,
                  image: DecorationImage(
                      image: AssetImage("res/drawable/ic_exchange_bg_right_sell.png"),
                      fit: BoxFit.fill
                  ),
                ),
                alignment: Alignment.center,
                child: Text('卖出'),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _depthChart() {
    /*return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        itemBuilder: (context, index) {
          ExcDetailChart excDetailChart = chartList[index];
          if (excDetailChart.viewType == 2 || excDetailChart.viewType == 4) {
            Color bgColor = excDetailChart.viewType == 2 ? HexColor("#EBF8F2") : HexColor("#F9EFEF");
            return Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: excDetailChart.leftPercent,
                      child: Container(
                        height: 23,
                        color: HexColor("#ffffff"),
                      ),
                    ),
                    Expanded(
                      flex: excDetailChart.rightPercent,
                      child: Container(
                        height: 23,
                        color: bgColor,
                      ),
                    )
                  ],
                ),
                Row(
                  children: <Widget>[
                    Text(
                      "1111",
                    ),
                    Spacer(),
                    Text(
                      "1111",
                    )
                  ],
                ),
              ],
            );
          } else {
            return Text("");
          }
        },
        itemCount: chartList.length);*/
    return Container();
  }

  Widget _consignList() {
    return Text("aaabbb",key: GlobalKey(),);
  }
}
