import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:titan/env.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/data_list_state.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/inject/injector.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/components/wallet/bloc/bloc.dart';
import 'package:titan/src/components/wallet/vo/coin_view_vo.dart';
import 'package:titan/src/components/wallet/vo/wallet_view_vo.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/domain/transaction_interactor.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_public_widget.dart';
import 'package:titan/src/pages/market/exchange_detail/exchange_detail_page.dart';
import 'package:titan/src/pages/market/order/entity/order.dart';
import 'package:titan/src/pages/wallet/api/hb_api.dart';
import 'package:titan/src/pages/wallet/tx_info_item.dart';
import 'package:titan/src/pages/webview/inappwebview.dart';
import 'package:titan/src/plugins/wallet/cointype.dart';
import 'package:titan/src/plugins/wallet/config/heco.dart';
import 'package:titan/src/plugins/wallet/config/tokens.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/pages/wallet/service/account_transfer_service.dart';
import 'package:titan/src/pages/wallet/wallet_receive_page.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/image_util.dart';
import 'package:titan/src/utils/log_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/utils/utils.dart';

import '../../pages/wallet/model/transtion_detail_vo.dart';
import 'api/hyn_api.dart';
import 'model/transaction_info_vo.dart';
import 'model/wallet_send_dialog_util.dart';

class ShowAccountHbPage extends StatefulWidget {
  CoinViewVo coinVo;

  ShowAccountHbPage(this.coinVo);

  @override
  State<StatefulWidget> createState() {
    return _ShowAccountHbPageState();
  }
}

class _ShowAccountHbPageState extends DataListState<ShowAccountHbPage> with RouteAware {
  DateFormat _dateFormat = new DateFormat("HH:mm MM/dd");

  AccountTransferService _accountTransferService = AccountTransferService();
  bool shouldRefresh = false;

  @override
  int getStartPage() {
    return 1;
  }

  @override
  void postFrameCallBackAfterInitState() async {
    loadDataBloc.add(LoadingEvent());
  }

  @override
  void onCreated() {

    _getDomain();
  }

  @override
  void didPopNext() {
    if (mounted && shouldRefresh) {
      shouldRefresh = false;
      // 手动帮刷新
      onWidgetRefreshCallback();
    }

    super.didPopNext();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    Application.routeObserver.subscribe(this, ModalRoute.of(context));
    widget.coinVo = WalletInheritedModel.of(context).getCoinVoBySymbolAndCoinType(
      widget.coinVo.symbol,
      widget.coinVo.coinType,
    );
  }

  String _lastMdexDomain = 'https://ht.mdex.co/#/swap?lang=en';
  void _getDomain() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var domain = 'https://ht.mdex.co/#/swap?lang=en';
    var last = prefs.getString(PrefsKey.lastMexDomain);
    _lastMdexDomain = last ?? domain;
    print("[Wallet]  _lastMdexDomain:$_lastMdexDomain");

    if (mounted) {
      setState(() {

      });
    }
  }

  @override
  void dispose() {
    Application.routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //activated quote sign
    var activeQuoteVoAndSign =
        WalletInheritedModel.of(context).tokenLegalPrice(widget.coinVo.symbol);

    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
          title: Text(
            "${widget.coinVo.name} (${widget.coinVo.symbol})",
            style: TextStyle(
              color: Colors.black,
              fontSize: 15,
            ),
          ),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                HbApi.jumpToScanByAddress(context, WalletModelUtil.walletEthAddress);
              },
              child: Text(
                '区块浏览器',
                style: TextStyle(
                  color: HexColor("#1F81FF"),
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
        body: BlocListener<WalletCmpBloc, WalletCmpState>(
          listener: (context, state) {
            //update WalletVo total balance
//            if (state is UpdatedWalletBalanceState) {
//              for (CoinVo coinVo in state.walletVo.coins) {
//                if (coinVo.contractAddress == widget.coinVo.contractAddress) {
//                  widget.coinVo = coinVo;
//                }
//              }
//            }
          },
          child: Container(
            color: Colors.white,
            child: LoadDataContainer(
              bloc: loadDataBloc,
              onLoadData: onWidgetLoadDataCallback,
              onRefresh: onWidgetRefreshCallback,
              onLoadingMore: onWidgetLoadingMoreCallback,
              child: SingleChildScrollView(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Stack(
                        children: [
                          Container(
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(top: 32, bottom: 24),
                                  child: Container(
                                    width: 82,
                                    height: 82,
                                    child: Stack(
                                      children: [
                                        Container(
                                          alignment: Alignment.center,
                                          width: 80,
                                          height: 80,
                                          child: Image.asset(widget.coinVo.logo),
                                        ),
                                        Positioned(
                                          bottom: 0,
                                          right: 0,
                                          child: ImageUtil.getChainIcon(widget.coinVo, 25),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Text(
                                  "${FormatUtil.coinBalanceHumanReadFormat(widget.coinVo)} ${widget.coinVo.symbol}",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "≈ ${activeQuoteVoAndSign?.legal?.sign ?? ''}${FormatUtil.formatPrice(FormatUtil.coinBalanceDouble(widget.coinVo) * (activeQuoteVoAndSign?.price ?? 0))}",
                                    style: TextStyle(fontSize: 14, color: Color(0xFF6D6D6D)),
                                  ),
                                ),
                                Container(
                                  height: 61,
                                  padding: const EdgeInsets.symmetric(vertical: 13),
                                  margin: const EdgeInsets.only(
                                      right: 16, left: 16, bottom: 16, top: 34),
                                  decoration: BoxDecoration(
                                    color: DefaultColors.colorf8f8f8,
                                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                  ),
                                  child: IntrinsicHeight(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: <Widget>[
                                        //发起新交易按钮
                                        InkWell(
                                          onTap: () async {
                                            gotoSendTokenPage();
                                          },
                                          child: Row(
                                            children: <Widget>[
                                              Image.asset(
                                                "res/drawable/ic_wallet_account_list_send.png",
                                                width: 20,
                                                height: 20,
                                              ),
                                              /*Icon(
                                                ExtendsIconFont.send,
                                                color: Theme.of(context).primaryColor,
                                                size: 24,
                                              ),*/
                                              SizedBox(
                                                width: 12,
                                              ),
                                              Text(
                                                S.of(context).send,
                                                style: TextStyle(
                                                    color: DefaultColors.color333, fontSize: 14),
                                              )
                                            ],
                                          ),
                                        ),
                                        Container(
                                          height: 36,
                                          width: 1,
                                          color: DefaultColors.colord7d7d7,
                                        ),
                                        InkWell(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        WalletReceivePage(widget.coinVo)));
                                          },
                                          child: Row(
                                            children: <Widget>[
                                              Image.asset(
                                                "res/drawable/ic_wallet_account_list_receiver.png",
                                                width: 20,
                                                height: 20,
                                              ),
                                              SizedBox(
                                                width: 12,
                                              ),
                                              Text(
                                                S.of(context).receiver,
                                                style: TextStyle(
                                                    color: DefaultColors.color333, fontSize: 14),
                                              )
                                            ],
                                          ),
                                        ),
                                        if (widget.coinVo.symbol == 'HYN' ||
                                            widget.coinVo.symbol == 'RP')
                                          Container(
                                            height: 36,
                                            width: 1,
                                            color: DefaultColors.colord7d7d7,
                                          ),
                                        if (widget.coinVo.symbol == 'HYN' ||
                                            widget.coinVo.symbol == 'RP')
                                          _swapButton(),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Positioned(
                            child: _quoteButton(),
                            right: 24,
                            top: 32,
                          ),
                        ],
                      ),
                      _localRecordHint(),
                      dataList.length > 1
                          ? ListView.builder(
                              primary: false,
                              shrinkWrap: true,
                              itemBuilder: (BuildContext context, int index) {
                                if (index == 0) {
                                  return SizedBox.shrink();
                                } else {
                                  var info = dataList[index];
                                  return TxInfoItem(info);
                                }
                              },
                              itemCount: max<int>(0, dataList.length),
                            )
                          : Padding(
                              padding: const EdgeInsets.only(
                                top: 20,
                              ),
                              child: Container(
                                width: double.infinity,
                                child: emptyListWidget(
                                  title: S.of(context).no_data,
                                  isAdapter: false,
                                ),
                              ),
                            )
                    ]),
              ),
            ),
          ),
        ));
  }

  Widget _quoteButton() {
    if (widget.coinVo.symbol != 'HYN' && widget.coinVo.symbol != 'RP') {
      return SizedBox();
    }
    return InkWell(
      onTap: () {
        var webTitleStr = FluroConvertUtils.fluroCnParamsEncode("MDEX");

        var rp = 'https://info.mdex.co/#/pair/0x2241e4d5cd6408e120974eda698801eaa4bdc294';
        var hyn = 'https://info.mdex.co/#/pair/0x8e6a7d6bd250d207df3b9efafc6c715885eda94e';

        var tokenUrl;
        if (widget.coinVo.symbol == 'HYN') {
          tokenUrl = hyn;
        } else {
          tokenUrl = rp;
        }

        // var tokenContractAddress = widget.coinVo.contractAddress;
        // var tokenUrl = 'https://info.mdex.me/#/token/$tokenContractAddress';
        var initUrl = FluroConvertUtils.fluroCnParamsEncode(tokenUrl);
        Application.router.navigateTo(
            context,
            Routes.toolspage_dapp_webview_page +
                "?initUrl=$initUrl&defaultCoin=${CoinType.HB_HT.toString()}&title=$webTitleStr");
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            "res/drawable/ic_quote.png",
            width: 20,
            height: 18,
          ),
          SizedBox(
            width: 6,
          ),
          Text(
            S.of(context).quote,
            style: TextStyle(
              color: DefaultColors.color999,
              fontSize: 12,
            ),
          )
        ],
      ),
    );
  }

  Widget _swapButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () {
            var webTitleStr = FluroConvertUtils.fluroCnParamsEncode("MDEX");
            var tokenContractAddress = widget.coinVo.contractAddress;
            var usdtContractAddress = env.buildType == BuildType.DEV
                ? DefaultTokenDefine.HUSDT_TEST.contractAddress
                : DefaultTokenDefine.HUSDT.contractAddress;
            // todo: medex
            var swapUrl =
                '$_lastMdexDomain&inputCurrency=$usdtContractAddress&&outputCurrency=$tokenContractAddress';
            var initUrl = FluroConvertUtils.fluroCnParamsEncode(swapUrl);
            Application.router.navigateTo(
                context,
                Routes.toolspage_dapp_webview_page +
                    "?initUrl=$initUrl&defaultCoin=${CoinType.HB_HT.toString()}&title=$webTitleStr");
          },
          child: Row(
            children: <Widget>[
              Image.asset(
                "res/drawable/ic_wallet_account_list_exchange.png",
                width: 20,
                height: 20,
              ),
              SizedBox(
                width: 12,
              ),
              Text(
                S.of(context).exchange,
                style: TextStyle(
                  color: DefaultColors.color333,
                  fontSize: 14,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(BuildContext context, TransactionDetailVo transactionDetail) {
    var iconPath;
    var title = "";
    var titleColor = DefaultColors.color333;
    var describe = "";
    var amountColor;
    var amountText = "";
    var amountSubText = "";
    amountText = "${FormatUtil.formatCoinNum(transactionDetail.amount)}";

    if (transactionDetail.type == TransactionType.TRANSFER_IN) {
      if (transactionDetail.amount > 0) {
        amountColor = HexColor("#FF259B24");
        amountText = '+$amountText';
      }
    } else if (transactionDetail.type == TransactionType.TRANSFER_OUT) {
      if (transactionDetail.amount > 0) {
        amountColor = HexColor("#FFE51C23");
        amountText = '-$amountText';
      }
    }

    var isPending = transactionDetail.state == null;
    var limitLength = isPending ? 4 : 6;

    if (transactionDetail.type == TransactionType.TRANSFER_IN) {
      iconPath = "res/drawable/ic_wallet_account_list_receiver.png";
      /*var fromAddress = WalletUtil.formatToHynAddrIfAtlasChain(
        widget.coinVo,
        transactionDetail.fromAddress,
      );*/
      describe = "From: " +
          shortBlockChainAddress(transactionDetail.fromAddress, limitCharsLength: limitLength);
    } else if (transactionDetail.type == TransactionType.TRANSFER_OUT) {
      iconPath = "res/drawable/ic_wallet_account_list_send.png";
      describe = "To: " +
          shortBlockChainAddress(transactionDetail.toAddress, limitCharsLength: limitLength);
    }

    if ((transactionDetail.state == null) ||
        (transactionDetail.state != null &&
            transactionDetail.state == 0 &&
            transactionDetail.gasUsed == "0" &&
            widget.coinVo.coinType == CoinType.HB_HT)) {
      title = S.of(context).pending;
    } else if ((widget.coinVo.coinType == CoinType.HB_HT) && transactionDetail.state == 1) {
      title = S.of(context).completed;
      if (HYNApi.isContractTokenAddress(transactionDetail.toAddress)) {
        // 代币
        title = S.of(context).contract_call;
        iconPath = "res/drawable/ic_hyn_wallet_contract.png";
      }
    } else if ((widget.coinVo.coinType == CoinType.HB_HT &&
        transactionDetail.state == 0 &&
        transactionDetail.gasUsed != "0")) {
      title = S.of(context).wallet_fail_title;
      titleColor = DefaultColors.colorf23524;
    }

    var time = _dateFormat.format(DateTime.fromMillisecondsSinceEpoch(transactionDetail.time));

    return Ink(
      color: Color(0xFFF5F5F5),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 18,
          ),
          Ink(
            color: Colors.white,
            child: InkWell(
              onTap: () {
                HbApi.jumpToScanByHash(context, transactionDetail.hash);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 21),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      iconPath,
                      width: 20,
                      height: 20,
                    ),
                    SizedBox(
                      width: 13,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                amountText,
                                style: TextStyle(
                                    color: DefaultColors.color333,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                              if (amountSubText.isNotEmpty)
                                Text(
                                  amountSubText,
                                  style: TextStyle(
                                    color: DefaultColors.color999,
                                    fontSize: 12,
                                  ),
                                ),
                              Spacer(),
                              Text(
                                title,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14, color: titleColor),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 4.0,
                          ),
                          Row(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Text(
                                  describe,
                                  style: TextStyle(fontSize: 14, color: DefaultColors.color999),
                                ),
                              ),
                              Spacer(),
                              Text(
                                time,
                                style: TextStyle(
                                  color: DefaultColors.color999,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 14,
                    ),
                    Image.asset(
                      "res/drawable/add_position_image_next.png",
                      height: 13,
                    )
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: 18.0,
          ),
          Divider(
            height: 1,
            indent: 21,
            endIndent: 21,
          )
        ],
      ),
    );
  }

  Widget _localRecordHint() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: HexColor('#F6FAFF'),
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: RichText(
              text: TextSpan(
                  text: '仅显示本地发出的交易，如要查看该币种的更多记录，请点击',
                  style: TextStyle(fontSize: 12, color: HexColor("#595B75"), height: 1.8),
                  children: [
                TextSpan(
                  text: ' [区块浏览器] ',
                  style: TextStyle(fontSize: 12, color: HexColor("#1F81FF"), height: 1.8),
                  recognizer: new TapGestureRecognizer()
                    ..onTap = () {
                      HbApi.jumpToScanByAddress(context, WalletModelUtil.walletEthAddress);
                    },
                ),
                TextSpan(
                    text: '进行查看。',
                    style: TextStyle(fontSize: 12, color: HexColor("#595B75"), height: 1.8))
              ])),
        ),
      ),
    );
  }

  Widget _buildTxnItemV2(BuildContext context, TransactionInfoVo txnInfo) {
    var iconPath = '';
    var title = "";
    var describe = "";
    var amountText = "";
    var amountSubText = "";
    amountText = "${FormatUtil.formatCoinNum(double.tryParse(txnInfo.amount))}";

    if (txnInfo.status == 0) {
      title = S.of(context).pending;
    } else if (txnInfo.status == 1) {
      title = S.of(context).completed;
    } else if (txnInfo.status == 2) {
      title = S.of(context).wallet_fail_title;
    }

    var limitLength = 4;

    if (WalletModelUtil.walletEthAddress == txnInfo.toAddress) {
      amountText = '+$amountText';
      iconPath = "res/drawable/ic_wallet_account_list_receiver.png";
      describe =
          "From: " + shortBlockChainAddress(txnInfo.fromAddress, limitCharsLength: limitLength);
    } else if (WalletModelUtil.walletEthAddress == txnInfo.fromAddress) {
      amountText = '-$amountText';
      iconPath = "res/drawable/ic_wallet_account_list_send.png";
      describe = "To: " + shortBlockChainAddress(txnInfo.toAddress, limitCharsLength: limitLength);
    }

    var time = _dateFormat.format(DateTime.fromMillisecondsSinceEpoch(txnInfo.time));

    return Ink(
      color: Color(0xFFF5F5F5),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 18,
          ),
          Ink(
            color: Colors.white,
            child: InkWell(
              onTap: () {
                HbApi.jumpToScanByHash(context, txnInfo.hash);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 21),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      iconPath,
                      width: 20,
                      height: 20,
                    ),
                    SizedBox(
                      width: 13,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                amountText,
                                style: TextStyle(
                                    color: DefaultColors.color333,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                              if (amountSubText.isNotEmpty)
                                Text(
                                  amountSubText,
                                  style: TextStyle(
                                    color: DefaultColors.color999,
                                    fontSize: 12,
                                  ),
                                ),
                              Spacer(),
                              Text(
                                title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: DefaultColors.color333,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4.0),
                          Row(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Text(
                                  describe,
                                  style: TextStyle(fontSize: 14, color: DefaultColors.color999),
                                ),
                              ),
                              Spacer(),
                              Text(
                                time,
                                style: TextStyle(
                                  color: DefaultColors.color999,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 14),
                    Image.asset(
                      "res/drawable/add_position_image_next.png",
                      height: 13,
                    )
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 18.0),
          Divider(
            height: 1,
            indent: 21,
            endIndent: 21,
          )
        ],
      ),
    );
  }

  Future gotoSendTokenPage() {
    shouldRefresh = true;
    return Application.router.navigateTo(
        context,
        Routes.wallet_account_send_transaction +
            '?coinVo=${FluroConvertUtils.object2string(widget.coinVo.toJson())}&entryRouteName=${Uri.encodeComponent(Routes.wallet_account_detail)}');
  }

  @override
  Future<List<dynamic>> onLoadData(int page) async {
    var retList = [];
    try {
      List<TransactionInfoVo> transferList =
          await _accountTransferService.getHecoTxListV2(context, widget.coinVo, page);
      if (page == getStartPage()) {
        if (!mounted) {
          return retList;
        }
        retList.add('header');

        //update balance
        BlocProvider.of<WalletCmpBloc>(context).add(UpdateActivatedWalletBalanceEvent(
          symbol: widget.coinVo.symbol,
          // contractAddress: widget.coinVo.contractAddress,
        ));
      }

      retList.addAll(transferList);
    } catch (e, stacktrace) {
      retList.add('header');
      LogUtil.toastException(e);
    }
    return retList;
  }
}
