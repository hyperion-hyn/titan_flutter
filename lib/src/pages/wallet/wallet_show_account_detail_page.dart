import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/quotes/coin_market_api.dart';
import 'package:titan/src/components/quotes/model.dart';
import 'package:titan/src/components/quotes/quotes_component.dart';
import 'package:titan/src/components/quotes/vo/symbol_quote_vo.dart';
import 'package:titan/src/pages/wallet/service/account_transfer_service.dart';
import 'package:titan/src/pages/wallet/wallet_show_account_info_page.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/plugins/wallet/token.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';

import 'api/hyn_api.dart';
import 'model/transtion_detail_vo.dart';

class WalletShowAccountDetailPage extends StatefulWidget {
  final TransactionDetailVo transactionDetail;

  WalletShowAccountDetailPage(this.transactionDetail);

  @override
  State<StatefulWidget> createState() {
    return WalletShowAccountDetailPageState();
  }
}

class WalletShowAccountDetailPageState extends BaseState<WalletShowAccountDetailPage> {
  List<String> _dataTitleList = [];
  List<String> _dataInfoList = [];
  CoinMarketApi _coinMarketApi = CoinMarketApi();
  var gasEstimateQuote;
  var hynPrice = "\$0";
  var inputData = "";
  var hasDefaultData = false;
  var selectDefault = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void onCreated() async {
    _dataTitleList = [
      "转账Hash:",
      "状态:",
      "纪元:",
      "区块:",
      "时间:",
      "付款地址:",
      "收款地址:",
      "金额:",
      "矿工费:",
      "Gas Price:",
      "HYN价格:",
      "Gas Limit:",
      "Gas Used:",
      "Nonce",
      "类型",
      "输入数据:",
    ];

    var transDetail = widget.transactionDetail;
    var amountText = "${HYNApi.getValueByHynType(transDetail.hynType, transactionDetail: transDetail, getAmountStr: true, formatComma: false)}";
    /*var amountText = "";
    if (transDetail.type == TransactionType.TRANSFER_IN) {
      amountText = '+${FormatUtil.strClearZero(transDetail.amount.toString())} HYN';
    } else if (transDetail.type == TransactionType.TRANSFER_OUT) {
      amountText = '-${FormatUtil.strClearZero(transDetail.amount.toString())} HYN';
    }*/
    var gasPriceGwei = ConvertTokenUnit.weiToGWei(weiBigInt: BigInt.parse(transDetail.gasPrice));
    var gasPriceWithHyn = ConvertTokenUnit.weiToEther(weiBigInt: BigInt.parse(transDetail.gasPrice));
    var gasPriceStr = "$gasPriceWithHyn Hyn ($gasPriceGwei Gdust)";

    var gasLimit = Decimal.parse(transDetail.gas);
    var gasPriceEth = ConvertTokenUnit.weiToEther(weiBigInt: BigInt.parse(transDetail.gasPrice));
    var gasEstimate = "${gasPriceEth * gasLimit} HYN";

    var statusStr = "";
    var timeStr = FormatUtil.formatDate(widget.transactionDetail.time, isSecond: true, isMillisecond: true);
    var hynPriceStr = "\$0 / HYN";
    var gasUsedStr = "${transDetail.gasUsed} (${FormatUtil.formatPercent(
        (Decimal.parse(transDetail.gasUsed) / Decimal.parse(transDetail.gas)).toDouble())})";
    var typeStr = HYNApi.getValueByHynType(transDetail.hynType,getTypeStr: true);

    _dataInfoList = [
      transDetail.hash,
      statusStr,
      "${transDetail.epoch}",
      "${transDetail.blockNum}",
      timeStr,
      WalletUtil.ethAddressToBech32Address(transDetail.fromAddress),
      WalletUtil.ethAddressToBech32Address(HYNApi.getHynToAddress(transDetail)),
      amountText,
      gasEstimate,
      gasPriceStr,
      hynPriceStr,
      transDetail.gas,
      gasUsedStr,
      transDetail.nonce,
      typeStr
    ];

    var timestamp = 0;
    if(transDetail.time != null && transDetail.time.toString().length >= 10){
      timestamp = int.parse(transDetail.time.toString().substring(0,10));
    }

    if(transDetail.dataDecoded == null){
      hasDefaultData = false;
      selectDefault = false;
      inputData = transDetail.data;
    } else {
      hasDefaultData = true;
      selectDefault = true;
      inputData = json.encode(transDetail.dataDecoded);
    }

    var quotes = await _coinMarketApi.quotes(timestamp);
    SymbolQuoteVo hynQuote;
    var quotesSign = QuotesInheritedModel.of(context).activeQuotesSign;
    for(var quoteItem in quotes){
      if(quoteItem.symbol == SupportedTokens.HYN_Atlas.symbol && quoteItem.quote == quotesSign.quote){
        hynQuote = quoteItem;
      }
    }
    if(hynQuote != null){
      var tempAmountText = amountText;
      if(tempAmountText.contains("-") || tempAmountText.contains("+")){
        tempAmountText = tempAmountText.substring(1);
        tempAmountText = tempAmountText.replaceAll(",", "");
      }

      var amountQuote = Decimal.parse(tempAmountText) * Decimal.parse(hynQuote.price.toString());
      amountText = "${FormatUtil.stringFormatCoinNum(tempAmountText)} (${quotesSign.sign}$amountQuote)";
      gasEstimateQuote = "(${(gasPriceEth * gasLimit) * Decimal.parse(hynQuote.price.toString())})";
      hynPrice = "${quotesSign.sign}${hynQuote.price} / HYN";

      _dataInfoList[7] = amountText;
      _dataInfoList[10] = hynPrice;
      setState(() {
      });
    }

    super.onCreated();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: BaseAppBar(baseTitle: "Hynscan"),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                var leftText = _dataTitleList[index];
                if(index == 0
                    || index == 5
                    || index == 6){
                  var rightText = _dataInfoList[index];
                  return accountInfoItem(leftText, rightText,hasCopy: true);
                }else if(index == 1){
                  var rightText = _dataInfoList[index];
                  var isFail = (widget.transactionDetail.state == 4 || widget.transactionDetail.state == 5);
                  return accountInfoItemStatus(leftText, rightText,isFail);
                }else if(index == 4){
                  var rightText = _dataInfoList[index];
                  return accountInfoItem(leftText, rightText,isTime: true);
                }else if(index == 13){
                  var rightText = _dataInfoList[index];
                  return accountInfoItem(leftText, rightText,hasSubTitle: true);
                }else if(index == 15){
                  return inputDataView(leftText);
                }else{
                  var rightText = _dataInfoList[index];
                  return accountInfoItem(leftText, rightText);
                }
          }, childCount: _dataTitleList.length))
        ],
      ),
    );
  }

  Widget accountInfoItemStatus(String leftText, String rightText,bool isFail){
    var infoItemTitle;
    Color accountItemColor;
    var accountItemImage = "res/drawable/ic_transfer_account_detail_pending.png";
    getAccountPageTitle(context,widget.transactionDetail,(pageTitle,pageStatusImage,pageDetailColor,pageDetailStatusImage){
      infoItemTitle = pageTitle;
      accountItemColor = pageDetailColor;
      accountItemImage = pageDetailStatusImage;
    });
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
                  style: TextStyles.textC333S13,
                ),
                Spacer(),
                Container(
                  padding: const EdgeInsets.only(top: 4.0, bottom: 4, left: 11, right: 11),
                  decoration: BoxDecoration(
                    color: accountItemColor,
                    borderRadius: BorderRadius.all(Radius.circular(4))
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top:2.0),
                        child: Image.asset(accountItemImage,width: 13,height: 13,),
                      ),
                      SizedBox(width: 2,),
                      Text(infoItemTitle,style: TextStyle(color: DefaultColors.color333, fontSize: 13, fontWeight: FontWeight.bold),)
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(
            color: DefaultColors.colorf2f2f2,
            indent: 15,
            endIndent: 15,
            height: 1,
          ),
        ],
      ),
    );
  }

  Widget accountInfoItem(String leftText, String rightText, {String bottomText, bool hasCopy = false,bool isTime = false,bool hasSubTitle = false}) {
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
                  style: TextStyles.textC333S13,
                ),
                if(hasSubTitle)
                  Padding(
                    padding: const EdgeInsets.only(left:6.0),
                    child: Text(
                      "Position",
                      style: TextStyles.textC999S13,
                    ),
                  ),
                Spacer(),
                Container(
                  width: 228,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      if(isTime)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(right:2.0),
                              child: Image.asset(
                                "res/drawable/ic_transfer_account_detail_time.png",
                                width: 13,
                                height: 13,
                              ),
                            ),
                            Text(
                              rightText,
                              style: TextStyle(color: DefaultColors.color333, fontSize: 13, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.end,
                            ),
                          ],
                        ),
                      if(!isTime)
                        Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              rightText??"",
                              style: TextStyle(color: DefaultColors.color333, fontSize: 13, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.end,
                            ),
                          ),
                          if(hasSubTitle)
                            Padding(
                              padding: const EdgeInsets.only(left:11.0),
                              child: Text(
                                "${widget.transactionDetail.transactionIndex}",
                                style: TextStyles.textC999S13,
                              ),
                            ),
                        ],
                      ),
                      if (hasCopy)
                        InkWell(
                          onTap: (){
                            Clipboard.setData(ClipboardData(text: rightText));
                            UiUtil.toast(S.of(context).copyed);
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(top: 7.0,left: 7,bottom: 7),
                            child: Image.asset(
                              "res/drawable/ic_copy.png",
                              width: 18,
                              height: 17,
                            ),
                          ),
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
          Divider(
            color: DefaultColors.colorf2f2f2,
            indent: 15,
            endIndent: 15,
            height: 1,
          ),
        ],
      ),
    );
  }
  
  Widget inputDataView(String leftText){
    return Padding(
      padding: const EdgeInsets.only(left:14,right: 14,top: 17,bottom: 17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            leftText,
            style: TextStyles.textC333S13,
          ),
          Container(
            margin: const EdgeInsets.only(top: 13.0,bottom: 11),
            padding: const EdgeInsets.only(top: 11.0,bottom: 11,left: 15,right: 15),
            height: 145,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(6)),
              color: DefaultColors.colorf2f2f2,
            ),
            child: SingleChildScrollView(child: Text(inputData)),
          ),
          if(hasDefaultData)
            Row(
            children: <Widget>[
              ClickOvalButton("Origi",(){
                selectDefault = false;
                inputData = widget.transactionDetail.data;
                setState(() {

                });
              },width: 112,btnColor: HexColor(selectDefault ? "#F2F2F2" : "#1F81FF"),radius: 4,fontColor: HexColor(selectDefault ? "#999999" : "#ffffff"),),
              SizedBox(width: 11,),
                ClickOvalButton("Decoded",(){
                  selectDefault = true;
                  inputData = json.encode(widget.transactionDetail.dataDecoded);
                  setState(() {

                  });
                },width: 112,btnColor: HexColor(selectDefault ? "#1F81FF" : "#F2F2F2"),radius: 4,fontColor: HexColor(selectDefault ? "#ffffff" : "#999999"),),
            ],
          )
        ],
      ),
    );
  }
  
}
