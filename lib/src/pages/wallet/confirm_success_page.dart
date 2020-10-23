import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/pages/wallet/service/wallet_service.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/routes/routes.dart';

class ConfirmSuccessPage extends StatefulWidget {
  final String msg;

  ConfirmSuccessPage({this.msg});

  @override
  State<StatefulWidget> createState() {
    return _ConfirmSuccessPage();
  }
}

class _ConfirmSuccessPage extends State<ConfirmSuccessPage> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.black),
          ),
          body: Center(
            child: Container(
              padding: EdgeInsets.all(16),
              alignment: Alignment.center,
              child: Column(
                children: <Widget>[
                  SizedBox(height: 48),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Image.asset(
                      "res/drawable/check_outline.png",
                      height: 76,
                      width: 124,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      S.of(context).broadcase_success,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.msg ?? S.of(context).transfer_broadcase_success_description,
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
                        Routes.popUntilCachedEntryRouteName(context, true);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              S.of(context).confirm,
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
          )),
    );
  }
}
