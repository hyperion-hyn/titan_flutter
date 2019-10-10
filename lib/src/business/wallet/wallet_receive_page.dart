import 'dart:io';

import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/business/wallet/model_vo.dart';

class WalletReceivePage extends StatefulWidget {
  final WalletAccountVo walletAccountVo;

  WalletReceivePage(this.walletAccountVo);

  @override
  State<StatefulWidget> createState() {
    return _WalletReceiveState();
  }
}

class _WalletReceiveState extends State<WalletReceivePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("接收 ${widget.walletAccountVo.symbol}"),
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
                      data: widget.walletAccountVo.account.address,
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.grey[800],
                      version: 4,
                      size: 180,
                    ),
                    Text(
                      widget.walletAccountVo.account.address,
                      softWrap: true,
                      style: TextStyle(color: Colors.grey[500], fontSize: 16),
                    )
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Builder(
                  builder: (BuildContext context) {
                    return GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: widget.walletAccountVo.account.address));
                        Scaffold.of(context).showSnackBar(SnackBar(content: Text("地址已复制")));
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
                    );
                  },
                ),
                GestureDetector(
                  onTap: () {
                    Share.text("我的${widget.walletAccountVo.symbol}接收地址:", widget.walletAccountVo.account.address,
                        "text/plain");
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
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
