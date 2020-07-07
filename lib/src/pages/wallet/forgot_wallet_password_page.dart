import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/app.dart';

class ForgotWalletPasswordPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ForgotWalletPasswordPageState();
  }
}

class _ForgotWalletPasswordPageState extends State<ForgotWalletPasswordPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        backgroundColor: Colors.white,
        title: Text(
          S.of(context).forgot_password,
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              S.of(context).forgot_password,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 32,
            ),
            Text(
              S.of(context).forgot_password_content_1,
              style: TextStyle(
                fontSize: 14,
                height: 1.8,
              ),
            ),
            SizedBox(
              height: 16,
            ),
            Text(
              S.of(context).forgot_password_content_2,
              style: TextStyle(
                height: 1.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
