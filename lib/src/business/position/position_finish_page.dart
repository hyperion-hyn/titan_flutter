import 'package:flutter/material.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/global.dart';

class FinishAddPositionPage extends StatefulWidget {

  FinishAddPositionPage();

  @override
  State<StatefulWidget> createState() {
    return _FinishAddPositionState();
  }
}

class _FinishAddPositionState extends State<FinishAddPositionPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: (){
                  if (createWalletPopUtilName == null) {
                    Navigator.of(context).popUntil((r) => r.isFirst);
                  } else {
                    Navigator.of(context).popUntil(ModalRoute.withName(createWalletPopUtilName));
                    createWalletPopUtilName = null;
                  }
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
                    "位置信息添加成功",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    S.of(context).scan_thanks_contribution_signal_hint,
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    disabledColor: Colors.grey[600],
                    color: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                    disabledTextColor: Colors.white,
                    onPressed: () async {

                      if (createWalletPopUtilName == null) {
                        Navigator.of(context).popUntil((r) => r.isFirst);
                      } else {
                        Navigator.of(context).popUntil(ModalRoute.withName(createWalletPopUtilName));
                        createWalletPopUtilName = null;
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "继续添加",
                            style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    disabledColor: Colors.grey[600],
                    color: HexColor('#259D25'),
                    textColor: Colors.white,
                    disabledTextColor: Colors.white,
                    onPressed: () async {

                      if (createWalletPopUtilName == null) {
                        Navigator.of(context).popUntil((r) => r.isFirst);
                      } else {
                        Navigator.of(context).popUntil(ModalRoute.withName(createWalletPopUtilName));
                        createWalletPopUtilName = null;
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            S.of(context).finish,
                            style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
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
}
