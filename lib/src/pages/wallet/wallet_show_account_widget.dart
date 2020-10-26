import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/data_list_state.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/inject/injector.dart';
import 'package:titan/src/components/quotes/model.dart';
import 'package:titan/src/components/quotes/quotes_component.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/components/wallet/bloc/bloc.dart';
import 'package:titan/src/components/wallet/vo/coin_vo.dart';
import 'package:titan/src/components/wallet/vo/wallet_vo.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/domain/transaction_interactor.dart';
import 'package:titan/src/pages/market/exchange_detail/exchange_detail_page.dart';
import 'package:titan/src/pages/market/order/entity/order.dart';
import 'package:titan/src/pages/wallet/wallet_show_account_info_page.dart';
import 'package:titan/src/pages/webview/inappwebview.dart';
import 'package:titan/src/pages/webview/webview.dart';
import 'package:titan/src/plugins/wallet/cointype.dart';
import 'package:titan/src/plugins/wallet/wallet_const.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/pages/wallet/service/account_transfer_service.dart';
import 'package:titan/src/pages/wallet/wallet_receive_page.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/plugins/wallet/token.dart';
import 'package:titan/src/config/extends_icon_font.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/utils/utils.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'package:web3dart/web3dart.dart';

import '../../pages/wallet/model/transtion_detail_vo.dart';
import 'api/etherscan_api.dart';
import 'api/hyn_api.dart';

class ShowAccountPage extends StatefulWidget {
  final CoinVo coinVo;
  TransactionInteractor transactionInteractor =
      Injector.of(Keys.rootKey.currentContext).transactionInteractor;

  ShowAccountPage(String coinVo)
      : coinVo = CoinVo.fromJson(FluroConvertUtils.string2map(coinVo));

  @override
  State<StatefulWidget> createState() {
    return _ShowAccountPageState();
  }
}

class _ShowAccountPageState extends DataListState<ShowAccountPage>
    with RouteAware {
  DateFormat _dateFormat = new DateFormat("HH:mm MM/dd");

  AccountTransferService _accountTransferService = AccountTransferService();

  @override
  int getStartPage() {
    return 1;
  }

  @override
  void postFrameCallBackAfterInitState() async {
    loadDataBloc.add(LoadingEvent());
  }

  @override
  void didPopNext() {
    if (mounted) {
      onWidgetRefreshCallback();
    }

    super.didPopNext();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    Application.routeObserver.subscribe(this, ModalRoute.of(context));

    var tempTransList = await getEthTransferList();
    if (tempTransList.length > 0) {
      await widget.transactionInteractor
          .deleteSameNonce(tempTransList[0].nonce);
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
    ActiveQuoteVoAndSign activeQuoteVoAndSign = QuotesInheritedModel.of(context)
        .activatedQuoteVoAndSign(widget.coinVo.symbol);

    var coinVo =
        WalletInheritedModel.of(context, aspect: WalletAspect.activatedWallet)
            .getCoinVoBySymbol(widget.coinVo.symbol);

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
                      Container(
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 32, bottom: 24),
                              child: Container(
                                alignment: Alignment.center,
                                width: 80,
                                height: 80,
                                child: Image.asset(coinVo.logo),
                              ),
                            ),
                            Text(
                              "${FormatUtil.coinBalanceHumanReadFormat(coinVo)} ${coinVo.symbol}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "≈ ${activeQuoteVoAndSign?.sign?.sign ?? ''}${FormatUtil.formatPrice(FormatUtil.coinBalanceDouble(coinVo) * (activeQuoteVoAndSign?.quoteVo?.price ?? 0))}",
                                style: TextStyle(
                                    fontSize: 14, color: Color(0xFF6D6D6D)),
                              ),
                            ),
                            Container(
                              height: 61,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              margin: const EdgeInsets.only(
                                  right: 16, left: 16, bottom: 16, top: 34),
                              decoration: BoxDecoration(
                                color: DefaultColors.colorf8f8f8,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0)),
                              ),
                              child: IntrinsicHeight(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    InkWell(
                                      onTap: () async {
                                        if (widget.coinVo.coinType ==
                                            CoinType.ETHEREUM) {
                                          TransactionDetailVo localTransfer =
                                              await getLocalTransfer(true);
                                          if (localTransfer != null) {
                                            await UiUtil.showDialogWidget(
                                                context,
                                                content:
                                                    Text("你有未确认的转账，继续转账将被覆盖。"),
                                                actions: [
                                                  FlatButton(
                                                      child: Text('取消'),
                                                      onPressed: () async {
                                                        Navigator.pop(context);
                                                      }),
                                                  FlatButton(
                                                      child: Text('确认'),
                                                      onPressed: () async {
                                                        Navigator.pop(context);
                                                        Application.router.navigateTo(
                                                            context,
                                                            Routes.wallet_account_send_transaction +
                                                                '?coinVo=${FluroConvertUtils.object2string(coinVo.toJson())}&entryRouteName=${Uri.encodeComponent(Routes.wallet_account_detail)}');
                                                      }),
                                                ]);
                                            return;
                                          }
                                        }
                                        if (dataList.length > 1) {
                                          TransactionDetailVo transaction =
                                              dataList[1];
                                          if (transaction.state == 0 &&
                                              widget.coinVo.coinType ==
                                                  CoinType.BITCOIN) {
                                            UiUtil.showConfirmDialog(
                                              context,
                                              content: S
                                                  .of(context)
                                                  .has_unconfirm_btc_wait,
                                            );
                                            return;
                                          }
                                        }
                                        Application.router.navigateTo(
                                            context,
                                            Routes.wallet_account_send_transaction +
                                                '?coinVo=${FluroConvertUtils.object2string(coinVo.toJson())}&entryRouteName=${Uri.encodeComponent(Routes.wallet_account_detail)}');
                                      },
                                      child: Row(
                                        children: <Widget>[
                                          Image.asset(
                                            "res/drawable/ic_wallet_account_list_send.png",
                                            width: 21,
                                            height: 21,
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
                                                color: DefaultColors.color333,
                                                fontSize: 14),
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
                                                    WalletReceivePage(coinVo)));
                                      },
                                      child: Row(
                                        children: <Widget>[
                                          Image.asset(
                                            "res/drawable/ic_wallet_account_list_receiver.png",
                                            width: 21,
                                            height: 21,
                                          ),
                                          /*Icon(
                                            ExtendsIconFont.receiver,
                                            color: Theme.of(context).primaryColor,
                                            size: 20,
                                          ),*/
                                          SizedBox(
                                            width: 12,
                                          ),
                                          Text(
                                            S.of(context).receiver,
                                            style: TextStyle(
                                                color: DefaultColors.color333,
                                                fontSize: 14),
                                          )
                                        ],
                                      ),
                                    ),
                                    Container(
                                      height: 36,
                                      width: 1,
                                      color: DefaultColors.colord7d7d7,
                                    ),
                                    Builder(
                                      builder: (BuildContext context) {
                                        return InkWell(
                                          onTap: () {
                                            if (widget.coinVo.coinType ==
                                                    CoinType.HYN_ATLAS ||
                                                widget.coinVo.symbol ==
                                                    SupportedTokens
                                                        .USDT_ERC20.symbol ||
                                                widget.coinVo.symbol ==
                                                    SupportedTokens
                                                        .USDT_ERC20_ROPSTEN
                                                        .symbol) {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ExchangeDetailPage(
                                                              selectedCoin:
                                                                  'USDT',
                                                              exchangeType:
                                                                  ExchangeType
                                                                      .BUY)));
                                            } else {
                                              Fluttertoast.showToast(
                                                  msg: "即将开通该交易对，敬请期待!");
                                            }
                                            /*Clipboard.setData(ClipboardData(text: coinVo.address));
                                            Scaffold.of(context)
                                                .showSnackBar(SnackBar(content: Text(S.of(context).address_copied)));*/
                                          },
                                          child: Row(
                                            children: <Widget>[
                                              Image.asset(
                                                "res/drawable/ic_wallet_account_list_exchange.png",
                                                width: 21,
                                                height: 21,
                                              ),
                                              /*Icon(
                                                ExtendsIconFont.copy_content,
                                                color: Theme.of(context).primaryColor,
                                                size: 20,
                                              ),*/
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
                                        );
                                      },
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      if (dataList.length > 1)
                        ListView.builder(
                          primary: false,
                          shrinkWrap: true,
                          itemBuilder: (BuildContext context, int index) {
                            if (index == 0) {
                              return SizedBox.shrink();
                            } else {
                              var currentTransactionDetail = dataList[index];
                              return _buildTransactionItem(
                                  context, currentTransactionDetail);
                            }
                          },
                          itemCount: max<int>(0, dataList.length),
                        )
                    ]),
              ),
            ),
          ),
        ));
  }

  Widget _buildTransactionItem(
      BuildContext context, TransactionDetailVo transactionDetail) {
    var iconPath;
    var title = "";
    var titleColor = DefaultColors.color333;
    var describe = "";
    var amountColor;
    var amountText = "";
    var amountSubText = "";
    amountText =
        "${FormatUtil.formatCoinNum(transactionDetail.amount)} ${transactionDetail.symbol}";

    if (widget.coinVo.coinType == CoinType.HYN_ATLAS) {
      amountText =
          "${HYNApi.getValueByHynType(transactionDetail.hynType, transactionDetail: transactionDetail, getAmountStr: true)}";
      amountSubText = " ${HYNApi.getValueByHynType(transactionDetail.hynType, getTypeStr: true)}";
    } else if (transactionDetail.type == TransactionType.TRANSFER_IN) {
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
      var fromAddress = WalletUtil.formatToHynAddrIfAtlasChain(
        widget.coinVo,
        transactionDetail.fromAddress,
      );
      describe = "From: " +
          shortBlockChainAddress(fromAddress, limitCharsLength: limitLength);
    } else if (transactionDetail.type == TransactionType.TRANSFER_OUT) {
      iconPath = "res/drawable/ic_wallet_account_list_send.png";
      if (widget.coinVo.coinType == CoinType.HYN_ATLAS) {
        var toAddress = WalletUtil.formatToHynAddrIfAtlasChain(
          widget.coinVo,
          HYNApi.getHynToAddress(transactionDetail),
        );
        describe = "To: " +
            shortBlockChainAddress(toAddress, limitCharsLength: limitLength);
      } else {
        describe = "To: " +
            shortBlockChainAddress(transactionDetail.toAddress,
                limitCharsLength: limitLength);
      }
    }

    if ((transactionDetail.state == null) ||
        (transactionDetail.state != null &&
            transactionDetail.state >= 0 &&
            transactionDetail.state < 6 &&
            widget.coinVo.coinType == CoinType.BITCOIN) ||
        (transactionDetail.state != null &&
            transactionDetail.state == 0 &&
            widget.coinVo.coinType == CoinType.ETHEREUM) ||
        (transactionDetail.state != null &&
            (transactionDetail.state == 1 || transactionDetail.state == 2) &&
            widget.coinVo.coinType == CoinType.HYN_ATLAS)) {
      title = S.of(context).pending;
    } else if (((widget.coinVo.coinType == CoinType.ETHEREUM) &&
            transactionDetail.state == 1) ||
        (widget.coinVo.coinType == CoinType.BITCOIN &&
            transactionDetail.state >= 6) ||
        (widget.coinVo.coinType == CoinType.HYN_ATLAS &&
            transactionDetail.state == 3)) {
      title = S.of(context).completed;
      if (SupportedTokens.allContractTokens(WalletConfig.netType)
          .map((token) => token.contractAddress.toLowerCase())
          .toList()
          .contains(transactionDetail.toAddress.toLowerCase())) {
        title = S.of(context).contract_call;
      } else if (WalletConfig.map3ContractAddress.toLowerCase() ==
          transactionDetail.toAddress.toLowerCase()) {
        title = S.of(context).map_contract_execution;
      }
    } else if ((widget.coinVo.coinType == CoinType.ETHEREUM &&
            transactionDetail.state == -1) ||
        (widget.coinVo.coinType == CoinType.HYN_ATLAS &&
            (transactionDetail.state == 4 || transactionDetail.state == 5))) {
      title = "失败";
      titleColor = DefaultColors.colorf23524;
    }

    var time = _dateFormat
        .format(DateTime.fromMillisecondsSinceEpoch(transactionDetail.time));

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
                if (widget.coinVo.coinType == CoinType.BITCOIN) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => InAppWebViewContainer(
                                initUrl:
                                    WalletConfig.BITCOIN_TRANSATION_DETAIL +
                                        transactionDetail.hash,
                                title: '',
                              )));
                } else {
                  if (widget.coinVo.coinType == CoinType.HYN_ATLAS) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>
                                WalletShowAccountInfoPage(transactionDetail)));
                  } else {
                    var isChinaMainland = SettingInheritedModel.of(context)
                            .areaModel
                            ?.isChinaMainland ==
                        true;
                    var url = EtherscanApi.getTxDetailUrl(
                        transactionDetail.hash, isChinaMainland);
                    if (url != null) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => InAppWebViewContainer(
                                    initUrl: url,
                                    title: '',
                                  )));
                    }
                  }
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 21),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      iconPath,
                      width: 18,
                      height: 18,
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
                              if(amountSubText.isNotEmpty)
                                Text(
                                  amountSubText,
                                  style: TextStyle(
                                      color: DefaultColors.color999,
                                      fontSize: 12,),
                                ),
                              Spacer(),
                              Text(
                                title,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: titleColor),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 4.0,
                          ),
                          Row(
                            children: <Widget>[
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: Text(
                                  describe,
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: DefaultColors.color999),
                                ),
                              ),
                              Spacer(),
                              Text(
                                time,
                                style: TextStyle(
                                    color: DefaultColors.color999,
                                    fontSize: 14,),
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
          if (transactionDetail.localTransferType != null)
            Padding(
              padding: const EdgeInsets.only(top: 11, right: 21.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  ClickOvalButton("取消", () async {
                    var password = await UiUtil.showDialogWidget(context,
                        content:
                            Text("取消交易操作无法保证能够成功取消您的原始交易。如果取消成功，您将被收取上述交易费用。"),
                        actions: [
                          FlatButton(
                              child: Text('取消'),
                              onPressed: () async {
                                Navigator.pop(context);
                              }),
                          FlatButton(
                              child: Text('确认'),
                              onPressed: () async {
                                var password = await widget
                                    .transactionInteractor
                                    .showPasswordDialog(context);
                                Navigator.pop(context, password);
                              }),
                        ]);

                    try {
                      if (password == null) {
                        return;
                      }

                      await widget.transactionInteractor.cancelTransaction(
                          context, transactionDetail, password);
                      Fluttertoast.showToast(
                          msg: "已发送取消操作，请稍后刷新。",
                          toastLength: Toast.LENGTH_LONG);
                    } catch (exception) {
                      if (exception.toString().contains("nonce too low") ||
                          exception.toString().contains("known transaction")) {
                        Fluttertoast.showToast(
                            msg: "交易即将完成，无法取消。",
                            toastLength: Toast.LENGTH_LONG);
                      }
                    }
                  },
                      width: 52,
                      height: 22,
                      fontSize: 12,
                      btnColor: Color(0xffDEDEDE)),
                  SizedBox(
                    width: 10,
                  ),
                  ClickOvalButton("加速", () async {
                    var password = await UiUtil.showDialogWidget(context,
                        content:
                            Text("加速交易操作无法保证能够成功加速您的原始交易。如果加速成功，您将被收取更高的交易费用。"),
                        actions: [
                          FlatButton(
                              child: Text('取消'),
                              onPressed: () async {
                                Navigator.pop(context);
                              }),
                          FlatButton(
                              child: Text('确认'),
                              onPressed: () async {
                                var password = await widget
                                    .transactionInteractor
                                    .showPasswordDialog(context);
                                Navigator.pop(context, password);
                              }),
                        ]);

                    try {
                      if (password == null) {
                        return;
                      }
                      await widget.transactionInteractor.speedTransaction(
                          context, transactionDetail, password);
                      Fluttertoast.showToast(
                          msg: "已发送加速操作，请稍后刷新。",
                          toastLength: Toast.LENGTH_LONG);
                    } catch (exception) {
                      if (exception.toString().contains("nonce too low") ||
                          exception.toString().contains("known transaction")) {
                        Fluttertoast.showToast(
                            msg: "交易即将完成，无法加速。",
                            toastLength: Toast.LENGTH_LONG);
                      }
                    }
                  },
                      width: 52,
                      height: 22,
                      fontSize: 12,
                      btnColor: Theme.of(context).primaryColor),
                ],
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

  @override
  Future<List<dynamic>> onLoadData(int page) async {
    var retList = [];
    if (page == getStartPage()) {
      retList.add('header');

      //update balance
      BlocProvider.of<WalletCmpBloc>(context)
          .add(UpdateActivatedWalletBalanceEvent(
        symbol: widget.coinVo.symbol,
        contractAddress: widget.coinVo.contractAddress,
      ));
    }

    List<TransactionDetailVo> transferList = [];
    if (widget.coinVo.symbol == SupportedTokens.HYN_Atlas.symbol) {
      transferList =
          await _accountTransferService.getTransferList(widget.coinVo, page);
      retList.addAll(transferList);
      return retList;
    }

    try {
      transferList =
          await _accountTransferService.getTransferList(widget.coinVo, page);

      //delete local transaction
      var tempTransList = await getEthTransferList();
      if (tempTransList.length > 0) {
        await widget.transactionInteractor
            .deleteSameNonce(tempTransList[0].nonce);
      }

      //add local transaction
      if (page == getStartPage()) {
        TransactionDetailVo localTransfer = await getLocalTransfer(false);
        if (localTransfer != null) {
          retList.add(localTransfer);
        }
      }

      retList.addAll(transferList);
    } catch (e) {
      logger.e(e);
    }
    return retList;
  }

  Future<List<TransactionDetailVo>> getEthTransferList() async {
    List<TransactionDetailVo> transferList = [];
    try {
      WalletVo walletVo =
          WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet;
      String fromAddress = walletVo.wallet.getEthAccount().address;
      var coinVo = CoinVo(symbol: "ETH", address: fromAddress);
      transferList = await _accountTransferService.getTransferList(coinVo, 0);
    } catch (e) {
      logger.e(e);
    }
    return transferList;
  }

  Future<TransactionDetailVo> getLocalTransfer(bool isAllLocal) async {
    TransactionDetailVo localTransfer;
    if (isAllLocal) {
      localTransfer = await widget.transactionInteractor.getShareTransaction(
          LocalTransferType.LOCAL_TRANSFER_ETH, isAllLocal);
    } else {
      if (widget.coinVo.symbol == "ETH") {
        localTransfer = await widget.transactionInteractor.getShareTransaction(
            LocalTransferType.LOCAL_TRANSFER_ETH, isAllLocal);
      } else {
        localTransfer = await widget.transactionInteractor.getShareTransaction(
            LocalTransferType.LOCAL_TRANSFER_HYN_USDT, isAllLocal,
            contractAddress: widget.coinVo.contractAddress);
      }
    }

    return localTransfer;
  }
}
