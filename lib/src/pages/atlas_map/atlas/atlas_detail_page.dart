import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/atlas_map/atlas/atlas_detail_edit_page.dart';
import 'package:titan/src/pages/atlas_map/atlas/atlas_look_over_page.dart';
import 'package:titan/src/pages/atlas_map/atlas/atlas_stake_select_page.dart';
import 'package:titan/src/pages/atlas_map/entity/atlas_info_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/enum_atlas_type.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_atlas_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_info_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/pledge_atlas_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/user_map3_entity.dart';
import 'package:titan/src/pages/node/model/enum_state.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/all_page_state/all_page_state_container.dart';
import 'package:titan/src/widget/animation/shake_animation_controller.dart';
import 'package:titan/src/widget/animation/shake_animation_type.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'package:titan/src/widget/animation/custom_shake_animation_widget.dart';
import 'package:titan/src/widget/all_page_state/all_page_state.dart' as all_page_state;

class AtlasDetailPage extends StatefulWidget {
  AtlasDetailPage();

  @override
  State<StatefulWidget> createState() {
    return AtlasDetailPageState();
  }
}

class AtlasDetailPageState extends State<AtlasDetailPage> {
  AtlasApi _atlasApi = AtlasApi();
  List<Map3InfoEntity> _dataList = List();
  LoadDataBloc _loadDataBloc = LoadDataBloc();
  int _currentPage = 1;
  int _pageSize = 30;

  var infoTitleList = ["最大抵押量", "网址", "安全联系", "描述", "费率", "最大费率", "费率幅度"];
  var infoContentList = ["12930903", "98%", "11.23%1", "欢迎参加我的合约，前10名参与者返10%管理费。", "98%", "11.23%", "11.23%"];

  ShakeAnimationController _shakeAnimationController;
  ShakeAnimationController _leftTextAnimationController;
  ShakeAnimationController _rightTextAnimationController;
  AtlasInfoEntity _atlasInfoEntity;
  all_page_state.AllPageState _currentState = all_page_state.LoadingState();
  var _selectedMap3NodeValue = 0;

  @override
  void initState() {
    super.initState();
    _refreshData();
    _shakeAnimationController = new ShakeAnimationController();
    _leftTextAnimationController = new ShakeAnimationController();
    _rightTextAnimationController = new ShakeAnimationController();
  }

  @override
  void dispose() {
    _shakeAnimationController.stop();
    _leftTextAnimationController.stop();
    _rightTextAnimationController.stop();
    _loadDataBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: BaseAppBar(baseTitle: "节点详情"),
      body: _pageWidget(context),
    );
  }

  Future _refreshData() async {
    _atlasInfoEntity = await _atlasApi.postAtlasInfo("", "");
    _atlasInfoEntity.name = "啦啦啦";
    _atlasInfoEntity.rank = 23;
    _atlasInfoEntity.pic = "http://www.missyuan.net/uploads/allimg/190815/14342Q051-0.png";
    _atlasInfoEntity.nodeId = "PB20202";
    _atlasInfoEntity.address = "0xsfasdasgadgas";
    _atlasInfoEntity.reward = "111111";
    _atlasInfoEntity.staking = "20000000";
    _atlasInfoEntity.signRate = "98%";
    _atlasInfoEntity.rewardRate = "98%";
    _atlasInfoEntity.status = AtlasInfoStatus.CREATE_SUCCESS_CANCEL_NODE_ING.index;
    _atlasInfoEntity.myMap3 = [
      Map3InfoEntity(
        "this.address",
        AtlasInfoEntity.onlyId(1),
        "this.contact",
        "this.createdAt",
        "this.creator",
        "this.describe",
        "this.endTime",
        "this.feeRate",
        "this.home",
        1,
        UserMap3Entity.onlyId(11),
        "this.name",
        "this.nodeId",
        "this.parentNodeId",
        "this.pic",
        "this.provider",
        "this.region",
        Map3AtlasEntity.onlyId(1, 1),
        "this.rewardHistory",
        "this.rewardRate",
        "this.staking",
        "this.startTime",
        Map3AtlasStatus.JOIN_DELEGATE_ING.index,
        "this.updatedAt",
      ),
    ];

    infoContentList.clear();
    infoContentList.add("${_atlasInfoEntity.maxStaking}");
    infoContentList.add("${_atlasInfoEntity.home}");
    infoContentList.add("${_atlasInfoEntity.contact}");
    infoContentList.add("${_atlasInfoEntity.describe}");
    infoContentList.add("${_atlasInfoEntity.feeRate}");
    infoContentList.add("${_atlasInfoEntity.feeRateMax}");
    infoContentList.add("${_atlasInfoEntity.feeRateTrim}");

    _currentPage = 1;
    _dataList.clear();

    _dataList = await _atlasApi.postAtlasMap3NodeList(_atlasInfoEntity.nodeId, page: _currentPage);
    _dataList.forEach((element) {
      element.name = "haha";
      element.address = "121112121";
      element.rewardRate = "11%";
      element.staking = "2313123";
      element.home = "http://www.missyuan.net/uploads/allimg/190815/14342Q051-0.png";
      element.relative = Map3AtlasEntity.onlyId(11, 1);
      element.relative.status = Map3InfoStatus.CREATE_SUBMIT_ING.index;
    });

    if (mounted)
      setState(() {
        _currentState = null;
      });
    _loadDataBloc.add(RefreshSuccessEvent());
  }

  _loadMoreData() async {
    _currentPage++;

    var _netDataList = await _atlasApi.postAtlasMap3NodeList(_atlasInfoEntity.nodeId, page: _currentPage);

    _netDataList.forEach((element) {
      element.name = "haha";
      element.address = "121112121";
      element.rewardRate = "11%";
      element.staking = "2313123";
      element.home = "http://www.missyuan.net/uploads/allimg/190815/14342Q051-0.png";
      element.relative = Map3AtlasEntity.onlyId(11, 1);
      element.relative.status = Map3InfoStatus.CREATE_SUBMIT_ING.index;
    });

    if (_netDataList != null) {
      _dataList.addAll(_netDataList);
      _loadDataBloc.add(LoadingMoreSuccessEvent());
    } else {
      _loadDataBloc.add(LoadMoreEmptyEvent());
    }

    if (mounted) setState(() {});
  }

  Widget _pageWidget(BuildContext context) {
    if (_currentState != null) {
      return AllPageStateContainer(_currentState, () {
        _refreshData();
      });
    }
    return Column(
      children: <Widget>[
        Expanded(
          child: LoadDataContainer(
              bloc: _loadDataBloc,
              onLoadData: () async {
                await _refreshData();
              },
              onRefresh: () async {
                await _refreshData();
              },
              onLoadingMore: () {
                _loadMoreData();
                setState(() {});
              },
              child: CustomScrollView(
                slivers: <Widget>[
                  _headerWidget(),
                  if (AtlasInfoStatus.CANCEL_NODE_SUCCESS_IS_IDLE == AtlasInfoStatus.values[_atlasInfoEntity.status])
                    _activeAtlasNode(),
                  _moneyWidget(),
                  _nodeInfoWidget(),
                  SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                    return _joinMap3Item(index);
                  }, childCount: _dataList.length + 1))
                ],
              )),
        ),
        _bottomBtnBar()
      ],
    );
  }

  _headerWidget() {
    bool showRemindBar = false;
    if (_atlasInfoEntity.myMap3 != null) {
      var status = _atlasInfoEntity.myMap3[_selectedMap3NodeValue].status;
      if (status == Map3AtlasStatus.JOIN_DELEGATE_ING.index ||
          status == Map3AtlasStatus.DELEGATE_SUCCESS_CANCEL_ING.index) {
        showRemindBar = true;
      }
    }
    return SliverToBoxAdapter(
      child: Column(
        children: <Widget>[
          if (showRemindBar)
            Container(
              height: 28,
              color: DefaultColors.color141fb9c7,
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 23, right: 7.0, top: 2),
                    child: Image.asset(
                      "res/drawable/ic_broadcase_speaker.png",
                      width: 14,
                      height: 14,
                    ),
                  ),
                  Text(
                    "${getMap3AtlasStatusRemind(_atlasInfoEntity.myMap3[_selectedMap3NodeValue].status)}",
                    style: TextStyles.textC333S12,
                  )
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(top: 18, bottom: 20),
            child: stakeHeaderInfo(context, _atlasInfoEntity),
          ),
        ],
      ),
    );
  }

  _activeAtlasNode() {
    return SliverToBoxAdapter(
      child: Column(
        children: <Widget>[
          Container(
            height: 10,
            color: HexColor("#f4f4f4"),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 19, bottom: 15, left: 20, right: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "*",
                  style: TextStyle(color: HexColor("#FF4C3B"), fontSize: 24),
                ),
                SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      text: "该Atlas节点处于非活跃状态",
                      style: TextStyles.textC333S14,
                      children: [
                        TextSpan(text: '(可能的原因是设备运行障碍/设备出块签名率低/节点主已经退出抵押)', style: TextStyles.textC999S12),
                        TextSpan(
                          text: '，如果你的设备已经恢复正常运行，请重新激活该节点。',
                          style: TextStyles.textC333S14,
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          ClickOvalButton(
            "重新激活",
            () {
              var nodeJoinType;
              if (_atlasInfoEntity.myMap3 == null) {
                nodeJoinType = NodeJoinType.JOINER;
              } else {
                nodeJoinType = NodeJoinType.values[_atlasInfoEntity.myMap3[_selectedMap3NodeValue].relative.creator];
              }
              switch (nodeJoinType) {
                case NodeJoinType.JOINER:
                  UiUtil.showAlertView(
                    context,
                    title: "激活节点",
                    actions: [
                      ClickOvalButton(
                        "好的",
                        () {
                          Navigator.pop(context);
                        },
                        width: 160,
                        height: 38,
                        fontSize: 16,
                      ),
                    ],
                    content: "只有节点主才能重新激活节点，请联系节点主激活",
                  );
                  break;
                case NodeJoinType.CREATOR:
                  Application.router.navigateTo(context,
                      Routes.map3node_formal_confirm_page + "?actionEvent=${Map3NodeActionEvent.ATLAS_ACTIVE_NODE.index}");
                  break;
              }
            },
            width: 160,
            height: 32,
            fontSize: 14,
          ),
          SizedBox(
            height: 22,
          ),
        ],
      ),
    );
  }

  _moneyWidget() {
    List<DropdownMenuItem> _map3NodeItems = List();
    if (_atlasInfoEntity.myMap3.length > 0) {
      _map3NodeItems.addAll(List.generate(_atlasInfoEntity.myMap3.length, (index) {
        Map3InfoEntity map3nodeEntity = _atlasInfoEntity.myMap3[index];
        return DropdownMenuItem(
          value: index,
          child: Text(
            '${map3nodeEntity.name}的Map3节点',
            style: TextStyles.textC333S14,
          ),
        );
      }).toList());
    } else {
      return Container();
    }

    return SliverToBoxAdapter(
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          Container(
              width: double.infinity,
              child: Image.asset("res/drawable/bg_atlas_get_money.png", width: double.infinity)),
          Column(
            children: <Widget>[
              InkWell(
                onTap: () {
                  var nodeJoinType;
                  if (_atlasInfoEntity.myMap3 == null) {
                    UiUtil.showAlertView(
                      context,
                      title: "领取奖励",
                      actions: [
                        ClickOvalButton(
                          "好的",
                          () {
                            Navigator.pop(context);
                          },
                          width: 160,
                          height: 38,
                          fontSize: 16,
                        ),
                      ],
                      content: "你还没有参与该Atlas节点抵押，不可以领取节点奖励。",
                    );
                  } else {
                    nodeJoinType =
                        NodeJoinType.values[_atlasInfoEntity.myMap3[_selectedMap3NodeValue].relative.creator];
                    switch (nodeJoinType) {
                      case NodeJoinType.CREATOR:
                        UiUtil.showAlertView(
                          context,
                          title: "领取奖励",
                          actions: [
                            ClickOvalButton(
                              S.of(context).cancel,
                              () {
                                Navigator.pop(context);
                              },
                              width: 120,
                              height: 32,
                              fontSize: 14,
                              fontColor: DefaultColors.color999,
                              btnColor: Colors.transparent,
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            ClickOvalButton(
                              "领取",
                              () {
                                Application.router.navigateTo(
                                    context,
                                    Routes.map3node_formal_confirm_page +
                                        "?actionEvent=${Map3NodeActionEvent.ATLAS_RECEIVE_AWARD.index}");
                              },
                              width: 120,
                              height: 38,
                              fontSize: 16,
                            ),
                          ],
                          content: "你将领取当前节点奖励，奖励会按抵押比例分配到参与抵押的每个map3节点，当然你会获得额外的管理费奖励。",
                        );

                        break;
                      case NodeJoinType.JOINER:
                        UiUtil.showAlertView(
                          context,
                          title: "领取奖励",
                          actions: [
                            ClickOvalButton(
                              "好的",
                              () {
                                Navigator.pop(context);
                              },
                              width: 160,
                              height: 38,
                              fontSize: 16,
                            ),
                          ],
                          content: "你不能领取节点奖励，你可以联系节点主去领取并分配节点奖励。",
                        );

                        break;
                    }
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: CustomShakeAnimationWidget(
                          shakeAnimationController: _leftTextAnimationController,
                          shakeAnimationType: ShakeAnimationType.TopBottomShake,
                          shakeRange: 0.3,
                          child: Text(
                            "点击领取",
                            style: TextStyle(fontSize: 16, color: HexColor("#C68A16")),
                          )),
                    ),
                    CustomShakeAnimationWidget(
                        shakeAnimationController: _shakeAnimationController,
                        shakeAnimationType: ShakeAnimationType.RoateShake,
                        child:
                            Image.asset("res/drawable/ic_atlas_get_money_wallet.png", width: 86, fit: BoxFit.contain)),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: CustomShakeAnimationWidget(
                          shakeAnimationController: _rightTextAnimationController,
                          shakeAnimationType: ShakeAnimationType.TopBottomShake,
                          shakeRange: 0.3,
                          delayForward: 1000,
                          child: Text(
                            "${_atlasInfoEntity.reward}",
                            style: TextStyle(fontSize: 16, color: HexColor("#C68A16")),
                          )),
                    ),
                  ],
                ),
              ),
              Container(
                color: Colors.white,
                height: 22,
                margin: const EdgeInsets.only(top: 4, bottom: 20),
                padding: EdgeInsets.only(top: 4, bottom: 4, left: 10, right: 10),
                child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(text: "已产生奖励  ", style: TextStyles.textC333S10, children: [
                      TextSpan(
                        text: "${_atlasInfoEntity.rewardHistory}",
                        style: TextStyles.textC333S12,
                      ),
                    ])),
              ),
              Container(
                margin: EdgeInsets.only(left: 10, right: 10),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0, bottom: 20),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              children: <Widget>[
                                Text("${_atlasInfoEntity.staking}", style: TextStyles.textC333S14),
                                SizedBox(
                                  height: 4,
                                ),
                                Text("总抵押", style: TextStyles.textC999S10)
                              ],
                            ),
                          ),
                          Container(
                            height: 20,
                            width: 0.5,
                            color: DefaultColors.colorf2f2f2,
                          ),
                          Expanded(
                            child: Column(
                              children: <Widget>[
                                Text("${_atlasInfoEntity.stakingCreator}", style: TextStyles.textC333S14),
                                SizedBox(
                                  height: 4,
                                ),
                                Text("管理节点抵押", style: TextStyles.textC999S10)
                              ],
                            ),
                          ),
                          Container(
                            height: 20,
                            width: 0.5,
                            color: DefaultColors.colorf2f2f2,
                          ),
                          Expanded(
                            child: Column(
                              children: <Widget>[
                                Text("${_atlasInfoEntity.signRate}", style: TextStyles.textC333S14),
                                SizedBox(
                                  height: 4,
                                ),
                                Text("签名率", style: TextStyles.textC999S10)
                              ],
                            ),
                          ),
                          Container(
                            height: 20,
                            width: 0.5,
                            color: DefaultColors.colorf2f2f2,
                          ),
                          Expanded(
                            child: Column(
                              children: <Widget>[
                                Text("${_atlasInfoEntity.rewardRate}", style: TextStyles.textC333S14),
                                SizedBox(
                                  height: 4,
                                ),
                                Text("最近回报率", style: TextStyles.textC999S10)
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      height: 1,
                      indent: 15,
                      endIndent: 15,
                      color: DefaultColors.colorf2f2f2,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 14, top: 24.0, bottom: 22),
                      child: RichText(
                          text: TextSpan(text: "我的Map3  ", style: TextStyles.textC333S16, children: [
                        TextSpan(
                          text: "(切换查看不同Map3节点抵押情况)",
                          style: TextStyles.textC999S12,
                        ),
                      ])),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 14, right: 14),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: HexColor('#F2F2F2'),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 13, right: 13),
                        child: DropdownButtonFormField(
                          icon: Image.asset(
                            "res/drawable/ic_arrow_down.png",
                            width: 14,
                            height: 14,
                          ),
                          decoration: InputDecoration(border: InputBorder.none),
                          onChanged: (value) {
                            setState(() {
                              _selectedMap3NodeValue = value;
                            });
                          },
                          value: _selectedMap3NodeValue,
                          items: _map3NodeItems,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 26, bottom: 18),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              children: <Widget>[
                                Text(
                                    _atlasInfoEntity.myMap3.isEmpty
                                        ? ""
                                        : "${_atlasInfoEntity.myMap3[_selectedMap3NodeValue].staking}",
                                    style: TextStyles.textC333S16),
                                SizedBox(
                                  height: 5,
                                ),
                                Text("Map3已抵押", style: TextStyles.textC999S12)
                              ],
                            ),
                          ),
                          Container(
                            height: 20,
                            width: 0.5,
                            color: HexColor("#33000000"),
                          ),
                          Expanded(
                            child: Column(
                              children: <Widget>[
                                Text("${_atlasInfoEntity.myMap3[_selectedMap3NodeValue].relative.reward}",
                                    style: TextStyles.textC333S16),
                                SizedBox(
                                  height: 5,
                                ),
                                Text("奖励", style: TextStyles.textC999S12)
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Container(
                height: 10,
                color: HexColor("#f4f4f4"),
              ),
            ],
          )
        ],
      ),
    );
  }

  _nodeInfoWidget() {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 20, left: 14, bottom: 11, right: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  "节点信息",
                  style: TextStyles.textC333S16,
                ),
                Spacer(),
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (BuildContext context) => AtlasDetailEditPage(_atlasInfoEntity)));
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        "res/drawable/icon_atlas_map3_edit_detail.png",
                        width: 12,
                        height: 12,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: Text("编辑节点", style: TextStyle(fontSize: 14, color: HexColor("#1F81FF"))),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          stakeInfoView(infoTitleList, infoContentList, true, null),
        ],
      ),
    );
  }

  _joinMap3Item(int index) {
    if (index == 0) {
      return Padding(
        padding: const EdgeInsets.only(left: 14, right: 14, top: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text(
              "参与的Map3",
              style: TextStyles.textC333S16,
            ),
            Spacer(),
            Text("共${_dataList.length}个节点", style: TextStyles.textC999S12)
          ],
        ),
      );
    }

    var map3InfoEntity = _dataList[index - 1];
    return Column(
      children: <Widget>[
        SizedBox(
          height: 17,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 26.0, right: 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: ClipOval(child: Image.network(map3InfoEntity.home, fit: BoxFit.cover, width: 40, height: 40)),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text("${map3InfoEntity.name}", style: TextStyles.textC000S14),
                        if (NodeJoinType.values[map3InfoEntity.relative.creator] == NodeJoinType.CREATOR)
                          Text("（创建者）", style: TextStyles.textC999S12)
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: Text("${map3InfoEntity.address}", style: TextStyles.textC999S12),
                    ),
                  ],
                ),
              ),
              Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text("${map3InfoEntity.staking}", style: TextStyles.textC333S14),
                      map3StatusText(map3InfoEntity)
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text("${FormatUtil.formatDateStr(map3InfoEntity.updatedAt)}", style: TextStyles.textC999S10)
                ],
              )
            ],
          ),
        ),
        SizedBox(
          height: 15,
        ),
        Divider(
          color: DefaultColors.colorf2f2f2,
          indent: 26,
          endIndent: 24,
        )
      ],
    );
  }

  Widget map3StatusText(Map3InfoEntity map3InfoEntity) {
    var statusText = "";
    var statuBgColor = "#228BA1";
    var statuTextColor = "#FFFFFF";
    switch (Map3AtlasStatus.values[map3InfoEntity.relative.status]) {
      case Map3AtlasStatus.JOIN_DELEGATE_ING:
        statusText = "新抵押";
        statuBgColor = "#228BA1";
        statuTextColor = "#FFFFFF";
        break;
      case Map3AtlasStatus.DELEGATE_SUCCESS_CANCEL_ING:
        statusText = "撤销中";
        statuBgColor = "#F2F2F2";
        statuTextColor = "#CC2D1E";
        break;
      case Map3AtlasStatus.DELEGATE_SUCCESS_NO_CANCEL: //todo 在已抵押中，如果大于起始块高则是新抵押
        statusText = "已抵押";
        statuBgColor = "#F2F2F2";
        statuTextColor = "#999999";
        break;
      default:
        return null;
    }

    return Container(
      padding: const EdgeInsets.only(top: 2.0, bottom: 2, left: 7, right: 7),
      margin: EdgeInsets.only(left: 6),
      decoration: BoxDecoration(color: HexColor(statuBgColor), borderRadius: BorderRadius.all(Radius.circular(10))),
      child: Text(
        statusText,
        style: TextStyle(fontSize: 6, color: HexColor(statuTextColor)),
      ),
    );
  }

  _bottomBtnBar() {
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
          Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 14),
            child: ClickOvalButton(
              "撤销抵押",
              () async {
                var atlasEntity = _atlasInfoEntity;
                var map3Entity = _atlasInfoEntity.myMap3[_selectedMap3NodeValue];
                await _atlasApi.postPledgeAtlas(PledgeAtlasEntity(
                    map3Entity.staking,
                    map3Entity.address,
                    111,
                    111,
                    AtlasPayload(atlasEntity.nodeId, map3Entity.nodeId),
                    "1111",
                    "11111",
                    atlasEntity.address,
                    AtlasActionType.JOIN_DELEGATE_ALAS));
              },
              width: 90,
              height: 32,
              fontSize: 14,
              fontColor: DefaultColors.color999,
              btnColor: Colors.transparent,
            ),
          ),
          ClickOvalButton(
            "抵押",
            () {
              if (_atlasInfoEntity.myMap3 == null) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => AtlasLookOverPage(_atlasInfoEntity)));
              } else {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => AtlasStakeSelectPage(_atlasInfoEntity)));
              }
            },
            width: 90,
            height: 32,
            fontSize: 14,
          ),
          SizedBox(
            width: 15,
          )
        ],
      ),
    );
  }
}
