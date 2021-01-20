import 'dart:io';

import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/atlas_map/entity/atlas_message.dart';
import 'package:titan/src/pages/atlas_map/entity/pledge_map3_entity.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/all_page_state/all_page_state.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'package:titan/src/widget/round_border_textfield.dart';

import 'map3_node_confirm_page.dart';
import 'map3_node_public_widget.dart';

class Map3NodeDivideAddPage extends StatefulWidget {
  Map3NodeDivideAddPage();

  @override
  _Map3NodeDivideAddState createState() => new _Map3NodeDivideAddState();
}

class _Map3NodeDivideAddState extends State<Map3NodeDivideAddPage> with WidgetsBindingObserver {
  AllPageState currentState = LoadingState();

  PublishSubject<String> _filterSubject = PublishSubject<String>();
  String endProfit = "";
  String spendManager = "";

  String originInputStr = "";

  // 输入框的焦点实例
  FocusNode _focusNode;

  // 当前键盘是否是激活状态
  bool _isKeyboardActive = false;

  TextEditingController _textEditingController = new TextEditingController();
  final _formKey = GlobalKey<FormState>();
  double minTotal = 0;
  double remainTotal = 0;

  @override
  void initState() {
    _filterSubject.debounceTime(Duration(milliseconds: 500)).listen((text) {
      getCurrentSpend(text);
    });

    getNetworkData();

    _setupNode();

    super.initState();
  }

  void _setupNode() {
    _focusNode = FocusNode();

    // 监听输入框焦点变化
    _focusNode.addListener(_onFocus);

    // 创建一个界面变化的观察者
    WidgetsBinding.instance.addObserver(this);
  }

  // 焦点变化时触发的函数
  _onFocus() {
    if (_focusNode.hasFocus) {
      // 聚焦时候的操作
      return;
    }

    // 失去焦点时候的操作
    setState(() {
      _isKeyboardActive = false;
    });

    print("[Keyboard] 1, isKeyboardActived:$_isKeyboardActive");
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("[Keyboard] 2, isKeyboardActived:$_isKeyboardActive");

      // 当前是安卓系统并且在焦点聚焦的情况下
      if (Platform.isAndroid && _focusNode.hasFocus) {
        if (_isKeyboardActive) {
          setState(() {
            _isKeyboardActive = false;
          });
          // 使输入框失去焦点
          _focusNode.unfocus();
          return;
        }
        setState(() {
          _isKeyboardActive = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        baseTitle: '增加抵押',
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              AtlasApi.goToAtlasMap3HelpPage(context);
            },
            child: Text(
              "关于节点分裂",
              style: TextStyle(color: HexColor("#1F81FF"), fontSize: 14),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: _pageView(context),
    );
  }

  void getNetworkData() async {
    setState(() {
      currentState = null;
    });
  }

  void getCurrentSpend(String inputText) {
    if (!mounted || originInputStr == inputText) {
      return;
    }

    originInputStr = inputText;

    if (inputText == null || inputText == "") {
      setState(() {
        endProfit = "";
        spendManager = "";
      });
      return;
    }
    double inputValue = double.parse(inputText);
    // endProfit = Map3NodeUtil.getEndProfit(contractItem.contract, inputValue);
    // spendManager = Map3NodeUtil.getManagerTip(contractItem.contract, inputValue);
  }

  @override
  void dispose() {
    _filterSubject.close();

    _focusNode.dispose();
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  Widget _pageView(BuildContext context) {
    /*
    if (currentState != null || contractItem?.contract == null) {
      return AllPageStateContainer(currentState, () {
        setState(() {
          currentState = LoadingState();
        });
        getNetworkData();
      });
    }*/

    var activatedWallet = WalletInheritedModel.of(context).activatedWallet;
    var walletName = activatedWallet.wallet.keystore.name;

    var divider = Container(
      color: HexColor("#F4F4F4"),
      height: 8,
    );
    return Column(
      children: <Widget>[
        Expanded(
          child: BaseGestureDetector(
            context: context,
            child: CustomScrollView(
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: Container(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _superNodeWidget(),
                      divider,
                      _inputWidget(),
                      divider,
                      _tipsWidget(),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
        _confirmButtonWidget(),
      ],
    );
  }

  Widget _superNodeWidget() {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 10, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                RichText(
                  text: TextSpan(
                      text: "分裂后子节点",
                      style: TextStyle(fontSize: 16, color: HexColor("#333333"), fontWeight: FontWeight.w500),
                      children: [
                        TextSpan(
                          text: "",
                          style: TextStyle(fontSize: 12, color: HexColor("#999999"), fontWeight: FontWeight.normal),
                        )
                      ]),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 16, right: 16),
            child: Row(
              children: <Widget>[
                Image.asset(
                  "res/drawable/map3_node_default_avatar.png",
                  width: 42,
                  height: 42,
                  fit: BoxFit.cover,
                ),
                SizedBox(
                  width: 8,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text.rich(TextSpan(children: [
                      TextSpan(
                          text: "派大星",
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: HexColor("#333333"))),
                      TextSpan(
                          text: "  币龄: 12天",
                          style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12, color: HexColor("#333333"))),
                    ])),
                    Container(
                      height: 4,
                    ),
                    Text("${UiUtil.shortEthAddress("钱包地址 oxfdaf89fda47sn43sff", limitLength: 9)}",
                        style: TextStyles.textC9b9b9bS12),
                  ],
                ),
                Spacer(),
                Container(
                  color: HexColor("#1FB9C7").withOpacity(0.08),
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text("第一期", style: TextStyle(fontSize: 12, color: HexColor("#5C4304"))),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16, right: 16),
            child: Container(
              color: HexColor("#F2F2F2"),
              height: 0.5,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30.0, right: 30, top: 16, bottom: 16),
            child: profitListWidget(
              [
                {"总抵押": "450,000"},
                {"我的抵押": "90,000"},
                {"管理费": "20%"}
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tipsWidget() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(left: 20.0, right: 20, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 8),
            child: Text("注意事项", style: TextStyle(color: HexColor("#333333"), fontSize: 16)),
          ),
          rowTipsItem("节点总抵押需满55万才能享受Map3工作服务奖励"),
          rowTipsItem("分裂后子节点马上进入运行状态，共享母节点节龄和运行时长"),
          rowTipsItem("如果母节点已经抵押Atlas节点，则分裂后子节点也会自动抵押到相同的Atlas节点上"),
        ],
      ),
    );
  }

  Widget _inputWidget() {
    var coinVo = WalletInheritedModel.of(context).getCoinVoOfHyn();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(left: 16.0, right: 16, bottom: 16),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 4, right: 8),
                  child: Image.asset(
                    "res/drawable/map3_add_input_star_tag.png",
                    width: 12,
                    height: 12,
                  ),
                ),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                        text: "做为节点主，分裂后子节点您至少拥有20%的抵押量，如果不足20%，需要增加抵押来完成节点分裂",
                        style: TextStyle(
                            fontSize: 14, color: HexColor("#333333"), fontWeight: FontWeight.w500, height: 1.5),
                        children: [
                          TextSpan(
                            text: "",
                            style: TextStyle(fontSize: 12, color: HexColor("#999999"), fontWeight: FontWeight.normal),
                          )
                        ]),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Row(
              children: <Widget>[
                RichText(
                  text: TextSpan(
                      text: "增加抵押",
                      style: TextStyle(fontSize: 16, color: HexColor("#333333"), fontWeight: FontWeight.normal),
                      children: [
                        TextSpan(
                          text: "（节点创建至少抵押110,000）",
                          style: TextStyle(fontSize: 12, color: HexColor("#999999"), fontWeight: FontWeight.normal),
                        )
                      ]),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16),
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
                      suffixText: "最佳",
                      suffixStyle: TextStyle(color: HexColor("#1F81FF"), fontSize: 14),
                      hintText: "最低买入200,000",
                      validator: (textStr) {
                        if (textStr.length == 0) {
                          return S.of(context).please_input_hyn_count;
                        } else if (minTotal == 0) {
                          return "抵押已满";
                        } else if (int.parse(textStr) < minTotal) {
                          return S.of(context).mintotal_hyn(FormatUtil.formatNumDecimal(minTotal));
                        } else if (int.parse(textStr) > remainTotal) {
                          return "不能超过剩余份额";
                        } else if (Decimal.parse(textStr) > Decimal.parse(FormatUtil.coinBalanceHumanRead(coinVo))) {
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
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: 48,
                ),
                Expanded(
                  child: Text(
                    "最佳裂变增投20,000HYN，子母节点皆可获得最高回报",
                    //"撤销抵押将会影响节点进度，剩余抵押不足20%节点将会被取消",
                    style: TextStyle(fontSize: 12, color: HexColor("#999999"), height: 1.5),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _confirmButtonWidget() {
    return Visibility(
      visible: !_isKeyboardActive,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 37, vertical: 18),
        child: ClickOvalButton(
          "马上分裂",
          () async {
            if (!_formKey.currentState.validate()) {
              return;
            }

            var amount = _textEditingController?.text ?? "200000";
            var entity = PledgeMap3Entity(/*payload: Payload(userIdentity: widget.map3infoEntity.nodeId,)*/);
            var message = ConfirmDivideMap3NodeMessage(
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
    );
  }
}
