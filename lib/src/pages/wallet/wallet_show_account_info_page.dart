import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/pages/wallet/api/hyn_api.dart';
import 'package:titan/src/pages/wallet/service/account_transfer_service.dart';
import 'package:titan/src/pages/wallet/wallet_show_account_detail_page.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';

import 'model/transtion_detail_vo.dart';

class WalletShowAccountInfoPage extends StatefulWidget {
  final TransactionDetailVo transactionDetail;

  WalletShowAccountInfoPage(this.transactionDetail);

  @override
  State<StatefulWidget> createState() {
    return WalletShowAccountInfoPageState();
  }
}

class WalletShowAccountInfoPageState extends BaseState<WalletShowAccountInfoPage> {
  List<String> _dataTitleList = [];
  List<String> _dataInfoList = List();
  var gasPriceStr = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  void onCreated() {
    _dataTitleList = [
      "金额",
      "矿工费",
      "收款地址",
      "付款地址",
      "交易号",
    ];
    var transDetail = widget.transactionDetail;
    var amountText = "${HYNApi.getValueByHynType(transDetail.hynType, transactionDetail: transDetail, getAmountStr: true)}";
    /*var amountText = "";
    if (transDetail.type == TransactionType.TRANSFER_IN) {
      amountText = '+${FormatUtil.strClearZero(transDetail.amount.toString())} HYN';
    } else if (transDetail.type == TransactionType.TRANSFER_OUT) {
      amountText = '-${FormatUtil.strClearZero(transDetail.amount.toString())} HYN';
    }*/

    var gasPriceGwei = ConvertTokenUnit.weiToGWei(weiBigInt: BigInt.parse(transDetail.gasPrice));
    var gasPriceEth = ConvertTokenUnit.weiToEther(weiBigInt: BigInt.parse(transDetail.gasPrice));
    gasPriceStr = "$gasPriceGwei Gdust";
    var gasLimit = Decimal.parse(transDetail.gas);
    var gasEstimate = "${gasPriceEth * gasLimit} HYN";
    _dataInfoList = [amountText, gasEstimate, WalletUtil.ethAddressToBech32Address(HYNApi.getHynToAddress(transDetail)), WalletUtil.ethAddressToBech32Address(transDetail.fromAddress), transDetail.hash];
    super.onCreated();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var isFail = (widget.transactionDetail.state == 4 || widget.transactionDetail.state == 5);
    var imagePath =
        isFail ? "res/drawable/ic_transfer_account_info_fail.png" : "res/drawable/ic_transfer_account_info_success.png";
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: BaseAppBar(baseTitle: "详情"),
      body: Container(
        color: DefaultColors.colorf2f2f2,
        child: CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 18.0, bottom: 20),
                      child: Image.asset(
                        imagePath,
                        width: 63,
                        height: 63,
                      ),
                    ),
                    Text(
                      isFail ? "转账失败" : "转账成功",
                      style: TextStyle(fontSize: 16, color: DefaultColors.color333, fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0, bottom: 34),
                      child: Text(
                        FormatUtil.formatDate(widget.transactionDetail.time, isSecond: true, isMillisecond: true),
                        style: TextStyle(color: DefaultColors.color999, fontSize: 13),
                      ),
                    ),
                    Container(
                      height: 11,
                      color: DefaultColors.colorf2f2f2,
                    )
                  ],
                ),
              ),
            ),
            SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
              var leftText = _dataTitleList[index];
              var rightText = _dataInfoList[index];
              if (index == 1) {
                var bottomText = "GasPrice($gasPriceStr) * Gas(${widget.transactionDetail.gas})";
                return accountInfoItem(leftText, rightText, bottomText: bottomText);
              } else if (index == 4) {
                return accountInfoItem(leftText, rightText, normalLine: false);
              } else {
                return accountInfoItem(leftText, rightText);
              }
            }, childCount: _dataTitleList.length)),
            SliverToBoxAdapter(
              child: InkWell(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => WalletShowAccountDetailPage(widget.transactionDetail)));
                },
                child: Container(
                  color: Colors.white,
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 16, bottom: 16.0, left: 15),
                        child: Text(
                          "查看详细信息",
                          style: TextStyles.textC333S13,
                        ),
                      ),
                      Spacer(),
                      Image.asset(
                        "res/drawable/add_position_image_next.png",
                        height: 13,
                      ),
                      SizedBox(
                        width: 15,
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget accountInfoItem(String leftText, String rightText, {String bottomText, bool normalLine = true}) {
    return Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 18.0, bottom: 18, left: 15, right: 15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  leftText,
                  style: TextStyles.textC999S13,
                ),
                Spacer(),
                Container(
                  width: 198,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        rightText??"",
                        style: TextStyles.textC333S13,
                        textAlign: TextAlign.end,
                      ),
                      if (bottomText != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child: Text(bottomText, style: TextStyles.textC999S11, textAlign: TextAlign.end),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (normalLine)
            Divider(
              color: DefaultColors.colorf2f2f2,
              indent: 15,
              endIndent: 15,
              height: 1,
            ),
          if (!normalLine)
            Container(
              height: 11,
              color: DefaultColors.colorf2f2f2,
            )
        ],
      ),
    );
  }
}
