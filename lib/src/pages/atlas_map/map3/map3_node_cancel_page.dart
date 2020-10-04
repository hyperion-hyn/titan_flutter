import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/components/quotes/quotes_component.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/atlas_map/entity/atlas_message.dart';
import 'package:titan/src/pages/atlas_map/entity/enum_atlas_type.dart';
import 'package:titan/src/pages/atlas_map/entity/pledge_map3_entity.dart';
import 'package:titan/src/pages/node/model/enum_state.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'package:titan/src/widget/round_border_textfield.dart';
import 'map3_node_confirm_page.dart';
import 'map3_node_public_widget.dart';

class Map3NodeCancelPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _Map3NodeCancelState();
  }
}

class _Map3NodeCancelState extends State<Map3NodeCancelPage> {
  TextEditingController _textEditingController = new TextEditingController();
  final _formKey = GlobalKey<FormState>();
  double minTotal = 0;
  double remainTotal = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var ethQuotePrice = QuotesInheritedModel.of(context).activatedQuoteVoAndSign('ETH')?.quoteVo?.price ?? 0; //
    var coinVo = WalletInheritedModel.of(context).getCoinVoOfHyn();

    return Scaffold(
      appBar: BaseAppBar(
        baseTitle: '撤销抵押',
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          Expanded(
            child: BaseGestureDetector(
              context: context,
              child: SingleChildScrollView(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  color: Colors.white,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, top: 18),
                        child: Row(
                          children: <Widget>[
                            Text("到账钱包", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, top: 16, right: 8, bottom: 18),
                        child: Row(
                          children: <Widget>[
                            Image.asset(
                              "res/drawable/map3_node_default_avatar.png",
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
                                  TextSpan(text: "大道至简", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                                  TextSpan(text: "", style: TextStyles.textC333S14bold),
                                ])),
                                Container(
                                  height: 4,
                                ),
                                Text("${UiUtil.shortEthAddress("钱包地址 oxfdaf89fda47sn43sff", limitLength: 9)}",
                                    style: TextStyles.textC9b9b9bS12),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                  child: Container(
                    color: HexColor("#F4F4F4"),
                  ),
                ),
                Container(
                  color: Colors.white,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, top: 16),
                        child: Row(
                          children: <Widget>[
                            Text("节点金额", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, top: 12),
                        child: profitListBigLightWidget(
                          [
                            {"节点总抵押": "900,000"},
                            {"我的抵押": "300,000"},
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, top: 18),
                        child: Row(
                          children: <Widget>[
                            Text("撤销数量", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, top: 16, right: 18),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              "HYN",
                              style: TextStyle(fontSize: 18, color: HexColor("#35393E")),
                            ),
                            SizedBox(
                              width: 12,
                            ),
                            Flexible(
                              flex: 1,
                              child: Form(
                                key: _formKey,
                                child: RoundBorderTextField(
                                  controller: _textEditingController,
                                  keyboardType: TextInputType.number,
                                  //inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                                  hint: "请输入提币数量",
                                  validator: (textStr) {
                                    if (textStr.length == 0) {
                                      return S.of(context).please_input_hyn_count;
                                    } /*else if (minTotal == 0) {
                                      return "抵押已满";
                                    } else if (int.parse(textStr) < minTotal) {
                                      return S.of(context).mintotal_hyn(FormatUtil.formatNumDecimal(minTotal));
                                    } else if (int.parse(textStr) > remainTotal) {
                                      return "不能超过剩余份额";
                                    } else if (Decimal.parse(textStr) >
                                        Decimal.parse(FormatUtil.coinBalanceHumanRead(coinVo))) {
                                      return S.of(context).hyn_balance_no_enough;
                                    }*/
                                    else {
                                      return null;
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, top: 12, bottom: 18, right: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(
                              width: 48,
                            ),
                            /*Text(
                              "*",
                              style: TextStyle(fontSize: 22, color: HexColor("#FF4C3B")),
                            ),
                            SizedBox(
                              width: 12,
                            ),*/
                            Expanded(
                              child: Text(
                                "撤销剩余量不能少于20,0000",
                                //"撤销抵押将会影响节点进度，剩余抵押不足20%节点将会被取消",
                                style: TextStyle(fontSize: 12, color: HexColor("#999999"), height: 1.5),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ])),
            ),
          ),
          _confirmButtonWidget(),
        ],
      ),
    );
  }

  Widget _confirmButtonWidget() {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 18.0, top: 10),
        child: Center(
          child: ClickOvalButton(
            "确认撤销",
            () {
              if (!_formKey.currentState.validate()) {
                return;
              }

              var amount = _textEditingController?.text ?? "200000";

              var entity = PledgeMap3Entity.onlyType(AtlasActionType.CANCEL_MAP3_NODE);
              entity.payload = PledgeMap3Payload("abc", amount);
              entity.amount = amount;
              var message = ConfirmCancelMap3NodeMessage(
                entity: entity,
                map3NodeAddress: "xxx",
              );
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Map3NodeConfirmPage(
                      message: message,
                    ),
                  ));
            },
            height: 46,
            width: MediaQuery.of(context).size.width - 37 * 2,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
