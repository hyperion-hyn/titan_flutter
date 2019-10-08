import 'package:flutter/material.dart';
import 'package:titan/src/business/wallet/wallet_send_confirm_page.dart';
import 'package:titan/src/presentation/extends_icon_font.dart';

class WalletSendPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _WalletSendState();
  }
}

class _WalletSendState extends State<WalletSendPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(""),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 32),
            decoration: BoxDecoration(color: Colors.white, border: Border.all(width: 0.8, color: Colors.grey[300])),
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 24),
            child: Column(
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(labelText: "接收者地址", border: InputBorder.none),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        "粘贴",
                        style: TextStyle(color: Colors.blue, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Icon(
                      ExtendsIconFont.qrcode_scan,
                      color: Colors.blue,
                      size: 22,
                    )
                  ],
                ),
                Divider(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(labelText: "HYN数量", border: InputBorder.none),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
                      child: Text(
                        "最大",
                        style: TextStyle(
                            color: Colors.blue,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            textBaseline: TextBaseline.ideographic),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 0),
                      child: Text(
                        "HYN",
                        style: TextStyle(color: Colors.blue, fontSize: 18, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
          Padding(padding: EdgeInsets.only(left: 8, top: 8), child: Text("≈ 34234321434 USD")),
          Spacer(),
          Row(children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                child: RaisedButton(
                  color: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 128, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => WalletSendConfirmPage()));
                  },
                  child: Text(
                    "下一步",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ])
        ],
      ),
    );
  }
}
