import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rxdart/rxdart.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/components/quotes/quotes_component.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/node/api/node_api.dart';
import 'package:titan/src/pages/node/model/contract_detail_item.dart';
import 'package:titan/src/pages/node/model/contract_node_item.dart';
import 'package:titan/src/pages/node/model/node_item.dart';
import 'package:titan/src/pages/node/widget/node_delegator_member_widget.dart';
import 'package:titan/src/pages/node/widget/node_join_member_widget.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/plugins/wallet/wallet_const.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/widget/all_page_state/all_page_state.dart' as all_page_state;
import 'package:titan/src/widget/all_page_state/all_page_state_container.dart';
import 'package:titan/src/widget/enter_wallet_password.dart';
import 'package:web3dart/json_rpc.dart';
import '../../../global.dart';
import 'map3_node_create_contract_page.dart';
import 'my_map3_contract_page.dart';

class Map3NodeContractDetailPage extends StatefulWidget {
  final int contractId;

  Map3NodeContractDetailPage(this.contractId);

  @override
  _Map3NodeContractDetailState createState() => new _Map3NodeContractDetailState();
}

class _Map3NodeContractDetailState extends State<Map3NodeContractDetailPage> {

  all_page_state.AllPageState _currentState = all_page_state.LoadingState();
  NodeApi _api = NodeApi();
  ContractDetailItem _contractDetailItem;
  ContractNodeItem _contractNodeItem;
  Wallet _wallet;
  bool _visible = false;
  bool _isTransferring = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_wallet == null) {
      _wallet = WalletInheritedModel.of(context).activatedWallet?.wallet;
      getNetworkData();
    }
  }

  void getNetworkData() async {

    // todo: test_jison_0411
/*    Future.delayed(Duration(seconds: 1), () {
      setState(() {

        var item = NodeItem(1, "aaa", 1, "0", 0.0, 0.0, 0.0, 1, 0, 0.0, false, "0.5", "", "");
        var nodeItem = ContractNodeItem(
            1,
            item,
            "0xaaaaa",
            "bbbbbbb",
            "0",
            "0",
            "",
            "",
            "",
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            "ACTIVE"
        );

        _contractDetailItem = ContractDetailItem(nodeItem, "", "", "0", "0", "0", 0, "ACTIVE");
        _contractNodeItem = nodeItem;
        // todo： 测试
        //_contractDetailItem.state = UserDelegateState.DUE_COLLECTED.toString().split(".").last;
        _currentState = null;
        _visible = true;
      });
    });

    return;*/

    try {
      var address = _wallet.getEthAccount().address;
      var item = await _api.getContractDetail("${widget.contractId}", address: address);

      Future.delayed(Duration(seconds: 1), () {
        setState(() {
          print('[map3] _loadLastData , id:${item.instance.id}');
          _contractDetailItem = item;
          _contractNodeItem = item.instance;
          // todo： 测试
          //_contractDetailItem.state = UserDelegateState.DUE_COLLECTED.toString().split(".").last;
          _currentState = null;
          _visible = true;
        });
      });
    } catch (e) {
      setState(() {
        _currentState = all_page_state.LoadFailState();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          _pageView(context),
          _bottomSureWidget(),
        ],
      ),
    );
  }

  Widget _pageView(BuildContext context) {
    if (_currentState != null || _contractNodeItem.contract == null) {
      return AllPageStateContainer(_currentState, () {
        setState(() {
          _currentState = all_page_state.LoadingState();
        });
      });
    }

    var state = enumContractStateFromString(_contractNodeItem.state);
    print('[contract] _pageView, stateString:${_contractNodeItem.state},state:$state');
    var amountDelegation = "${FormatUtil.formatNum(int.parse(_contractDetailItem.amountDelegation))}";
    var nodeStateDesc = "节点配置中";
    var contractStateDesc = "正在创建中，等待区块链网络验证";
    switch (state) {
      case ContractState.PENDING:
        nodeStateDesc = "节点配置中";
        contractStateDesc = "正在创建中，等待区块链网络验证";
        break;

      case ContractState.ACTIVE:
        nodeStateDesc = "节点进行中";
        contractStateDesc = "已广播投入$amountDelegation HYN，等待区块链网络验证";
        break;

      case ContractState.DUE:
        nodeStateDesc = "节点已停止";

        break;

      case ContractState.CANCELLED:
        nodeStateDesc = "节点已停止";
        contractStateDesc = "启动失败，请申请退款";
        break;

      case ContractState.DUE_COMPLETED:
        nodeStateDesc = "节点已停止";
        contractStateDesc = "已取回投入资金";
        break;

      case ContractState.CANCELLED_COMPLETED:
        nodeStateDesc = "节点已停止";
        contractStateDesc = "已取回投入资金";
        break;

      default:
        break;
    }

    return SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:
        [
          Container(
              color: Colors.white,
              child: getMap3NodeProductHeadItem(context, _contractNodeItem.contract, isJoin: true, isDetail: false)
          ),
          _nodeInfoWidget(nodeStateDesc),
          _Spacer(),
          _contractActionsWidget(contractStateDesc: contractStateDesc),
          _lineSpacer(),
          _contractProgressWidget(),
          _Spacer(),
          NodeJoinMemberWidget(
            "${widget.contractId}",
            _contractNodeItem.remainDay,
            _contractNodeItem.shareUrl,
            isShowInviteItem: false,
          ),
          _Spacer(),
          _delegatorListWidget(),
          _Spacer(),
          Container(
            height: 48,
          ),
        ]),
    );
  }

  Widget _nodeInfoWidget(String nodeStateDesc) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
          child: Row(
            children: <Widget>[
              Text(nodeStateDesc, style: TextStyle(fontSize: 14, color: HexColor("#666666"))),
              Spacer(),
              InkWell(
                  onTap: () {
                    String webUrl = FluroConvertUtils.fluroCnParamsEncode("https://www.map3.network");
                    String webTitle = FluroConvertUtils.fluroCnParamsEncode("Map3节点详情");
                    Application.router
                        .navigateTo(context, Routes.toolspage_webview_page + '?initUrl=$webUrl&title=$webTitle');
                  },
                  child: Text("点击查看详情", style: TextStyle(fontSize: 14, color: HexColor("#666666"))))
            ],
          ),
        ),
        Container(
          height: 0.8,
          color: DefaultColors.colorf5f5f5,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(45, 6, 5, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                      width: 100, child: Text("节点版本", style: TextStyle(fontSize: 14, color: HexColor("#92979a")))),
                  new Text("${_contractNodeItem.contract.nodeName}", style: TextStyles.textC333S14)
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: <Widget>[
                    Container(
                        width: 100, child: Text("服务商", style: TextStyle(fontSize: 14, color: HexColor("#92979a")))),
                    new Text("${_contractNodeItem.nodeProviderName}", style: TextStyles.textC333S14)
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: <Widget>[
                    Container(
                        width: 100, child: Text("节点位置", style: TextStyle(fontSize: 14, color: HexColor("#92979a")))),
                    new Text("${_contractNodeItem.nodeRegionName}", style: TextStyles.textC333S14)
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _delegatorListWidget() {
    var amountDelegation = _amountToString(_contractNodeItem.amountDelegation);
    return NodeDelegatorMemberWidget("${_contractNodeItem.id}", amountDelegation);
  }

  Widget _contractActionsWidget({String contractStateDesc = ""}) {
    var amountDelegation = _amountToString(_contractDetailItem.amountDelegation);
    var expectedYield = _amountToString(_contractDetailItem.expectedYield);
    var commission = _amountToString(_contractDetailItem.commission);

    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.volume_up,
                  color: HexColor("#5C4304"),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Text(
                      contractStateDesc,
                      style: TextStyle(fontSize: 14, color: HexColor("#5C4304")),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12.0, bottom: 12.0),
            child: Row(
              children: [1, 2, 3].map((value) {
                String title = "";
                String detail = "";
                TextStyle style = TextStyle(fontSize: 19, color: HexColor("#000000"), fontWeight: FontWeight.w600);
                switch (value) {
                  case 1:
                    title = "你已投入(HYN)";
                    detail = amountDelegation;
                    //style = TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold);
                    break;

                  case 2:
                    title = "预期产出(HYN)";
                    detail = expectedYield;
                    //style = TextStyle(fontSize: 14, color: Colors.red, fontWeight: FontWeight.bold);
                    break;

                  case 3:
                    title = "获得管理费(HYN)";
                    detail = commission;
                    //style = TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold);
                    break;
                }
                return Expanded(
                  child: Center(
                      child: Column(
                    children: <Widget>[
                      Text(detail, style: style),
                      Container(
                        height: 8,
                      ),
                      Text(title, style: TextStyles.textC9b9b9bS12),
                    ],
                  )),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _contractProgressWidget() {
    double horizontal = 0;
    double lineWidth = 40;
    double gap = 16;
    double sectionWidth = (MediaQuery.of(context).size.width - horizontal * 2.0 - lineWidth * 4.0 - gap * 8.0) * 0.125;

    return Container(
      color: Colors.white,
      //height: 180,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 18, right: 8.0),
                  child: Container(
                    width: 10,
                    height: 10,
                    //color: Colors.red,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _getStatusColor(enumContractStateFromString(_contractNodeItem.state)),
                        border: Border.all(color: Colors.grey, width: 1.0)),
                  ),
                ),
                Text.rich(TextSpan(children: [
                  TextSpan(text: "等待启动，剩余", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  TextSpan(
                    text: "${_contractNodeItem.remainDay}天",
                    style: TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.w500),
                  ),
                ])),
              ],
            ),
          ),
          //_lightItem("创建时间", _contractNodeItem.instanceStartTime),

          Container(
            height: 110,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
//            color: Colors.red,
            child: Stack(
              children: <Widget>[


                _lightItem("创建时间", _contractNodeItem.instanceStartTime, left: horizontal),
                _lightLine("7天", lineWidth, left: horizontal + sectionWidth + gap * 2.0),
                _lightItem("启动成功", _contractNodeItem.instanceActiveTime, left: horizontal + sectionWidth + gap * 2.0 + lineWidth * 0.75),
                _lightLine("90天", lineWidth, left: horizontal + sectionWidth * 2.0 + gap * 4.0 + lineWidth * 0.75),
                _midItem("中期可提取50%奖励", left: horizontal + sectionWidth * 2.0 + gap * 4.0 + lineWidth * 0.75),
                _greyLine("90天", lineWidth, left: horizontal + sectionWidth * 2.0 + gap * 6.0 + lineWidth * 1.75),
                _greyItem("到期时间", left: horizontal + sectionWidth * 3.0 + gap * 7.0 + lineWidth * 1.75),
                _greyLine("", lineWidth, left: horizontal + sectionWidth * 3.0 + gap * 7.0 + lineWidth * 2.75),
                _greyItem("提取时间", left: horizontal + sectionWidth * 3.0 + gap * 6.0 + lineWidth * 3.75),

              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _lightItem(String name, int date, {double left = 10}) {
    return Positioned(
      left: left,
      top: 30,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 11,
            height: 11,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: HexColor("#322300"), width: 2.0)),
          ),
          Container(height: 8.0,),
          Text(
            name,
            style: TextStyle(fontSize: 12, color: HexColor("#4B4B4B"), fontWeight: FontWeight.normal),
          ),
          Container(height: 8.0,),
          Text(
            "${FormatUtil.formatDate(date)}",
            style: TextStyle(fontSize: 10, color: HexColor("#A7A7A7"), fontWeight: FontWeight.normal),
          ),
          Container(height: 8.0,),
        ],
      ),
    );
  }

  Widget _greyItem(String name, {double left = 10}) {
    return Positioned(
      left: left,
      top: 30,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: HexColor("#CCCCCC"), width: 2.0)),
          ),
          Container(height: 8.0,),
          Text(
            name,
            style: TextStyle(fontSize: 12, color: HexColor("#A7A7A7"), fontWeight: FontWeight.normal),
          ),
          Container(height: 8.0,),
          Text(
            "",
            style: TextStyle(fontSize: 10, color: HexColor("#A7A7A7"), fontWeight: FontWeight.normal),
          ),
          Container(height: 8.0,),
        ],
      ),
    );
  }

  Widget _midItem(String name, {double left = 10}) {
    return Positioned(
      left: left,
      top: 30,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: HexColor("#CCCCCC"), width: 2.0)),
          ),
          Container(height: 8.0,),
          Text(
            name,
            style: TextStyle(fontSize: 10, color: HexColor("#999999"), fontWeight: FontWeight.normal),
          ),
          Container(height: 8.0,),
          Text(
            "",
            style: TextStyle(fontSize: 10, color: HexColor("#A7A7A7"), fontWeight: FontWeight.normal),
          ),
          Container(height: 8.0,),
        ],
      ),
    );
  }


  Widget _lightLine(String name, double width, { double left = 10}) {
    return Positioned(
      top: 10,
      left: left,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[

          Text(
            name,
            style: TextStyle(fontSize: 12, color: HexColor("#4B4B4B"), fontWeight: FontWeight.normal),
          ),
          Container(height: 8.0,),
          Container(height: 1.0, width: width, color: HexColor("#322300"),),
        ],
      ),
    );
  }

  Widget _greyLine(String name, double width, { double left = 10}) {
    return Positioned(
      top: 10,
      left: left,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[

          Text(
            name,
            style: TextStyle(fontSize: 12, color: HexColor("#4B4B4B"), fontWeight: FontWeight.normal),
          ),
          Container(height: 8.0,),
          Container(height: 1.0, width: width, color: HexColor("#ECECEC"),),
        ],
      ),
    );
  }

  HexColor _getStatusColor(ContractState status) {

    var statusColor = HexColor('#EED097');

    switch (status) {
      case ContractState.PENDING:
        statusColor = HexColor('#EED097');
        break;

      case ContractState.ACTIVE:
        statusColor = HexColor('#3FF78C');
        break;

      case ContractState.DUE:
        statusColor = HexColor('#867B7B');
        break;

      case ContractState.CANCELLED:
        statusColor = HexColor('#F22504');
        break;

      default:
        statusColor = HexColor('#867B7B');
        //statusColor = Theme.of(context).primaryColor;
        break;
    }
    return statusColor;
  }

  Widget _lineSpacer() {
    return Container(
      height: 0.5,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      color: DefaultColors.colorf5f5f5,
    );
  }

  Widget _Spacer() {
    return Container(
      height: 10,
      color: DefaultColors.colorf5f5f5,
    );
  }

  Widget _bottomSureWidget() {
    var state = enumUerDelegateStateFromString(_contractDetailItem?.state??"");
    var actionTitle = _isTransferring ? "提取中...": "确定";
    void Function() onPressed =  (){};

    switch (state) {
      case UserDelegateState.PENDING:
        actionTitle = "增加投入";
        onPressed = (){
          Application.router.navigateTo(context, Routes.map3node_join_contract_page
              + "?contractId=${_contractNodeItem.id}");
        };
        break;

      case UserDelegateState.ACTIVE:
        actionTitle = "已抵押";
        onPressed = (){
          Fluttertoast.showToast(msg: "节点正在运行中。。。");
        };
        break;

      case UserDelegateState.DUE:
        actionTitle = "提取";
        onPressed = (){
          _collectAction();
        };
        break;

      case UserDelegateState.DUE_COLLECTED:
        actionTitle = "完成";
        onPressed = (){
          Fluttertoast.showToast(msg: "节点收益已经提取完成。");
        };
        break;

      case UserDelegateState.HALFDUE:
        actionTitle = "提取";
        onPressed = (){
          _collectAction();
        };
        break;

      case UserDelegateState.HALFDUE_COLLECTED:
        actionTitle = "完成";
        onPressed = (){
          Fluttertoast.showToast(msg: "节点一半的收益已经提取完成。");
        };
        break;

      case UserDelegateState.CANCELLED:
        actionTitle = "提取";
        onPressed = (){
          _collectAction();
        };
        break;

      case UserDelegateState.CANCELLED_COLLECTED:
        actionTitle = "完成";
        onPressed = (){
          Fluttertoast.showToast(msg: "节点退款已经提取完成。");
        };
        break;

      default:
        break;
    }

    return Visibility(
      visible: _visible,
      child: Positioned(
        bottom: 0,
        height: 48,
        width: MediaQuery.of(context).size.width,
        child: Container(
          child: RaisedButton(
            textColor: Colors.white,
            color: DefaultColors.color0f95b0,
            shape: RoundedRectangleBorder(
                side: BorderSide(color: Theme.of(context).primaryColor), borderRadius: BorderRadius.circular(0)),
            child: Text(actionTitle),
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }

  Future _collectAction() async {

    if (_wallet == null || _contractDetailItem == null) {
      return;
    }

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
        setState(() {
          if (mounted) {
            _isTransferring = true;
          }
        });

        ///创建节点合约的钱包地址
        var createNodeWalletAddress = _contractNodeItem.owner;
        var gasPriceRecommend = QuotesInheritedModel.of(context, aspect: QuotesAspect.gasPrice).gasPriceRecommend;
        var gasPrice = BigInt.from(gasPriceRecommend.average.toInt());
        //TODO: 如果创建者，使用COLLECT_MAP3_NODE_CREATOR_GAS_LIMIT，如果中期取币 COLLECT_HALF_MAP3_NODE_GAS_LIMIT, 如果参与者 COLLECT_MAP3_NODE_PARTNER_GAS_LIMIT
        var gasLimit = EthereumConst.COLLECT_MAP3_NODE_CREATOR_GAS_LIMIT;

        var collectHex = await _wallet.sendCollectMap3Node(
          createNodeWalletAddress: createNodeWalletAddress,
          gasPrice: gasPrice,
          gasLimit: gasLimit,
          password: walletPassword,
        );
        logger.i('map3 collect, collectHex: $collectHex');

        Application.router.navigateTo(
            context,
            Routes.map3node_broadcase_success_page +
                "?pageType=${Map3NodeCreateContractPage.CONTRACT_PAGE_TYPE_COLLECT}");
      } catch (_) {
        logger.e(_);
        setState(() {
          if (mounted) {
            _isTransferring = false;
          }
        });
        if (_ is PlatformException) {
          if (_.code == WalletError.PASSWORD_WRONG) {
            Fluttertoast.showToast(msg: S.of(context).password_incorrect);
          } else {
            Fluttertoast.showToast(msg: S.of(context).transfer_fail);
          }
        } else if (_ is RPCError) {
          if (_.errorCode == -32000) {
            Fluttertoast.showToast(msg: S.of(context).eth_balance_not_enough_for_gas_fee);
          } else {
            Fluttertoast.showToast(msg: S.of(context).transfer_fail);
          }
        } else {
          Fluttertoast.showToast(msg: S.of(context).transfer_fail);
        }
      }
    });
  }

  String _amountToString(String amount) => FormatUtil.formatNum(double.parse(amount).toInt());

}
