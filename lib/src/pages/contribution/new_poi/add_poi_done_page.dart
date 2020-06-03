import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import '../../../extension/navigator_ext.dart';

class AddPOIDonePage extends StatefulWidget {
  final String backRouteName;

  AddPOIDonePage({this.backRouteName});

  @override
  State<StatefulWidget> createState() {
    return _AddPOIDonePageState();
  }
}

class _AddPOIDonePageState extends State<AddPOIDonePage> {
  String _POIName = '麦当劳';
  double _rewardHYN = 0.1;
  int _rewardCoins = 10;
  int _extraRewardCoins = 20;

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
        body: Center(
          child: Container(
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
                    '添加成功',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    ' 干的漂亮！您在地图上添加了 $_POIName，获得${_rewardHYN}HYN + ${_rewardCoins}个金币。如果你的地点被评为优质地点，将额外再获得$_extraRewardCoins个金币。',
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
                    onPressed: () async {},
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
              ],
            ),
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
