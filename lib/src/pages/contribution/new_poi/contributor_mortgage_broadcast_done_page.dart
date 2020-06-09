import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/utils/utile_ui.dart';

import '../../../extension/navigator_ext.dart';

class ContributorMortgageBroadcastDonePage extends StatefulWidget {
  final String backRouteName;

  ContributorMortgageBroadcastDonePage({this.backRouteName});

  @override
  State<StatefulWidget> createState() {
    return _ContributorMortgageBroadcastDonePageState();
  }
}

class _ContributorMortgageBroadcastDonePageState
    extends State<ContributorMortgageBroadcastDonePage> {
  double _rewardHyn = 0.1;
  int _rewardCoins = 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  _doneAndBack();
                },
              );
            },
          ),
        ),
        body: Container(
          padding: EdgeInsets.all(10),
          alignment: Alignment.center,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Image.asset(
                  "res/drawable/check_outline.png",
                  width: 124,
                  height: 76,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  '广播成功',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '已在区块链上网络广播 【数据贡献者抵押】的消息，区块链网络需要5-30分钟开采验证。',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF9B9B9B)),
                ),
              ),
              SizedBox(
                height: 36,
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 16, horizontal: 36),
                constraints: BoxConstraints.expand(height: 48),
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  disabledColor: Colors.grey[600],
                  color: Theme.of(context).primaryColor,
                  textColor: Colors.white,
                  disabledTextColor: Colors.white,
                  onPressed: () async {
                    _doneAndBack();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          S.of(context).finish,
                          style: TextStyle(
                              fontWeight: FontWeight.normal, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 16, horizontal: 36),
                constraints: BoxConstraints.expand(height: 48),
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  disabledColor: Colors.grey[500],
                  color: Colors.white,
                  disabledTextColor: Colors.white,
                  onPressed: () async {},
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          '纠正该地点 +${_rewardHyn}HYN + ${_rewardCoins}积分',
                          style: TextStyle(
                              fontWeight: FontWeight.normal, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  void _doneAndBack() {
    if (widget.backRouteName == null) {
      Navigator.pop(context);
    } else {
      Navigator.of(context)
          .popUntilRouteName(Uri.decodeComponent(widget.backRouteName));
    }
  }
}
