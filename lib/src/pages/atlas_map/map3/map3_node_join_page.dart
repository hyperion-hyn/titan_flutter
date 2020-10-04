import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rxdart/rxdart.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/atlas_map/entity/atlas_message.dart';
import 'package:titan/src/pages/atlas_map/entity/enum_atlas_type.dart';
import 'package:titan/src/pages/atlas_map/entity/pledge_map3_entity.dart';
import 'package:titan/src/pages/node/model/contract_node_item.dart';
import 'package:titan/src/pages/node/model/enum_state.dart';
import 'package:titan/src/pages/node/model/map3_node_util.dart';
import 'package:titan/src/pages/node/model/node_item.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/widget/all_page_state/all_page_state.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'map3_node_confirm_page.dart';
import 'map3_node_public_widget.dart';

class Map3NodeJoinPage extends StatefulWidget {
  final String contractId;

  Map3NodeJoinPage(this.contractId);

  @override
  _Map3NodeJoinState createState() => new _Map3NodeJoinState();
}

class _Map3NodeJoinState extends State<Map3NodeJoinPage> {
  TextEditingController _joinCoinController = new TextEditingController();
  final _joinCoinFormKey = GlobalKey<FormState>();
  AllPageState currentState = LoadingState();

  ContractNodeItem contractItem;
  PublishSubject<String> _filterSubject = PublishSubject<String>();
  String endProfit = "";
  String spendManager = "";

  String originInputStr = "";

  @override
  void initState() {
    _joinCoinController.addListener(textChangeListener);

    _filterSubject.debounceTime(Duration(milliseconds: 500)).listen((text) {
      getCurrentSpend(text);
    });

    getNetworkData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF3F0F5),
      appBar: BaseAppBar(
        baseTitle: '抵押Map3节点',
      ),
      body: _pageView(context),
    );
  }

  void getNetworkData() async {
    setState(() {
      currentState = null;
    });
  }

  void textChangeListener() {
    _filterSubject.sink.add(_joinCoinController.text);
  }

  void getCurrentSpend(String inputText) {
    if (contractItem == null || !mounted || originInputStr == inputText) {
      return;
    }

    originInputStr = inputText;
    _joinCoinFormKey.currentState?.validate();

    if (inputText == null || inputText == "") {
      setState(() {
        endProfit = "";
        spendManager = "";
      });
      return;
    }
    double inputValue = double.parse(inputText);
    endProfit = Map3NodeUtil.getEndProfit(contractItem.contract, inputValue);
    spendManager = Map3NodeUtil.getManagerTip(contractItem.contract, inputValue);

    if (mounted) {
      setState(() {
        _joinCoinController.value = TextEditingValue(
            // 设置内容
            text: inputText,
            // 保持光标在最后
            selection:
                TextSelection.fromPosition(TextPosition(affinity: TextAffinity.downstream, offset: inputText.length)));
      });
    }
  }

  @override
  void dispose() {
    _filterSubject.close();
    super.dispose();
  }

  Widget _pageView(BuildContext context) {
    /*if (currentState != null || contractItem?.contract == null) {
      return Scaffold(
        body: AllPageStateContainer(currentState, () {
          setState(() {
            currentState = LoadingState();
          });
          getNetworkData();
        }),
      );
    }

    var activatedWallet = WalletInheritedModel.of(context).activatedWallet;
    var walletName = activatedWallet.wallet.keystore.name;
  */
    return Column(
      children: <Widget>[
        Expanded(
          child: BaseGestureDetector(
            context: context,
            child: SingleChildScrollView(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _nodeWidget(context, contractItem?.contract),
              SizedBox(height: 8),
              getHoldInNum(
                  context, contractItem, _joinCoinFormKey, _joinCoinController, endProfit, spendManager, false),
              SizedBox(height: 8),
              _tipsWidget(),
            ])),
          ),
        ),
        _confirmButtonWidget(),
      ],
    );
  }

  Widget _tipsWidget() {
    return Container(
      color: Colors.white,
      //height: MediaQuery.of(context).size.height-50,
      padding: const EdgeInsets.only(left: 20.0, right: 20, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 8),
            child: Text("注意事项", style: TextStyle(color: HexColor("#333333"), fontSize: 16)),
          ),
          rowTipsItem("抵押7天内不可撤销", top: 0),
          rowTipsItem("需要总抵押满100万HYN才能正式启动，每次参与抵押数额不少于10000HYN"),
          rowTipsItem("节点主在到期前倒数第二周设置下一周期是否继续运行，或调整管理费率。抵押者在到期前最后一周可选择是否跟随下一周期"),
          rowTipsItem("如果节点主扩容节点，你的抵押也会分布在扩容的节点里面。", subTitle: "关于扩容", onTap: () {
            // todo: test_jison_0604
            String webUrl = FluroConvertUtils.fluroCnParamsEncode("http://baidu.com");
            String webTitle = FluroConvertUtils.fluroCnParamsEncode("关于扩容");
            Application.router.navigateTo(context, Routes.toolspage_webview_page + '?initUrl=$webUrl&title=$webTitle');
          }),
        ],
      ),
    );
  }

  Widget _nodeWidget(BuildContext context, NodeItem nodeItem) {
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
          _delegateCountWidget(),
        ],
      ),
    );
  }

  Widget _delegateCountWidget() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 16.0, left: 16, right: 16),
      child: profitListWidget(
        [
          {"总抵押": "800,000"},
          {"管理费": "20%"},
          {"最低抵押": "1%"}
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
            "确定",
            () {
              // if (!(_joinCoinFormKey.currentState?.validate()??false)) {
              //   return;
              // };


              if (_joinCoinController?.text?.isEmpty??true) {
                Fluttertoast.showToast(msg: S.of(context).please_input_hyn_count);
                return;
              }

              var amount = _joinCoinController?.text??"200000";
              var entity = PledgeMap3Entity.onlyType(AtlasActionType.JOIN_DELEGATE_MAP3);
              entity.payload = PledgeMap3Payload("abc",amount);
              entity.amount = amount;
              var message = ConfirmDelegateMap3NodeMessage(
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

  Widget _nodeOwnerWidget() {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 18, right: 18, bottom: 18),
      child: Row(
        children: <Widget>[
          Image.asset(
            "res/drawable/ic_map3_node_default_icon.png",
            width: 42,
            height: 42,
            fit: BoxFit.cover,
          ),
          SizedBox(
            width: 10,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text.rich(TextSpan(children: [
                TextSpan(text: "派大星", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                TextSpan(text: "  编号 PB2020", style: TextStyle(fontSize: 13, color: HexColor("#333333"))),
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
}
