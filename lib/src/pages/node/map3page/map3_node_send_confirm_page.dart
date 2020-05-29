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
import 'package:titan/src/pages/node/map3page/map3_node_page.dart';
import 'package:titan/src/pages/node/model/contract_detail_item.dart';
import 'package:titan/src/pages/node/model/contract_node_item.dart';
import 'package:titan/src/pages/node/model/node_item.dart';
import 'package:titan/src/pages/node/model/start_join_instance.dart';
import 'package:titan/src/plugins/wallet/wallet_const.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/config/extends_icon_font.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/utils.dart';
import 'package:titan/src/widget/click_rectangle_button.dart';
import 'package:titan/src/widget/enter_wallet_password.dart';
import 'package:titan/src/widget/gas_input_widget.dart';
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
              nodeWidget(context, widget.contractNodeItem.contract),
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
                )
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
    /*Application.router.navigateTo(
        context,
        Routes.map3node_broadcase_success_page +
            "?pageType=${widget.pageType}" +
            "&contractNodeItem=${FluroConvertUtils.object2string(widget.contractNodeItem.toJson())}");
    return;*/

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
}

