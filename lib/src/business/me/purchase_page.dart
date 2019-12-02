import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:titan/src/app.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/business/me/model/user_info.dart';
import 'package:titan/src/consts/consts.dart';
import 'package:titan/src/utils/utils.dart';

import '../../global.dart';
import 'enter_fund_password.dart';
import 'model/contract_info.dart';
import 'model/contract_info_v2.dart';
import 'model/pay_order.dart';
import 'model/quotes.dart';
import 'my_hash_rate_page.dart';
import 'recharge_purchase_page.dart';
import 'service/user_service.dart';
import 'dart:math';

class PurchasePage extends StatefulWidget {
  final ContractInfoV2 contractInfo;

  final PayOrder payOrder;

  PurchasePage({@required this.contractInfo, @required this.payOrder});

  @override
  State<StatefulWidget> createState() {
    return _PurchaseState();
  }
}

class _PurchaseState extends State<PurchasePage> {
  int payType = 1; //0: HYN 1：HYN余额

  ///直充余额类型支付
  static const String PAY_BALANCE_TYPE_RECHARGE = "RB_HYN";

  ///收益余额类型支付
  static const String PAY_BALANCE_TYPE_INCOME = "B_HYN";
  String payBalanceType = PAY_BALANCE_TYPE_RECHARGE;

  var service = UserService();

//  PayOrder payOrder;
  Quotes quotes;
  UserInfo userInfo;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    //行情
    quotes = await service.quotes();
    //用户余额等信息
    userInfo = await service.getUserInfo();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // todo: jison edit_抵押方式
    //var payTypeName = payType == 0 ? "使用HYN" : "使用余额";
    var payTypeName = payType == 0 ? "使用HYN" : "选择抵押方式";

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "算力抵押",
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
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
                          "产品：",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        Text(
                          "${widget.contractInfo.name}",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        "金额：",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      Text(
                        "${Const.DOUBLE_NUMBER_FORMAT.format(widget.contractInfo.amount)} USDT",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      )
                    ],
                  )
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
                          Spacer(),
// todo: jison edit_抵押方式
//                          GestureDetector(
//                            onTapUp: (detail) {
//                              RenderBox overlay = Overlay.of(context).context.findRenderObject();
//                              var position = RelativeRect.fromRect(
//                                  detail.globalPosition & Size(80, 80), // smaller rect, the touch area
//                                  Offset.zero & overlay.size // Bigger rect, the entire screen
//                                  );
//                              showMenu(
//                                      context: context,
//                                      position: position,
//                                      items: <PopupMenuEntry>[
//                                        PopupMenuItem(
//                                          value: 0,
//                                          child: Text(
//                                            "HYN",
//                                            style: TextStyle(fontSize: 14),
//                                          ),
//                                        ),
//                                        PopupMenuItem(
//                                          value: 1,
//                                          child: Text("使用余额", style: TextStyle(fontSize: 14)),
//                                        ),
//                                      ],
//                                      initialValue: payType)
//                                  .then((selected) {
//                                print("selected:$selected ");
//                                if (selected == null) {
//                                  return;
//                                }
//                                payType = selected;
//                                setState(() {});
//                              });
//                            },
//                            child: Text(
//                              "切换方式>",
//                              style: TextStyle(fontSize: 14, color: HexColor("#9E101010")),
//                            ),
//                          )
                        ],
                      )),
                  if (payType == 0) _buildHynPayBox(),
                  if (payType == 1) _buildHynBalancePayBox(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  RelativeRect _getPosition(BuildContext context) {
    final RenderBox bar = context.findRenderObject();
    final RenderBox overlay = Overlay.of(context).context.findRenderObject();
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        bar.localToGlobal(bar.size.bottomRight(Offset.zero), ancestor: overlay),
        bar.localToGlobal(bar.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );
    return position;
  }

  Widget _buildHynPayBox() {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 0),
          alignment: Alignment.topCenter,
          decoration: BoxDecoration(color: Colors.white, shape: BoxShape.rectangle),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              InkWell(
                onTap: () {
                  if (widget.payOrder?.hyn_amount != null) {
                    Clipboard.setData(ClipboardData(text: widget.payOrder?.hyn_amount));
                    Fluttertoast.showToast(msg: "金额复制成功");
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "请抵押",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Container(
                        constraints: BoxConstraints(maxWidth: 220),
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Text(
                          '${widget.payOrder?.hyn_amount}',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFFCE9D40)),
                          softWrap: true,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Text(
                          'HYN',
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
              SizedBox(
                height: 8,
              ),
              Text(
                '请务必转入指定的HYN金额！',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.red[800]),
              ),
              if (widget.payOrder?.qr_code != null)
                Image.memory(
                  Base64Decoder().convert(widget.payOrder?.qr_code),
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
                  if (widget.payOrder?.address != null) {
                    Clipboard.setData(ClipboardData(text: widget.payOrder?.address));
                    Fluttertoast.showToast(msg: "地址复制成功");
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "转入地址",
                      style: TextStyle(fontSize: 14),
                    ),
                    Text('${shortEthAddress(widget.payOrder?.address)}', style: TextStyle(fontSize: 14)),
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

//              Text(
//                '推荐使用imToken扫码支付',
//                style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal, color: Colors.grey[500]),
//              ),
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
                        "使用HYN钱包转入",
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
                    var ret =
                        await service.confirmPay(orderId: widget.payOrder.order_id, payType: 'HYN', fundToken: " ");
                    if (ret.code == 0) {
                      //支付成功
                      Fluttertoast.showToast(msg: '支付成功');
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyHashRatePage()));
                    } else {
                      if (ret.code == -1007) {
                        Fluttertoast.showToast(msg: '已到达上限');
                      } else {
                        Fluttertoast.showToast(msg: '暂未发现转入信息，请稍后再试');
                      }
                    }
                  },
                  child: SizedBox(
                    height: 48,
                    width: 192,
                    child: Center(
                      child: Text(
                        "我已使用外部钱包转入",
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
                  "当前 ${quotes?.currency} 兑换 ${quotes?.to} 的汇率为: 1${quotes?.currency} = ${NumberFormat("#,###.####").format(quotes?.rate ?? 0)}${quotes?.to}。\n禁止从交易所直接提到上述地址，请使用数字钱包转账入。勿往上述地址转入非HYN资产，否则资产将不可找回。您转账后后，需要整个网络节点的确认，大约需要20分钟。",
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

  double getBalanceByType(String type) {

    if (userInfo == null) return 0.0;

    print('balance: ${userInfo.balance}, chargeBalance: ${userInfo.chargeBalance})');

    double balance = 0;
    if (type == PAY_BALANCE_TYPE_INCOME) {
      balance = (userInfo?.balance ?? 0) - (userInfo?.chargeBalance ?? 0);
    } else if (type == PAY_BALANCE_TYPE_RECHARGE) {
      balance = userInfo?.chargeBalance ?? 0;
    }

    int decimals = 2;
    int fac = pow(10, decimals);
    print('fac: $fac');
    double d = balance;
    d = (d * fac).floor()/fac;
    print("d: $d");

    return d;
  }

  Widget _buildHynBalancePayBox() {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.topCenter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.max,
//                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: RadioListTile(
                      groupValue: payBalanceType,
                      onChanged: (value) {
                        setState(() {
                          payBalanceType = value;
                        });
                      },
                      activeColor: Theme.of(context).primaryColor,
                      value: PAY_BALANCE_TYPE_RECHARGE,
                      title: Text('充值余额'),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile(
                      groupValue: payBalanceType,
                      onChanged: (value) {
                        setState(() {
                          payBalanceType = value;
                        });
                      },
                      activeColor: Theme.of(context).primaryColor,
                      value: PAY_BALANCE_TYPE_INCOME,
                      title: Text('收益余额'),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      "请抵押",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Text(
                        '${widget.payOrder?.amount ?? 0}',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFFCE9D40)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Text(
                        'USDT',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFFCE9D40)),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "可用余额 ${Const.DOUBLE_NUMBER_FORMAT.format(getBalanceByType(payBalanceType))} USDT",
                    style: TextStyle(fontSize: 14, color: Color(0xFF9B9B9B)),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 32),
                child: RaisedButton(
                  elevation: 1,
                  color: Color(0xFFD6A734),
                  onPressed: () async {
                    if (userInfo != null && widget.payOrder != null) {
                      if (getBalanceByType(payBalanceType) < widget.payOrder.amount) {
                        Fluttertoast.showToast(msg: '余额不足');
                      } else {
                        try {
                          showModalBottomSheet(
                              isScrollControlled: true,
                              context: context,
                              builder: (BuildContext context) {
                                return EnterFundPasswordWidget();
                              }).then((fundToken) async {
                            if (fundToken == null) {
                              return;
                            }
                            var ret = await service.confirmPay(
                                orderId: widget.payOrder.order_id, payType: payBalanceType, fundToken: fundToken);
                            if (ret.code == 0) {
                              //支付成功
                              Fluttertoast.showToast(msg: '操作成功');
                              Navigator.pushReplacement(
                                  context, MaterialPageRoute(builder: (context) => MyHashRatePage()));
                            } else {
                              if (ret.code == -1007) {
                                Fluttertoast.showToast(msg: '已到达上限');
                              } else {
                                Fluttertoast.showToast(msg: '支付失败');
                              }
                            }
                          });
                        } catch (e) {
                          logger.e(e);
                          Fluttertoast.showToast(msg: '转入异常');
                        }
                      }
                    } else {
                      Fluttertoast.showToast(msg: "数据异常，请重试");
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                    child: SizedBox(
                        height: 40,
                        width: 192,
                        child: Center(
                            child: Text(
                          "确认抵押",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ))),
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
              if (getBalanceByType(payBalanceType) < widget.payOrder.amount)
                Container(
                  padding: EdgeInsets.only(top: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "余额不足",
                        style: TextStyle(color: Colors.red),
                      ),
                      SizedBox(
                        width: 16,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => RechargePurchasePage(),
                                      settings: RouteSettings(name: "/recharge_purchase_page")))
                              .then((value) async {
//                            if (value == null || value == false) {
//                              return;
//                            }
                            userInfo = await service.getUserInfo();
                            payBalanceType = PAY_BALANCE_TYPE_RECHARGE;
                            setState(() {});
                          });
                        },
                        child: Text(
                          "点击充值",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),
//              Padding(
//                padding: const EdgeInsets.symmetric(vertical: 64.0),
//                child: Text(
//                  '提示：算力抵押只能使用收益余额进行抵押',
//                  style: TextStyle(color: Colors.grey),
//                ),
//              ),
            ],
          ),
        ),
      ],
    );
  }
}
