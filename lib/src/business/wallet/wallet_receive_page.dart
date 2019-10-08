import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:titan/src/basic/utils/hex_color.dart';

class WalletReceivePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _WalletReceiveState();
  }
}

class _WalletReceiveState extends State<WalletReceivePage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("接收HYN"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: EdgeInsets.symmetric(vertical: 24),
                width: 224,
                decoration: BoxDecoration(
                    color: Colors.white, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(8)),
                alignment: Alignment.center,
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    QrImage(
                      data: "0x9432fewfefet4t24tfrwf4g4f3qw4f4w4f43wf4w34f4",
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.grey[800],
                      version: 4,
                      size: 180,
                    ),
                    Text(
                      "0x9fdr53424grgsrgresg434tgr43tw43gwrg",
                      softWrap: true,
                      style: TextStyle(color: Colors.grey[500], fontSize: 16),
                    )
                  ],
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Text(
                    "30 HYN",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
                  ),
                  Text(
                    "≈ USD \$1.74 ",
                    style: TextStyle(color: Colors.grey[400], fontSize: 22),
                  )
                ],
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                GestureDetector(
                  onTap: (){
                  },
                  child: Column(
                    children: <Widget>[
                      Container(
                        alignment: Alignment.center,
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          color: HexColor("#FF3F51B5"),
                          border: Border.all(color: Colors.grey, width: 0),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.content_copy,
                          color: Colors.white,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "复制",
                          style: TextStyle(
                            color: HexColor(
                              "#FF3F51B5",
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: (){
                  },
                  child: Column(
                    children: <Widget>[
                      Container(
                        alignment: Alignment.center,
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          color: HexColor("#FF3F51B5"),
                          border: Border.all(color: Colors.grey, width: 0),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.bookmark,
                          color: Colors.white,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "设置数额",
                          style: TextStyle(
                            color: HexColor(
                              "#FF3F51B5",
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Column(
                  children: <Widget>[
                    Container(
                      alignment: Alignment.center,
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: HexColor("#FF3F51B5"),
                        border: Border.all(color: Colors.grey, width: 0),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.share,
                        color: Colors.white,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "分享",
                        style: TextStyle(
                          color: HexColor(
                            "#FF3F51B5",
                          ),
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
