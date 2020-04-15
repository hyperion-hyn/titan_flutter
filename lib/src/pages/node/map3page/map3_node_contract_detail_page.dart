import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rxdart/rxdart.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/load_data_bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/quotes/quotes_component.dart';
import 'package:titan/src/components/wallet/vo/wallet_vo.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/node/api/node_api.dart';
import 'package:titan/src/pages/node/model/contract_delegator_item.dart';
import 'package:titan/src/pages/node/model/contract_detail_item.dart';
import 'package:titan/src/pages/node/model/contract_node_item.dart';
import 'package:titan/src/pages/node/model/enum_state.dart';
import 'package:titan/src/pages/node/model/node_item.dart';
import 'package:titan/src/pages/node/widget/node_delegator_member_widget.dart';
import 'package:titan/src/pages/node/widget/node_join_member_widget.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/plugins/wallet/wallet_const.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/utils.dart';
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
  bool _isCreator = false; // 判断当前钱包用户是否是为合约创建者
  void Function() onPressed = () {};
  var _actionTitle = "";

  var _amountDelegation = "0";
  var _nodeStateDesc = "";
  var _contractStateDesc = "";

  var _contractProgressDesc = "";
  var _contractProgressDetail = "";
  double _contractProgressIndex = 1.0;

  LoadDataBloc loadDataBloc = LoadDataBloc();
  int _currentPage = 0;
  NodeApi _nodeApi = NodeApi();
  List<ContractDelegateRecordItem> delegateRecordList = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    loadDataBloc.close();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_wallet == null) {
      _wallet = WalletInheritedModel.of(context).activatedWallet?.wallet;
      getContractInstanceItem();
      getJoinMemberData();
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          _pageWidget(context),
          _bottomSureButtonWidget(),
        ],
      ),
    );
  }

  Widget _pageWidget(BuildContext context) {
    if (_currentState != null || _contractNodeItem.contract == null) {
      return AllPageStateContainer(_currentState, () {
        setState(() {
          _currentState = all_page_state.LoadingState();
        });
      });
    }

    return LoadDataContainer(
        bloc: loadDataBloc,
        enablePullDown: false,
        onLoadingMore: () {
          getJoinMemberMoreData();
        },
        child: CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: Container(
                  color: Colors.white,
                  child:
                      getMap3NodeProductHeadItem(context, _contractNodeItem.contract, isJoin: true, isDetail: false)),
            ),
            SliverToBoxAdapter(child: _nodeInfoWidget(_nodeStateDesc)),
            _Spacer(),
            SliverToBoxAdapter(child: _contractActionsWidget(contractStateDesc: _contractStateDesc)),
            SliverToBoxAdapter(child: _lineSpacer()),
            SliverToBoxAdapter(child: _contractProgressWidget()),
            _Spacer(),
            SliverToBoxAdapter(
              child: NodeJoinMemberWidget(
                "${widget.contractId}",
                _contractNodeItem.remainDay,
                _contractNodeItem.shareUrl,
                isShowInviteItem: false,
              ),
            ),
            _Spacer(),
            //SliverToBoxAdapter(child: _delegatorListWidget()),
            SliverToBoxAdapter(child: _delegateRecordHeaderWidget()),
            SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
              return _delegateRecordItemWidget(delegateRecordList[index]);
            }, childCount: delegateRecordList.length)),
            //_Spacer(),
            SliverToBoxAdapter(
              child: Visibility(
                visible: _visible,
                child: Container(
                  height: 48,
                ),
              ),
            )
          ],
        ));
  }

  Widget _bottomSureButtonWidget() {
    _actionTitle = _isTransferring ? "提取中..." : _actionTitle;

    return Visibility(
      visible: _visible,
      child: Positioned(
        bottom: 0,
        height: 48,
        width: MediaQuery.of(context).size.width,
        child: Container(
          child: RaisedButton(
            textColor: Colors.white,
            color: Theme.of(context).primaryColor,
            shape: RoundedRectangleBorder(
                side: BorderSide(color: Theme.of(context).primaryColor), borderRadius: BorderRadius.circular(0)),
            child: Text(_actionTitle),
            onPressed: onPressed,
          ),
        ),
      ),
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

  Widget _contractActionsWidget({String contractStateDesc = ""}) {
    if (!_isCreator || _contractDetailItem == null) {
      return Container();
    }

    var amountDelegation = FormatUtil.amountToString(_contractDetailItem.amountDelegation);
    var expectedYield = FormatUtil.amountToString(_contractDetailItem.expectedYield);
    var commission = FormatUtil.amountToString(_contractDetailItem.commission);

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
    var durationType = _contractNodeItem.contract.durationType;

    double lineWidth = durationType == 2 ? 40 : 45;
    double _left(bool isLine, double index) {
      double horizontal = durationType == 2 ? 0 : 30;
      double gap = 16;
      double multi = durationType == 2 ? 40 : 8;
      double sectionWidth =
          (MediaQuery.of(context).size.width - horizontal * 2.0 - lineWidth * 4.0 - gap * 8.0) / multi;

      if (!isLine) {
        return horizontal + sectionWidth * (index - 1) + gap * (2.0 * (index - 1)) + lineWidth * (index - 1);
      }
      return horizontal + sectionWidth * (index - 1) + gap * (2.0 * (index - 1)) + lineWidth * (index);
    }

    List<Widget> children = [];

    if (_isCreator) {
      var stateIndex = enumUserDelegateStateFromString(_contractDetailItem?.state)?.index ?? 0;
      children = [
        _nodeWidget("创建时间", date: _contractNodeItem.instanceStartTime, left: _left(false, 1)),
        _lineWidget("7天", lineWidth,
            left: _left(true, 1),
            progress: stateIndex >= UserDelegateState.ACTIVE.index ? 1 : _contractNodeItem.remainProgress),
        _nodeWidget("启动成功",
            date: _contractNodeItem.instanceActiveTime,
            left: _left(false, 2),
            isLight: stateIndex >= UserDelegateState.ACTIVE.index),
        _lineWidget("90天", lineWidth,
            left: _left(true, 2),
            progress: stateIndex >= UserDelegateState.HALFDUE.index ? 1 : _contractNodeItem.expectHalfDueProgress),
        _nodeWidget("可提50%奖励", left: _left(false, 3), isLight: stateIndex >= UserDelegateState.HALFDUE.index),
        _lineWidget("90天", lineWidth,
            left: _left(true, 3),
            progress: stateIndex >= UserDelegateState.DUE.index ? 1 : _contractNodeItem.expectDueProgress),
        _nodeWidget("到期时间",
            date: _contractNodeItem.instanceDueTime,
            left: _left(false, 4),
            isLight: stateIndex >= UserDelegateState.DUE.index),
        _lineWidget("", lineWidth,
            left: _left(true, 4), progress: stateIndex >= UserDelegateState.DUE_COLLECTED.index ? 1 : 0.0),
        _nodeWidget("提取时间",
            date: _contractNodeItem.instanceFinishTime,
            left: _left(false, 5),
            isLight: stateIndex >= UserDelegateState.DUE_COLLECTED.index),
        _stateWidget(_contractProgressDetail, left: _left(false, _contractProgressIndex - 0.5)),
        _transformWidget(left: _left(false, _contractProgressIndex - 0.5)),
      ];
    } else {
      var stateIndex = enumContractStateFromString(_contractNodeItem.state).index;
      print("is:${stateIndex >= ContractState.DUE.index}, progress:${_contractNodeItem.expectDueProgress}");
      children = [
        _nodeWidget("创建时间", date: _contractNodeItem.instanceStartTime, left: _left(false, 1)),
        _lineWidget("7天", lineWidth,
            left: _left(true, 1),
            progress: stateIndex >= ContractState.ACTIVE.index ? 1 : _contractNodeItem.remainProgress),
        _nodeWidget("启动成功",
            date: _contractNodeItem.instanceActiveTime,
            left: _left(false, 2),
            isLight: stateIndex >= ContractState.ACTIVE.index),
        _lineWidget("${_contractNodeItem.contract.duration}天", lineWidth,
            left: _left(true, 2),
            progress: stateIndex >= ContractState.DUE.index ? 1.0 : _contractNodeItem.expectDueProgress),
        _nodeWidget("到期时间",
            date: _contractNodeItem.instanceDueTime,
            left: _left(false, 3),
            isLight: stateIndex >= ContractState.DUE.index),
        _lineWidget("", lineWidth,
            left: _left(true, 3), progress: stateIndex >= ContractState.DUE_COMPLETED.index ? 1.0 : 0.0),
        _nodeWidget("提取时间",
            date: _contractNodeItem.instanceFinishTime,
            left: _left(false, 4),
            isLight: stateIndex >= ContractState.DUE_COMPLETED.index),
        _stateWidget(_contractProgressDetail, left: _left(false, _contractProgressIndex - 0.75)),
        _transformWidget(left: _left(false, _contractProgressIndex - 0.75)),
      ];
    }

    return Container(
      color: Colors.white,
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
                  TextSpan(text: _contractProgressDesc, style: TextStyle(fontSize: 12, color: Colors.grey)),
                  /*TextSpan(
                    text: _contractProgressDetail,
                    style: TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.w500),
                  ),*/
                ])),
              ],
            ),
          ),
          Container(
            height: 140,
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
//            color: Colors.red,
            child: Stack(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stateWidget(String name, {double left = 10}) {
    return Positioned(
      left: left,
      top: 10,
      child: Container(
        color: _getStatusColor(enumContractStateFromString(_contractNodeItem.state)),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Text(
            name,
            style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.normal),
          ),
        ),
      ),
    );
  }

  Widget _transformWidget({double left = 10}) {
    return Positioned(
      left: left,
      top: 32.5,
      width: 2.0,
      height: 30,
      child: Container(
        color: _getStatusColor(enumContractStateFromString(_contractNodeItem.state)),
        // rotationZ 的参数为弧度，1.6 大概等于 90°
        // 转换公式 ( 度数 * 3.14 / 180 )
        transform: Matrix4.rotationZ(0.45),
      ),
    );
  }

  Widget _nodeWidget(String name, {int date = 0, double left = 10, bool isLight = true, bool isMiddle = false}) {
    double top = isLight ? 60 : 62;
    double wh = isLight ? 11 : 6;
    var circleColor = isLight ? HexColor("#322300") : HexColor("#CCCCCC");
    var textColor = isLight ? HexColor("#4B4B4B") : HexColor("#A7A7A7");
    var dateString = date > 0 ? "${FormatUtil.formatDate(date)}" : "";

    return Positioned(
      left: left,
      top: top,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: wh,
            height: wh,
            decoration: BoxDecoration(
                shape: BoxShape.circle, color: Colors.white, border: Border.all(color: circleColor, width: 2.0)),
          ),
          Container(
            height: 8.0,
          ),
          Text(
            name,
            style: TextStyle(fontSize: isMiddle ? 10 : 12, color: textColor, fontWeight: FontWeight.normal),
          ),
          Container(
            height: 8.0,
          ),
          Text(
            dateString,
            style: TextStyle(fontSize: 10, color: HexColor("#A7A7A7"), fontWeight: FontWeight.normal),
          ),
          Container(
            height: 8.0,
          ),
        ],
      ),
    );
  }

  Widget _lineWidget(String name, double width, {double left = 10, double progress = 0.0}) {
    var lightColor = HexColor("#322300");
    var greyColor = HexColor("#ECECEC");

    return Positioned(
      top: 38,
      left: left,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            name,
            style: TextStyle(fontSize: 12, color: HexColor("#4B4B4B"), fontWeight: FontWeight.normal),
          ),
          Container(
            height: 8.0,
          ),
          Stack(
            children: <Widget>[
              Container(
                height: 1.0,
                width: width,
                color: greyColor,
              ),
              Container(
                height: 1.0,
                width: width * progress == double.infinity ? 0 : width * progress,
                color: lightColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _lineSpacer() {
    return Container(
      height: 0.5,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      color: DefaultColors.colorf5f5f5,
    );
  }

  Widget _Spacer() {
    return SliverToBoxAdapter(
      child: Container(
        height: 10,
        color: DefaultColors.colorf5f5f5,
      ),
    );
  }

  Widget _delegateRecordHeaderWidget() {
    return Container(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
        child: Row(
          children: <Widget>[
            Text(S.of(context).account_flow, style: TextStyle(fontSize: 16, color: HexColor("#333333"))),
            Spacer(),
            Text(S.of(context).total + "：${FormatUtil.amountToString(_contractNodeItem.amountDelegation)} (HYN)",
                style: TextStyle(fontSize: 14, color: HexColor("#999999")))
          ],
        ),
      ),
    );
  }

  Widget _delegateRecordItemWidget(ContractDelegateRecordItem delegateItem) {
    String showName = delegateItem.userName.substring(0, 1);
    String userAddress = shortBlockChainAddress(" ${delegateItem.userAddress}", limitCharsLength: 8);
    String txHash = shortBlockChainAddress(delegateItem.txHash, limitCharsLength: 6);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      child: Stack(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
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
                    showName,
                    style: TextStyle(fontSize: 15, color: HexColor("#000000")),
                  )),
                ),
              ),
              Flexible(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      RichText(
                        text: TextSpan(
                            text: "${delegateItem.userName}",
                            style: TextStyle(fontSize: 14, color: HexColor("#000000")),
                            children: [
                              TextSpan(
                                text: userAddress,
                                style: TextStyle(fontSize: 12, color: HexColor("#9B9B9B")),
                              )
                            ]),
                      ),
                      Container(
                        height: 6.0,
                      ),
                      Text("${FormatUtil.formatDate(delegateItem.createAt)}",
                          style: TextStyle(fontSize: 12, color: HexColor("#333333"))),
                      Container(
                        height: 6.0,
                      ),
                    ],
                  ),
                ),
              ),
              //Spacer(),
              Container(
                width: 8,
              ),
              Flexible(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    RichText(
                      text: TextSpan(
                        text: FormatUtil.amountToString(delegateItem.amount),
                        style: TextStyle(fontSize: 14, color: HexColor("#333333"), fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      height: 6.0,
                    ),
                    Text(txHash, style: TextStyle(fontSize: 12, color: HexColor("#333333")))
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 40,
            right: 8,
            child: Container(
              height: 0.5,
              color: DefaultColors.colorf5f5f5,
            ),
          ),
        ],
      ),
    );
  }

  HexColor _getStatusColor(ContractState status) {
    var statusColor = HexColor('#EED197');

    switch (status) {
      case ContractState.PENDING:
        statusColor = HexColor('#EED197');
        break;

      case ContractState.ACTIVE:
      case ContractState.DUE:
        statusColor = HexColor('#1FB9C7');
        break;

      case ContractState.CANCELLED:
      case ContractState.CANCELLED_COMPLETED:
        statusColor = HexColor('#F30202');
        break;

      default:
        statusColor = HexColor('#FFDB58');
        break;
    }
    return statusColor;
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

        var gasPriceRecommend = QuotesInheritedModel.of(context, aspect: QuotesAspect.gasPrice).gasPriceRecommend;
        var gasPrice = gasPriceRecommend.average.toInt();

        var gasLimit = EthereumConst.COLLECT_MAP3_NODE_CREATOR_GAS_LIMIT;
        if (enumUserDelegateStateFromString(_contractDetailItem?.state) == UserDelegateState.HALFDUE) {
          gasLimit = EthereumConst.COLLECT_HALF_MAP3_NODE_GAS_LIMIT;
        } else {
          if (_isCreator) {
            gasLimit = EthereumConst.COLLECT_MAP3_NODE_CREATOR_GAS_LIMIT;
          } else {
            gasLimit = EthereumConst.COLLECT_MAP3_NODE_PARTNER_GAS_LIMIT;
          }
        }

        var collectHex = await _api.withdrawContractInstance(
            _contractNodeItem, WalletVo(wallet: _wallet), walletPassword, gasPrice, gasLimit);
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

  void getJoinMemberData() async {
    try {
      _currentPage = 0;
      delegateRecordList = [];
      List<ContractDelegateRecordItem> tempMemberList =
          await _nodeApi.getContractDelegateRecord(widget.contractId, page: _currentPage);

      if (tempMemberList.length > 0) {
        delegateRecordList.addAll(tempMemberList);
        loadDataBloc.add(LoadingMoreSuccessEvent());
      } else {
        loadDataBloc.add(LoadMoreEmptyEvent());
      }

      setState(() {});
    } catch (e) {
      setState(() {
        loadDataBloc.add(LoadMoreFailEvent());
      });
    }
  }

  void getJoinMemberMoreData() async {
    try {
      _currentPage++;
      List<ContractDelegateRecordItem> tempMemberList =
          await _nodeApi.getContractDelegateRecord(widget.contractId, page: _currentPage);

      if (tempMemberList.length > 0) {
        delegateRecordList.addAll(tempMemberList);
        loadDataBloc.add(LoadingMoreSuccessEvent());
      } else {
        loadDataBloc.add(LoadMoreEmptyEvent());
      }

      setState(() {});
    } catch (e) {
      setState(() {
        loadDataBloc.add(LoadMoreFailEvent());
      });
    }
  }

  void getContractInstanceItem() async {
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
            "",
            ContractState.DUE_COMPLETED.toString().split(".").last
        );

        LatestTransaction _transaction = LatestTransaction("",0,0,"","","");
        _contractDetailItem = ContractDetailItem(nodeItem, "", "", "0", "0", "0", 0,  _transaction, "ACTIVE");
        _contractNodeItem = nodeItem;
        // todo： 测试
        //_contractDetailItem.userDelegateState = UserDelegateState.DUE_COLLECTED.toString().split(".").last;
        _currentState = null;
        _visible = true;
      });
    });

    return;*/

    try {
      // 0.
      var instanceItem = await _api.getContractInstanceItem("${widget.contractId}");

      var address = _wallet.getEthAccount().address;

      _isCreator = address == instanceItem.owner;

      // todo： 测试
      //_isCreator = true;

      if (_isCreator) {
        var detailItem = await _api.getContractDetail("${widget.contractId}", address: address);
        _contractDetailItem = detailItem;
        _contractNodeItem = detailItem.instance;
        print('[map3] getContractDetail , id:${_contractNodeItem.id}, _isCreator:${_isCreator}');

        // todo： 测试
        _contractNodeItem.contract.durationType = 2;
        _contractDetailItem.state = UserDelegateState.DUE_COLLECTED.toString().split(".").last ?? "";
      } else {
        _contractNodeItem = instanceItem;

        // todo： 测试
        _contractNodeItem.state = ContractState.DUE.toString().split(".").last ?? "";

        print('[map3] getContractInstanceItem , id:${_contractNodeItem.id}, _isCreator:${_isCreator}');
      }

      // 1.
      var userDelegateState = enumUserDelegateStateFromString(_contractDetailItem?.state ?? "");

      switch (userDelegateState) {
        case UserDelegateState.PENDING:
          _actionTitle = "增加投入";
          onPressed = () {
            Application.router
                .navigateTo(context, Routes.map3node_join_contract_page + "?contractId=${_contractNodeItem.id}");
          };
          _visible = true;
          break;

        case UserDelegateState.ACTIVE:
          _actionTitle = "已抵押";
          onPressed = () {
            Fluttertoast.showToast(msg: "节点正在运行中。。。");
          };
          _visible = false;
          break;

        case UserDelegateState.DUE:
          _actionTitle = "提取";
          onPressed = () {
            _collectAction();
          };
          _visible = true;
          break;

        case UserDelegateState.DUE_COLLECTED:
          _actionTitle = "完成";
          onPressed = () {
            Fluttertoast.showToast(msg: "节点收益已经提取完成。");
          };
          _visible = false;
          break;

        case UserDelegateState.HALFDUE:
          _actionTitle = "提取50%收益";
          onPressed = () {
            _collectAction();
          };
          _visible = true;
          break;

        case UserDelegateState.HALFDUE_COLLECTED:
          _actionTitle = "完成";
          onPressed = () {
            Fluttertoast.showToast(msg: "节点一半的收益已经提取完成。");
          };
          _visible = false;
          break;

        case UserDelegateState.CANCELLED:
          _actionTitle = "提取";
          onPressed = () {
            _collectAction();
          };
          _visible = true;
          break;

        case UserDelegateState.CANCELLED_COLLECTED:
          _actionTitle = "完成";
          onPressed = () {
            Fluttertoast.showToast(msg: "节点退款已经提取完成。");
          };
          _visible = false;
          break;

        default:
          break;
      }

      var contractState = enumContractStateFromString(_contractNodeItem.state);
      print('[contract] _pageView, stateString:${_contractNodeItem.state},state:$contractState');

      if (!_isCreator && contractState == ContractState.PENDING) {
        _actionTitle = "增加投入";
        onPressed = () {
          Application.router
              .navigateTo(context, Routes.map3node_join_contract_page + "?contractId=${_contractNodeItem.id}");
        };
        _visible = true;
      }

      // 2.
      switch (contractState) {
        case ContractState.PENDING:
          _nodeStateDesc = "节点待启动";
          _contractStateDesc = "正在创建中，等待区块链网络验证";

          _contractProgressDesc = "等待启动";
          _contractProgressDetail = "还差${FormatUtil.amountToString(_contractNodeItem.remainDelegation)}HYN";
          _contractProgressIndex = 3.0;
          break;

        case ContractState.ACTIVE:
          _nodeStateDesc = "节点进行中";
          _contractStateDesc = "已广播投入$_amountDelegation HYN，等待区块链网络验证";

          _contractProgressDesc = "启动成功";
          _contractProgressDetail = "剩余${_contractNodeItem.expectDueDay}天";
          _contractProgressIndex = 3.0;
          break;

        case ContractState.DUE:
          _nodeStateDesc = "节点已停止";

          _contractProgressDesc = "启动成功";
          _contractProgressDetail = "已到期,可提全部奖励";
          _contractProgressIndex = 4.0;
          break;

        case ContractState.CANCELLED:
          _nodeStateDesc = "节点已停止";
          _contractStateDesc = "启动失败，请申请退款";

          _contractProgressDesc = "启动失败";
          _contractProgressDetail = "启动失败";
          _contractProgressIndex = 3.0;
          break;

        case ContractState.DUE_COMPLETED:
          _nodeStateDesc = "节点已停止";
          _contractStateDesc = "已取回投入资金";

          _contractProgressDesc = "已获取奖励";
          _contractProgressDetail = "恭喜，已提取奖励";
          _contractProgressIndex = 5.0;
          break;

        case ContractState.CANCELLED_COMPLETED:
          _nodeStateDesc = "节点已停止";
          _contractStateDesc = "已取回投入资金";

          _contractProgressDesc = "启动失败";
          _contractProgressDetail = "启动失败";
          _contractProgressIndex = 3.0;
          break;

        default:
          break;
      }

      if (_isCreator &&
          UserDelegateState.HALFDUE_COLLECTED == enumUserDelegateStateFromString(_contractDetailItem?.state ?? "")) {
        _contractProgressDesc = "启动成功";
        _contractProgressDetail = "可提取50%奖励";
        _contractProgressIndex = 4.0;
      }

      // 3.
      Future.delayed(Duration(seconds: 1), () {
        setState(() {
          _currentState = null;
        });
      });
    } catch (e) {
      setState(() {
        _currentState = all_page_state.LoadFailState();
      });
    }
  }
}
