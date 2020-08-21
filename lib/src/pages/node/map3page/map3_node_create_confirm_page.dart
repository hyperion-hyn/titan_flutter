
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:rxdart/rxdart.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/pages/node/api/node_api.dart';
import 'package:titan/src/pages/node/map3page/map3_node_normal_confirm_page.dart';
import 'package:titan/src/pages/node/model/contract_node_item.dart';
import 'package:titan/src/pages/node/model/enum_state.dart';
import 'package:titan/src/pages/node/model/map3_node_util.dart';
import 'package:titan/src/pages/node/model/node_provider_entity.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/widget/all_page_state/all_page_state.dart';
import 'package:titan/src/widget/all_page_state/all_page_state_container.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';



class Map3NodeCreateConfirmPage extends StatefulWidget {
  final String contractId;

  Map3NodeCreateConfirmPage(this.contractId);

  @override
  _Map3NodeCreateConfirmState createState() => new _Map3NodeCreateConfirmState();
}

class _Map3NodeCreateConfirmState extends State<Map3NodeCreateConfirmPage> {

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

    _filterSubject.debounceTime(Duration(milliseconds: 500)).listen((text) {
      getCurrentSpend(text);
    });

    getNetworkData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        centerTitle: true,
        title: Text(
          '确认创建节点',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: _pageView(context),
    );
  }

  void getNetworkData() async {
    try {
      var requestList =
          await Future.wait([_nodeApi.getContractItem(widget.contractId), _nodeApi.getNodeProviderList()]);
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
      DropdownMenuItem item =
          new DropdownMenuItem(value: i, child: new Text(regions.name, style: TextStyles.textC333S14));
      nodeList.add(item);
    }
    selectNodeItemValue = nodeList[regionIndex].value;
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

  }

  @override
  void dispose() {
    _filterSubject.close();
    super.dispose();
  }

  var _localImagePath;
  List<String> _titleList = ["图标", "名称", "节点号", "首次抵押", "管理费", "网址", "安全联系", "描述", "云服务商", "节点地址"];
  List<String> _detailList = [
    "",
    "派大星",
    "PB2020",
    "200,000 HYN",
    "20%",
    "www.hyn.space",
    "12345678901",
    "欢迎参加我的合约，前10名参与者返10%管理。",
    "亚马逊云",
    "美国东部（弗吉尼亚北部）"
  ];
  Widget _pageView(BuildContext context) {
    if (currentState != null || contractItem.contract == null) {
      return AllPageStateContainer(currentState, () {
        setState(() {
          currentState = LoadingState();
        });
        getNetworkData();
      });
    }

    var activatedWallet = WalletInheritedModel.of(context).activatedWallet;
    var walletName = activatedWallet.wallet.keystore.name;

    var divider = Container(
      color: HexColor("#F4F4F4"),
      height: 8,
    );
    return Column(
      children: <Widget>[
        _headerWidget(),

        Expanded(
          child: CustomScrollView(
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: Container(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    //_headerWidget(),
                  ]),
                ),
              ),
              SliverToBoxAdapter(
                child: ListView.separated(
                  itemBuilder: (context, index) {
                    var title = _titleList[index];
                    var detail = _detailList[index];

                    return Container(
                      color: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: detail.isNotEmpty ? 18 : 14, horizontal: 14),
                        child: Row(
                          children: <Widget>[
                            SizedBox(
                              width: 100,
                              child: Text(
                                title,
                                style: TextStyle(color: HexColor("#999999"), fontSize: 14),
                              ),
                            ),
                            detail.isNotEmpty
                                ? Expanded(
                                    child: Text(
                                      detail,
                                      style: TextStyle(color: HexColor("#333333"), fontSize: 14),
                                    ),
                                  )
                                : Image.asset(
                                    _localImagePath ?? "res/drawable/ic_map3_node_item_2.png",
                                    width: 36,
                                    height: 36,
                                    fit: BoxFit.cover,
                                  ),

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
                  itemCount: _detailList.length,
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
    return Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 14,vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              "你即将要创建如下Map3节点",
              style: TextStyle(
                color: HexColor("#333333"),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ));
  }

  Widget _confirmButtonWidget() {
    var activatedWallet = WalletInheritedModel.of(context).activatedWallet;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 37, vertical: 18),
      child: ClickOvalButton(
        "提交",
        () async {

          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) =>
                  Map3NodeNormalConfirmPage(actionEvent: Map3NodeActionEvent.CREATE,)));
        },
        height: 46,
        width: MediaQuery.of(context).size.width - 37 * 2,
        fontSize: 18,
      ),
    );
  }
}
