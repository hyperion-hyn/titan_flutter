import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PromoteQrCodePage extends StatelessWidget {
  final String url;

  PromoteQrCodePage(this.url);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
//        backgroundColor: Colors.white,
        title: Text(
          "邀请二维码",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: <Widget>[
          Center(
            child: Container(
              padding: EdgeInsets.all(48),
              child: QrImage(
                data: url,
                backgroundColor: Colors.white,
                version: 4,
                size: 240,
              ),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            ),
          )
        ],
      ),
    );
  }
}
