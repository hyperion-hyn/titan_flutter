import 'package:flutter/material.dart';
import 'package:titan/src/pages/market/order/entity/order_entity.dart';

class ExchangeDetailPage extends StatefulWidget {
  final String symbol;
  final int type;

  ExchangeDetailPage({@required this.symbol, @required this.type});

  @override
  State<StatefulWidget> createState() {
    return ExchangeDetailPageState();
  }
}

class ExchangeDetailPageState extends State<ExchangeDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              _appBar(),
              Row(
                children: <Widget>[
                  _exchangeOptions(),
                  _depthChart(),
                ],
              )
            ],
          )
        ],
      )),
    );
  }

  _appBar() {
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
              'HYN/${widget.symbol}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          Container(
            padding: EdgeInsets.all(2.0),
            child: Text(
              '+13.0%',
              style: TextStyle(
                color: widget.type == ExchangeType.BUY
                    ? Colors.red[400]
                    : Colors.green[400],
                fontSize: 13.0,
              ),
            ),
            decoration: BoxDecoration(
                color: widget.type == ExchangeType.BUY
                    ? Colors.red[50]
                    : Colors.green[200],
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

  _depthChart() {}

  _exchangeOptions() {
    return Column(
      children: <Widget>[],
    );
  }
}
