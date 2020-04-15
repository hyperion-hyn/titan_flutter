import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/node/api/node_api.dart';
import 'package:titan/src/pages/node/model/contract_node_item.dart';
import 'package:titan/src/pages/node/widget/node_join_member_widget.dart';
import 'package:titan/src/plugins/wallet/wallet_const.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/widget/all_page_state/all_page_state.dart'
    as all_page_state;
import 'package:titan/src/widget/all_page_state/all_page_state_container.dart';
import 'map3_node_create_contract_page.dart';

class Map3NodeJoinContractPage extends StatefulWidget {
  final String pageType = Map3NodeCreateContractPage.CONTRACT_PAGE_TYPE_JOIN;
  final String contractId;

  Map3NodeJoinContractPage(this.contractId);

  @override
  _Map3NodeJoinContractState createState() => new _Map3NodeJoinContractState();
}

class _Map3NodeJoinContractState extends State<Map3NodeJoinContractPage> {
  TextEditingController _joinCoinController = new TextEditingController();
  final _joinCoinFormKey = GlobalKey<FormState>();
  all_page_state.AllPageState currentState = all_page_state.LoadingState();
  NodeApi _nodeApi = NodeApi();
  ContractNodeItem contractNodeItem;
  PublishSubject<String> _filterSubject = PublishSubject<String>();
  String endProfit = "";
  String spendManager = "";
  bool isMyself = false;

  @override
  void initState() {
    _joinCoinController.addListener(textChangeListener);

    _filterSubject.debounceTime(Duration(milliseconds: 500)).listen((text) {
      getCurrentSpend(text);
//      widget.fieldCallBack(text);
    });

    getNetworkData();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
//      appBar: AppBar(centerTitle: true, title: Text(pageTitle)),
      backgroundColor: Colors.white,
      body: _pageView(context),
    );
  }

  void getNetworkData() async {
    try {
      contractNodeItem = await _nodeApi.getContractInstanceItem(widget.contractId);

      String myAddress = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet.wallet.getEthAccount().address;
      if(contractNodeItem.owner == myAddress){
        isMyself = true;
      }else{
        isMyself = false;
      }

      Future.delayed(Duration(seconds: 1), () {
        setState(() {
          currentState = null;
        });
      });
    } catch (e) {
      setState(() {
        currentState = all_page_state.LoadFailState();
      });
    }
  }

  void textChangeListener() {
    _filterSubject.sink.add(_joinCoinController.text);
  }

  void getCurrentSpend(String inputText) {
    if (contractNodeItem == null) {
      return;
    }

    _joinCoinFormKey.currentState.validate();

    if (inputText == null || inputText == "") {
      setState(() {
        endProfit = "";
        spendManager = "";
      });
      return;
    }
    double inputValue = double.parse(inputText);
    double doubleEndProfit = inputValue *
            contractNodeItem.contract.annualizedYield *
            contractNodeItem.contract.duration /
            365 +
        inputValue;
    double doubleSpendManager = inputValue *
        contractNodeItem.contract.annualizedYield *
        contractNodeItem.contract.duration /
        365 *
        contractNodeItem.contract.commission;
    endProfit = FormatUtil.formatNumDecimal(doubleEndProfit);
    spendManager = FormatUtil.formatNumDecimal(doubleSpendManager);

    setState(() {
      if (!mounted) return;
      _joinCoinController.value = TextEditingValue(
          // 设置内容
          text: inputText,
          // 保持光标在最后
          selection: TextSelection.fromPosition(TextPosition(
              affinity: TextAffinity.downstream, offset: inputText.length)));
    });
  }

  @override
  void dispose() {
    _filterSubject.close();
    super.dispose();
  }

  Widget _pageView(BuildContext context) {
    if (currentState != null || contractNodeItem.contract == null) {
      return AllPageStateContainer(currentState, () {
        setState(() {
          currentState = all_page_state.LoadingState();
        });
      });
    }

    var activatedWallet = WalletInheritedModel.of(context).activatedWallet;
    var walletName = activatedWallet.wallet.keystore.name;
    return Column(
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
                color: Colors.white,
                child: getMap3NodeProductHeadItem(context, contractNodeItem.contract,
                    isJoin: true)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 16,left: 16),
                  child: Row(
                    children: <Widget>[
                      Container(
                          width: 100,
                          child: Text(S.of(context).node_version,
                              style: TextStyle(
                                  fontSize: 14, color: HexColor("#92979a")))),
                      new Text("${contractNodeItem.contract.nodeName}",
                          style: TextStyles.textC333S14)
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, left: 16),
                  child: Row(
                    children: <Widget>[
                      Container(
                          width: 100,
                          child: Text(S.of(context).service_provider,
                              style: TextStyle(
                                  fontSize: 14, color: HexColor("#92979a")))),
                      new Text("${contractNodeItem.nodeProviderName}", style: TextStyles.textC333S14)
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16.0, left: 16),
                  child: Row(
                    children: <Widget>[
                      Container(
                          width: 100,
                          child: Text(S.of(context).node_location,
                              style: TextStyle(
                                  fontSize: 14, color: HexColor("#92979a")))),
                      new Text("${contractNodeItem.nodeRegionName}", style: TextStyles.textC333S14)
                    ],
                  ),
                ),
              ],
            ),
            Container(
              height: 10,
              margin: const EdgeInsets.only(top: 15.0),
              color: DefaultColors.colorf5f5f5,
            ),
                getHoldInNum(context, contractNodeItem, _joinCoinFormKey,
                    _joinCoinController, endProfit, spendManager, true, (textStr) {
                      _filterSubject.sink.add(textStr);
                    }, (textStr) {
                      getCurrentSpend(textStr);
                    }, joinEnougnFunction: () {
                      getCurrentSpend(contractNodeItem.remainDelegation);
                    },isMyself: isMyself),
            Container(
              height: 10,
              color: DefaultColors.colorf5f5f5,
            ),
                NodeJoinMemberWidget(widget.contractId, contractNodeItem.remainDay,contractNodeItem.ownerName,contractNodeItem.shareUrl),

                Container(
              height: 10,
              color: DefaultColors.colorf5f5f5,
              margin: EdgeInsets.only(top: 15.0, bottom: 15),
            ),
            Container(
              padding: const EdgeInsets.only(left: 20.0, right: 20, bottom: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(S.of(context).please_confirm_eth_gas_enough(walletName),
                      style: TextStyles.textC999S12),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0, bottom: 10),
                    child: Text(
                        S.of(context).no_enough_hyn_fail_invest_extract,
                        style: TextStyles.textC999S12),
                  ),
                  Text(S.of(context).invest_cant_undo, style: TextStyles.textC999S12),
                ],
              ),
            ),
          ])),
        ),
        Container(
          constraints: BoxConstraints.expand(height: 50),
          child: RaisedButton(
              textColor: Colors.white,
              color: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                  side: BorderSide(color: Theme.of(context).primaryColor)),
              child: Text(S.of(context).confirm_mortgage),
              onPressed: () {
                setState(() {
                  if (!_joinCoinFormKey.currentState.validate()) {
                    return;
                  }
                  Application.router.navigateTo(
                      context,
                      Routes.map3node_send_confirm_page +
                          "?coinVo=${FluroConvertUtils.object2string(activatedWallet.coins[1].toJson())}" +
                          "&contractNodeItem=${FluroConvertUtils.object2string(contractNodeItem.toJson())}" +
                          "&transferAmount=${_joinCoinController.text}&receiverAddress=${WalletConfig.map3ContractAddress}" +
                          "&pageType=${widget.pageType}" +
                          "&contractId=${widget.contractId}");
                });
              }),
        )
      ],
    );
  }
}
