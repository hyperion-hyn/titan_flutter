import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/quotes/bloc/bloc.dart';
import 'package:titan/src/components/quotes/quotes_component.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/components/wallet/vo/coin_vo.dart';
import 'package:titan/src/components/wallet/vo/wallet_vo.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/atlas_map/entity/create_map3_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/tx_hash_entity.dart';
import 'package:titan/src/pages/node/model/contract_node_item.dart';
import 'package:titan/src/pages/node/model/enum_state.dart';
import 'package:titan/src/config/extends_icon_font.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/plugins/wallet/wallet_const.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/utils/utils.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';

class Map3NodeFormalConfirmPage extends StatefulWidget {
  final CoinVo coinVo;
  final Decimal transferAmount;
  final String receiverAddress;
  final Map3NodeActionEvent actionEvent;
  final String contractId;
  final ContractNodeItem contractNodeItem;
  final String atlasNodeId;
  final CreateMap3Entity createMap3Entity;
//  Map3NodeSendConfirmPage(
//      String coinVo, [this.contractNodeItem, this.transferAmount, this.receiverAddress, this.actionEvent, this.contractId])
//      : coinVo = CoinVo.fromJson(FluroConvertUtils.string2map(coinVo));
//
  Map3NodeFormalConfirmPage({
    this.coinVo,
    this.contractNodeItem,
    this.transferAmount,
    this.receiverAddress,
    this.actionEvent,
    this.contractId,
    this.atlasNodeId,
    this.createMap3Entity,
  });

  @override
  State<StatefulWidget> createState() {
    return _Map3NodeFormalConfirmState();
  }
}

class _Map3NodeFormalConfirmState extends BaseState<Map3NodeFormalConfirmPage> {
  AtlasApi _atlasApi = AtlasApi();
  double ethFee = 0.0;
  double currencyFee = 0.0;

  var _isTransferring = false;
  var isLoadingGasFee = false;

  int selectedPriceLevel = 2;

  WalletVo activatedWallet;

  List<String> _titleList = ["From", "To", ""];
  List<String> _subList = ["钱包", "Map3节点", "矿工费"];
  List<String> _detailList = ["Star01 (89hfisbjgiw…2owooe8)", "节点号: PB2020", "0.0000021 HYN"];
  String _pageTitle = "";
  var gasPriceRecommend;

  @override
  void onCreated() {
    activatedWallet = WalletInheritedModel.of(context).activatedWallet;
    var myActiveShortAddr = shortBlockChainAddress(activatedWallet.wallet.getEthAccount().address);
    switch (widget.actionEvent) {
//      case Map3NodeActionEvent.DELEGATE:
//        _pageTitle = S.of(context).transfer_confirm;
//        break;
      case Map3NodeActionEvent.COLLECT:
        _pageTitle = "提取奖励";
        break;
      case Map3NodeActionEvent.CANCEL:
        break;
      case Map3NodeActionEvent.CANCEL_CONFIRMED:
        break;
      case Map3NodeActionEvent.ADD:
        break;
      case Map3NodeActionEvent.RECEIVE_AWARD:
        _pageTitle = "提取奖励";
        _subList[0] = "Atlas节点";
        _subList[1] = "钱包";
        _detailList = [
          "节点号: ${widget.atlasNodeId}",
          "${activatedWallet.wallet.keystore.name} ($myActiveShortAddr})",
          "${widget.transferAmount} HYN"
        ];
        break;
      case Map3NodeActionEvent.EDIT_ATLAS:
        _pageTitle = "确认编辑Atlas节点";
        _subList[1] = "Atlas节点";
        _detailList = [
          "${activatedWallet.wallet.keystore.name} ($myActiveShortAddr)",
          "节点号: ${widget.atlasNodeId}",
          "${widget.transferAmount} HYN"
        ];
        break;
      case Map3NodeActionEvent.ACTIVE_NODE:
        _pageTitle = "激活节点";
        _subList[1] = "Atlas链";
        _detailList = [
          "${activatedWallet.wallet.keystore.name} ($myActiveShortAddr)",
          "",
          "${widget.transferAmount} HYN"
        ];
        break;
      case Map3NodeActionEvent.STAKE_ATLAS:
        _pageTitle = "激活节点";
        _subList[1] = "Atlas链";
        _detailList = [
          "${activatedWallet.wallet.keystore.name} ($myActiveShortAddr)",
          "",
          "${widget.transferAmount} HYN"
        ];
        break;
      case Map3NodeActionEvent.EXCHANGE_HYN:
        _pageTitle = "兑换HYN";
        _titleList[2] = "网络费用";
        _subList = ["ERC20钱包", "主链钱包", ""];
        _detailList = [
          "${activatedWallet.wallet.keystore.name} ($myActiveShortAddr)",
          "${activatedWallet.wallet.keystore.name} ($myActiveShortAddr)",
          ""
        ];
        break;

      case Map3NodeActionEvent.PRE_EDIT:
        _pageTitle = "修改预设";
        _subList[1] = "Atlas节点";
        _subList[0] = "钱包";
        _detailList = [
          "${activatedWallet.wallet.keystore.name} ($myActiveShortAddr)",
          "${activatedWallet.wallet.keystore.name} ($myActiveShortAddr)",
          ""
        ];
        break;

      default:
        _pageTitle = S.of(context).transfer_confirm;
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    BlocProvider.of<QuotesCmpBloc>(context).add(UpdateGasPriceEvent());
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return !_isTransferring;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: BaseAppBar(
          baseTitle: _pageTitle,
        ),
        body: _pageView(context),
      ),
    );
  }

  Widget _pageView(BuildContext context) {
    var activatedWallet = WalletInheritedModel.of(context).activatedWallet;
    //var walletName = activatedWallet.wallet.keystore.name;

    if (widget.actionEvent == Map3NodeActionEvent.EXCHANGE_HYN) {
      var activatedQuoteSign = QuotesInheritedModel.of(context).activeQuotesSign;
      var ethQuotePrice = QuotesInheritedModel.of(context).activatedQuoteVoAndSign('ETH')?.quoteVo?.price ?? 0;
      var quoteSign = activatedQuoteSign?.sign;
      gasPriceRecommend = QuotesInheritedModel.of(context, aspect: QuotesAspect.gasPrice).gasPriceRecommend;
      var gasLimit = SettingInheritedModel.ofConfig(context).systemConfigEntity.ethTransferGasLimit;
      var gasEstimate = ConvertTokenUnit.weiToEther(
          weiBigInt: BigInt.parse((gasPrice * Decimal.fromInt(gasLimit)).toStringAsFixed(0)));
      var gasPriceEstimate = gasEstimate * Decimal.parse(ethQuotePrice.toString());
      var gasPriceEstimateStr =
          "${(gasPrice / Decimal.fromInt(TokenUnit.G_WEI)).toStringAsFixed(1)} GWEI (≈ $quoteSign ${FormatUtil.formatPrice(gasPriceEstimate.toDouble())})";
      _subList[2] = gasPriceEstimateStr;
    }
    return Column(
      children: <Widget>[
        Expanded(
          child: CustomScrollView(
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: Container(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _headerWidget(),
                  ]),
                ),
              ),
              SliverToBoxAdapter(
                child: ListView.separated(
                  itemBuilder: (context, index) {
                    var title = _titleList[index];
                    var subTitle = _subList[index];
                    var detail = _detailList[index];
                    return Container(
                      color: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                        child: Row(
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                if (title.isNotEmpty)
                                  Row(
                                    children: <Widget>[
                                      Text(
                                        title,
                                        style: TextStyle(color: HexColor("#999999"), fontSize: 14),
                                      ),
                                    ],
                                  ),
                                SizedBox(
                                  height: 4,
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                Row(
                                  children: <Widget>[
                                    Text(
                                      subTitle,
                                      style: TextStyle(color: HexColor("#333333"), fontSize: 14),
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Text(
                                      detail,
                                      style: TextStyle(color: HexColor("#999999"), fontSize: 14),
                                    ),
                                  ],
                                )
                              ],
                            )

                            //Spacer(),
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return Divider(
                      height: 0.5,
                      color: HexColor("#F2F2F2"),
                    );
                  },
                  itemCount: _subList.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                ),
              ),
              if (widget.actionEvent == Map3NodeActionEvent.EXCHANGE_HYN)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                                  color: selectedPriceLevel == 0 ? Colors.grey : Colors.grey[200],
                                  border: Border(),
                                  borderRadius:
                                      BorderRadius.only(topLeft: Radius.circular(30), bottomLeft: Radius.circular(30))),
                              child: Column(
                                children: <Widget>[
                                  Text(
                                    S.of(context).speed_slow,
                                    style: TextStyle(
                                        color: selectedPriceLevel == 0 ? Colors.white : Colors.black, fontSize: 12),
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
                                  color: selectedPriceLevel == 1 ? Colors.grey : Colors.grey[200],
                                  border: Border(),
                                  borderRadius: BorderRadius.all(Radius.circular(0))),
                              child: Column(
                                children: <Widget>[
                                  Text(
                                    S.of(context).speed_normal,
                                    style: TextStyle(
                                        color: selectedPriceLevel == 1 ? Colors.white : Colors.black, fontSize: 12),
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
                                  color: selectedPriceLevel == 2 ? Colors.grey : Colors.grey[200],
                                  border: Border(),
                                  borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(30), bottomRight: Radius.circular(30))),
                              child: Column(
                                children: <Widget>[
                                  Text(
                                    S.of(context).speed_fast,
                                    style: TextStyle(
                                        color: selectedPriceLevel == 2 ? Colors.white : Colors.black, fontSize: 12),
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
                  ),
                )
            ],
          ),
        ),
        _confirmButtonWidget(),
      ],
    );
  }

  Decimal get gasPrice {
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

  void _speedOnTap(int index) {
    setState(() {
      selectedPriceLevel = index;
    });
  }

  Widget _headerWidget() {
    var activatedQuoteSign = QuotesInheritedModel.of(context).activatedQuoteVoAndSign(widget.coinVo?.symbol ?? "btc");
    var quotePrice = activatedQuoteSign?.quoteVo?.price ?? 0;
    var quoteSign = activatedQuoteSign?.sign?.sign;

    //SettingInheritedModel.ofConfig(context).systemConfigEntity.createMap3NodeGasLimit;

    //var pre = widget.actionEvent != Map3NodeActionEvent.COLLECT ? "-" : "+";
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
                    "-${widget.transferAmount} ${widget.coinVo?.symbol ?? "HYN"}",
                    style: TextStyle(color: Color(0xFF252525), fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
                Text(
                  "≈ $quoteSign${FormatUtil.formatPrice(widget.transferAmount ?? 0.toDouble() * quotePrice)}",
                  style: TextStyle(color: Color(0xFF9B9B9B), fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _confirmButtonWidget() {
    var activatedWallet = WalletInheritedModel.of(context).activatedWallet;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 37, vertical: 18),
      child: ClickOvalButton(
        S.of(context).submit,
        () async {
          try {
            var password = await UiUtil.showWalletPasswordDialogV2(context, activatedWallet.wallet);
            if (password == null) {
              return;
            }

            // todo: sign transfer
            switch (widget.actionEvent) {
              case Map3NodeActionEvent.CREATE:
                TxHashEntity txHashEntity = await _atlasApi.postCreateMap3Node(widget.createMap3Entity);
                print("[Confirm] txHashEntity:${txHashEntity.txHash}");
                break;

              case Map3NodeActionEvent.DELEGATE:
                break;
              case Map3NodeActionEvent.COLLECT:
                break;
              case Map3NodeActionEvent.CANCEL:
                break;
              case Map3NodeActionEvent.CANCEL_CONFIRMED:
                break;
              case Map3NodeActionEvent.ADD:
                break;
              case Map3NodeActionEvent.RECEIVE_AWARD:
                break;
              case Map3NodeActionEvent.EDIT_ATLAS:
                break;
              case Map3NodeActionEvent.ACTIVE_NODE:
//                await _atlasApi.activeAtlasNode(entity);
                break;
              case Map3NodeActionEvent.STAKE_ATLAS:
                break;
            }

            var contractNodeItem = ContractNodeItem.onlyNodeId(1);
            Application.router.navigateTo(
                context,
                Routes.map3node_broadcast_success_page +
                    "?actionEvent=${widget.actionEvent}" +
                    "&contractNodeItem=${FluroConvertUtils.object2string(contractNodeItem.toJson())}");
          } catch (error) {}
        },
        height: 46,
        width: MediaQuery.of(context).size.width - 37 * 2,
        fontSize: 18,
      ),
    );
  }
}
