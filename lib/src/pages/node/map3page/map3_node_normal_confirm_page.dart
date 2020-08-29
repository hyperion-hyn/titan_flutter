import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/quotes/bloc/bloc.dart';
import 'package:titan/src/components/quotes/model.dart';
import 'package:titan/src/components/quotes/quotes_component.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/components/wallet/vo/coin_vo.dart';
import 'package:titan/src/components/wallet/vo/wallet_vo.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/node/model/contract_node_item.dart';
import 'package:titan/src/pages/node/model/enum_state.dart';
import 'package:titan/src/config/extends_icon_font.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';

class Map3NodeNormalConfirmPage extends StatefulWidget {
  final CoinVo coinVo;
  final Decimal transferAmount;
  final String receiverAddress;
  final Map3NodeActionEvent actionEvent;
  final String contractId;
  final ContractNodeItem contractNodeItem;
  final String atlasNodeId;

//  Map3NodeSendConfirmPage(
//      String coinVo, [this.contractNodeItem, this.transferAmount, this.receiverAddress, this.actionEvent, this.contractId])
//      : coinVo = CoinVo.fromJson(FluroConvertUtils.string2map(coinVo));
//
  Map3NodeNormalConfirmPage(
      {this.coinVo,
      this.contractNodeItem,
      this.transferAmount,
      this.receiverAddress,
      this.actionEvent,
      this.contractId,
      this.atlasNodeId});

  @override
  State<StatefulWidget> createState() {
    return _Map3NodeNormalConfirmState();
  }
}

class _Map3NodeNormalConfirmState extends BaseState<Map3NodeNormalConfirmPage> {
  double ethFee = 0.0;
  double currencyFee = 0.0;

  var _isTransferring = false;
  var isLoadingGasFee = false;

  int selectedPriceLevel = 2;

  WalletVo activatedWallet;
  ActiveQuoteVoAndSign activatedQuoteSign;

  List<String> _titleList = ["From", "To", ""];
  List<String> _subList = ["钱包", "Map3节点", "矿工费"];
  List<String> _detailList = ["Star01 (89hfisbjgiw…2owooe8)", "节点号: PB2020", "0.0000021 HYN"];
  String _pageTitle = "";

  @override
  void onCreated() {
    activatedQuoteSign = QuotesInheritedModel.of(context).activatedQuoteVoAndSign(widget.coinVo?.symbol ?? "btc");
    activatedWallet = WalletInheritedModel.of(context).activatedWallet;
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
        _pageTitle = "确认领取节点奖励";
        _detailList = [
          "${activatedWallet.wallet.keystore.name} (${activatedWallet.wallet.getEthAccount().address})",
          "节点号: ${widget.atlasNodeId}",
          "${widget.transferAmount} HYN"
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
    var walletName = activatedWallet.wallet.keystore.name;

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
            ],
          ),
        ),
        _confirmButtonWidget(),
      ],
    );
  }

  Widget _headerWidget() {
    var activatedQuoteSign = QuotesInheritedModel.of(context).activatedQuoteVoAndSign(widget.coinVo?.symbol ?? "btc");
    var quotePrice = activatedQuoteSign?.quoteVo?.price ?? 0;
    var quoteSign = activatedQuoteSign?.sign?.sign;

    SettingInheritedModel.ofConfig(context).systemConfigEntity.createMap3NodeGasLimit;

    var pre = widget.actionEvent != Map3NodeActionEvent.COLLECT ? "-" : "+";
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
                    pre + "${widget.transferAmount} ${widget.coinVo?.symbol ?? "HYN"}",
                    style: TextStyle(color: Color(0xFF252525), fontWeight: FontWeight.w600, fontSize: 20),
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
          var contractNodeItem = ContractNodeItem.onlyNodeId(1);
          Application.router.navigateTo(
              context,
              Routes.map3node_broadcast_success_page +
                  "?actionEvent=${widget.actionEvent}" +
                  "&contractNodeItem=${FluroConvertUtils.object2string(contractNodeItem.toJson())}");
        },
        height: 46,
        width: MediaQuery.of(context).size.width - 37 * 2,
        fontSize: 18,
      ),
    );
  }
}
