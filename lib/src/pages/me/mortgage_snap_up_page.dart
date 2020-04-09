import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/pages/me/components/account/account_component.dart';
import 'package:titan/src/pages/me/my_node_mortgage_page.dart';
import 'package:titan/src/pages/me/recharge_purchase_page.dart';
import 'package:titan/src/pages/me/service/user_service.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/global.dart';

import 'enter_fund_password.dart';
import 'model/mortgage_info_v2.dart';

class MortgageSnapUpPage extends StatefulWidget {
  final MortgageInfoV2 mortgageInfo;

  MortgageSnapUpPage(this.mortgageInfo);

  @override
  State<StatefulWidget> createState() {
    return _MortgageSnapUpPageState();
  }
}

class _MortgageSnapUpPageState extends State<MortgageSnapUpPage> {
  var service = UserService();

//  UserInfo userInfo;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    await UserService.syncUserInfo(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
//        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          S.of(context).snap_up,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: <Widget>[
            Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: <Widget>[
                      Text(
                        S.of(context).snap_up_product_fuc('${widget.mortgageInfo.name}'),
                        style: TextStyle(color: Color(0xFF252525), fontSize: 16),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: <Widget>[
                    Text(
                      "${S.of(context).amount}${Const.DOUBLE_NUMBER_FORMAT.format(widget.mortgageInfo.amount)} USDT",
                      style: TextStyle(color: Color(0xFF252525), fontSize: 16),
                    ),
                  ],
                )
              ],
            ),
            SizedBox(height: 16),
            _buildBalancePayBox(),
          ],
        ),
      ),
    );
  }

  Widget _buildBalancePayBox() {
    var userInfo = AccountInheritedModel.of(context, aspect: AccountAspect.userInfo).userInfo;
    return Column(
      children: <Widget>[
        Material(
          elevation: 3,
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            alignment: Alignment.topCenter,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        S.of(context).need_transfer,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Text(
                          '${Const.DOUBLE_NUMBER_FORMAT.format(widget.mortgageInfo?.amount ?? 0)} USDT',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Color(0xFFCE9D40)),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        '${S.of(context).becharge_amount}：',
                        style: TextStyle(color: Color(0xFF9B9B9B), fontSize: 13),
                      ),
                      Text(
                        "${Const.DOUBLE_NUMBER_FORMAT.format(userInfo?.chargeHynBalance ?? 0)} USDT",
                        style: TextStyle(fontSize: 16, color: Color(0xFF9B9B9B)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 32,
        ),
        if (userInfo.chargeHynBalance < widget.mortgageInfo.amount)
          Container(
            padding: EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  S.of(context).balance_lack,
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
                        .then((value) {
                      if (value == null || value == false) {
                        return;
                      }
                      UserService.syncUserInfo(context);
                    });
                  },
                  child: Text(
                    S.of(context).click_charge,
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        RaisedButton(
          elevation: 1,
          color: Theme.of(context).primaryColor,
          onPressed: () async {
            if (widget.mortgageInfo != null && userInfo != null) {
              if (userInfo.chargeHynBalance < widget.mortgageInfo.amount) {
                Fluttertoast.showToast(msg: S.of(context).balance_lack);
              } else {
                showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    builder: (BuildContext context) {
                      return EnterFundPasswordWidget();
                    }).then((value) async {
                  if (value == null) {
                    return;
                  }
                  try {
                    await service.mortgageSnapUp(confId: widget.mortgageInfo.id, fundToken: value);
                    Fluttertoast.showToast(msg: S.of(context).snap_up_success_hint);
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyNodeMortgagePage()));
                  } catch (e) {
                    logger.e(e);
                    Fluttertoast.showToast(msg: S.of(context).snap_up_fail);
                  }
                });
              }
            }
          },
          child: SizedBox(
            width: 192,
            height: 56,
            child: Center(
              child: Text(
                S.of(context).confirm_snap_up,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 64.0),
          child: Text(
            S.of(context).tip_snap_up_balance_hint,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ],
    );
  }
}
