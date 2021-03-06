import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';

class QrCodePage extends StatelessWidget {
  final String qrCodeStr;

  QrCodePage(this.qrCodeStr);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text(
            S.of(context).scan_qrcode_result,
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: Center(child: Text(qrCodeStr,style: TextStyle(fontSize: 23),),)
    );
  }
}
