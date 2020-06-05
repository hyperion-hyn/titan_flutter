import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/quotes/bloc/bloc.dart';
import 'package:titan/src/components/quotes/model.dart';
import 'package:titan/src/components/quotes/quotes_component.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/components/wallet/vo/coin_vo.dart';
import 'package:titan/src/components/wallet/vo/wallet_vo.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/data/cache/memory_cache.dart';
import 'package:titan/src/pages/node/api/node_api.dart';
import 'package:titan/src/pages/node/model/contract_node_item.dart';
import 'package:titan/src/pages/node/model/enum_state.dart';
import 'package:titan/src/pages/node/model/node_item.dart';
import 'package:titan/src/pages/node/model/start_join_instance.dart';
import 'package:titan/src/plugins/wallet/wallet_const.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/config/extends_icon_font.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/widget/click_rectangle_button.dart';
import 'package:titan/src/widget/enter_wallet_password.dart';
import 'package:titan/src/widget/gas_input_widget.dart';
import 'package:web3dart/json_rpc.dart';

import 'map3_node_create_contract_page.dart';

class Map3NodeSendConfirmPage extends StatefulWidget {
  final CoinVo coinVo;
  final Decimal transferAmount;
  final String receiverAddress;
  final Map3NodeActionEvent actionEvent;
  final String contractId;
  final ContractNodeItem contractNodeItem;

  Map3NodeSendConfirmPage(
      String coinVo, this.contractNodeItem, this.transferAmount, this.receiverAddress, this.actionEvent, this.contractId)
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

  int selectedPriceLevel = 2;

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
              _headerWidget(),
              _dividerWidget(),
              _nodeWidget(context, widget.contractNodeItem.contract),
              _dividerWidget(),
              _gasInputWidget(),
              _dividerWidget(),
              _sendWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _gasInputWidget() {
    var activatedQuoteSign = QuotesInheritedModel.of(context).activatedQuoteVoAndSign(widget.coinVo.symbol);
    var quotePrice = activatedQuoteSign?.quoteVo?.price ?? 0;
    var quoteSign = activatedQuoteSign?.sign?.sign;

    var totalGasLimit = SettingInheritedModel.ofConfig(context).systemConfigEntity.erc20TransferGasLimit +
        SettingInheritedModel.ofConfig(context).systemConfigEntity.createMap3NodeGasLimit;
    var gasEstimate = ConvertTokenUnit.weiToEther(
        weiBigInt: BigInt.parse((gasPrice * Decimal.fromInt(totalGasLimit)).toStringAsFixed(0)));

    var ethQuotePrice = QuotesInheritedModel.of(context).activatedQuoteVoAndSign('ETH')?.quoteVo?.price ?? 0; //

    var gasPriceEstimate = gasEstimate * Decimal.parse(ethQuotePrice.toString());

    print("[confirm] gasPriceEstimate:$gasPriceEstimate, ethQuotePrice:$ethQuotePrice");

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GasInputWidget(
          currentEthPrice: ethQuotePrice,
          callback: (double gasPrice, double gasPriceLimit) {
            print("[input] gasPrice:$gasPrice, gasPriceLimit:$gasPriceLimit");
          }),
    );
  }


  Widget _sendWidget() {
    return ClickRectangleButton(S.of(context).send,()async{
      await _transferNew();
    });
  }

  Widget _dividerWidget() {
    return SizedBox(
      height: 10,
      child: Container(
        color: HexColor("#F4F4F4"),
      ),
    );
  }

  Widget _headerWidget() {
    //var gasPriceRecommend = QuotesInheritedModel.of(context, aspect: QuotesAspect.gasPrice).gasPriceRecommend;
    var activatedQuoteSign = QuotesInheritedModel.of(context).activatedQuoteVoAndSign(widget.coinVo.symbol);
    var quotePrice = activatedQuoteSign?.quoteVo?.price ?? 0;
    var quoteSign = activatedQuoteSign?.sign?.sign;

    var totalGasLimit = SettingInheritedModel.ofConfig(context).systemConfigEntity.erc20TransferGasLimit +
        SettingInheritedModel.ofConfig(context).systemConfigEntity.createMap3NodeGasLimit;
    var gasEstimate = ConvertTokenUnit.weiToEther(
        weiBigInt: BigInt.parse((gasPrice * Decimal.fromInt(totalGasLimit)).toStringAsFixed(0)));

    var ethQuotePrice = QuotesInheritedModel.of(context).activatedQuoteVoAndSign('ETH')?.quoteVo?.price ?? 0; //

    var gasPriceEstimate = gasEstimate * Decimal.parse(ethQuotePrice.toString());

    print("[confirm] gasPriceEstimate:$gasPriceEstimate, ethQuotePrice:$ethQuotePrice");

    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            //color: Color(0xFFF5F5F5),
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
                  "≈ $quoteSign${FormatUtil.formatPrice(widget.transferAmount.toDouble() * quotePrice)}",
                  style: TextStyle(color: Color(0xFF9B9B9B), fontSize: 14),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    "1300（合约余额）+7000（钱包转入）",
                    style: TextStyle(color: HexColor("#333333"), fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _speedOnTap(int index) {
    setState(() {
      selectedPriceLevel = index;
    });
  }

  Future _transferNew() async {
    // todo: test_jison_0526
    Application.router.navigateTo(
        context,
        Routes.map3node_broadcast_success_page +
            "?actionEvent=${widget.actionEvent}" +
            "&contractNodeItem=${FluroConvertUtils.object2string(widget.contractNodeItem.toJson())}");
    return;

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
            StartJoinInstance(activatedWallet.wallet.getEthAccount().address, widget.contractNodeItem.nodeProvider, widget.contractNodeItem.nodeRegion);
        //ContractDetailItem _detailItem;
        String resultMsg = "";
        ContractNodeItem contractNodeItem;
        if (widget.actionEvent == Map3NodeActionEvent.CREATE) {
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
            Routes.map3node_broadcast_success_page +
                "?actionEvent=${widget.actionEvent}" +
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
          Fluttertoast.showToast(msg: MemoryCache.contractErrorStr(_.message), toastLength: Toast.LENGTH_LONG);

          /*if (_.errorCode == -32000) {
            Fluttertoast.showToast(msg: _.message, toastLength: Toast.LENGTH_LONG);
          } else {
            Fluttertoast.showToast(msg: S.of(context).transfer_fail);
          }*/
        } else {
          Fluttertoast.showToast(msg: S.of(context).transfer_fail);
        }
      }
    });
  }

  Widget _nodeWidget(BuildContext context, NodeItem nodeItem) {

    if (widget.actionEvent == Map3NodeActionEvent.DELEGATE) {
      return Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            _nodeOwnerWidget(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Divider(
                height: 2,
              ),
            ),
          _nodeIntroductionWidget(context, nodeItem),
          ],
        ),
      );
    }

    return Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          _nodeIntroductionWidget(context, nodeItem),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(
              height: 2,
            ),
          ),
          _nodeServerWidget(context, nodeItem),
        ],
      ),
    );
  }

  Widget _nodeOwnerWidget() {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 18, right: 18, bottom: 18),
      child: Row(
        children: <Widget>[
          Image.asset(
            "res/drawable/map3_node_default_avatar_1.png",
            width: 42,
            height: 42,
            fit: BoxFit.cover,
          ),
          SizedBox(
            width: 6,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text.rich(TextSpan(children: [
                TextSpan(text: "派大星", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                TextSpan(
                    text: "  编号 PB2020", style: TextStyle(fontSize: 13, color: HexColor("#333333"))),
              ])),
              Container(
                height: 4,
              ),
              Text("节点地址 oxfdaf89fdaff", style: TextStyles.textC9b9b9bS12),
            ],
          ),
          Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Container(
                color: HexColor("#1FB9C7").withOpacity(0.08),
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text("第一期", style: TextStyle(fontSize: 12, color: HexColor("#5C4304"))),
              ),
              Container(
                height: 4,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _nodeIntroductionWidget(BuildContext context, NodeItem nodeItem) {
    //var nodeItem = widget.contractNodeItem.contract;

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        //mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Image.asset(
            "res/drawable/ic_map3_node_item_2.png",
            width: 62,
            height: 63,
            fit: BoxFit.cover,
          ),
          SizedBox(
            width: 12,
          ),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Expanded(child: Text(nodeItem.name, style: TextStyle(fontWeight: FontWeight.bold)))
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                          "启动所需" +
                              " ${FormatUtil.formatTenThousandNoUnit(nodeItem.minTotalDelegation)}" +
                              S.of(context).ten_thousand,
                          style: TextStyles.textC99000000S13,
                          maxLines: 1,
                          softWrap: true),
                      Text("  |  ", style: TextStyle(fontSize: 12, color: HexColor("000000").withOpacity(0.2))),
                      Text(S.of(context).n_day(nodeItem.duration.toString()), style: TextStyles.textC99000000S13)
                    ],
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: <Widget>[
              Text("${FormatUtil.formatPercent(nodeItem.annualizedYield)}", style: TextStyles.textCff4c3bS20),
              Padding(
                padding: const EdgeInsets.only(top: 3.0),
                child: Text(S.of(context).annualized_rewards, style: TextStyles.textC99000000S13),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _nodeServerWidget(BuildContext context, NodeItem nodeItem) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [1, 2, 3, 4, 5, 6].map((value) {

          var title = "";
          var detail = "";
          switch (value) {
            case 1:
              title = S.of(context).service_provider;
              detail = widget.contractNodeItem.nodeProviderName;
              break;

            case 2:
              title = S.of(context).node_location;
              detail = widget.contractNodeItem.nodeRegionName;
              break;

            case 3:
              title = "管理费";
              print("[confirm] widget.contractNodeItem.commission:${widget.contractNodeItem.commission}");
              detail = FormatUtil.formatPercent(widget.contractNodeItem.commission);
              break;

            case 4:
              title = "自动续约";
              detail = widget.contractNodeItem.renew??false ?"是":"否";
              break;

            case 5:
              title = "节点公告";
              detail = FormatUtil.formatPercent(widget.contractNodeItem.commission);
              var announcement = widget.contractNodeItem.announcement ?? "";
              detail = announcement.isNotEmpty?announcement:"欢迎参加我的合约，前10名参与者返$detail管理。";
              break;

            default:
              return SizedBox(
                height: 8,
              );
              break;
          }

          if (detail == null) {
            detail = "";
          }

          return Padding(
            padding: EdgeInsets.only(top: value == 1 ? 0:12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                    width: 80,
                    child:
                    Text(title, style: TextStyle(fontSize: 14, color: HexColor("#92979A")),)),
                Expanded(child: Text(detail, style: TextStyle(fontSize: 15, color: HexColor("#333333")), maxLines: 2, overflow: TextOverflow.ellipsis,))
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

}

