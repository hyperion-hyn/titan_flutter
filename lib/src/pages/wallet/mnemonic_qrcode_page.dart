import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:titan/generated/i18n.dart';

class MnemonicQrcodePage extends StatelessWidget {
  final String mnemonic;

  MnemonicQrcodePage({this.mnemonic});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).qrcode)),
      backgroundColor: Theme.of(context).backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 48),
            Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(24.0)),
              ),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Image.asset(
                        "res/drawable/ic_logo.png",
                        width: 24,
                        color: Theme.of(context).primaryColor,
                      ),
                      SizedBox(width: 8),
                      Image.asset(
                        'res/drawable/logo_title.png',
                        height: 8,
                        color: Theme.of(context).primaryColor,
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  RepaintBoundary(
                    child: QrImage(
                      data: mnemonic,
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.grey[800],
                      version: 5,
                      size: 200,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    S.of(context).mnemonic_qrcode_tip,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),
            Icon(Icons.warning, color: Colors.grey),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Text(
                S.of(context).save_mnemonic_safe_notice,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
