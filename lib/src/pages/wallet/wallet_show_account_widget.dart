import 'dart:async';
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
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/domain/transaction_interactor.dart';
import 'package:titan/src/pages/webview/inappwebview.dart';
import 'package:titan/src/pages/webview/webview.dart';
import 'package:titan/src/plugins/wallet/wallet_const.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/pages/wallet/service/account_transfer_service.dart';
import 'package:titan/src/pages/wallet/wallet_receive_page.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/plugins/wallet/token.dart';
import 'package:titan/src/config/extends_icon_font.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/utils/utils.dart';

import '../../pages/wallet/model/transtion_detail_vo.dart';
import 'api/etherscan_api.dart';

class ShowAccountPage extends StatefulWidget {
  final CoinVo coinVo;
  TransactionInteractor transactionInteractor = Injector.of(Keys.rootKey.currentContext).transactionInteractor;

  ShowAccountPage(String coinVo) : coinVo = CoinVo.fromJson(FluroConvertUtils.string2map(coinVo));

  @override
  State<StatefulWidget> createState() {
    return _ShowAccountPageState();
  }
}

class _ShowAccountPageState extends DataListState<ShowAccountPage> with RouteAware {
  DateFormat _dateFormat = new DateFormat("yyyy/MM/dd");

  AccountTransferService _accountTransferService = AccountTransferService();

  @override
  int getStartPage() {
    return 1;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Application.routeObserver.subscribe(this, ModalRoute.of(context));
  }

  @override
  void didPopNext() {
    onWidgetRefreshCallback();
    super.didPopNext();
  }

  @override
  void dispose() {
    Application.routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void postFrameCallBackAfterInitState() async {
    loadDataBloc.add(LoadingEvent());
  }

  @override
  Widget build(BuildContext context) {
    //activated quote sign
    ActiveQuoteVoAndSign activeQuoteVoAndSign =
        QuotesInheritedModel.of(context).activatedQuoteVoAndSign(widget.coinVo.symbol);

    var coinVo =
        WalletInheritedModel.of(context, aspect: WalletAspect.activatedWallet).getCoinVoBySymbol(widget.coinVo.symbol);

    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
          title: Text(
            "${widget.coinVo.name} (${widget.coinVo.symbol})",
            style: TextStyle(color: Colors.white),
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
                              decoration: BoxDecoration(
                                border: Border.all(color: Color(0xFF9B9B9B), width: 0),
                                shape: BoxShape.circle,
                              ),
                              child: Image.asset(coinVo.logo),
                            ),
                          ),
                          Text(
                            "${FormatUtil.coinBalanceHumanReadFormat(coinVo)} ${coinVo.symbol}",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "≈ ${activeQuoteVoAndSign?.sign?.sign ?? ''}${FormatUtil.formatPrice(FormatUtil.coinBalanceDouble(coinVo) * (activeQuoteVoAndSign?.quoteVo?.price ?? 0))}",
                              style: TextStyle(fontSize: 14, color: Color(0xFF6D6D6D)),
                            ),
                          ),
                          SizedBox(
                            height: 24,
                          ),
                          Divider(
                            height: 2,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: IntrinsicHeight(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  InkWell(
                                    onTap: () {
                                      Application.router.navigateTo(
                                          context,
                                          Routes.wallet_account_send_transaction +
                                              '?coinVo=${FluroConvertUtils.object2string(coinVo.toJson())}&entryRouteName=${Uri.encodeComponent(Routes.wallet_account_detail)}');
                                    },
                                    child: Row(
                                      children: <Widget>[
                                        Icon(
                                          ExtendsIconFont.send,
                                          color: Theme.of(context).primaryColor,
                                          size: 32,
                                        ),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            S.of(context).send,
                                            style: TextStyle(
                                              color: HexColor(
                                                "#FF6D6D6D",
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  VerticalDivider(),
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context, MaterialPageRoute(builder: (context) => WalletReceivePage(coinVo)));
                                    },
                                    child: Row(
                                      children: <Widget>[
                                        Icon(
                                          ExtendsIconFont.receiver,
                                          color: Theme.of(context).primaryColor,
                                          size: 24,
                                        ),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            S.of(context).receiver,
                                            style: TextStyle(
                                              color: HexColor(
                                                "#FF6D6D6D",
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  VerticalDivider(),
                                  Builder(
                                    builder: (BuildContext context) {
                                      return InkWell(
                                        onTap: () {
                                          Clipboard.setData(ClipboardData(text: coinVo.address));
                                          Scaffold.of(context)
                                              .showSnackBar(SnackBar(content: Text(S.of(context).address_copied)));
                                        },
                                        child: Row(
                                          children: <Widget>[
                                            Icon(
                                              ExtendsIconFont.copy_content,
                                              color: Theme.of(context).primaryColor,
                                              size: 24,
                                            ),
                                            SizedBox(
                                              width: 8,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(
                                                S.of(context).copy,
                                                style: TextStyle(
                                                  color: HexColor(
                                                    "#FF6D6D6D",
                                                  ),
                                                ),
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
                            TransactionDetailVo lastTransactionDetail;
                            if (index > 1) {
                              lastTransactionDetail = dataList[index - 1];
                            }
                            return _buildTransactionItem(context, currentTransactionDetail, lastTransactionDetail);
                          }
                        },
                        itemCount: max<int>(0, dataList.length),
                      )
                  ]),
            ),
          ),
        ));
  }

  Widget _buildTransactionItem(
    BuildContext context,
    TransactionDetailVo transactionDetail,
    TransactionDetailVo lastTransactionDetail,
  ) {
    var iconData;
    var title = "";
    var describe = "";
    var amountColor;
    var amountText = "${FormatUtil.formatPrice(transactionDetail.amount,false)} ${transactionDetail.symbol}";
    if (transactionDetail.type == TransactionType.TRANSFER_IN) {
      iconData = ExtendsIconFont.receiver;
      title = S.of(context).received;
      describe = "From:" + shortBlockChainAddress(transactionDetail.fromAddress);
      if (transactionDetail.amount > 0) {
        amountColor = HexColor("#FF259B24");
        amountText = '+ $amountText';
      }
    } else if (transactionDetail.type == TransactionType.TRANSFER_OUT) {
      iconData = ExtendsIconFont.send;
      title = S.of(context).sent;
      describe = "To:" + shortBlockChainAddress(transactionDetail.toAddress);

      if (transactionDetail.amount > 0) {
        amountColor = HexColor("#FFE51C23");
        amountText = '- $amountText';
      }
    }

    if (SupportedTokens.allContractTokens(WalletConfig.netType)
        .map((token) => token.contractAddress.toLowerCase())
        .toList()
        .contains(transactionDetail.toAddress.toLowerCase())) {
      title = S.of(context).contract_call;
    } else if (WalletConfig.map3ContractAddress.toLowerCase() == transactionDetail.toAddress.toLowerCase()) {
      title = S.of(context).map_contract_execution;
    }

    var time = _dateFormat.format(DateTime.fromMillisecondsSinceEpoch(transactionDetail.time));
    var lastTransactionTime = lastTransactionDetail != null
        ? _dateFormat.format(DateTime.fromMillisecondsSinceEpoch(lastTransactionDetail.time))
        : null;
    var isShowTime = lastTransactionTime != time;
    return Ink(
      color: Color(0xFFF5F5F5),
      child: Column(
        children: <Widget>[
          if (isShowTime)
            Container(
                padding: EdgeInsets.symmetric(vertical: 4),
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Text(
                    time,
                    style: TextStyle(color: Color(0xFF9B9B9B)),
                  ),
                )),
          if (transactionDetail.localTransferType != null)
            Ink(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 8, right: 8),
                      child: Icon(
                        iconData,
                        color: Color(0xFFCDCDCD),
                        size: ExtendsIconFont.receiver == iconData ? 19 : 24,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  title,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Spacer(),
                                Text(
                                  amountText,
                                  style: TextStyle(color: amountColor, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Text(
                                    describe,
                                    style: TextStyle(fontSize: 14, color: Color(0xFF9B9B9B)),
                                  ),
                                ),
                                Spacer(),
                                SizedBox(
                                  width: 60,
                                  child: FlatButton(
                                      padding: EdgeInsets.all(0),
                                      child: Text("取消"),
                                      onPressed: () async {
                                        UiUtil.showDialogWidget(context,
                                            content: Text("确认提交该操作无法保证能够成功取消您的原始交易。如果取消成功，您将被收取上述交易费用。"),
                                            actions: [
                                              FlatButton(
                                                  child: Text('确认'),
                                                  onPressed: () async {
                                                    try {
                                                      await widget.transactionInteractor
                                                          .cancelTransaction(transactionDetail);
                                                      Fluttertoast.showToast(
                                                          msg: "已发送取消操作，请稍后刷新。", toastLength: Toast.LENGTH_LONG);
                                                    } catch (exception) {
                                                      if (exception.toString().contains("nonce too low") ||
                                                          exception.toString().contains("known transaction")) {
                                                        Fluttertoast.showToast(
                                                            msg: "交易即将完成，无法取消。", toastLength: Toast.LENGTH_LONG);
                                                      }
                                                    }
                                                    onWidgetRefreshCallback();
                                                    Navigator.pop(context);
                                                  }),
                                              FlatButton(
                                                  child: Text('取消'),
                                                  onPressed: () async {
                                                    Navigator.pop(context);
                                                  })
                                            ]);
                                      }),
                                ),
                                SizedBox(
                                  width: 60,
                                  child: FlatButton(padding: EdgeInsets.all(0), child: Text("加速"), onPressed: () {
                                    UiUtil.showDialogWidget(context,
                                        content: Text("确认提交该操作无法保证能够成功加速您的原始交易。如果加速成功，您将被收取更高的交易费用。"),
                                        actions: [
                                          FlatButton(
                                              child: Text('确认'),
                                              onPressed: () async {
                                                try {
                                                  await widget.transactionInteractor
                                                      .speedTransaction(transactionDetail);
                                                  Fluttertoast.showToast(
                                                      msg: "已发送加速操作，请稍后刷新。", toastLength: Toast.LENGTH_LONG);
                                                } catch (exception) {
                                                  if (exception.toString().contains("nonce too low") ||
                                                      exception.toString().contains("known transaction")) {
                                                    Fluttertoast.showToast(
                                                        msg: "交易即将完成，无法加速。", toastLength: Toast.LENGTH_LONG);
                                                  }
                                                }
                                                onWidgetRefreshCallback();
                                                Navigator.pop(context);
                                              }),
                                          FlatButton(
                                              child: Text('取消'),
                                              onPressed: () async {
                                                Navigator.pop(context);
                                              })
                                        ]);
                                  }),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (transactionDetail.localTransferType == null)
            Ink(
              color: Colors.white,
              child: InkWell(
                onTap: () {
                  var isChinaMainland = SettingInheritedModel.of(context).areaModel?.isChinaMainland == true;
                  var url = EtherscanApi.getTxDetailUrl(transactionDetail.hash, isChinaMainland);
                  if (url != null) {
                    // todo: jison_test_0421
                    /*
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => WebViewContainer(
                                  initUrl: url,
                                  title: '',
                                )));
                  */

                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => InAppWebViewContainer(
                                  initUrl: url,
                                  title: '',
                                )));
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 8, right: 8),
                        child: Icon(
                          iconData,
                          color: Color(0xFFCDCDCD),
                          size: ExtendsIconFont.receiver == iconData ? 19 : 24,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    title,
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Spacer(),
                                  Text(
                                    amountText,
                                    style: TextStyle(color: amountColor, fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Text(
                                  describe,
                                  style: TextStyle(fontSize: 14, color: Color(0xFF9B9B9B)),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          SizedBox(height: 1),
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
      BlocProvider.of<WalletCmpBloc>(context).add(UpdateActivatedWalletBalanceEvent(symbol: widget.coinVo.symbol));
    }

    List<TransactionDetailVo> transferList = [];
    try {
      transferList = await _accountTransferService.getTransferList(widget.coinVo, page);

      //delete local transaction
      transferList.forEach((element) async {
        await widget.transactionInteractor.deleteSameNonce(element.nonce);
      });

      //add local transaction
      if (page == getStartPage()) {
        List<TransactionDetailVo> localTransferList = [];
        if (widget.coinVo.symbol == "ETH") {
          localTransferList =
              await widget.transactionInteractor.getTransactionList(LocalTransferType.LOCAL_TRANSFER_ETH);
        } else {
          localTransferList =
              await widget.transactionInteractor.getTransactionList(LocalTransferType.LOCAL_TRANSFER_HYN_USDT
                  ,contractAddress: widget.coinVo.contractAddress);
        }
        if (localTransferList.length > 0) {
          localTransferList.forEach((element) {
            print("!!!!! local data ${element.id} ${element.hash} ${element.nonce} ${element.amount}");
          });
          retList.addAll(localTransferList);
        }
      }

      retList.addAll(transferList);
    } catch (e) {
      logger.e(e);
    }
    return retList;
  }
}
