import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:titan/src/app.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/business/me/model/user_info.dart';
import 'package:titan/src/business/me/my_asset_page.dart';
import 'package:titan/src/consts/consts.dart';
import 'package:titan/src/utils/utils.dart';

import '../../global.dart';
import 'model/contract_info.dart';
import 'model/contract_info_v2.dart';
import 'model/pay_order.dart';
import 'model/purchase_order_info.dart';
import 'model/quotes.dart';
import 'my_hash_rate_page.dart';
import 'service/user_service.dart';

class RechargePurchasePage extends StatefulWidget {
  final double rechargeAmount;

  RechargePurchasePage({@required this.rechargeAmount});

  @override
  State<StatefulWidget> createState() {
    return _RechargePurchaseState();
  }
}

class _RechargePurchaseState extends State<RechargePurchasePage> {
  var service = UserService();

  PurchaseOrderInfo rechargeOrder;
  Quotes quotes;
  UserInfo userInfo;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    try {
      var data = await service.createPurchaseOrder(amount: widget.rechargeAmount);
      setState(() {
        rechargeOrder = data;
      });
    } catch (e) {
      logger.e(e);
      Fluttertoast.showToast(msg: "创建订单失败");
    }

    //行情
    var quotesData = await service.quotes();
    setState(() {
      quotes = quotesData;
    });

    //用户余额等信息
    var _userInfo = await service.getUserInfo();
    setState(() {
      userInfo = _userInfo;
    });
  }

  @override
  Widget build(BuildContext context) {
    var payTypeName = "HYN支付";
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "充值",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(2)), shape: BoxShape.rectangle),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: <Widget>[
                        Text(
                          "充值数量：",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        Text(
                          "${Const.DOUBLE_NUMBER_FORMAT.format(widget.rechargeAmount)} USDT",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: <Widget>[
                  Container(
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: Color(0xFFF2F2F2),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          )),
                      child: Row(
                        children: <Widget>[
                          Text(payTypeName),
                        ],
                      )),
                  _buildHynPayBox(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildHynPayBox() {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          alignment: Alignment.topCenter,
          decoration: BoxDecoration(color: Colors.white, shape: BoxShape.rectangle),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              if (rechargeOrder?.qrCode != null)
                Image.memory(
                  Base64Decoder().convert(rechargeOrder?.qrCode),
                  height: 240,
                  width: 240,
                )
              else
                Container(
                  color: Colors.white,
                  height: 240,
                  width: 240,
                ),
              InkWell(
                onTap: () {
                  if (rechargeOrder?.address != null) {
                    Clipboard.setData(ClipboardData(text: rechargeOrder?.address));
                    Fluttertoast.showToast(msg: "地址复制成功");
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "支付地址",
                      style: TextStyle(fontSize: 14),
                    ),
                    Text('${shortEthAddress(rechargeOrder?.address)}', style: TextStyle(fontSize: 14)),
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Icon(
                        Icons.content_copy,
                        size: 16,
                        color: Colors.black54,
                      ),
                    )
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  if (rechargeOrder?.hynAmount != null) {
                    Clipboard.setData(ClipboardData(text: rechargeOrder?.hynAmount));
                    Fluttertoast.showToast(msg: "支付金额复制成功");
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        "请支付",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Text(
                          '${rechargeOrder?.hynAmount} HYN',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFFCE9D40)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Icon(
                          Icons.content_copy,
                          size: 16,
                          color: Colors.black54,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Text(
                '请务必支付指定的HYN金额！',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.red[800]),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 22.0),
                child: RaisedButton(
                  color: Color(0xFFD6A734),
                  onPressed: () {
                    Fluttertoast.showToast(msg: 'HYN钱包即将开放');
                  },
                  child: SizedBox(
                    height: 48,
                    width: 192,
                    child: Center(
                      child: Text(
                        "使用HYN钱包支付",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: RaisedButton(
                  color: Color(0xFF73C42D),
                  onPressed: () async {
                    var ret = await service.confirmRecharge(orderId: rechargeOrder.orderId);
                    if (ret.code == 0) {
                      //支付成功
                      Fluttertoast.showToast(msg: '充值成功');
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyAssetPage()));
                    } else {
                      if (ret.code == -1007) {
                        Fluttertoast.showToast(msg: '已到达购买上限');
                      } else {
                        Fluttertoast.showToast(msg: '暂未发现转账信息，请稍后再试');
                      }
                    }
                  },
                  child: SizedBox(
                    height: 48,
                    width: 192,
                    child: Center(
                      child: Text(
                        "我已使用外部钱包支付",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              )
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 8),
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.notification_important,
                  color: Colors.grey,
                  size: 20,
                ),
              ),
              Expanded(
                child: Text(
                  "当前 ${quotes?.currency} 兑换 ${quotes?.to} 的汇率为: 1${quotes?.currency} = ${quotes?.rate}${quotes?.to}。\n请勿往上述地址转入非HYN资产，否则资产将不可找回。您支付后后，需要整个网络节点的确认，大约需要20分钟。",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                  softWrap: true,
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
