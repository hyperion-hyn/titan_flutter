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
  all_page_state.AllPageState currentState = all_page_state.LoadingState();
  NodeApi api = NodeApi();
  ContractDetailItem _contractDetailItem;
  ContractNodeItem _contractNodeItem;
  Wallet _wallet;

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

    _wallet = WalletInheritedModel.of(context).activatedWallet?.wallet;

    getNetworkData();
  }

  void getNetworkData() async {
    try {
      var address = _wallet.getEthAccount().address;
      var item = await api.getContractDetail("${widget.contractId}", address: address);

      Future.delayed(Duration(seconds: 1), () {
        setState(() {
          print('[map3] _loadLastData , id:${item.instance.id}');
          _contractDetailItem = item;
          _contractNodeItem = item.instance;
          currentState = null;
        });
      });
    } catch (e) {
      setState(() {
        currentState = all_page_state.LoadFailState();
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

  Widget _bottomSureWidget() {
    return Positioned(
      bottom: 0,
      height: 48,
      width: MediaQuery.of(context).size.width,
      child: Container(
        //padding: EdgeInsets.only(top: 100),
        //padding: EdgeInsets.symmetric(horizontal: 30),
        //padding: EdgeInsets.fromLTRB(0, 0, 0, 100),
        //constraints: BoxConstraints.expand(height: 48),
        child: RaisedButton(
          textColor: Colors.white,
          color: DefaultColors.color0f95b0,
          shape: RoundedRectangleBorder(
              side: BorderSide(color: Theme.of(context).primaryColor), borderRadius: BorderRadius.circular(0)),
          child: Text("确定"),
          onPressed: _collectAction,
        ),
      ),
    );
  }

  Widget _pageView(BuildContext context) {
    if (currentState != null || _contractNodeItem.contract == null) {
      return AllPageStateContainer(currentState, () {
        setState(() {
          currentState = all_page_state.LoadingState();
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
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
          color: Colors.white,
          child: getMap3NodeProductHeadItem(context, _contractNodeItem.contract, isJoin: true, isDetail: false)),
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
                Container(width: 100, child: Text("节点版本", style: TextStyle(fontSize: 14, color: HexColor("#92979a")))),
                new Text("${_contractNodeItem.contract.nodeName}", style: TextStyles.textC333S14)
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: <Widget>[
                  Container(width: 100, child: Text("服务商", style: TextStyle(fontSize: 14, color: HexColor("#92979a")))),
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
      _Spacer(),
      _contractActionsWidget(contractStateDesc: contractStateDesc),
      Container(
        height: 0.5,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        color: DefaultColors.colorf5f5f5,
      ),
      _contractProgressWidget(),
      _Spacer(),
      NodeJoinMemberWidget(
        "${widget.contractId}",
        _contractNodeItem.remainDay,
        isShowInviteItem: false,
      ),
      _Spacer(),
      _delegatorListWidget(),
      _Spacer(),
      Container(
        height: 48,
      ),
    ]));
  }

  Widget _delegatorListWidget() {
    var amountDelegation = _amountToString(_contractNodeItem.amountDelegation);

    return Container(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
            child: Row(
              children: <Widget>[
                Text("入账流水", style: TextStyle(fontSize: 14, color: HexColor("#333333"))),
                Spacer(),
                Text("总额：${amountDelegation} (HYN)", style: TextStyle(fontSize: 12, color: HexColor("#999999")))
              ],
            ),
          ),
          Container(
            height: 50,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: 40,
                    width: 40,
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(13.0)),
                      ),
                      child: Center(
                          child: Text(
                        "M",
                        style: TextStyle(fontSize: 15, color: HexColor("#000000")),
                      )),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Column(
                      children: <Widget>[
                        RichText(
                          text: TextSpan(
                              text: "Moo",
                              style: TextStyle(fontSize: 14, color: HexColor("#000000")),
                              children: [
                                TextSpan(
                                  text: " oxfdaf89fdaff",
                                  style: TextStyle(fontSize: 12, color: HexColor("#9B9B9B")),
                                )
                              ]),
                        ),
                        Container(
                          height: 6.0,
                        ),
                        Text("2019-10-02 17:00", style: TextStyle(fontSize: 12, color: HexColor("#333333")))
                      ],
                    ),
                  ),
                  Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      RichText(
                        text: TextSpan(
                          text: "20,000",
                          style: TextStyle(fontSize: 14, color: HexColor("#333333"), fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        height: 6.0,
                      ),
                      Text("0xfffsdfsdffsf", style: TextStyle(fontSize: 12, color: HexColor("#333333")))
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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
    double horizontal = 25;
    double sectionWidth = (MediaQuery.of(context).size.width - horizontal * 2.0) * 0.2;
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
                    text: "2天",
                    style: TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.w500),
                  ),
                ])),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 48),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text("7天", style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.normal)),
                Container(
                  width: sectionWidth,
                ),
                Text("90天", style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.normal)),
                Container(
                  width: sectionWidth * 0.5,
                ),
                Text("90天", style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.normal)),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontal),
            child: Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                    shape: BoxShape.circle, color: Colors.white, border: Border.all(color: Colors.blue, width: 1.0)),
              ),
              Container(
                height: 2.5,
                width: sectionWidth,
                color: Colors.green,
              ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                    shape: BoxShape.circle, color: Colors.white, border: Border.all(color: Colors.grey, width: 1.0)),
              ),
              Container(
                height: 2.5,
                width: sectionWidth,
                color: Colors.green,
              ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                    shape: BoxShape.circle, color: Colors.white, border: Border.all(color: Colors.grey, width: 1.0)),
              ),
              Container(
                height: 2.5,
                width: sectionWidth,
                color: Colors.green,
              ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                    shape: BoxShape.circle, color: Colors.white, border: Border.all(color: Colors.grey, width: 1.0)),
              ),
              Container(
                height: 2.5,
                width: sectionWidth,
                color: Colors.green,
              ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                    shape: BoxShape.circle, color: Colors.white, border: Border.all(color: Colors.grey, width: 1.0)),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("待启动", style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.normal)),
                Text("启动", style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.normal)),
                Padding(
                  padding: const EdgeInsets.only(top: 0),
                  child: Text("中期可取50%奖励",
                      style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.normal)),
                ),
                Text("到期", style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.normal)),
                Text("已提取", style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.normal)),
              ],
            ),
          ),
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
        statusColor = Theme.of(context).primaryColor;
        break;
    }
    return statusColor;
  }

  Widget _Spacer() {
    return Container(
      height: 10,
      color: DefaultColors.colorf5f5f5,
    );
  }

  bool isTransferring = false;

  Future _collectAction() async {
    var btnTitle = isTransferring ? S.of(context).please_waiting : "查看合约";

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
            isTransferring = true;
          }
        });

        ///创建节点合约的钱包地址
        var createNodeWalletAddress = _contractNodeItem.owner;
        var gasPriceRecommend = QuotesInheritedModel.of(context, aspect: QuotesAspect.gasPrice).gasPriceRecommend;
        var gasPrice = BigInt.from(gasPriceRecommend.average.toInt());
        //TODO 如果创建者，使用COLLECT_MAP3_NODE_CREATOR_GAS_LIMIT，如果中期取币 COLLECT_HALF_MAP3_NODE_GAS_LIMIT, 如果参与者 COLLECT_MAP3_NODE_PARTNER_GAS_LIMIT
        var gasLimit = EthereumConst.COLLECT_MAP3_NODE_CREATOR_GAS_LIMIT;

        /*var signedHex = await _wallet.signCollectMap3Node(
          createNodeWalletAddress: createNodeWalletAddress,
          gasPrice: gasPrice,
          gasLimit: gasLimit,
          password: walletPassword,
        );
        var ret = await WalletUtil.postToEthereumNetwork(method: 'eth_sendRawTransaction', params: [signedHex]);

        logger.i('map3 collect, result: $ret');

       */

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
            isTransferring = false;
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
