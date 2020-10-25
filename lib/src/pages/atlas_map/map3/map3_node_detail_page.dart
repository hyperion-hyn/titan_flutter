import 'dart:convert';
import 'dart:math';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/load_data_bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/atlas_map/entity/atlas_home_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/atlas_info_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/enum_atlas_type.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_info_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_tx_log_entity.dart';
import 'package:titan/src/pages/atlas_map/widget/custom_stepper.dart';
import 'package:titan/src/pages/atlas_map/widget/node_join_member_widget.dart';
import 'package:titan/src/pages/node/api/node_api.dart';
import 'package:titan/src/pages/node/model/map3_node_util.dart';
import 'package:titan/src/pages/node/model/node_provider_entity.dart';
import 'package:titan/src/pages/wallet/model/hyn_transfer_history.dart';
import 'package:titan/src/pages/webview/webview.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/log_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/utils/utils.dart';
import 'package:titan/src/widget/all_page_state/all_page_state.dart' as all_page_state;
import 'package:titan/src/widget/all_page_state/all_page_state_container.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'package:titan/src/widget/map3_nodes_widget.dart';
import 'package:titan/src/widget/popup/bubble_widget.dart';
import 'package:titan/src/widget/popup/pop_route.dart';
import 'package:titan/src/widget/popup/pop_widget.dart';
import 'package:titan/src/widget/wallet_widget.dart';
import 'package:web3dart/web3dart.dart';
import '../../../global.dart';
import 'map3_node_create_wallet_page.dart';
import 'map3_node_public_widget.dart';
import 'package:web3dart/src/models/map3_node_information_entity.dart';

class Map3NodeDetailPage extends StatefulWidget {
  final Map3InfoEntity map3infoEntity;

  Map3NodeDetailPage(this.map3infoEntity);

  @override
  _Map3NodeDetailState createState() => _Map3NodeDetailState();
}

class _Map3NodeDetailState extends BaseState<Map3NodeDetailPage> {
  all_page_state.AllPageState _currentState = all_page_state.LoadingState();
  AtlasApi _atlasApi = AtlasApi();

  // 0映射中;1 创建提交中；2创建失败; 3募资中,没在撤销节点;4募资中，撤销节点提交中，如果撤销失败将回到3状态；5撤销节点成功；6合约已启动；7合约期满终止；
  Map3InfoStatus _map3Status = Map3InfoStatus.CREATE_SUBMIT_ING;
  Map3InfoEntity _map3infoEntity;

  Microdelegations _microDelegationsCreator;
  Microdelegations _microDelegationsJoiner;

  get _atlasInfoEntity => _map3infoEntity.atlas;

  var _currentEpoch = 0;

  //get _unlockEpoch => _microDelegationsJoiner?.pendingDelegation?.unlockedEpoch;

  String _notifyMessage() {
    var startMin = double.parse(AtlasApi.map3introduceEntity?.startMin ?? "0"); //最小启动所需
    var staking = double.parse(_map3infoEntity?.getStaking() ?? "0"); //当前抵押量
    var isFull = (startMin > 0) && (staking > 0) && (staking >= startMin);
    if (_map3Status == Map3InfoStatus.FUNDRAISING_NO_CANCEL && isFull) {
      var startMinValue = FormatUtil.formatTenThousandNoUnit(startMin.toString()) + S.of(context).ten_thousand;
      return "抵押已满$startMinValue，将在下个纪元启动……";
    } else if (_map3Status == Map3InfoStatus.CONTRACT_IS_END) {
      return "节点已到期，将在下个纪元结算……";
    }
    return null;
  }

  get _visibleReDelegation {
    return _map3Status == Map3InfoStatus.CONTRACT_HAS_STARTED;
  }

  /*
  enum Map3InfoStatus {
  MAP,
  CREATE_SUBMIT_ING,
  CREATE_FAIL,
  FUNDRAISING_NO_CANCEL,
  FUNDRAISING_CANCEL_SUBMIT,
  CANCEL_NODE_SUCCESS,
  CONTRACT_HAS_STARTED,
  CONTRACT_IS_END,
}*/

  get _visibleBottomBar {
    return [
      Map3InfoStatus.FUNDRAISING_NO_CANCEL,
      Map3InfoStatus.CONTRACT_HAS_STARTED,
    ].contains(_map3Status);
  }

  LoadDataBloc _loadDataBloc = LoadDataBloc();
  int _currentPage = 0;
  List<HynTransferHistory> _delegateRecordList = [];

  get _stateColor => Map3NodeUtil.statusColor(_map3Status);

  get _isNoWallet => _address.isEmpty;

  //get _unlockRemainEpoch => Decimal.parse('${_unlockEpoch ?? 0}') - Decimal.parse('${_currentEpoch ?? 0}');

  get _endRemainEpoch => Decimal.parse('${_map3infoEntity?.endEpoch ?? 0}') - Decimal.parse('${_currentEpoch ?? 0}');

  // 到期纪元
  get releaseEpoch => double.parse(_map3nodeInformationEntity?.map3Node?.releaseEpoch ?? "0").toInt();

  get _visibleEditNextPeriod {
    return _map3Status == Map3InfoStatus.CONTRACT_HAS_STARTED;
  }

  /*
  tips:
  “创建者“显示编辑： 倒数14个纪元到倒数7纪元 且 状态为未设置  开始显示。
  如果已经设置了关闭，就显示【关闭】，其他情况显示【已开启】

  ”抵押者“显示编辑： 倒数7纪元后  且 （“创建者”设置为【已开启】或【未设置】） 且  自己状态为未设置，    或“创建者”已设置为【已开启】 且 自己状态为未设置，  开始显示。
  如果已经设置了关闭，就显示【关闭】，其他情况显示【已开启】
  */
  get _canEditNextPeriod {
    // 周期
    var periodEpoch14 = releaseEpoch - 14 > 0 ? releaseEpoch - 14 : 0;
    var periodEpoch7 = releaseEpoch - 7 > 0 ? releaseEpoch - 7 : 0;

    var statusCreator = _microDelegationsCreator?.renewal?.status ?? 0;

    //  创建者
    if (_isCreator) {
      var isInActionPeriodCreator = (_currentEpoch > periodEpoch14) && (_currentEpoch <= periodEpoch7);
      if (isInActionPeriodCreator && statusCreator == 0) {
        //在可编辑时间内，且未修改过
        return true;
      }
    }

    // 参与者
    var statusJoiner = _microDelegationsJoiner?.renewal?.status ?? 0;
    var isInActionPeriodJoiner = _currentEpoch > periodEpoch7 && _currentEpoch <= releaseEpoch;
    var isCreatorSetOpen = statusCreator == 2; //创建人已开启
    if (statusJoiner == 0 && (isInActionPeriodJoiner || isCreatorSetOpen)) {
      return true;
    }

    return false;
  }

  get _canExit {
    // 0.募集中
    var isPending = _map3Status == Map3InfoStatus.FUNDRAISING_NO_CANCEL;

    // 1.纪元已经过7天；
    var isOver7Epoch = (_currentEpoch - (_map3infoEntity?.startEpoch ?? 0)) >= 7;
    return _isCreator && isPending && isOver7Epoch;
  }

  /*
  get _canCancel {
    // 0.募集中
    var condition0 = _map3Status == Map3InfoStatus.FUNDRAISING_NO_CANCEL;

    // 1.纪元已经过7天；
    var condition1 = (_currentEpoch - (_map3infoEntity?.startEpoch ?? 0)) > 7;
    return _isDelegator && condition0 && condition1;
  }
  */

  get _canDelegate => _map3Status == Map3InfoStatus.FUNDRAISING_NO_CANCEL;

  /*
  角色分析：
  1.判断是否参与抵押
  Yes：用户（包括：创建人，参与者）
  NO：未抵押，即：游客

  2.针对角色开放不同权限
  a: 创建人
  b: 参与人
  c: 游客
  *
   */
  get _isCreator => _map3infoEntity?.isCreator() ?? false;

  get _isDelegator => _map3infoEntity?.mine != null;

  get _currentStep {
    if (_map3Status == null) return 0;

    int value = 0;

    switch (_map3Status) {
      case Map3InfoStatus.MAP:
      case Map3InfoStatus.CREATE_SUBMIT_ING:
      case Map3InfoStatus.FUNDRAISING_NO_CANCEL:
      case Map3InfoStatus.FUNDRAISING_CANCEL_SUBMIT:
      case Map3InfoStatus.CANCEL_NODE_SUCCESS:
        value = 0;
        break;

      case Map3InfoStatus.CONTRACT_HAS_STARTED:
        value = 1;
        break;

      case Map3InfoStatus.CONTRACT_IS_END:
        value = 2;
        break;

      default:
        break;
    }

    return value;
  }

  get _currentStepProgress {
    if (_map3Status == null) return 0.0;

    double value = 0.0;

    switch (_map3Status) {
      case Map3InfoStatus.MAP:
      case Map3InfoStatus.CREATE_SUBMIT_ING:
      case Map3InfoStatus.FUNDRAISING_NO_CANCEL:
      case Map3InfoStatus.FUNDRAISING_CANCEL_SUBMIT:
      case Map3InfoStatus.CANCEL_NODE_SUCCESS:
        value = 0.5;
        break;

      case Map3InfoStatus.CONTRACT_HAS_STARTED:
        value = 0.5;
        break;

      case Map3InfoStatus.CONTRACT_IS_END:
        value = 0.5;
        break;

      default:
        break;
    }

    return value;
  }

  get _contractStateDesc {
    if (_map3Status == null) {
      return S.of(context).wait_to_launch;
    }

    var _map3StatusDesc = "待启动";

    switch (_map3Status) {

      case Map3InfoStatus.MAP:
        _map3StatusDesc = "映射中";

        break;

      case Map3InfoStatus.CREATE_SUBMIT_ING:
        _map3StatusDesc = "创建中";

        break;

      case Map3InfoStatus.FUNDRAISING_NO_CANCEL:
        _map3StatusDesc = "待启动";

        break;

      case Map3InfoStatus.CREATE_FAIL:
        _map3StatusDesc = "启动失败";

        break;

      case Map3InfoStatus.CONTRACT_HAS_STARTED:
        _map3StatusDesc = "运行中";

        break;

      case Map3InfoStatus.CONTRACT_IS_END:
        _map3StatusDesc = "已到期";

        break;

      case Map3InfoStatus.CANCEL_NODE_SUCCESS:
        _map3StatusDesc = "已终止";

        break;

      case Map3InfoStatus.FUNDRAISING_CANCEL_SUBMIT:
        _map3StatusDesc = "撤销中";

        break;

      case Map3InfoStatus.MAP:
        _map3StatusDesc = "映射中";

        break;

      default:
        _map3StatusDesc = "";

        break;
    }

    print("_map3Status：$_map3Status, _map3StatusDesc:$_map3StatusDesc");

    return _map3StatusDesc;
  }

  get _contractStateDetail {
    if (_map3Status == null) {
      return S.of(context).wait_block_chain_verification;
    }

    var _map3StatusDesc = "";

    switch (_map3Status) {
      case Map3InfoStatus.MAP:
      case Map3InfoStatus.CREATE_SUBMIT_ING:
        _map3StatusDesc = "";

        break;

      case Map3InfoStatus.CREATE_FAIL:
        _map3StatusDesc = "";

        break;

      case Map3InfoStatus.CONTRACT_HAS_STARTED:
        _map3StatusDesc = "距离到期还有${(_endRemainEpoch.toInt()) > 0 ? _endRemainEpoch : 0}纪元";

        break;

      case Map3InfoStatus.CONTRACT_IS_END:
        _map3StatusDesc = "";

        break;

      case Map3InfoStatus.CANCEL_NODE_SUCCESS:
        _map3StatusDesc = "";

        break;

      case Map3InfoStatus.FUNDRAISING_CANCEL_SUBMIT:
        _map3StatusDesc = "";

        break;

      case Map3InfoStatus.FUNDRAISING_NO_CANCEL:
        var startMin = double.parse(AtlasApi.map3introduceEntity?.startMin ?? "0");
        var staking = double.parse(_map3infoEntity?.getStaking() ?? "0");
        var remain = startMin - staking;
        if (remain <= 0) {
          _map3StatusDesc = "抵押已满，准备启动";
        } else {
          var remainDelegation = FormatUtil.formatPrice(remain);
          _map3StatusDesc = S.of(context).remain + remainDelegation + "启动";
        }

        break;

      default:
        _map3StatusDesc = "";

        break;
    }

    return _map3StatusDesc;
  }

  var _moreKey = GlobalKey(debugLabel: '__more_global__');
  double _moreSizeHeight = 18;
  double _moreSizeWidth = 100;
  double _moreOffsetLeft = 246;
  double _moreOffsetTop = 76;
  var _address = "";
  var _nodeId = "";
  var _nodeAddress = "";
  final client = WalletUtil.getWeb3Client(true);
  Map3NodeInformationEntity _map3nodeInformationEntity;

  NodeApi _nodeApi = NodeApi();
  NodeProviderEntity _selectProviderEntity;
  Regions _selectedRegion;

  @override
  void onCreated() {
    super.onCreated();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    var _wallet = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet?.wallet;
    _address = _wallet?.getEthAccount()?.address ?? "";
    _map3infoEntity = widget.map3infoEntity;

    _nodeId = _map3infoEntity?.nodeId ?? "";
    _nodeAddress = _map3infoEntity?.address ?? "";
    _map3Status = Map3InfoStatus.values[_map3infoEntity?.status ?? 1];

    getContractDetailData();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);

    super.initState();
  }

  void _afterLayout(_) {
    _getMorePosition();
  }

  _getMorePosition() {
    final RenderBox renderBox = _moreKey?.currentContext?.findRenderObject();
    if (renderBox == null) return;

    final positions = renderBox.localToGlobal(Offset(0, 0));
    _moreOffsetLeft = positions.dx - _moreSizeWidth * 0.75;
    _moreOffsetTop = positions.dy + 18 * 2.0 + 10;
    //print("positions of more:$positions, left:$_moreOffsetLeft, top:$_moreOffsetTop");
  }

//  left: 246,
//  top: 76,

  @override
  void dispose() {
    print("[detail] dispose");

    _loadDataBloc.close();
    super.dispose();
  }

  Widget build(BuildContext context) {
    // todo: test_jison
    //_map3Status = Map3InfoStatus.values[0];

    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        backgroundColor: DefaultColors.colorf5f5f5,
        appBar: BaseAppBar(
          baseTitle: S.of(context).node_contract_detail,
          actions: <Widget>[
            InkWell(
              onTap: _canExit ? _showMoreAlertView : _shareAction,
              borderRadius: BorderRadius.circular(60),
              child: Padding(
                padding: EdgeInsets.only(left: 20, right: 35),
                child: Icon(
                  _canExit ? Icons.add : Icons.share,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ],
        ),
        body: _pageWidget(context),
      ),
    );
  }

  Widget _pageWidget(BuildContext context) {
    if (_currentState != null || _map3infoEntity == null) {
      return Scaffold(
        body: AllPageStateContainer(_currentState, () {
          setState(() {
            _currentState = all_page_state.LoadingState();
            getContractDetailData();
          });
        }),
      );
    }

    return Column(
      children: <Widget>[
        Expanded(
          child: LoadDataContainer(
              bloc: _loadDataBloc,
              //enablePullDown: false,
              onRefresh: getContractDetailData,
              onLoadingMore: getMap3StakingLogMoreData,
              child: CustomScrollView(
                slivers: <Widget>[
                  // 0.通知
                  SliverToBoxAdapter(child: _topNextEpisodeNotifyWidget()),

                  // 1.合约介绍信息
                  SliverToBoxAdapter(
                    child: _map3NodeInfoItem(context),
                  ),
                  _spacer(),

                  // 3.合约状态信息
                  // 3.1最近已操作状态通知 + 总参与抵押金额及期望收益
                  SliverToBoxAdapter(child: _contractProfitWidget()),
                  _spacer(),

                  // 2
                  SliverToBoxAdapter(
                    child: _nodeNextPeriodWidget(),
                  ),
                  _spacer(isVisible: _visibleEditNextPeriod),

                  // 3.2服务器
                  SliverToBoxAdapter(child: _reDelegationWidget()),
                  _spacer(),

                  SliverToBoxAdapter(child: _nodeServerWidget()),
                  _spacer(),

                  // SliverToBoxAdapter(child: _lineSpacer()),
                  // _spacer(),

                  // 3.2合约进度状态
                  SliverToBoxAdapter(child: _contractProgressWidget()),
                  _spacer(),

                  // 4.参与人员列表信息
                  SliverToBoxAdapter(
                    child: Material(
                      color: Colors.white,
                      child: NodeJoinMemberWidget(
                        nodeId: _nodeId,
                        isShowInviteItem: false,
                        loadDataBloc: _loadDataBloc,
                      ),
                    ),
                  ),
                  _spacer(),

                  // 5.合约流水信息
                  SliverToBoxAdapter(child: _delegateRecordHeaderWidget()),

                  _delegateRecordList.isNotEmpty
                      ? SliverList(
                          delegate: SliverChildBuilderDelegate((context, index) {
                          return delegateRecordItemWidget(
                            _delegateRecordList[index],
                            map3CreatorAddress: _map3nodeInformationEntity?.map3Node?.operatorAddress ?? "",
                          );
                        }, childCount: _delegateRecordList.length))
                      : emptyListWidget(title: "节点记录为空"),
                ],
              )),
        ),
        _bottomBtnBarWidget(),
      ],
    );
  }

  _showMoreAlertView() {
    return Navigator.push(
      context,
      PopRoute(
        child: Popup(
          child: BubbleWidget(_moreSizeWidth, 92.0, Colors.white, BubbleArrowDirection.top,
              length: 50,
              innerPadding: 0.0,
              child: Container(
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 0),
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (subContext, index) {
                    var title = "";
                    if (index == 2) {
                      title = "裂变";
                    } else if (index == 0) {
                      title = "终止";
                    } else if (index == 1) {
                      title = "分享";
                    }

                    return SizedBox(
                      width: 100,
                      height: index == 0 ? 44 : 36,
                      child: FlatButton(
                        onPressed: () {
                          Navigator.of(context).pop();

                          if (index == 2) {
                            _divideAction();
                          } else if (index == 0) {
                            _exitAction();
                          } else if (index == 1) {
                            _shareAction();
                          }
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Divider(
                              height: 0.5,
                              color: DefaultColors.colorf2f2f2,
                              indent: 13,
                              endIndent: 13,
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(8, index == 0 ? 12 : 8, 8, 8),
                              child: Text(
                                title,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  itemCount: 2,
                ),
              )),
          left: _moreOffsetLeft,
          top: _moreOffsetTop,
        ),
      ),
    );
  }

  Widget _bottomBtnBarWidget() {
    print("_invisibleBottomBar:$_visibleBottomBar");

    if (!_visibleBottomBar) return Container();

    List<Widget> children = [];
    if (_map3Status == Map3InfoStatus.FUNDRAISING_NO_CANCEL) {
      children = <Widget>[
        Spacer(),
        ClickOvalButton(
          "撤销抵押",
          _cancelAction,
          width: 120,
          height: 32,
          fontSize: 14,
          fontColor: HexColor("#999999"),
          btnColor: Colors.transparent,
        ),
        Spacer(),
        ClickOvalButton(
          "抵押",
          _joinAction,
          width: 120,
          height: 32,
          fontSize: 14,
        ),
        Spacer(),
      ];
    } else {
      children = <Widget>[
        ClickOvalButton(
          "提取奖励",
          _collectAction,
          width: 160,
          height: 36,
          fontSize: 14,
          //btnColor: HexColor("#FFC900"),
        )
      ];
    }
    return Container(
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
          color: Colors.black12,
          offset: Offset(0.0, 0.1), //阴影xy轴偏移量
          blurRadius: 1, //阴影模糊程度
        )
      ]),
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: children,
      ),
    );
  }

  /*
  Widget _bottomBtnBarWidget() {
    if (_invisibleBottomBar) return Container();

    print("_invisibleBottomBar:$_invisibleBottomBar");

    return Container(
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
          color: Colors.black12,
          offset: Offset(0.0, 0.1), //阴影xy轴偏移量
          blurRadius: 1, //阴影模糊程度
        )
      ]),
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Spacer(),
          ClickOvalButton(
            "撤销抵押",
            _canCancel ? _cancelAction : null,
            width: 100,
            height: 32,
            fontSize: 14,
            fontColor: _canCancel ? Colors.white : DefaultColors.color999,
            btnColor: _canCancel ? null : Colors.transparent,
          ),
          Spacer(),
          ClickOvalButton(
            "提取奖励",
            _isJoiner ? _collectAction : null,
            width: 100,
            height: 32,
            fontSize: 14,
            fontColor: _isJoiner ? Colors.white : DefaultColors.color999,
            btnColor: _isJoiner ? null : Colors.transparent,
          ),
          Spacer(),
          ClickOvalButton(
            "抵押",
            _canDelegate ? _joinAction : null,
            width: 100,
            height: 32,
            fontSize: 14,
            fontColor: _canDelegate ? Colors.white : DefaultColors.color999,
            btnColor: _canDelegate ? null : Colors.transparent,
          ),
          Spacer(),
        ],
      ),
    );
  }
  */

  Widget _topNextEpisodeNotifyWidget() {
    var notification = _notifyMessage();
    if (notification == null) {
      return Container();
    }
    return Container(
      color: HexColor("#1FB9C7").withOpacity(0.08),
      padding: const EdgeInsets.fromLTRB(23, 0, 16, 0),
      child: Row(
        children: <Widget>[
          Image.asset(
            "res/drawable/volume.png",
            width: 15,
            height: 14,
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Text(
                notification,
                style: TextStyle(fontSize: 12, color: HexColor("#333333")),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _map3NodeInfoItem(BuildContext context) {
    if (_map3infoEntity == null) return Container();

    var nodeName = _map3infoEntity?.name ?? "***";
    var oldYear = double.parse(_map3nodeInformationEntity?.map3Node?.age ?? "0").toInt();
    var oldYearValue = oldYear > 0 ? "节龄：${FormatUtil.formatPrice(oldYear.toDouble())}天" : "";

    var nodeAddress = "${UiUtil.shortEthAddress(_map3infoEntity?.address ?? "***", limitLength: 8)}";
    var nodeIdPre = "节点号：";
    var nodeId = " ${_map3infoEntity.nodeId ?? "***"}";
    var descPre = "节点公告：";
    var desc = (_map3infoEntity?.describe ?? "").isEmpty ? "大家快来参与我的节点吧，收益高高，收益真的很高，" : _map3infoEntity.describe;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16, top: 16, bottom: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                iconMap3Widget(_map3infoEntity),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8, top: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text.rich(TextSpan(children: [
                          TextSpan(
                              text: nodeName,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              )),
                          TextSpan(
                              text: "    ",
                              style: TextStyle(
                                fontSize: 12,
                                color: HexColor("#999999"),
                              )),
                          TextSpan(
                              text: oldYearValue,
                              style: TextStyle(
                                fontSize: 12,
                                color: HexColor("#999999"),
                              )),
                        ])),
                        Container(
                          height: 4,
                        ),
                        Text(nodeAddress, style: TextStyles.textC9b9b9bS12),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(_contractStateDesc, style: TextStyle(color: _stateColor, fontSize: 12)),
                        Container(
                          height: 4,
                        ),
                        Text.rich(TextSpan(children: [
                          TextSpan(
                              text: nodeIdPre,
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 12,
                                color: HexColor("#333333"),
                              )),
                          TextSpan(
                              text: nodeId,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                                color: HexColor("#333333"),
                              )),
                        ])),
                      ],
                    ),
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 12),
              child: Column(
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        descPre,
                        style: TextStyle(fontSize: 12, color: HexColor("#999999")),
                      ),
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: Text(
                            desc,
                            maxLines: 3,
                            textAlign: TextAlign.justify,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 13, color: HexColor("#333333")),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Visibility(
                    visible: false,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: InkWell(
                        //color: HexColor("#FF15B2D2"),
                        //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        onTap: () {
                          var encodeEntity = FluroConvertUtils.object2string(_map3infoEntity.toJson());
                          Application.router.navigateTo(context, Routes.map3node_edit_page + "?entity=$encodeEntity");
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Spacer(),
                            Text("编辑节点", style: TextStyle(fontSize: 14, color: HexColor("#1F81FF"))),
                          ],
                        ),
                        //style: TextStyles.textC906b00S13),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _nodeNextPeriodWidget() {
    var currentMicroDelegations = _isCreator ? _microDelegationsCreator : _microDelegationsJoiner;
    var status = currentMicroDelegations?.renewal?.status ?? 0;
    if (!_visibleEditNextPeriod) {
      return Container();
    }

    var lastFeeRate = FormatUtil.formatPercent(double.parse(_map3infoEntity?.getFeeRate() ?? "0"));
    var rateForNextPeriod = _map3nodeInformationEntity?.map3Node?.commission?.rateForNextPeriod ?? "0";
    var newFeeRate = FormatUtil.formatPercent(double.parse(rateForNextPeriod));

    var statusDesc = "已开启";
    var feeRate = lastFeeRate;
    switch (status) {
      case 0: // 未编辑，默认，开启，取上传rate
        statusDesc = "已开启";
        feeRate = lastFeeRate;
        break;

      case 1:
        statusDesc = "关闭";
        feeRate = newFeeRate;
        break;

      case 2:
        statusDesc = "已开启";
        feeRate = newFeeRate;
        break;
    }

    // 周期
    var periodEpoch14 = releaseEpoch - 14;
    var periodEpoch7 = releaseEpoch - 7;
    var editDateLimit = "（请在纪元$periodEpoch14 - $periodEpoch7前修改）";
    if (periodEpoch14 < 0 || periodEpoch7 < 0) {
      editDateLimit = "";
    }

    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(left: 15, right: 15, top: 12, bottom: 20),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Text.rich(TextSpan(children: [
                  TextSpan(text: "下期预设", style: TextStyle(fontSize: 16, color: HexColor("#333333"))),
                  TextSpan(text: editDateLimit, style: TextStyle(fontSize: 12, color: HexColor("#999999"))),
                ])),
                Spacer(),
                Visibility(
                  visible: _canEditNextPeriod,
                  child: SizedBox(
                    height: 30,
                    child: InkWell(
                      onTap: () {
                        if (!_canEditNextPeriod) return;

                        if (_isDelegator) {
                          _map3infoEntity.rateForNextPeriod = rateForNextPeriod;
                        }

                        Application.router.navigateTo(
                            context,
                            Routes.map3node_pre_edit_page +
                                "?info=${FluroConvertUtils.object2string(_map3infoEntity.toJson())}");
                      },
                      child: Center(
                          child: Text(
                        "修改",
                        style: TextStyle(
                          fontSize: 14,
                          color: !_canEditNextPeriod ? HexColor("#999999") : HexColor("#1F81FF"),
                        ),
                      )),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      _isCreator ? "自动续期" : "跟随续期",
                      style: TextStyle(
                        color: HexColor("#999999"),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      statusDesc,
                      style: TextStyle(
                        color: HexColor("#333333"),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      "管理费",
                      style: TextStyle(
                        color: HexColor("#999999"),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      feeRate,
                      style: TextStyle(
                        color: HexColor("#333333"),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _reDelegationWidget() {
    if (!_visibleReDelegation) return Container();

    bool isReDelegation = _atlasInfoEntity != null;

    if (!isReDelegation) {
      return Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.only(left: 15, right: 15, top: 12, bottom: 20),
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 36),
                  child: Text.rich(
                    TextSpan(children: [
                      TextSpan(
                          text: "暂未复投Atlas节点，复投Atlas节点可以获得出块奖励",
                          style: TextStyle(
                            fontSize: 14,
                            color: HexColor("#333333"),
                          )),
                    ]),
                    textAlign: TextAlign.center,
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Text.rich(TextSpan(children: [
                    TextSpan(
                        text: "复投Atlas节点",
                        style: TextStyle(
                          fontSize: 14,
                          color: HexColor("#1F81FF"),
                        )),
                  ])),
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget _item(String title, String detail) {
      return Text.rich(TextSpan(children: [
        TextSpan(
            text: title, style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12, color: HexColor("#999999"))),
        TextSpan(text: detail, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12, color: HexColor("#333333"))),
      ]));
    }

    var atlasEntity = _atlasInfoEntity as AtlasInfoEntity;

    Decimal rewardDecimal = Decimal.parse(atlasEntity.rewardRate);
    var rewardValueString = FormatUtil.truncateDecimalNum(rewardDecimal, 4);
    var rewardValue = double.parse(rewardValueString);
    var rewardRate = FormatUtil.formatPercent(rewardValue);
    //print("rank:${atlasEntity.rank},atlasEntity.reward:${atlasEntity.rewardRate}, rewardValueString:$rewardValueString");

    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(left: 15, right: 15, top: 12, bottom: 20),
        child: Container(
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text.rich(TextSpan(children: [
                    TextSpan(
                        text: "正在复投Atlas共识节点",
                        style: TextStyle(
                          fontSize: 16,
                          color: HexColor("#333333"),
                        )),
                  ])),
                ],
              ),
              InkWell(
                onTap: () {
                  var map3Address =
                      _map3nodeInformationEntity?.map3Node?.map3Address ?? (_map3infoEntity?.address ?? "");
                  Application.router.navigateTo(
                    context,
                    Routes.atlas_detail_page +
                        '?atlasNodeId=${FluroConvertUtils.fluroCnParamsEncode(atlasEntity?.nodeId ?? _nodeId)}&atlasNodeAddress=${FluroConvertUtils.fluroCnParamsEncode(atlasEntity?.address ?? map3Address)}',
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: HexColor("#F8F8F8"),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          iconWidget(
                            atlasEntity.pic,
                            atlasEntity.name,
                            atlasEntity.address,
                          ),
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text.rich(TextSpan(children: [
                                    TextSpan(
                                        text: atlasEntity?.name ?? "",
                                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                                  ])),
                                  Container(
                                    height: 4,
                                  ),
                                  _item("节点排名：", "${atlasEntity?.rank ?? 0}"),
                                ],
                              ),
                            ),
                          ),
                          //Spacer(),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Text(rewardRate,
                                    style: TextStyle(
                                      color: HexColor("#9B9B9B"),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    )),
                                Container(
                                  height: 4,
                                ),
                                Text("年化奖励",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: HexColor("#999999"),
                                    )),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _nodeServerWidget() {
    List points = [];
    var point = {'name': _map3infoEntity.name, 'value': _selectedRegion?.location?.getCoordinatesAfterSwap() ?? []};
    points.add(point);
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(left: 15, right: 15, top: 12, bottom: 20),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Text.rich(TextSpan(children: [
                  TextSpan(text: "节点服务", style: TextStyle(fontSize: 16, color: HexColor("#333333"))),
                ])),
                Spacer(),
                Visibility(
                  visible: false,
                  child: SizedBox(
                    height: 30,
                    child: InkWell(
                      onTap: _pushNodeInfoAction,
                      child: Center(child: Text("访问节点", style: TextStyle(fontSize: 14, color: HexColor("#1F81FF")))),
                      //style: TextStyles.textC906b00S13),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: Container(
                        height: 100,
                        child: Map3NodesWidget(
                          json.encode(points),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [0, 1].map((index) {
                          var titles = ["设备", "位置"];
                          var details = [_selectProviderEntity?.name ?? "亚马逊云", _selectedRegion?.name ?? ""];

                          return Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    titles[index],
                                    style: TextStyle(
                                      color: HexColor("#92979A"),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    details[index],
                                    style: TextStyle(
                                      color: HexColor("#333333"),
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _contractProfitWidget() {
    if (_map3infoEntity == null) return Container();

    var totalDelegation = FormatUtil.stringFormatNum(_map3infoEntity?.getStaking() ?? "0");
    var feeRate = FormatUtil.formatPercent(double.parse(_map3infoEntity?.getFeeRate() ?? "0"));

    var totalReward =
        FormatUtil.clearScientificCounting(_map3nodeInformationEntity?.accumulatedReward?.toDouble() ?? 0);
    var totalRewardValue = ConvertTokenUnit.weiToEther(weiBigInt: BigInt.parse(totalReward)).toDouble();
    var totalRewardString = FormatUtil.formatPrice(totalRewardValue);

    var myDelegationString = "0";
    var myRewardString = "0";

    if (_microDelegationsJoiner != null) {
      var myDelegation = FormatUtil.clearScientificCounting(_microDelegationsJoiner?.pendingDelegation?.amount ?? 0);
      var myDelegationValue = ConvertTokenUnit.weiToEther(weiBigInt: BigInt.parse(myDelegation)).toDouble();
      myDelegationString = FormatUtil.formatPrice(myDelegationValue);

      var myReward = FormatUtil.clearScientificCounting(_microDelegationsJoiner?.reward?.toDouble() ?? 0);
      var myRewardValue = ConvertTokenUnit.weiToEther(weiBigInt: BigInt.parse(myReward)).toDouble();
      myRewardString = FormatUtil.formatPrice(myRewardValue);
    }

    if (_isDelegator) {
      if (myDelegationString == "0" || myDelegationString.isEmpty) {
        myDelegationString = FormatUtil.stringFormatNum(ConvertTokenUnit.weiToEther(
            weiBigInt: BigInt.parse(
          _map3infoEntity?.mine?.staking ?? "0",
        )).toString());
      }

      if (myRewardString == "0" || myRewardString.isEmpty) {
        myRewardString = FormatUtil.stringFormatNum(ConvertTokenUnit.weiToEther(
            weiBigInt: BigInt.parse(
          _map3infoEntity?.mine?.reward ?? "0",
        )).toString());
      }
    }

    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 18, top: 16),
                child: Text("节点金额", style: TextStyle(fontSize: 16, color: HexColor("#333333"))),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: Text(
                      totalDelegation,
                      style: TextStyle(fontSize: 22, color: HexColor("#228BA1"), fontWeight: FontWeight.w600),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      "总抵押",
                      style: TextStyle(fontSize: 14, color: HexColor("#999999"), fontWeight: FontWeight.normal),
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: 60,
              ),
              Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: Text(
                      myRewardString,
                      style: TextStyle(fontSize: 22, color: HexColor("#BF8D2A"), fontWeight: FontWeight.w600),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      "可提奖励",
                      style: TextStyle(fontSize: 14, color: HexColor("#999999"), fontWeight: FontWeight.normal),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.only(bottom: 20, top: 30, left: 14, right: 14),
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 16,
              ),
              decoration: BoxDecoration(
                color: HexColor("#F8F8F8"),
                borderRadius: BorderRadius.circular(14),
              ),
              child: profitListBigWidget(
                [
                  {"累积产生": totalRewardString},
                  {"管理费": feeRate},
                  {"我的抵押": myDelegationString},
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _contractProgressWidget() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(top: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
            child: Row(
              children: <Widget>[
                Text("节点进度", style: TextStyle(fontSize: 16, color: HexColor("#333333"))),
                Spacer(),
                Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 18, right: 8.0),
                      child: Container(
                        width: 10,
                        height: 10,
                        //color: Colors.red,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _stateColor,
                          border: Border.all(
                            color: Map3NodeUtil.statusBorderColor(_map3Status),
                            width: 1.0,
                          ),
                        ),
                      ),
                    ),
                    Text.rich(
                      TextSpan(children: [
                        TextSpan(
                          text: _contractStateDesc,
                          style: TextStyle(fontSize: 12, color: _stateColor),
                        ),
                      ]),
                    ),
                  ],
                ),
/*
            child: Text("节点进度", style: TextStyle(fontSize: 16, color: HexColor("#333333"))),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 16, 8),
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 18, right: 8.0),
                  child: Container(
                    width: 10,
                    height: 10,
                    //color: Colors.red,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: _stateColor, border: Border.all(color: Colors.grey, width: 1.0)),
                  ),
                ),
                Text.rich(TextSpan(children: [
                  TextSpan(text: _contractStateDesc, style: TextStyle(fontSize: 14, color: _stateColor)),
                ])),
*/
              ],
            ),
          ),
          Container(
            height: 140,
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
            child: _customStepperWidget(),
          ),
        ],
      ),
    );
  }

  Widget _customStepperWidget() {
    var pendingEpoch = _map3nodeInformationEntity?.map3Node?.pendingEpoch ?? 0;
    var activationEpoch = _map3nodeInformationEntity?.map3Node?.activationEpoch ?? 0;
    var releaseEpoch = double.parse(_map3nodeInformationEntity?.map3Node?.releaseEpoch ?? "0")?.toInt() ?? 0;
    var titles = [
      pendingEpoch > 0 ? "创建 #$pendingEpoch" : "创建",
      activationEpoch > 0 ? "启动 #$activationEpoch" : "启动",
      releaseEpoch > 0 ? "到期 #$releaseEpoch" : "到期",
    ];

    var createdAt = FormatUtil.formatDate(_map3infoEntity?.createTime ?? 0, isSecond: false);
    var startTime = FormatUtil.formatDate(_map3infoEntity?.startTime ?? 0, isSecond: false);
    var endTime = FormatUtil.formatDate(_map3infoEntity?.endTime ?? 0, isSecond: false);

    var subtitles = [
      createdAt,
      startTime, // todo
      endTime,
    ];
    var progressHints = [
      "",
      "${AtlasApi.map3introduceEntity?.days}纪元",
      "",
    ];

    //print('[detail] _currentStep:$_currentStep， _currentStepProgress：${_currentStepProgress}');
    return CustomStepper(
      tickColor: _stateColor,
      tickText: _contractStateDetail,
      currentStepProgress: _currentStepProgress,
      currentStep: _currentStep,
      steps: titles.map(
        (title) {
          var index = titles.indexOf(title);
          var subtitle = subtitles[index];
          var date = progressHints[index];
          var textColor = _currentStep != index ? HexColor("#A7A7A7") : HexColor('#1FB9C7');

          return CustomStep(
            title: Text(
              title,
              style: TextStyle(fontSize: 12, color: textColor, fontWeight: FontWeight.normal),
            ),
            progressHint: Text(
              date,
              style: TextStyle(fontSize: 12, color: HexColor("#4B4B4B"), fontWeight: FontWeight.normal),
            ),
            subtitle: Text(
              subtitle,
              style: TextStyle(fontSize: 10, color: textColor, fontWeight: FontWeight.normal),
            ),
            content: Container(),
            isActive: true,
          );
        },
      ).toList(),
    );
  }

  Widget _lineSpacer() {
    return Container(
      height: 0.5,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
    );
  }

  Widget _spacer({bool isVisible = true}) {
    return SliverToBoxAdapter(
      child: Visibility(
        visible: isVisible,
        child: Container(
          height: 10,
        ),
      ),
    );
  }

  Widget _delegateRecordHeaderWidget() {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
        child: Row(
          children: <Widget>[
            Text(S.of(context).account_flow, style: TextStyle(fontSize: 16, color: HexColor("#333333"))),
          ],
        ),
      ),
    );
  }

  Future getMap3StakingLogMoreData() async {
    try {
      _currentPage++;

      List<HynTransferHistory> tempMemberList = await _atlasApi.getMap3StakingLogList(_nodeId, page: _currentPage);

      if (tempMemberList.length > 0) {
        _delegateRecordList.addAll(tempMemberList);
        _loadDataBloc.add(LoadingMoreSuccessEvent());
      } else {
        _loadDataBloc.add(LoadMoreEmptyEvent());
      }

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadDataBloc.add(LoadMoreFailEvent());
        });
      }
    }
  }

  // todo: test_detail

  _setupMicroDelegations() {
    if (_map3nodeInformationEntity == null ||
        (_map3nodeInformationEntity != null && _map3nodeInformationEntity.microdelegations.isEmpty)) return;

    var creatorAddress = _map3nodeInformationEntity.map3Node.operatorAddress;
    var joinerAddress = _address;

    for (var item in _map3nodeInformationEntity.microdelegations) {
      if (item.delegatorAddress.isNotEmpty &&
          (item.delegatorAddress == creatorAddress || item.delegatorAddress == joinerAddress)) {
        if (item.delegatorAddress == creatorAddress && _microDelegationsCreator == null) {
          _microDelegationsCreator = item;
        }

        if (item.delegatorAddress == joinerAddress && _microDelegationsJoiner == null) {
          _microDelegationsJoiner = item;
        }
      }
    }
  }

  Future getContractDetailData() async {
    try {
      var requestList = await Future.wait([
        _atlasApi.getMap3Info(_address, _nodeId),
        _atlasApi.postAtlasHome(_address),
        _nodeApi.getNodeProviderList(),
        _atlasApi.getMap3StakingLogList(_nodeAddress),
      ]);

      _map3infoEntity = requestList[0];
      _map3Status = Map3InfoStatus.values[_map3infoEntity.status];

      if (_map3infoEntity != null && _map3infoEntity.address.isNotEmpty) {
        _nodeAddress = _map3infoEntity.address;

        var map3Address = EthereumAddress.fromHex(_nodeAddress);
        _map3nodeInformationEntity = await client.getMap3NodeInformation(map3Address);

        _setupMicroDelegations();
      }

      AtlasHomeEntity _atlasHomeEntity = requestList[1];
      _currentEpoch = _atlasHomeEntity?.info?.epoch ?? 0;

      var providerList = requestList[2] as List;
      if (providerList.isNotEmpty) {
        _selectProviderEntity = providerList[0];

        for (var region in _selectProviderEntity.regions) {
          if (region.id == _map3infoEntity.region) {
            _selectedRegion = region;
            break;
          }
        }
      }

      List<HynTransferHistory> tempMemberList = requestList[3];
      _delegateRecordList = tempMemberList;

      // 3.
      if (mounted) {
        setState(() {
          _currentState = null;
          _loadDataBloc.add(RefreshSuccessEvent());
        });
      }
    } catch (e) {
      logger.e(e);
      LogUtil.toastException(e);

      if (mounted) {
        setState(() {
          _loadDataBloc.add(RefreshFailEvent());
          _currentState = all_page_state.LoadFailState();
        });
      }
    }
  }

  void _pushNodeInfoAction() {
    if (_map3infoEntity != null) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => WebViewContainer(
                    initUrl: "https://www.map3.network",
                    title: "",
                  )));
    }
  }

  void _pushWalletManagerAction() {
    Application.router.navigateTo(
        context, Routes.map3node_create_wallet + "?pageType=${Map3NodeCreateWalletPage.CREATE_WALLET_PAGE_TYPE_JOIN}");
  }

  void _cancelAction() {
    if (_isNoWallet) {
      _pushWalletManagerAction();
      return;
    }

    print("_map3infoEntity.status:${_map3infoEntity.status}");

    if (_map3Status == Map3InfoStatus.CREATE_SUBMIT_ING) {
      Fluttertoast.showToast(msg: "节点创建中, 暂不能撤销抵押！");
      return;
    }

    // todo: 撤销节点中
    /*
    if (_map3Status == Map3InfoStatus.FUNDRAISING_CANCEL_SUBMIT) {
      Fluttertoast.showToast(msg: "正在撤销节点中, 暂不能撤销抵押");
      return;
    }*/

    if (_map3infoEntity != null) {
      Application.router.navigateTo(
        context,
        Routes.map3node_cancel_page + '?info=${FluroConvertUtils.object2string(_map3infoEntity.toJson())}',
      );
    }
  }

  void _shareAction() {
    Application.router.navigateTo(context,
        Routes.map3node_share_page + "?contractNodeItem=${FluroConvertUtils.object2string(_map3infoEntity.toJson())}");
  }

  void _divideAction() {
    if (_isNoWallet) {
      _pushWalletManagerAction();
      return;
    }
    Application.router.navigateTo(context, Routes.map3node_divide_page);
  }

  void _exitAction() {
    if (_isNoWallet) {
      _pushWalletManagerAction();
      return;
    }
    if (_map3infoEntity != null) {
      Application.router.navigateTo(
        context,
        Routes.map3node_exit_page + '?info=${FluroConvertUtils.object2string(_map3infoEntity.toJson())}',
      );
    }
  }

  void _collectAction() {
    if (_isNoWallet) {
      _pushWalletManagerAction();
      return;
    }

    Application.router.navigateTo(context, Routes.map3node_my_page);
  }

  void _joinAction() async {
    if (_isNoWallet) {
      _pushWalletManagerAction();
      return;
    }

    if (_map3Status == Map3InfoStatus.CREATE_SUBMIT_ING) {
      Fluttertoast.showToast(msg: "节点创建中, 暂不能抵押！");
      return;
    }

    // todo: 撤销节点中
    /*
    if (_map3Status == Map3InfoStatus.FUNDRAISING_CANCEL_SUBMIT) {
      Fluttertoast.showToast(msg: "正在撤销节点中, 暂不能抵押");
      return;
    }*/

    if (_map3infoEntity != null) {
      var entryRouteName = Uri.encodeComponent(Routes.map3node_contract_detail_page);
      await Application.router.navigateTo(
          context,
          Routes.map3node_join_contract_page +
              "?entryRouteName=$entryRouteName&entityInfo=${FluroConvertUtils.object2string(_map3infoEntity.toJson())}");
      _nextAction();
    }
  }

  void _nextAction() {
    final result = ModalRoute.of(context).settings?.arguments;

    print("[detail] _next action, result:$result");

    if (result != null && result is Map && result["result"] is bool) {
      getContractDetailData();
    }
  }
}
