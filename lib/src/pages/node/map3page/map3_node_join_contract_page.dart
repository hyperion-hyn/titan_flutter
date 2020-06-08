import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/node/api/node_api.dart';
import 'package:titan/src/pages/node/model/contract_node_item.dart';
import 'package:titan/src/pages/node/model/enum_state.dart';
import 'package:titan/src/pages/node/model/map3_node_util.dart';
import 'package:titan/src/pages/node/model/node_item.dart';
import 'package:titan/src/pages/node/model/node_provider_entity.dart';
import 'package:titan/src/plugins/wallet/wallet_const.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/widget/all_page_state/all_page_state.dart';
import 'package:titan/src/widget/all_page_state/all_page_state_container.dart';
import 'package:titan/src/widget/click_rectangle_button.dart';
import 'map3_node_create_contract_page.dart';

class Map3NodeJoinContractPage extends StatefulWidget {
  final String contractId;

  Map3NodeJoinContractPage(this.contractId);

  @override
  _Map3NodeJoinContractState createState() => new _Map3NodeJoinContractState();
}

class _Map3NodeJoinContractState extends State<Map3NodeJoinContractPage> {
  TextEditingController _joinCoinController = new TextEditingController();
  final _joinCoinFormKey = GlobalKey<FormState>();
  AllPageState currentState = LoadingState();
  NodeApi _nodeApi = NodeApi();
  ContractNodeItem contractItem;
  PublishSubject<String> _filterSubject = PublishSubject<String>();
  String endProfit = "";
  String spendManager = "";
  var selectServerItemValue = 0;
  var selectNodeItemValue = 0;
  List<DropdownMenuItem> serverList;
  List<DropdownMenuItem> nodeList;
  List<NodeProviderEntity> providerList = [];
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
      appBar: AppBar(
          centerTitle: true, title: Text(S.of(context).join_map_node_mortgage)),
      body: _pageView(context),
    );
  }

  void getNetworkData() async {
    try {
      var requestList = await Future.wait([
        _nodeApi.getContractItem(widget.contractId),
        _nodeApi.getNodeProviderList()
      ]);
      contractItem = requestList[0];
      providerList = requestList[1];

      selectNodeProvider(0, 0);

      setState(() {
        currentState = null;
      });
    } catch (e) {
      setState(() {
        currentState = LoadFailState();
      });
    }
  }

  void selectNodeProvider(int providerIndex, int regionIndex) {
    if (providerList.length == 0) {
      return;
    }

    serverList = new List();
    for (int i = 0; i < providerList.length; i++) {
      NodeProviderEntity nodeProviderEntity = providerList[i];
      DropdownMenuItem item = new DropdownMenuItem(
          value: i,
          child: new Text(
            nodeProviderEntity.name,
            style: TextStyles.textC333S14,
          ));
      serverList.add(item);
    }
    selectServerItemValue = serverList[providerIndex].value;

    List<Regions> nodeListStr = providerList[providerIndex].regions;
    nodeList = new List();
    for (int i = 0; i < nodeListStr.length; i++) {
      Regions regions = nodeListStr[i];
      DropdownMenuItem item = new DropdownMenuItem(
          value: i,
          child: new Text(regions.name, style: TextStyles.textC333S14));
      nodeList.add(item);
    }
    selectNodeItemValue = nodeList[regionIndex].value;
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
    spendManager =
        Map3NodeUtil.getManagerTip(contractItem.contract, inputValue);

    if (mounted) {
      setState(() {
        _joinCoinController.value = TextEditingValue(
            // 设置内容
            text: inputText,
            // 保持光标在最后
            selection: TextSelection.fromPosition(TextPosition(
                affinity: TextAffinity.downstream, offset: inputText.length)));
      });
    }
  }

  @override
  void dispose() {
    _filterSubject.close();
    super.dispose();
  }

  Widget _pageView(BuildContext context) {
    if (currentState != null || contractItem.contract == null) {
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

    return Column(
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                _nodeWidget(context, contractItem.contract),
                SizedBox(height: 8),
                getHoldInNum(context, contractItem, _joinCoinFormKey,
                    _joinCoinController, endProfit, spendManager, false),
                SizedBox(height: 8),
                _autoRenewalWidget(),
                SizedBox(height: 8),
                _tipsWidget(),
              ])),
        ),
        _confirmButtonWidget(),
      ],
    );
  }

  Widget _tipsWidget() {
    var activatedWallet = WalletInheritedModel.of(context).activatedWallet;
    var walletName = activatedWallet.wallet.keystore.name;

    var _nodeWidget = Padding(
      padding: const EdgeInsets.only(right: 10, top: 10),
      child: Container(
        width: 3,
        height: 3,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: DefaultColors.color999,
            border: Border.all(color: DefaultColors.color999, width: 1.0)),
      ),
    );

    Widget _rowWidget(String title, {double top = 8}) {
      return Padding(
        padding: EdgeInsets.only(top: top),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _nodeWidget,
            Expanded(
                child: Text(title,
                    style: TextStyle(
                        height: 1.8,
                        color: DefaultColors.color999,
                        fontSize: 12))),
          ],
        ),
      );
    }

    return Container(
      color: Colors.white,
      //height: MediaQuery.of(context).size.height-50,
      padding: const EdgeInsets.only(left: 16.0, right: 20, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 8),
            child: Text("注意事项",
                style: TextStyle(color: HexColor("#333333"), fontSize: 16)),
          ),
          _rowWidget("创建7天内不可撤销", top: 0),
          _rowWidget(S.of(context).please_confirm_eth_gas_enough(walletName)),
          _rowWidget(
              "需要总抵押满100万才能正式启动，每次参与抵押数额不少于10000HYN（如果节点剩余额度少于10000HYN，你必须抵押剩下的全部额度"),
          _rowWidget("你可以设置是否自动跟随自动续约来决定本期满期后是否跟随节点自动进入下一期来获得更多的奖励"),
          _rowWidget("如果节点主撤销节点，已抵押的HYN可自行取回"),
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
          _nodeIntroductionWidget(context, nodeItem),
          _nodeManagerWidget(nodeItem),
        ],
      ),
    );
  }

  Widget _nodeManagerWidget(NodeItem nodeItem) {
    return Padding(
      padding: const EdgeInsets.only(left: 86.0, bottom: 16),
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 30),
            child: RichText(
              text: TextSpan(
                  style: TextStyle(fontSize: 12, color: HexColor("#999999")),
                  text: "管理费",
                  children: [
                    TextSpan(
                      text:
                          "  ${FormatUtil.formatPercent(nodeItem.ownerMinDelegationRate)}",
                      style:
                          TextStyle(fontSize: 12, color: HexColor("#333333")),
                    )
                  ]),
            ),
          ),
          RichText(
            text: TextSpan(
                style: TextStyle(fontSize: 12, color: HexColor("#999999")),
                text: "最低抵押",
                children: [
                  TextSpan(
                    text:
                        "  ${FormatUtil.formatPercent(nodeItem.minDelegationRate)}",
                    style: TextStyle(fontSize: 12, color: HexColor("#333333")),
                  )
                ]),
          ),
        ],
      ),
    );
  }

  Widget _nodeOwnerWidget() {
    return Padding(
      padding:
          const EdgeInsets.only(left: 16.0, top: 18, right: 18, bottom: 18),
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
                TextSpan(
                    text: "派大星",
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                TextSpan(
                    text: "  编号 PB2020",
                    style: TextStyle(fontSize: 13, color: HexColor("#333333"))),
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
                child: Text("第一期",
                    style: TextStyle(fontSize: 12, color: HexColor("#5C4304"))),
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
                    Expanded(
                        child: Text(nodeItem.name,
                            style: TextStyle(fontWeight: FontWeight.bold)))
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
                      Text("  |  ",
                          style: TextStyle(
                              fontSize: 12,
                              color: HexColor("000000").withOpacity(0.2))),
                      Text(S.of(context).n_day(nodeItem.duration.toString()),
                          style: TextStyles.textC99000000S13)
                    ],
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: <Widget>[
              Text("${FormatUtil.formatPercent(nodeItem.annualizedYield)}",
                  style: TextStyles.textCff4c3bS20),
              Padding(
                padding: const EdgeInsets.only(top: 3.0),
                child: Text(S.of(context).annualized_rewards,
                    style: TextStyles.textC99000000S13),
              )
            ],
          )
        ],
      ),
    );
  }

  bool _renew = true;

  Widget _autoRenewalWidget() {
    return Container(
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "是否跟随自动续约",
              style: TextStyle(fontSize: 16, color: HexColor("#333333")),
            ),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Transform.scale(
              scale: 0.8,
              child: CupertinoSwitch(
                value: _renew,
                activeColor: Theme.of(context).primaryColor,
                onChanged: (value) {
                  setState(() {
                    _renew = value;
                  });
                  print("[AutoRenewalWidget] --> value:$value");
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _confirmButtonWidget() {
    var activatedWallet = WalletInheritedModel.of(context).activatedWallet;
    return ClickRectangleButton(S.of(context).confirm_bug, () async {
      setState(() {
        if (!_joinCoinFormKey.currentState.validate()) {
          return;
        }

        var transferAmount = _joinCoinController.text?.isNotEmpty == true
            ? _joinCoinController.text
            : "0";

        Application.router.navigateTo(
            context,
            Routes.map3node_send_confirm_page +
                "?coinVo=${FluroConvertUtils.object2string(activatedWallet.coins[1].toJson())}" +
                "&contractNodeItem=${FluroConvertUtils.object2string(contractItem.toJson())}" +
                "&transferAmount=${transferAmount.trim()}" +
                "&receiverAddress=${WalletConfig.map3ContractAddress}" +
                "&actionEvent=${Map3NodeActionEvent.DELEGATE}" +
                "&contractId=${widget.contractId}");
      });
    });
  }
}
