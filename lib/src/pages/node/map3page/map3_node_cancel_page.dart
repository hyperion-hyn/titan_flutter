import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/components/quotes/quotes_component.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/pages/node/map3page/map3_node_cancel_confirm_page.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/click_oval_button.dart';
import 'package:titan/src/widget/click_rectangle_button.dart';
import 'package:titan/src/widget/enter_wallet_password.dart';
import 'package:titan/src/widget/gas_input_widget.dart';

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
      appBar: AppBar(centerTitle: true, title: Text("撤销抵押")),
      //backgroundColor: Color(0xffF3F0F5),
      body: Column(
        children: <Widget>[
          Expanded(
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [1, 0.5, 2].map((value) {
                          String title = "";
                          String detail = "0";
                          Color color = HexColor("#333333");

                          switch (value) {
                            case 1:
                              title = "节点总抵押";
                              detail = "900,000";
                              color = HexColor("#BF8D2A");
                              break;

                            case 2:
                              title = "我的抵押";
                              detail = "300,000";
                              break;

                            default:
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 30),
                                child: Container(
                                  height: 20,
                                  width: 1.0,
                                  color: HexColor("#000000").withOpacity(0.2),
                                ),
                              );
                              break;
                          }

                          TextStyle style = TextStyle(fontSize: 18, color: color, fontWeight: FontWeight.w600);

                          return Column(
                            children: <Widget>[
                              Text(detail, style: style),
                              Container(
                                height: 4,
                              ),
                              Text(title, style: TextStyles.textC333S11),
                            ],
                          );
                        }).toList(),
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
                      padding: const EdgeInsets.only(left: 16.0, top: 8, right: 18),
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
                              child: TextFormField(
                                controller: _textEditingController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                                decoration: InputDecoration(
                                  focusedErrorBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: HexColor("#FF4C3B")),
                                    borderRadius: BorderRadius.circular(0),
                                  ),
                                  errorStyle: TextStyle(color: HexColor("#FF4C3B"), fontSize: 14),
                                  hintStyle: TextStyle(color: HexColor("#B8B8B8"), fontSize: 12),
                                  labelStyle: TextStyles.textC333S14,
                                  hintText: S.of(context).mintotal_buy(FormatUtil.formatNumDecimal(minTotal)),
                                  //border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                                ),
                                validator: (textStr) {
                                  if (textStr.length == 0) {
                                    return S.of(context).please_input_hyn_count;
                                  } else if (minTotal == 0) {
                                    return "抵押已满";
                                  } else if (int.parse(textStr) < minTotal) {
                                    return S.of(context).mintotal_hyn(FormatUtil.formatNumDecimal(minTotal));
                                  } else if (int.parse(textStr) > remainTotal) {
                                    return "不能超过剩余份额";
                                  } else if (Decimal.parse(textStr) >
                                      Decimal.parse(FormatUtil.coinBalanceHumanRead(coinVo))) {
                                    return S.of(context).hyn_balance_no_enough;
                                  } else {
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
                            width: 30,
                          ),
                          Text(
                            "*",
                            style: TextStyle(fontSize: 22, color: HexColor("#FF4C3B")),
                          ),
                          SizedBox(
                            width: 12,
                          ),
                          Expanded(
                            child: Text(
                              "撤销抵押将会影响节点进度，剩余抵押不足20%节点将会被取消",
                              style: TextStyle(fontSize: 12, color: HexColor("#333333"), height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    )
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: GasInputWidget(
                      currentEthPrice: ethQuotePrice,
                      callback: (double gasPrice, double gasPriceLimit) {
                        print("[input] gasPrice:$gasPrice, gasPriceLimit:$gasPriceLimit");
                      }),
                ),
              ),
            ])),
          ),
          _confirmButtonWidget(),
        ],
      ),
    );
  }

  Widget _confirmButtonWidget() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 4.0,
          ),
        ],
      ),
      constraints: BoxConstraints.expand(height: 50),
      child: RaisedButton(
          textColor: Colors.white,
          color: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColor)),
          child: Text("确认撤销", style: TextStyle(fontSize: 16, color: Colors.white)),
          onPressed: () {

            showAlertView(
                context,
                title: "重要提示",
                actions: [
                  FlatButton(
                    onPressed: () {
                      print("[Alert] --> 确定撤销");
                      Navigator.pop(context);

                      Navigator.push(context, MaterialPageRoute(builder: (context) => Map3NodeCancelConfirmPage()));
                    },
                    child: Text(
                      '确定撤销',
                      style: TextStyle(color: HexColor("#999999"), fontSize: 16),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  ClickOvalButton(
                    "再想想",
                    () {
                      print("[Alert] --> 再想想");
                      Navigator.pop(context);
                    },
                    width: 120,
                    height: 38,
                    fontSize: 16,
                  ),
                ],
                content: "你将撤销全部抵押(20,000HYN) 到原来钱包，且当前节点",
                boldContent: "将被取消",
                suffixContent: "，是否继续操作?");

            /*
            showAlertView(
                context,
                title: "操作错误",
                actions: [
                  ClickOvalButton(
                    "重新输入",
                    () {
                      print("[Alert] --> 再想想");
                      Navigator.pop(context);
                    },
                    width: 200,
                    height: 38,
                    fontSize: 16,
                  ),
                ],
                content: "撤销200,000后剩余抵押不足节点启动所需的20%!",
                detail: "你必须保证剩余额度不少于启动所需的20%来保证节点继续有效，或者撤销全部抵押以取消节点。");

            showAlertView(
              context,
                title: "重要提示",
                actions: [
                  FlatButton(
                    onPressed: () {
                      print("[Alert] --> 确定撤销");
                      Navigator.pop(context);

                      showModalBottomSheet(
                          isScrollControlled: true,
                          context: context,
                          builder: (BuildContext context) {
                            return EnterWalletPasswordWidget();
                          }).then((walletPassword) async {
                        if (walletPassword == null) {
                          return;
                        }
                      });
                    },
                    child: Text(
                      '确定撤销',
                      style: TextStyle(color: HexColor("#999999"), fontSize: 16),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  ClickOvalButton(
                    "再想想",
                    () {
                      print("[Alert] --> 再想想");
                      Navigator.pop(context);
                    },
                    width: 120,
                    height: 38,
                    fontSize: 16,
                  ),
                ],
                content: "您的抵押金额为300,000 撤销100,000剩余200,000 距离节点启动所需还差400,000！");
            */
          }),
    );
  }
}

void showAlertView(
    BuildContext context,
    {String title,
    List<Widget> actions,
    String content,
    String detail = "",
    String boldContent = "",
    String suffixContent = ""}) {
  showDialog(
    // 传入 context
    context: context,
    // 构建 Dialog 的视图
    builder: (_) => Padding(
      padding: EdgeInsets.all(36),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            //alignment: Alignment.center,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Stack(
              children: <Widget>[
                Positioned(
                  right: 10,
                  top: 10,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(_),
                    child: Image.asset(
                      "res/drawable/map3_node_close.png",
                      width: 18,
                      height: 18,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Text(title,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: HexColor("#333333"),
                              decoration: TextDecoration.none)),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 24, left: 24, right: 24),
                      child: RichText(
                          text: TextSpan(
                              text: content,
                              style: TextStyle(fontSize: 15, color: HexColor("#333333"), height: 1.8),
                              children: [
                            TextSpan(
                              text: boldContent,
                              style: TextStyle(fontSize: 15, color: HexColor("#FF4C3B"), height: 1.8),
                            ),
                            TextSpan(
                              text: suffixContent,
                              style: TextStyle(fontSize: 15, color: HexColor("#333333"), height: 1.8),
                            ),
                          ])),
                    ),
                    if (detail.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 6, left: 24, right: 24),
                        child: Text(detail,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.normal,
                                color: HexColor("#999999"),
                                height: 1.8,
                                decoration: TextDecoration.none)),
                      ),
                    Padding(
                      padding: EdgeInsets.only(top: 15, bottom: 18),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: actions,
                      ),
                    )
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    ),
  );
}
