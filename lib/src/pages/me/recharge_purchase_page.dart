import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/components/wallet/vo/wallet_vo.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/me/components/account/account_component.dart';
import 'package:titan/src/pages/me/model/user_eth_address.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/utils/utile_ui.dart';

import 'model/quotes.dart';
import 'recharge_by_titan_finish_page.dart';
import 'service/user_service.dart';

class RechargePurchasePage extends StatefulWidget {
  RechargePurchasePage();

  @override
  State<StatefulWidget> createState() {
    return _RechargePurchaseState();
  }
}

class _RechargePurchaseState extends State<RechargePurchasePage> {
  var service = UserService();

//  WalletService _walletService = WalletService();
  Quotes quotes;

  UserEthAddress userEthAddress;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    var datas = await Future.wait([service.getUserEthAddress(), service.quotes()]);
    setState(() {
      userEthAddress = datas[0];
      quotes = datas[1];
    });

    _showAlertDialog();
  }

  void _showAlertDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text(
              S.of(context).recharge_tips,
              style: TextStyle(color: Colors.red[700]),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(S.of(context).transfer_warning_hint),
              ],
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(S.of(context).i_already_know),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          S.of(context).recharge,
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              padding: EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: _buildHynPayBox(),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildHynPayBox() {
    var userInfo = AccountInheritedModel.of(context, aspect: AccountAspect.userInfo).userInfo;
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          alignment: Alignment.topCenter,
          decoration: BoxDecoration(color: Colors.white, shape: BoxShape.rectangle),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              if (quotes != null)
                Text(
                  S.of(context).current_exchange_rate('${quotes?.to}', '${quotes?.currency}'),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.normal,
                  ),
                )
              else
                Text(
                  '',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              SizedBox(
                height: 8,
              ),
              if (quotes != null)
                Text(
                  '1${quotes?.to} ≈ ${NumberFormat("#,###.####").format(quotes?.rate == null ? 0 : (1 / quotes?.rate))}${quotes?.currency}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red[800]),
                )
              else
                Text(
                  '',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red[800]),
                ),
              if (userEthAddress?.qrCode != null)
                Image.memory(
                  Base64Decoder().convert(userEthAddress?.qrCode),
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
                  if (userEthAddress?.address != null) {
                    Clipboard.setData(ClipboardData(text: userEthAddress?.address));
                    Fluttertoast.showToast(msg: S.of(context).address_copy_success_hint);
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "${S.of(context).transfer_address}: ${UiUtil.shortEthAddress(userEthAddress?.address)}",
                      style: TextStyle(fontSize: 14),
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
              SizedBox(
                height: 16,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 22.0),
                child: RaisedButton(
                  color: Color(0xFFD6A734),
                  onPressed: () async {
                    WalletVo _walletVo =
                        WalletInheritedModel.of(context, aspect: WalletAspect.activatedWallet).activatedWallet;
                    if (_walletVo == null) {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return Platform.isIOS
                                ? CupertinoAlertDialog(
                                    title: Text(S.of(context).Tips),
                                    content: Text(S.of(context).without_hyn_wallet),
                                    actions: <Widget>[
//                                      new FlatButton(
//                                        onPressed: () {
//                                          createWalletPopUtilName = "/recharge_purchase_page";
//                                          Navigator.push(
//                                              context, MaterialPageRoute(builder: (context) => CreateAccountPage()));
//                                        },
//                                        child: new Text(S.of(context).create),
//                                      ),
                                      new FlatButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          Application.router.navigateTo(context, Routes.wallet_manager);
                                        },
                                        child: new Text(S.of(context).wallet_manage),
                                      ),
                                      new FlatButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: new Text(S.of(context).close),
                                      ),
                                    ],
                                  )
                                : AlertDialog(
                                    title: new Text(S.of(context).tips),
                                    content: new Text(S.of(context).without_hyn_wallet),
                                    actions: <Widget>[
//                                      new FlatButton(
//                                        onPressed: () {
//                                          createWalletPopUtilName = "/recharge_purchase_page";
//                                          Navigator.push(
//                                              context, MaterialPageRoute(builder: (context) => CreateAccountPage()));
//                                        },
//                                        child: new Text(S.of(context).create),
//                                      ),
                                      new FlatButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          Application.router.navigateTo(context, Routes.wallet_manager);
                                        },
                                        child: new Text(S.of(context).wallet_manage),
                                      ),
                                      new FlatButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: new Text(S.of(context).close),
                                      ),
                                    ],
                                  );
                          });
                    } else {
                      showModalBottomSheet(
                          context: context,
                          builder: (ctx) {
                            return Wrap(
                              children: <Widget>[
                                ListTile(
                                  leading: Image(
                                    image: AssetImage('res/drawable/hyn_logo.png'),
                                    height: 24,
                                    width: 24,
                                  ),
                                  title: Text(S.of(context).transfer_in_hyn),
                                  onTap: () {
                                    Navigator.pop(ctx);
                                    _transferToken(context, 'HYN');
                                  },
                                ),
                                ListTile(
                                  leading: Image(
                                    image: AssetImage('res/drawable/usdt_logo.png'),
                                    height: 24,
                                    width: 24,
                                  ),
                                  title: Text(S.of(context).transfer_in_usdt),
                                  onTap: () {
                                    Navigator.pop(ctx);
                                    _transferToken(context, 'USDT');
                                  },
                                ),
                                ListTile(
                                  leading: Icon(
                                    Icons.close,
                                  ),
                                  title: Text(S.of(context).close),
                                  onTap: () {
                                    Navigator.pop(ctx);
                                  },
                                ),
                              ],
                            );
                          });
                    }
                  },
                  child: SizedBox(
                    height: 48,
                    width: 192,
                    child: Center(
                      child: Text(
                        S.of(context).by_hyn_transfer,
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
                    var ret = await service.confirmRechargeV2(userInfo.balance);
                    if (ret.code == 0) {
                      Fluttertoast.showToast(msg: S.of(context).recharge_success_hint);
                      Navigator.pop(context, true);
                    } else {
                      if (ret.code == -1007) {
                        Fluttertoast.showToast(msg: S.of(context).over_limit_amount_hint);
                      } else {
                        Fluttertoast.showToast(msg: S.of(context).no_transfer_info_hint);
                      }
                    }
                  },
                  child: SizedBox(
                    height: 48,
                    width: 192,
                    child: Center(
                      child: Text(
                        S.of(context).out_wallet_transfer_hint,
                        textAlign: TextAlign.center,
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
          margin: EdgeInsets.only(top: 8, right: 8),
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.notification_important,
                  color: Color(0xFFCE9D40),
                  size: 20,
                ),
              ),
              Expanded(
                child: Text(
                  S.of(context).transfer_warning_hint,
                  style: TextStyle(color: Color(0xFFCE9D40), fontSize: 13),
                  softWrap: true,
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  void _transferToken(BuildContext context, String symbol) {
    var coinVo = WalletInheritedModel.of(context, aspect: WalletAspect.activatedWallet).getCoinVoBySymbol(symbol);
    if (coinVo != null) {
      var route = ModalRoute.of(context);
      var routeName = Uri.encodeComponent(route.settings?.name?.split('?')[0] ?? '');
      Application.router
          .navigateTo(
              context,
              Routes.wallet_account_send_transaction +
                  '?coinVo=${FluroConvertUtils.object2string(coinVo.toJson())}&entryRouteName=$routeName&toAddress=${userEthAddress.address}')
          .then((_) {
        final arguments = ModalRoute.of(context).settings.arguments as Map;
        final result = arguments['result'];
        if (result == true) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => RechargeByTitanFinishPage()));
        }
      });
    }
//    Navigator.push(
//        context,
//        MaterialPageRoute(
//            builder: (context) => WalletSendPage(null,
//                receiverAddress: userEthAddress.address,
//                symbol: symbol,
//                backRouteName: "/recharge_purchase_page"))).then((value) {
//      if (isRechargeByTianWalletFinish) {
//        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => RechargeByTitanFinishPage()));
//      }
//    });
  }
}
