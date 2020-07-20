import 'package:flutter/material.dart';

class KLineDetailPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _KLineDetailPageState();
  }
}

class _KLineDetailPageState extends State<KLineDetailPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("!!!!");
    return Scaffold(
      appBar: AppBar(
        title: Text("行情信息"),
      ),
      body: Column(children: <Widget>[
        _appBar(),
      ]),
    );
  }

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
}
