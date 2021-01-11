import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/data_list_state.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/inject/injector.dart';
import 'package:titan/src/components/wallet/model.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/components/wallet/bloc/bloc.dart';
import 'package:titan/src/components/wallet/vo/coin_vo.dart';
import 'package:titan/src/components/wallet/vo/wallet_vo.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/domain/transaction_interactor.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_public_widget.dart';
import 'package:titan/src/pages/market/exchange_detail/exchange_detail_page.dart';
import 'package:titan/src/pages/market/order/entity/order.dart';
import 'package:titan/src/pages/webview/inappwebview.dart';
import 'package:titan/src/plugins/wallet/cointype.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/plugins/wallet/wallet_const.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/pages/wallet/service/account_transfer_service.dart';
import 'package:titan/src/pages/wallet/wallet_receive_page.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/plugins/wallet/token.dart';
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
  CoinVo coinVo;

  ShowAccountPage(this.coinVo);

  @override
  State<StatefulWidget> createState() {
    return _ShowAccountPageState();
  }
}

class _ShowAccountPageState extends DataListState<ShowAccountPage> with RouteAware {
  TransactionInteractor transactionInteractor;

  DateFormat _dateFormat = new DateFormat("HH:mm MM/dd");

  AccountTransferService _accountTransferService = AccountTransferService();
  bool shouldRefresh = false;

  int txCount;
  bool isHaveNearestPendingTx = false;

  List<TransactionDetailVo> localPendingTxs = [];

  // void mergeLocalPendingTxs() {
  //   if (localPendingTxs.length > 0 && dataList.length > 1) {
  //     var dataListOrig = dataList.where((element) {
  //       if (element is TransactionDetailVo) {
  //         return element.localTransferType == null;
  //       }
  //       return false;
  //     }).toList();
  //
  //     var newList = ['header', ...localPendingTxs, ...dataListOrig];
  //     setState(() {
  //       dataList = newList;
  //     });
  //   }
  // }

  @override
  int getStartPage() {
    return 0;
  }

  @override
  void postFrameCallBackAfterInitState() async {
    loadDataBloc.add(LoadingEvent());
  }

  @override
  void onCreated() {
    transactionInteractor = Injector.of(context).transactionInteractor;
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
    widget.coinVo = WalletInheritedModel.of(context).getCoinVoBySymbol(widget.coinVo.symbol);
  }

  @override
  void dispose() {
    Application.routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //activated quote sign
    ActiveQuoteVoAndSign activeQuoteVoAndSign =
        WalletInheritedModel.of(context).activatedQuoteVoAndSign(widget.coinVo.symbol);

    // var coinVo =
    //     WalletInheritedModel.of(context, aspect: WalletAspect.activatedWallet).getCoinVoBySymbol(widget.coinVo.symbol);

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
                              padding: const EdgeInsets.only(top: 32, bottom: 24),
                              child: Container(
                                alignment: Alignment.center,
                                width: 80,
                                height: 80,
                                child: Image.asset(widget.coinVo.logo),
                              ),
                            ),
                            Text(
                              "${FormatUtil.coinBalanceHumanReadFormat(widget.coinVo)} ${widget.coinVo.symbol}",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "≈ ${activeQuoteVoAndSign?.sign?.sign ?? ''}${FormatUtil.formatPrice(FormatUtil.coinBalanceDouble(widget.coinVo) * (activeQuoteVoAndSign?.quoteVo?.price ?? 0))}",
                                style: TextStyle(fontSize: 14, color: Color(0xFF6D6D6D)),
                              ),
                            ),
                            Container(
                              height: 61,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              margin: const EdgeInsets.only(right: 16, left: 16, bottom: 16, top: 34),
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
                                        //以太坊链 token
                                        if (widget.coinVo.coinType == CoinType.ETHEREUM) {
                                          if (isHaveNearestPendingTx == true) {
                                            await UiUtil.showDialogWidget(context,
                                                content: Text(S.of(context).wallet_transfer_title),
                                                actions: [
                                                  FlatButton(
                                                      child: Text(S.of(context).cancel),
                                                      onPressed: () async {
                                                        Navigator.pop(context);
                                                      }),
                                                  FlatButton(
                                                      child: Text(S.of(context).confirm),
                                                      onPressed: () async {
                                                        Navigator.pop(context);
                                                        gotoSendTokenPage();
                                                      }),
                                                ]);
                                            return;
                                          }
                                        }
                                        // 比特币还在转账中
                                        if (dataList.length > 1) {
                                          TransactionDetailVo transaction = dataList[1];
                                          if (transaction.state == 0 && widget.coinVo.coinType == CoinType.BITCOIN) {
                                            UiUtil.showConfirmDialog(
                                              context,
                                              content: S.of(context).has_unconfirm_btc_wait,
                                            );
                                            return;
                                          }
                                        }

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
                                            style: TextStyle(color: DefaultColors.color333, fontSize: 14),
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
                                        Navigator.push(context,
                                            MaterialPageRoute(builder: (context) => WalletReceivePage(widget.coinVo)));
                                      },
                                      child: Row(
                                        children: <Widget>[
                                          Image.asset(
                                            "res/drawable/ic_wallet_account_list_receiver.png",
                                            width: 20,
                                            height: 20,
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
                                            style: TextStyle(color: DefaultColors.color333, fontSize: 14),
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
                                            if (widget.coinVo.symbol == SupportedTokens.USDT_ERC20.symbol ||
                                                widget.coinVo.symbol == SupportedTokens.USDT_ERC20_ROPSTEN.symbol) {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) => ExchangeDetailPage(
                                                          quote: 'HYN', base: 'USDT', exchangeType: ExchangeType.BUY)));
                                            } else {
                                              Fluttertoast.showToast(
                                                  msg: S.of(context).exchange_is_not_yet_open(widget.coinVo.symbol));
                                            }
                                            /*Clipboard.setData(ClipboardData(text: coinVo.address));
                                            Scaffold.of(context)
                                                .showSnackBar(SnackBar(content: Text(S.of(context).address_copied)));*/
                                          },
                                          child: Row(
                                            children: <Widget>[
                                              Image.asset(
                                                "res/drawable/ic_wallet_account_list_exchange.png",
                                                width: 20,
                                                height: 20,
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
                      dataList.length > 1
                          ? ListView.builder(
                              primary: false,
                              shrinkWrap: true,
                              itemBuilder: (BuildContext context, int index) {
                                if (index == 0) {
                                  return SizedBox.shrink();
                                } else {
                                  var currentTransactionDetail = dataList[index];
                                  return _buildTransactionItem(context, currentTransactionDetail);
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
      describe = "From: " + shortBlockChainAddress(transactionDetail.fromAddress, limitCharsLength: limitLength);
    } else if (transactionDetail.type == TransactionType.TRANSFER_OUT) {
      iconPath = "res/drawable/ic_wallet_account_list_send.png";
      describe = "To: " + shortBlockChainAddress(transactionDetail.toAddress, limitCharsLength: limitLength);
    }

    if ((transactionDetail.state == null) ||
        (transactionDetail.state != null &&
            transactionDetail.state >= 0 &&
            transactionDetail.state < 6 &&
            widget.coinVo.coinType == CoinType.BITCOIN) ||
        (transactionDetail.state != null &&
            transactionDetail.state == 0 &&
            widget.coinVo.coinType == CoinType.ETHEREUM)) {
      title = S.of(context).pending;
    } else if (((widget.coinVo.coinType == CoinType.ETHEREUM) && transactionDetail.state == 1) ||
        (widget.coinVo.coinType == CoinType.BITCOIN && transactionDetail.state >= 6)) {
      title = S.of(context).completed;
      if (HYNApi.isContractTokenAddress(transactionDetail.toAddress)) {
        // 代币
        title = S.of(context).contract_call;
        iconPath = "res/drawable/ic_hyn_wallet_contract.png";
      } else if (WalletConfig.map3ContractAddress.toLowerCase() == transactionDetail.toAddress.toLowerCase()) {
        // map3抵押
        title = S.of(context).map_contract_execution;
      }
    } else if ((widget.coinVo.coinType == CoinType.ETHEREUM && transactionDetail.state == -1)) {
      title = S.of(context).wallet_fail_title;
      titleColor = DefaultColors.colorf23524;
    }

    var time = _dateFormat.format(DateTime.fromMillisecondsSinceEpoch(transactionDetail.time));
    if (transactionDetail.localTransferType != null) {
      // TODO test
      // transactionDetail.lastOptType = 1;
      // transactionDetail.speedUpTimes = 1;
      // transactionDetail.cancelTimes = 2;
      // transactionDetail.nonce = '2';

      if (transactionDetail.lastOptType == OptType.SPEED_UP) {
        // speed up
        title = S.of(context).speed_up_times(transactionDetail.speedUpTimes);
      } else if (transactionDetail.lastOptType == OptType.CANCEL) {
        //cancel
        title = S.of(context).cancel_times(transactionDetail.cancelTimes);
      }
    }

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
                                initUrl: WalletConfig.BITCOIN_TRANSATION_DETAIL + transactionDetail.hash,
                                title: '',
                              )));
                } else {
                  var isChinaMainland = SettingInheritedModel.of(context).areaModel?.isChinaMainland ?? true == true;
                  var url = EtherscanApi.getTxDetailUrl(transactionDetail.hash, isChinaMainland);
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
                                style:
                                    TextStyle(color: DefaultColors.color333, fontSize: 16, fontWeight: FontWeight.bold),
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
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: titleColor),
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
          if (isPendingTx(transactionDetail))
            Padding(
              padding: const EdgeInsets.only(top: 8, right: 18.0, left: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  SizedBox(width: 36),
                  Text('nonce ', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Text('${transactionDetail.nonce}', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                  SizedBox(width: 16),
                  Text('${S.of(context).price} ', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Text(
                      '${ConvertTokenUnit.weiToGWei(weiInt: int.parse(transactionDetail.gasPrice)).toStringAsFixed(1)} GWEI',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                  Spacer(),
                  if (isNearestPendingTx(transactionDetail)) ...[
                    //取消交易按钮
                    ClickOvalButton(S.of(context).cancel, () async {
                      var password = await UiUtil.showDialogWidget(context,
                          content: Text(S.of(context).wallet_cancel_transfer_tips),
                          actions: [
                            FlatButton(
                                child: Text(S.of(context).cancel),
                                onPressed: () async {
                                  Navigator.pop(context);
                                }),
                            FlatButton(
                                child: Text(S.of(context).confirm),
                                onPressed: () async {
                                  var password = await transactionInteractor.showPasswordDialog(context);
                                  Navigator.pop(context, password);
                                }),
                          ]);

                      try {
                        if (password == null) {
                          return;
                        }

                        var txHash =
                            await transactionInteractor.cancelTransaction(context, transactionDetail, password);
                        if (txHash != null) {
                          Fluttertoast.showToast(
                              msg: S.of(context).wallet_cancel_send_tips, toastLength: Toast.LENGTH_LONG);
                        }
                      } catch (exception) {
                        if (exception.toString().contains("nonce too low") ||
                            exception.toString().contains("known transaction")) {
                          Fluttertoast.showToast(
                              msg: S.of(context).wallet_transaction_finish_tips, toastLength: Toast.LENGTH_LONG);
                        }
                      }
                    }, width: 52, height: 22, fontSize: 12, btnColor: [Color(0xffDEDEDE)]),
                    SizedBox(
                      width: 10,
                    ),
                    //加速交易按钮
                    ClickOvalButton(S.of(context).wallet_speed, () async {
                      var password = await UiUtil.showDialogWidget(context,
                          content: Text(S.of(context).wallet_speed_transfer_tips),
                          actions: [
                            FlatButton(
                                child: Text(S.of(context).cancel),
                                onPressed: () async {
                                  Navigator.pop(context);
                                }),
                            FlatButton(
                                child: Text(S.of(context).confirm),
                                onPressed: () async {
                                  var password = await transactionInteractor.showPasswordDialog(context);
                                  Navigator.pop(context, password);
                                }),
                          ]);

                      try {
                        if (password == null) {
                          return;
                        }
                        var txHash =
                            await transactionInteractor.speedUpTransaction(context, transactionDetail, password);
                        if (txHash != null) {
                          Fluttertoast.showToast(
                              msg: S.of(context).wallet_have_speed_tips, toastLength: Toast.LENGTH_LONG);
                        }
                      } catch (exception) {
                        if (exception.toString().contains("nonce too low") ||
                            exception.toString().contains("known transaction")) {
                          Fluttertoast.showToast(
                              msg: S.of(context).wallet_translation_finish_not_speed_tips,
                              toastLength: Toast.LENGTH_LONG);
                        }
                      }
                    }, width: 52, height: 22, fontSize: 12, btnColor: [Theme.of(context).primaryColor])
                  ],
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

  bool isPendingTx(TransactionDetailVo transactionDetail) {
    // var ethAddress = WalletInheritedModel.of(context).activatedWallet?.wallet?.getEthAccount()?.address;
    return transactionDetail.localTransferType != null;
  }

  bool isNearestPendingTx(TransactionDetailVo transactionDetail) {
    // var ethAddress = WalletInheritedModel.of(context).activatedWallet?.wallet?.getEthAccount()?.address;
    return /*transactionDetail.fromAddress == ethAddress && */ int.parse(transactionDetail.nonce) == txCount;
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
    List<TransactionDetailVo> transferList = [];

    try {
      transferList = await _accountTransferService.getTransferList(widget.coinVo, page);
      if (page == getStartPage()) {
        if(!mounted){
          return retList;
        }

        retList.add('header');

        //update balance
        BlocProvider.of<WalletCmpBloc>(context).add(UpdateActivatedWalletBalanceEvent(
          symbol: widget.coinVo.symbol,
          contractAddress: widget.coinVo.contractAddress,
        ));

        //merge local pending txs
        if (widget.coinVo.coinType == CoinType.ETHEREUM) {
          try {
            isHaveNearestPendingTx = false;
            var ethAddress = WalletInheritedModel.of(context).activatedWallet?.wallet?.getEthAccount()?.address;
            if (ethAddress != null && ethAddress != '') {
              var localTransferType = widget.coinVo.symbol == 'ETH'
                  ? LocalTransferType.LOCAL_TRANSFER_ETH
                  : LocalTransferType.LOCAL_TRANSFER_ERC20;
              final client = WalletUtil.getWeb3Client(false);
              txCount = await client.getTransactionCount(EthereumAddress.fromHex(ethAddress));
              //test
              // txCount = 11;
              await transactionInteractor.removeLocalPendingConfirmedTxsByNonce(
                  ethAddress, localTransferType, widget.coinVo.contractAddress, txCount);
              localPendingTxs = await transactionInteractor.getLocalPendingTransactions(
                  ethAddress, localTransferType, widget.coinVo.contractAddress);
              print('xxx $txCount, ${localPendingTxs.length}');
              for (var tx in localPendingTxs) {
                if (int.parse(tx.nonce) == txCount) {
                  isHaveNearestPendingTx = true;
                }
              }
              retList.addAll(localPendingTxs);
            }
          } catch (e) {
            print(e);
          }
        }
      }

      retList.addAll(transferList);
    } catch (e, stacktrace) {
      print(stacktrace);
      logger.e(e);
    }
    return retList;
  }

// Future<TransactionDetailVo> getLocalTransfer(bool isAllLocal) async {
//   TransactionDetailVo localTransfer;
//   if (isAllLocal) {
//     localTransfer =
//         await transactionInteractor.getShareTransaction(LocalTransferType.LOCAL_TRANSFER_ETH, isAllLocal);
//   } else {
//     if (widget.coinVo.symbol == "ETH") {
//       localTransfer =
//           await transactionInteractor.getShareTransaction(LocalTransferType.LOCAL_TRANSFER_ETH, isAllLocal);
//     } else {
//       localTransfer = await widget.transactionInteractor.getShareTransaction(
//           LocalTransferType.LOCAL_TRANSFER_ERC20, isAllLocal,
//           contractAddress: widget.coinVo.contractAddress);
//     }
//   }
//
//   return localTransfer;
// }
}

Future<List<TransactionDetailVo>> getEthTransferList(AccountTransferService _accountTransferService) async {
  List<TransactionDetailVo> transferList = [];
  try {
    WalletVo walletVo = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet;
    String fromAddress = walletVo.wallet.getEthAccount().address;
    var coinVo = CoinVo(symbol: "ETH", address: fromAddress);
    transferList = await _accountTransferService.getTransferList(coinVo, 0);
  } catch (e) {
    logger.e(e);
  }
  return transferList;
}
