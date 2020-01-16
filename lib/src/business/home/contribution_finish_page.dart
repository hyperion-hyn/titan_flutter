import 'package:flutter/material.dart';
import 'package:titan/generated/i18n.dart';

class FinishUploadPage extends StatefulWidget {

  FinishUploadPage();

  @override
  State<StatefulWidget> createState() {
    return _FinishUploadState();
  }
}

class _FinishUploadState extends State<FinishUploadPage> {

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
                  Navigator.pop(context);
//                  if (createWalletPopUtilName == null) {
//                    Navigator.of(context).popUntil((r) => r.isFirst);
//                  } else {
//                    Navigator.of(context).popUntil(ModalRoute.withName(createWalletPopUtilName));
//                    createWalletPopUtilName = null;
//                  }
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
                    height: 120,
                    width: 120,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    S.of(context).scan_upload_signal_success_hint,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    S.of(context).scan_thanks_contribution_signal_hint,
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    disabledColor: Colors.grey[600],
                    color: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                    disabledTextColor: Colors.white,
                    onPressed: () async {
                      Navigator.pop(context);
//                      if (createWalletPopUtilName == null) {
//                        Navigator.of(context).popUntil((r) => r.isFirst);
//                      } else {
//                        Navigator.of(context).popUntil(ModalRoute.withName(createWalletPopUtilName));
//                        createWalletPopUtilName = null;
//                      }
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
