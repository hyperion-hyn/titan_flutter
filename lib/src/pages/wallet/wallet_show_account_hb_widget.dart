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
import 'package:titan/src/plugins/wallet/cointype.dart';
import 'package:titan/src/plugins/wallet/config/tokens.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/pages/wallet/service/account_transfer_service.dart';
import 'package:titan/src/pages/wallet/wallet_receive_page.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/utils/utils.dart';

import '../../pages/wallet/model/transtion_detail_vo.dart';
import 'api/hyn_api.dart';

class ShowAccountPage extends StatefulWidget {
  CoinViewVo coinVo;

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
                                "≈ ${activeQuoteVoAndSign?.legal?.legal ?? ''}${FormatUtil.formatPrice(FormatUtil.coinBalanceDouble(widget.coinVo) * (activeQuoteVoAndSign?.price ?? 0))}",
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
      }
    } else if ((widget.coinVo.coinType == CoinType.ETHEREUM && transactionDetail.state == -1)) {
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
                //TODO
                UiUtil.toast('TODO');
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
          // contractAddress: widget.coinVo.contractAddress,
        ));
      }

      retList.addAll(transferList);
    } catch (e, stacktrace) {
      print(stacktrace);
      logger.e(e);
    }
    return retList;
  }

}

Future<List<TransactionDetailVo>> getEthTransferList(AccountTransferService _accountTransferService) async {
  List<TransactionDetailVo> transferList = [];
  try {
    WalletViewVo walletVo = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet;
    String fromAddress = walletVo.wallet.getEthAccount().address;
    var coinVo = CoinViewVo(symbol: "ETH", address: fromAddress);
    transferList = await _accountTransferService.getTransferList(coinVo, 0);
  } catch (e) {
    logger.e(e);
  }
  return transferList;
}
