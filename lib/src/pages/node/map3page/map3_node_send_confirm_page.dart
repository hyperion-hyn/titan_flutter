import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/quotes/bloc/bloc.dart';
import 'package:titan/src/components/quotes/model.dart';
import 'package:titan/src/components/quotes/quotes_component.dart';
import 'package:titan/src/components/wallet/vo/coin_vo.dart';
import 'package:titan/src/components/wallet/vo/wallet_vo.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/node/api/node_api.dart';
import 'package:titan/src/pages/node/model/contract_detail_item.dart';
import 'package:titan/src/pages/node/model/contract_node_item.dart';
import 'package:titan/src/pages/node/model/start_join_instance.dart';
import 'package:titan/src/plugins/wallet/wallet_const.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/config/extends_icon_font.dart';
import 'package:titan/src/utils/utils.dart';
import 'package:titan/src/widget/enter_wallet_password.dart';
import 'package:web3dart/json_rpc.dart';

import 'map3_node_create_contract_page.dart';

class Map3NodeSendConfirmPage extends StatefulWidget {
  final CoinVo coinVo;
  final Decimal transferAmount;
  final String receiverAddress;
  final String pageType;
  final String contractId;
  final String provider;
  final String region;
  final ContractNodeItem contractNodeItem;

  Map3NodeSendConfirmPage(
      String coinVo, this.contractNodeItem, this.transferAmount, this.receiverAddress, this.pageType, this.contractId,
      {this.provider, this.region})
      : coinVo = CoinVo.fromJson(FluroConvertUtils.string2map(coinVo));

  @override
  State<StatefulWidget> createState() {
    return _Map3NodeSendConfirmState();
  }
}

class _Map3NodeSendConfirmState extends BaseState<Map3NodeSendConfirmPage> {
  double ethFee = 0.0;
  double currencyFee = 0.0;

  var _isTransferring = false;
  var isLoadingGasFee = false;

  int selectedPriceLevel = 1;

  WalletVo activatedWallet;
  ActiveQuoteVoAndSign activatedQuoteSign;
  NodeApi _nodeApi = NodeApi();

  @override
  void onCreated() {
    activatedQuoteSign = QuotesInheritedModel.of(context).activatedQuoteVoAndSign(widget.coinVo.symbol);
    activatedWallet = WalletInheritedModel.of(context).activatedWallet;

    _speedOnTap(1);
  }

  @override
  void initState() {
    super.initState();
    BlocProvider.of<QuotesCmpBloc>(context).add(UpdateGasPriceEvent());
  }

  Decimal get gasPrice {
    var gasPriceRecommend = QuotesInheritedModel.of(context, aspect: QuotesAspect.gasPrice).gasPriceRecommend;
    switch (selectedPriceLevel) {
      case 0:
        return gasPriceRecommend.safeLow;
      case 1:
        return gasPriceRecommend.average;
      case 2:
        return gasPriceRecommend.fast;
      default:
        return gasPriceRecommend.average;
    }
  }

  @override
  Widget build(BuildContext context) {
    var activatedQuoteSign = QuotesInheritedModel.of(context).activatedQuoteVoAndSign(widget.coinVo.symbol);
    var quotePrice = activatedQuoteSign?.quoteVo?.price ?? 0;
    var quoteSign = activatedQuoteSign?.sign?.sign;
    var gasPriceRecommend = QuotesInheritedModel.of(context, aspect: QuotesAspect.gasPrice).gasPriceRecommend;

    var totalGasLimit = EthereumConst.ERC20_TRANSFER_GAS_LIMIT + EthereumConst.CREATE_MAP3_NODE_GAS_LIMIT;
    var gasEstimate = ConvertTokenUnit.weiToEther(
        weiBigInt: BigInt.parse((gasPrice * Decimal.fromInt(totalGasLimit)).toStringAsFixed(0)));

    var ethQuotePrice = QuotesInheritedModel.of(context).activatedQuoteVoAndSign('ETH')?.quoteVo?.price ?? 0; //

    var gasPriceEstimate = gasEstimate * Decimal.parse(ethQuotePrice.toString());

    return WillPopScope(
      onWillPop: () async {
        return !_isTransferring;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          centerTitle: true,
          title: Text(
            S.of(context).transfer_confirm,
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      color: Color(0xFFF5F5F5),
                      padding: const EdgeInsets.only(top: 24, bottom: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            ExtendsIconFont.send,
                            color: Theme.of(context).primaryColor,
                            size: 48,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                            child: Text(
                              "-${widget.transferAmount} ${widget.coinVo.symbol}",
                              style: TextStyle(color: Color(0xFF252525), fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                          ),
                          Text(
                            "≈ $quoteSign${WalletUtil.formatPrice(widget.transferAmount.toDouble() * quotePrice)}",
                            style: TextStyle(color: Color(0xFF9B9B9B), fontSize: 14),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            "From",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal, color: Color(0xFF9B9B9B)),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            "${activatedWallet.wallet.keystore.name}(${shortBlockChainAddress(widget.coinVo.address)})",
                            style: TextStyle(fontSize: 16, color: Color(0xFF252525)),
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
              Divider(
                height: 2,
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            "To",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal, color: Color(0xFF9B9B9B)),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            S.of(context).map_node_contract_address(shortBlockChainAddress(widget.receiverAddress)),
                            style: TextStyle(fontSize: 16, color: Color(0xFF252525)),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
              Divider(
                height: 2,
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        S.of(context).gas_fee,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal, color: Color(0xFF9B9B9B)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            alignment: Alignment.centerLeft,
                            height: 24,
                            child: Text(
                              "${(gasPrice / Decimal.fromInt(TokenUnit.G_WEI)).toStringAsFixed(1)} GWEI (≈ $quoteSign${WalletUtil.formatPrice(gasPriceEstimate.toDouble())})",
                              style: TextStyle(fontSize: 16, color: Color(0xFF252525)),
                            ),
                          ),
                          if (isLoadingGasFee)
                            Container(
                              width: 24,
                              height: 24,
                              child: CupertinoActivityIndicator(),
                            )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                _speedOnTap(0);
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 4),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: gasPrice == gasPriceRecommend.safeLow ? Colors.grey : Colors.grey[200],
                                    border: Border(),
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(30), bottomLeft: Radius.circular(30))),
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      S.of(context).speed_slow,
                                      style: TextStyle(
                                          color: gasPrice == gasPriceRecommend.safeLow ? Colors.white : Colors.black,
                                          fontSize: 12),
                                    ),
                                    Text(
                                      S.of(context).wait_min(gasPriceRecommend.safeLowWait.toString()),
                                      style: TextStyle(fontSize: 10, color: Colors.black38),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          VerticalDivider(
                            width: 1,
                            thickness: 2,
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                _speedOnTap(1);
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 4),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: gasPrice == gasPriceRecommend.average ? Colors.grey : Colors.grey[200],
                                    border: Border(),
                                    borderRadius: BorderRadius.all(Radius.circular(0))),
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      S.of(context).speed_normal,
                                      style: TextStyle(
                                          color: gasPrice == gasPriceRecommend.average ? Colors.white : Colors.black,
                                          fontSize: 12),
                                    ),
                                    Text(
                                      S.of(context).wait_min(gasPriceRecommend.avgWait.toString()),
                                      style: TextStyle(fontSize: 10, color: Colors.black38),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          VerticalDivider(
                            width: 1,
                            thickness: 2,
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                _speedOnTap(2);
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 4),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: gasPrice == gasPriceRecommend.fast ? Colors.grey : Colors.grey[200],
                                    border: Border(),
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(30), bottomRight: Radius.circular(30))),
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      S.of(context).speed_fast,
                                      style: TextStyle(
                                          color: gasPrice == gasPriceRecommend.fast ? Colors.white : Colors.black,
                                          fontSize: 12),
                                    ),
                                    Text(
                                      S.of(context).wait_min(gasPriceRecommend.fastWait.toString()),
                                      style: TextStyle(fontSize: 10, color: Colors.black38),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 36,
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 36, horizontal: 36),
                constraints: BoxConstraints.expand(height: 48),
                child: RaisedButton(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  disabledColor: Colors.grey[600],
                  color: Theme.of(context).primaryColor,
                  textColor: Colors.white,
                  disabledTextColor: Colors.white,
                  onPressed: _isTransferring ? null : _transferNew,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          _isTransferring ? S.of(context).please_waiting : S.of(context).send,
                          style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _speedOnTap(int index) {
    setState(() {
      selectedPriceLevel = index;
    });
  }

  Future _transferNew() async {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return EnterWalletPasswordWidget();
        }).then((walletPassword) async {
      if (walletPassword == null) {
        return;
      }

      try {
        if (mounted) {
          setState(() {
            _isTransferring = true;
          });
        }

        var startJoin =
            StartJoinInstance(activatedWallet.wallet.getEthAccount().address, widget.provider, widget.region);
        //ContractDetailItem _detailItem;
        String resultMsg = "";
        ContractNodeItem contractNodeItem;
        if (widget.pageType == Map3NodeCreateContractPage.CONTRACT_PAGE_TYPE_CREATE) {
          contractNodeItem = await _nodeApi.startContractInstance(widget.contractNodeItem, activatedWallet,
              walletPassword, gasPrice.toInt(), widget.contractId, startJoin, widget.transferAmount);
          print("creat post result = $resultMsg");
        } else {
          contractNodeItem = widget.contractNodeItem;
          resultMsg = await _nodeApi.joinContractInstance(widget.contractNodeItem, activatedWallet, walletPassword,
              gasPrice.toInt(), widget.contractNodeItem.owner, widget.contractId, widget.transferAmount);
          print("join post result = $resultMsg");
        }
        Application.router.navigateTo(
            context,
            Routes.map3node_broadcase_success_page +
                "?pageType=${widget.pageType}" +
                "&contractNodeItem=${FluroConvertUtils.object2string(contractNodeItem.toJson())}");
      } catch (_) {
        logger.e(_);

        if (mounted) {
          setState(() {
            _isTransferring = false;
          });
        }

        if (_ is PlatformException) {
          if (_.code == WalletError.PASSWORD_WRONG) {
            Fluttertoast.showToast(msg: S.of(context).password_incorrect);
          } else {
            Fluttertoast.showToast(msg: S.of(context).transfer_fail);
          }
        } else if (_ is RPCError) {
          if (_.errorCode == -32000) {
//            Fluttertoast.showToast(msg: S.of(context).eth_balance_not_enough_for_gas_fee);
            Fluttertoast.showToast(msg: _.message, toastLength: Toast.LENGTH_LONG);
          } else {
            Fluttertoast.showToast(msg: S.of(context).transfer_fail);
          }
        } else {
          Fluttertoast.showToast(msg: S.of(context).transfer_fail);
        }
      }
    });
  }
}
