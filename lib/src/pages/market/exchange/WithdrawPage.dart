import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WithdrawPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _WithdrawPageState();
  }
}

class _WithdrawPageState extends State<WithdrawPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          _appBar(),
          _coinView(),
          //_withdrawView(),
        ],
      ),
    );
  }

  _appBar() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          child: IconButton(
            icon: Icon(
              Icons.arrow_back,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        Spacer(),
        Icon(Icons.format_align_center),
        SizedBox(
          width: 16.0,
        ),
      ],
    );
  }

  _coinView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            '充币',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
          ),
        ),
        InkWell(
          onTap: () {
            _showCoinSelectDialog();
          },
          child: Container(
            decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.all(
                  Radius.circular(8.0),
                )),
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: <Widget>[
                Text(
                  'USDT',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                Text(
                  '选择币种 ',
                  style: TextStyle(
                      fontWeight: FontWeight.w500, color: Colors.grey[500]),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  _showCoinSelectDialog() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Column(
            children: <Widget>[
              Center(
                child: Text('USDT'),
              ),
              Center(
                child: Text('BTC'),
              ),
              Center(
                child: Text('ETH'),
              )
            ],
          );
        });
  }

  _withdrawView() {}
}
