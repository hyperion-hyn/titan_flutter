import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/wallet/coin_market_api.dart';
import 'package:titan/src/components/wallet/model.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/components/wallet/vo/symbol_quote_vo.dart';
import 'package:titan/src/pages/wallet/service/account_transfer_service.dart';
import 'package:titan/src/pages/wallet/wallet_show_account_info_page.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/plugins/wallet/token.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/utils/utils.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';

import 'api/hyn_api.dart';
import 'model/transtion_detail_vo.dart';
import 'package:titan/src/widget/all_page_state/all_page_state.dart';
import 'package:titan/src/widget/all_page_state/all_page_state_container.dart';
import 'package:titan/src/utils/log_util.dart';

class WalletShowAccountDetailPage extends StatefulWidget {
  final TransactionDetailVo transactionDetail;
  final bool isContain;

  WalletShowAccountDetailPage(this.transactionDetail, {this.isContain = false});

  @override
  State<StatefulWidget> createState() {
    return WalletShowAccountDetailPageState();
  }
}

class WalletShowAccountDetailPageState extends BaseState<WalletShowAccountDetailPage> {
  AllPageState _currentState = LoadingState();
  List<String> _dataTitleList = [];
  List<String> _dataInfoList = [];
  List<AccountDetailItemView> _accountDetailViewList = [];
  CoinMarketApi _coinMarketApi = CoinMarketApi();
  var gasEstimateQuote;
  var hynPrice = "\$0";
  var inputData = "";
  var hasDecodeData = false;
  var selectLeftData = true;
  var isContract = false;

  get _toHynAddress {
    var ethAddress = HYNApi.getHynToAddress(widget.transactionDetail);
    var toAddress = WalletUtil.ethAddressToBech32Address(ethAddress);
    return toAddress;
  }

  get _toEthAddress {
    var ethAddress = HYNApi.getHynToAddress(widget.transactionDetail);
    return widget.isContain ? ethAddress : '';
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void onCreated() {
    getNetworkData();
    super.onCreated();
  }

  void getNetworkData() async {
    try {
      var transDetail = widget.transactionDetail;

      if (transDetail.dataDecoded == null) {
        hasDecodeData = false;
      } else {
        hasDecodeData = true;
      }
      inputData = transDetail.data;

      isContract = (transDetail.internalTransactions != null && transDetail.internalTransactions.length != 0);

      print("[widget.isContain] ${widget.isContain}");
      var fromAddressTitle = HYNApi.toAddressHint(transDetail.hynType, true);
      var toAddressTitle = HYNApi.toAddressHint(transDetail.hynType, false);

      var amountText = "${HYNApi.getValueByHynType(
        transDetail.hynType,
        transactionDetail: transDetail,
        getAmountStr: true,
        isWallet: true,
      )}";
      var gasPriceGwei = ConvertTokenUnit.weiToGWei(weiBigInt: BigInt.parse(transDetail.gasPrice));
      var gasPriceWithHyn = ConvertTokenUnit.weiToEther(weiBigInt: BigInt.parse(transDetail.gasPrice));
      var gasPriceStr = "$gasPriceWithHyn Hyn ($gasPriceGwei Gdust)";

      var gasLimit = Decimal.parse(transDetail.gasUsed);
      var gasPriceEth = ConvertTokenUnit.weiToEther(weiBigInt: BigInt.parse(transDetail.gasPrice));
      var gasEstimate = "${gasPriceEth * gasLimit} HYN";

      var statusStr = "";
      var timeStr = FormatUtil.formatDate(transDetail.time, isSecond: true, isMillisecond: true);
      var hynPriceStr = "\$0 / HYN";
      var gasUsedStr =
          "${transDetail.gasUsed} (${FormatUtil.formatPercent((Decimal.parse(transDetail.gasUsed) / Decimal.parse(transDetail.gas)).toDouble())})";
      var typeStr = HYNApi.getValueByHynType(
        transDetail.hynType,
        getTypeStr: true,
        creatorAddress: transDetail.fromAddress,
        isWallet: true,
      );

      var timestamp = 0;
      var netAmountText;
      var netHynPrice;
      if (transDetail.time != null && transDetail.time.toString().length >= 10) {
        timestamp = int.parse(transDetail.time.toString().substring(0, 10));
      }
      var quotes = await _coinMarketApi.quotes(timestamp);
      SymbolQuoteVo hynQuote;
      var quotesSign = WalletInheritedModel.of(context).activeQuotesSign;
      for (var quoteItem in quotes) {
        if (quoteItem.symbol == SupportedTokens.HYN_Atlas.symbol && quoteItem.quote == quotesSign.quote) {
          hynQuote = quoteItem;
        }
      }
      if (hynQuote != null) {
        var tempAmountText = amountText;
        if (tempAmountText.contains("-") || tempAmountText.contains("+")) {
          tempAmountText = tempAmountText.substring(1);
        }
        if (tempAmountText.contains(",")) {
          tempAmountText = tempAmountText.replaceAll(",", "");
        }

        var amountQuote = Decimal.parse(tempAmountText) * Decimal.parse(hynQuote.price.toString());
        amountText =
            "${FormatUtil.stringFormatCoinNum(tempAmountText)} HYN (${quotesSign.sign}${FormatUtil.truncateDecimalNum(amountQuote, 4)})";
        gasEstimateQuote = "(${(gasPriceEth * gasLimit) * Decimal.parse(hynQuote.price.toString())})";
        hynPrice =
            "${quotesSign.sign}${FormatUtil.truncateDecimalNum(Decimal.parse(hynQuote.price.toString()), 4)} / HYN";

        netAmountText = amountText;
        netHynPrice = hynPrice;
      }

      _accountDetailViewList.add(AccountDetailItemView(
        AccountDetailType.TEXT_COPY,
        S.of(context).transfer_hash,
        rightStr: transDetail.hash,
      ));
      _accountDetailViewList.add(AccountDetailItemView(
        AccountDetailType.TEXT_STATUS,
        S.of(context).transfer_status,
        transactionDetailVo: transDetail,
      ));
      _accountDetailViewList.add(AccountDetailItemView(
        AccountDetailType.TEXT_TEXT,
        S.of(context).tx_age,
        rightStr: "${transDetail.epoch}",
      ));
      _accountDetailViewList.add(AccountDetailItemView(
        AccountDetailType.TEXT_TEXT,
        "${S.of(context).tx_block}:",
        rightStr: "${transDetail.blockNum}",
      ));
      _accountDetailViewList.add(AccountDetailItemView(
        AccountDetailType.TEXT_TIME,
        "${S.of(context).tx_time}:",
        rightStr: timeStr,
      ));

      var fromTitle = widget.isContain ? "$fromAddressTitle:" : "${S.of(context).tx_from_address}:";
      _accountDetailViewList.add(AccountDetailItemView(
        AccountDetailType.TEXT_COPY,
        fromTitle,
        rightStr: WalletUtil.ethAddressToBech32Address(transDetail.fromAddress),
      ));

      _accountDetailViewList.add(AccountDetailItemView(
        AccountDetailType.TEXT_COPY,
        "$toAddressTitle:",
        rightStr: _toHynAddress,
      ));

      if (widget.isContain) {
        _accountDetailViewList.add(AccountDetailItemView(
          AccountDetailType.TEXT_COPY,
          "${S.of(context).tx_to_address}（原以太链0X开头）:",
          rightStr: _toEthAddress,
        ));
      }

      if (isContract) {
        _accountDetailViewList.add(AccountDetailItemView(
          AccountDetailType.TEXT_INSIDE_TRANSFER,
          S.of(context).amount_transfer,
          transactionDetailVo: transDetail,
        ));
      }

      _accountDetailViewList.add(AccountDetailItemView(
        AccountDetailType.TEXT_TEXT,
        "${S.of(context).tx_amount}:",
        rightStr: netAmountText ?? amountText,
      ));
      _accountDetailViewList.add(AccountDetailItemView(
        AccountDetailType.TEXT_TEXT,
        "${S.of(context).transfer_gas_fee}:",
        rightStr: gasEstimate,
      ));
      _accountDetailViewList.add(AccountDetailItemView(
        AccountDetailType.TEXT_TEXT,
        "${S.of(context).gas_price}:",
        rightStr: gasPriceStr,
      ));
      _accountDetailViewList.add(AccountDetailItemView(
        AccountDetailType.TEXT_TEXT,
        "HYN${S.of(context).price}:",
        rightStr: netHynPrice ?? hynPriceStr,
      ));
      _accountDetailViewList.add(AccountDetailItemView(
        AccountDetailType.TEXT_TEXT,
        "${S.of(context).gas_limit}:",
        rightStr: transDetail.gas,
      ));
      _accountDetailViewList.add(AccountDetailItemView(
        AccountDetailType.TEXT_TEXT,
        "${S.of(context).transaction_gas_fee}:",
        rightStr: gasUsedStr,
      ));
      _accountDetailViewList.add(AccountDetailItemView(
        AccountDetailType.TEXT_TWO_RIGHT,
        S.of(context).random_number,
        rightStr: transDetail.nonce,
        transactionDetailVo: transDetail,
      ));
      _accountDetailViewList.add(AccountDetailItemView(
        AccountDetailType.TEXT_TEXT,
        "${S.of(context).tx_type}:",
        rightStr: typeStr,
      ));
      _accountDetailViewList.add(AccountDetailItemView(
        AccountDetailType.TEXT_DECODE_VIEW,
        "${S.of(context).tx_input_data}:",
        transactionDetailVo: transDetail,
      ));

      setState(() {
        _currentState = null;
      });
    } catch (e) {
      LogUtil.toastException(e);

      setState(() {
        _currentState = LoadFailState();
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentState != null || _accountDetailViewList.length == 0) {
      return Scaffold(
        appBar: BaseAppBar(baseTitle: "Hynscan"),
        body: AllPageStateContainer(_currentState, () {
          setState(() {
            _currentState = LoadingState();
          });
          getNetworkData();
        }),
      );
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: BaseAppBar(baseTitle: "Hynscan"),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
            var accountViewItem = _accountDetailViewList[index];
            switch (accountViewItem.type) {
              case AccountDetailType.TEXT_COPY:
                return accountInfoItem(accountViewItem, hasCopy: true);
              case AccountDetailType.TEXT_STATUS:
                var isFail = (widget.transactionDetail.state == 4 || widget.transactionDetail.state == 5);
                return accountInfoItemStatus(accountViewItem, isFail);
              case AccountDetailType.TEXT_TEXT:
                return accountInfoItem(accountViewItem);
              case AccountDetailType.TEXT_TIME:
                return accountInfoItem(accountViewItem, isTime: true);
              case AccountDetailType.TEXT_INSIDE_TRANSFER:
                return accountContractItem(accountViewItem);
              case AccountDetailType.TEXT_TWO_RIGHT:
                return accountInfoItemTwoRight(accountViewItem);
              case AccountDetailType.TEXT_DECODE_VIEW:
                return inputDataView(accountViewItem);
            }
            return null;
          }, childCount: _accountDetailViewList.length))
        ],
      ),
    );
  }

  Widget accountInfoItemStatus(AccountDetailItemView accountDetailItemView, bool isFail) {
    var infoItemTitle;
    Color accountItemColor;
    var accountItemImage = "res/drawable/ic_transfer_account_detail_pending.png";
    getAccountPageTitle(context, widget.transactionDetail,
        (pageTitle, pageStatusImage, pageDetailColor, pageDetailStatusImage) {
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
                  accountDetailItemView.leftStr,
                  style: TextStyles.textC333S13,
                ),
                Spacer(),
                Container(
                  padding: const EdgeInsets.only(top: 4.0, bottom: 4, left: 11, right: 11),
                  decoration:
                      BoxDecoration(color: accountItemColor, borderRadius: BorderRadius.all(Radius.circular(4))),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Image.asset(
                          accountItemImage,
                          width: 13,
                          height: 13,
                        ),
                      ),
                      SizedBox(
                        width: 2,
                      ),
                      Text(
                        infoItemTitle,
                        style: TextStyle(color: DefaultColors.color333, fontSize: 13, fontWeight: FontWeight.bold),
                      )
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

  Widget accountContractItem(
    AccountDetailItemView accountDetailItemView,
  ) {
    var contractList = List.generate(widget.transactionDetail.internalTransactions.length, (index) {
      var contractItem = widget.transactionDetail.internalTransactions[index];
      return Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 18.0, bottom: 18, left: 15, right: 15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  accountDetailItemView.leftStr,
                  style: TextStyles.textC333S13,
                ),
                Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    RichText(
                      text: TextSpan(
                          text: "${S.of(context).exchange_from} ",
                          style: TextStyle(color: DefaultColors.color999, fontSize: 13),
                          children: [
                            TextSpan(
                              text:
                                  "${shortBlockChainAddress(WalletUtil.ethAddressToBech32Address(contractItem.from))}\n",
                              style:
                                  TextStyle(color: DefaultColors.color333, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                                text: "${S.of(context).exchange_to} ",
                                style: TextStyle(color: DefaultColors.color999, fontSize: 13)),
                            TextSpan(
                              text: "${shortBlockChainAddress(WalletUtil.ethAddressToBech32Address(contractItem.to))}",
                              style:
                                  TextStyle(color: DefaultColors.color333, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ]),
                    ),
                    Text(
                      "${ConvertTokenUnit.weiToEther(weiBigInt: BigInt.parse(contractItem.value))} ${HYNApi.getHynSymbol(contractItem.contractAddress)}",
                      style: TextStyle(color: DefaultColors.color333, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ],
                )
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
      );
    }).toList();

    return Container(
      child: Column(
        children: contractList,
      ),
    );
  }

  Widget accountInfoItem(AccountDetailItemView accountDetailItemView,
      {String bottomText, bool hasCopy = false, bool isTime = false, bool hasSubTitle = false}) {
    return Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 18.0, bottom: 18, left: 15, right: 15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                hasCopy
                    ? Expanded(
                        flex: 2,
                        child: Text(
                          accountDetailItemView.leftStr,
                          style: TextStyles.textC333S13,
                        ),
                      )
                    : Text(
                        accountDetailItemView.leftStr,
                        style: TextStyles.textC333S13,
                      ),
                if (hasSubTitle)
                  Padding(
                    padding: const EdgeInsets.only(left: 6.0),
                    child: Text(
                      S.of(context).transaction_location,
                      style: TextStyles.textC999S13,
                    ),
                  ),
                Spacer(),
                Container(
                  width: 204,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      if (isTime)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(right: 2.0),
                              child: Image.asset(
                                "res/drawable/ic_transfer_account_detail_time.png",
                                width: 13,
                                height: 13,
                              ),
                            ),
                            Text(
                              accountDetailItemView.rightStr,
                              style:
                                  TextStyle(color: DefaultColors.color333, fontSize: 13, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.end,
                              maxLines: 2,
                            ),
                          ],
                        ),
                      if (!isTime)
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                accountDetailItemView.rightStr ?? "",
                                style:
                                    TextStyle(color: DefaultColors.color333, fontSize: 13, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.end,
                              ),
                            ),
                            if (hasSubTitle)
                              Padding(
                                padding: const EdgeInsets.only(left: 11.0),
                                child: Text(
                                  "${widget.transactionDetail.transactionIndex}",
                                  style: TextStyles.textC999S13,
                                ),
                              ),
                          ],
                        ),
                      if (hasCopy)
                        InkWell(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: accountDetailItemView.rightStr));
                            UiUtil.toast(S.of(context).copyed);
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(top: 7.0, left: 7, bottom: 7),
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

  Widget accountInfoItemTwoRight(AccountDetailItemView accountDetailItemView,) {
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
                  accountDetailItemView.leftStr,
                  style: TextStyles.textC333S13,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 6.0),
                  child: Text(
                    S.of(context).transaction_location,
                    style: TextStyles.textC999S13,
                  ),
                ),
                Spacer(),
                Text(
                  accountDetailItemView.rightStr ?? "",
                  style:
                  TextStyle(color: DefaultColors.color333, fontSize: 13, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.end,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 11.0),
                  child: Text(
                    "${widget.transactionDetail.transactionIndex}",
                    style: TextStyles.textC999S13,
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

  Widget inputDataView(
    AccountDetailItemView accountDetailItemView,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 14, right: 14, top: 17, bottom: 17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            accountDetailItemView.leftStr,
            style: TextStyles.textC333S13,
          ),
          Container(
            margin: const EdgeInsets.only(top: 13.0, bottom: 11),
            padding: const EdgeInsets.only(top: 11.0, bottom: 11, left: 15, right: 15),
            height: 145,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(6)),
              color: DefaultColors.colorf2f2f2,
            ),
            child: SingleChildScrollView(child: Text(inputData)),
          ),
          if (hasDecodeData)
            Row(
              children: <Widget>[
                ClickOvalButton(
                  S.of(context).origin,
                  () {
                    selectLeftData = true;
                    inputData = widget.transactionDetail.data;
                    setState(() {});
                  },
                  width: 112,
                  btnColor: [HexColor(selectLeftData ? "#1F81FF" : "#F2F2F2")],
                  radius: 4,
                  fontColor: HexColor(selectLeftData ? "#ffffff" : "#999999"),
                ),
                SizedBox(
                  width: 11,
                ),
                ClickOvalButton(
                  S.of(context).decoded,
                  () {
                    selectLeftData = false;
                    inputData = json.encode(widget.transactionDetail.dataDecoded);
                    setState(() {});
                  },
                  width: 112,
                  btnColor: [HexColor(selectLeftData ? "#F2F2F2" : "#1F81FF")],
                  radius: 4,
                  fontColor: HexColor(selectLeftData ? "#999999" : "#ffffff"),
                ),
              ],
            )
        ],
      ),
    );
  }
}

enum AccountDetailType {
  TEXT_COPY,
  TEXT_STATUS,
  TEXT_TEXT,
  TEXT_TIME,
  TEXT_INSIDE_TRANSFER,
  TEXT_TWO_RIGHT,
  TEXT_DECODE_VIEW
}

class AccountDetailItemView {
  AccountDetailType type;
  String leftStr;
  String rightStr;
  TransactionDetailVo transactionDetailVo;

  AccountDetailItemView(this.type, this.leftStr, {this.rightStr, this.transactionDetailVo});
}
