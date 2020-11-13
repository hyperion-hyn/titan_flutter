import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/wallet/api/hyn_api.dart';
import 'package:titan/src/pages/wallet/service/account_transfer_service.dart';
import 'package:titan/src/pages/wallet/wallet_show_account_detail_page.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:web3dart/web3dart.dart';

import 'model/transtion_detail_vo.dart';

class WalletShowAccountInfoPage extends StatefulWidget {
  final TransactionDetailVo transactionDetail;
  final bool isContain;

  WalletShowAccountInfoPage(this.transactionDetail, {this.isContain = false});

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

  get _toAddress {
    var ethAddress = HYNApi.getHynToAddress(widget.transactionDetail);
    //var toAddress = widget.isContain ? ethAddress : WalletUtil.ethAddressToBech32Address(ethAddress);
    return WalletUtil.ethAddressToBech32Address(ethAddress);
  }

  @override
  void onCreated() async {
    var fromAddressTitle = HYNApi.toAddressHint(widget.transactionDetail.hynType,true);
    var toAddressTitle = HYNApi.toAddressHint(widget.transactionDetail.hynType,false);

    _dataTitleList = [
      S.of(context).transfer_amount,
      S.of(context).transfer_gas_fee,
      fromAddressTitle,
      toAddressTitle,
      S.of(context).transfer_id,
    ];
    var transDetail = widget.transactionDetail;
    var amountText =
        "${HYNApi.getValueByHynType(transDetail.hynType, transactionDetail: transDetail, getAmountStr: true)}";
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

    _dataInfoList = [
      amountText,
      gasEstimate,
      _toAddress,
      WalletUtil.ethAddressToBech32Address(transDetail.fromAddress),
      transDetail.hash,
    ];
    super.onCreated();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var isFail = (widget.transactionDetail.state == 4 || widget.transactionDetail.state == 5);
    var infoItemTitle;
    var infoItemStatusImage;
    getAccountPageTitle(context, widget.transactionDetail,
        (pageTitle, pageStatusImage, pageDetailColor, pageDetailStatusImage) {
      infoItemTitle = pageTitle;
      infoItemStatusImage = pageStatusImage;
    });
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: BaseAppBar(baseTitle: S.of(context).detail),
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
                        infoItemStatusImage,
                        width: 63,
                        height: 63,
                      ),
                    ),
                    Text(
                      infoItemTitle,
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
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => WalletShowAccountDetailPage(
                                widget.transactionDetail,
                                isContain: widget.isContain,
                              )));
                },
                child: Container(
                  color: Colors.white,
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 16, bottom: 16.0, left: 15),
                        child: Text(
                          S.of(context).check_for_detail_info,
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
                        rightText ?? "",
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

void getAccountPageTitle(BuildContext context, TransactionDetailVo transactionDetail, Function function) {
  var pageTitle = "";
  var pageStatusImage = "";
  var pageDetailColor = HexColor("#22F2F2F2");
  var pageDetailStatusImage = "";
  if (transactionDetail.state == 1 || transactionDetail.state == 2) {
    pageTitle = S.of(context).pending;
    pageStatusImage = "res/drawable/ic_transfer_account_info_pending.png";

    pageDetailColor = HexColor("#22F2F2F2");
    pageDetailStatusImage = "res/drawable/ic_transfer_account_detail_pending.png";
  } else if (transactionDetail.state == 3) {
    if (transactionDetail.hynType == MessageType.typeNormal) {
      pageTitle = S.of(context).transfer_successful;
    } else {
      pageTitle = S.of(context).completed;
    }
    pageStatusImage = "res/drawable/ic_transfer_account_info_success.png";

    pageDetailColor = HexColor("#2207C160");
    pageDetailStatusImage = "res/drawable/ic_transfer_account_detail_success.png";
  } else if (transactionDetail.state == 4 || transactionDetail.state == 5) {
    if (transactionDetail.hynType == MessageType.typeNormal) {
      pageTitle = S.of(context).transfer_fail;
    } else {
      pageTitle = S.of(context).failed;
    }
    pageStatusImage = "res/drawable/ic_transfer_account_info_fail.png";

    pageDetailColor = HexColor("#22FF5E5E");
    pageDetailStatusImage = "res/drawable/ic_transfer_account_detail_fail.png";
  }
  function(pageTitle, pageStatusImage, pageDetailColor, pageDetailStatusImage);
}
