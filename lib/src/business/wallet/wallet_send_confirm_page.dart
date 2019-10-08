import 'package:flutter/material.dart';
import 'package:titan/src/basic/utils/hex_color.dart';

class WalletSendConfirmPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _WalletSendConfirmState();
  }
}

class _WalletSendConfirmState extends State<WalletSendConfirmPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(),
        body: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    alignment: Alignment.center,
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_upward,
                      color: Colors.grey,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      "-50HYN",
                      style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 24),
                    ),
                  ),
                  Text(
                    "(USD\$2.91)",
                    style: TextStyle(color: Colors.grey[500], fontSize: 16),
                  )
                ],
              ),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "From",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          "主钱包1(0x89r3wr32feafedfaffdafsdfd)",
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "To",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          "0x89r3wr32feafedfaffdafsdfd5425454235432245",
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: <Widget>[
                  Text(
                    "网络费用",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
                  ),
                  Spacer(),
                  Text(
                    "0.000058985 ETH(USD\$0.10)",
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  )
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(color: HexColor("#fbf8f9")),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: <Widget>[
                    Text(
                      "最大总计",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Spacer(),
                    Text(
                      "0.000058985 ETH(USD\$0.10)",
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    )
                  ],
                ),
              ),
            ),
            Spacer(),
            Row(children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  child: RaisedButton(
                    color: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 128, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    onPressed: () {},
                    child: Text(
                      "发送",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ])
          ],
        ));
  }
}
