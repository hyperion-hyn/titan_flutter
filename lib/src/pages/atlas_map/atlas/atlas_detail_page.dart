import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/wallet/vo/wallet_vo.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/atlas_map/atlas/atlas_detail_edit_page.dart';
import 'package:titan/src/pages/atlas_map/atlas/atlas_look_over_page.dart';
import 'package:titan/src/pages/atlas_map/atlas/atlas_stake_select_page.dart';
import 'package:titan/src/pages/atlas_map/entity/atlas_info_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/atlas_message.dart';
import 'package:titan/src/pages/atlas_map/entity/create_atlas_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/enum_atlas_type.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_atlas_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_info_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_tx_log_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/pledge_atlas_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/reward_history_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/user_map3_entity.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_confirm_page.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_public_widget.dart';
import 'package:titan/src/pages/atlas_map/widget/atlas_join_map3_widget.dart';
import 'package:titan/src/pages/atlas_map/widget/node_join_member_widget.dart';
import 'package:titan/src/pages/atlas_map/widget/simple_line_chart.dart';
import 'package:titan/src/pages/atlas_map/widget/sliding_viewport_on_selection.dart';
import 'package:titan/src/pages/node/model/enum_state.dart';
import 'package:titan/src/pages/wallet/api/hyn_api.dart';
import 'package:titan/src/pages/wallet/model/hyn_transfer_history.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/log_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/utils/utils.dart';
import 'package:titan/src/widget/all_page_state/all_page_state_container.dart';
import 'package:titan/src/widget/animation/shake_animation_controller.dart';
import 'package:titan/src/widget/animation/shake_animation_type.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'package:titan/src/widget/animation/custom_shake_animation_widget.dart';
import 'package:titan/src/widget/all_page_state/all_page_state.dart' as all_page_state;
import 'package:titan/src/widget/wallet_widget.dart';
import 'package:web3dart/src/models/validator_information_entity.dart';
import 'package:web3dart/web3dart.dart';

class AtlasDetailPage extends StatefulWidget {
  String atlasNodeId;
  String atlasNodeAddress;

  AtlasDetailPage(this.atlasNodeId, this.atlasNodeAddress);

  @override
  State<StatefulWidget> createState() {
    return AtlasDetailPageState();
  }
}

class AtlasDetailPageState extends State<AtlasDetailPage> {
  AtlasApi _atlasApi = AtlasApi();
  final _client = WalletUtil.getWeb3Client(true);
  List<HynTransferHistory> _delegateRecordList = List();
  ValidatorInformationEntity _validatorInformationEntity;
  LoadDataBloc _loadDataBloc = LoadDataBloc();
  int _currentPage = 1;
  int _pageSize = 30;
  bool isShowAll = false;

  var infoTitleList = [
    "当前管理费",
    S.of(Keys.rootKey.currentContext).description,
    "可设最高管理费",
    "单纪元可调管理费幅度",
    S.of(Keys.rootKey.currentContext).max_staking_num,
    S.of(Keys.rootKey.currentContext).website,
    S.of(Keys.rootKey.currentContext).contact,
  ];
  List<String> infoContentList = [];

  ShakeAnimationController _shakeAnimationController;
  ShakeAnimationController _leftTextAnimationController;
  ShakeAnimationController _rightTextAnimationController;
  AtlasInfoEntity _atlasInfoEntity;
  all_page_state.AllPageState _currentState = all_page_state.LoadingState();
  var _selectedMap3NodeValue = 0;
  WalletVo _activatedWallet;
  var showMyMap3 = false;
  List<Map3InfoEntity> showMap3List = [];
  List<RewardHistoryEntity> rewardHistoryList = [];

  @override
  void initState() {
    super.initState();
    _activatedWallet = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet;
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
      appBar: BaseAppBar(baseTitle: S.of(context).node_contract_detail),
      body: _pageWidget(context),
    );
  }

  Future _refreshData() async {
    showMyMap3 = false;
    infoContentList.clear();
    _delegateRecordList.clear();
    showMap3List.clear();
    _currentPage = 1;

    var hasWallet = _activatedWallet != null;
    try {
      var resultList = await Future.wait([
        _atlasApi.postAtlasInfo(_activatedWallet?.wallet?.getAtlasAccount()?.address ?? "", widget.atlasNodeId),
        _atlasApi.getAtlasStakingLogList(widget.atlasNodeAddress),
        _client.getValidatorInformation(EthereumAddress.fromHex(widget.atlasNodeAddress)),
        hasWallet
            ? _atlasApi.getMap3NodeListByMyCreate(_activatedWallet.wallet.getAtlasAccount().address, size: 10000)
            : Future.delayed(Duration()),
//        _atlasApi.postAtlasChartHistory(widget.atlasNodeAddress)
      ]);
      _atlasInfoEntity = resultList[0];
      _delegateRecordList = resultList[1];
      _validatorInformationEntity = resultList[2];
      List<Map3InfoEntity> myMap3List = hasWallet ? resultList[3] : null;
//      rewardHistoryList = resultList[4];

      if (_atlasInfoEntity.myMap3 != null && _atlasInfoEntity.myMap3.length > 0) {
        showMyMap3 = true;
      }

      if (hasWallet)
        myMap3List.forEach((myElement) {
          bool isShowMap3 = true;
          if (myElement.status != Map3InfoStatus.CONTRACT_HAS_STARTED.index) {
            isShowMap3 = false;
          }
          if (_atlasInfoEntity.myMap3 != null) {
            _atlasInfoEntity.myMap3.forEach((atlasMap3Element) {
              if (myElement.address == atlasMap3Element.address || myElement.relative != null) {
                isShowMap3 = false;
              }
            });
          }
          if (isShowMap3) {
            showMap3List.add(myElement);
          }
        });

      var maxStaking = FormatUtil.formatPrice(double.parse(_atlasInfoEntity.getMaxStaking()));
      infoContentList.add("${FormatUtil.formatPercent(double.parse(_atlasInfoEntity.getFeeRate()))}");
      infoContentList.add("${getContentOrEmptyStr(_atlasInfoEntity.describe)}");
      var feeRateMax = "${FormatUtil.formatPercent(double.parse(_atlasInfoEntity.getFeeRateMax()))}";
      infoContentList.add(feeRateMax);
      infoContentList.add("${FormatUtil.formatPercent(double.parse(_atlasInfoEntity.getFeeRateTrim()))}");
      infoContentList.add(maxStaking);
      infoContentList.add("${getContentOrEmptyStr(_atlasInfoEntity.home)}");
      infoContentList.add("${getContentOrEmptyStr(_atlasInfoEntity.contact)}");

      /*_dataList.forEach((element) {
        element.name = "haha";
        element.address = "121112121";
        element.rewardRate = "11%";
        element.staking = "2313123";
        element.home = "http://www.missyuan.net/uploads/allimg/190815/14342Q051-0.png";
        element.relative = Map3AtlasEntity.onlyId(11, 1);
        element.relative.status = Map3InfoStatus.CREATE_SUBMIT_ING.index;
      });*/

      if (mounted) {
        setState(() {
          _currentState = null;
        });
        _loadDataBloc.add(RefreshSuccessEvent());
      }
    } catch (error) {
      LogUtil.toastException(error);
      setState(() {
        _currentState = all_page_state.LoadFailState();
      });
    }
  }

  _loadMoreData() async {
    _currentPage++;

    var _netDataList = await _atlasApi.getAtlasStakingLogList(widget.atlasNodeAddress, page: _currentPage);

    if (_netDataList != null) {
      _delegateRecordList.addAll(_netDataList);
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
//                  _chartDetailWidget(),
                  _joinMap3Widget(),
                  _nodeRecordHeader(),
                  _delegateRecordList.isNotEmpty
                      ? SliverList(
                          delegate: SliverChildBuilderDelegate((context, index) {
                          return delegateRecordItemWidget(_delegateRecordList[index], isAtlasDetail: true);
                        }, childCount: _delegateRecordList.length))
                      : emptyListWidget(title: S.of(context).node_record_empty),
                  /*SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                    return _joinMap3Item(index);
                  }, childCount: _stackMap3List.length + 1))*/
                ],
              )),
        ),
        _bottomBtnBar()
      ],
    );
  }

  _headerWidget() {
    bool showRemindBar = false;
    if (_atlasInfoEntity.myMap3 != null && _atlasInfoEntity.myMap3.length > 0) {
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
                      text: S.of(context).this_atlas_node_is_inactive,
                      style: TextStyles.textC333S14,
                      children: [
                        TextSpan(
                            text: S.of(context).reason_obstacles_sign_rate_withdrawn_mortgage,
                            style: TextStyles.textC999S12),
                        TextSpan(
                          text: S.of(context).your_device_normal_reactivate_node,
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
            S.of(context).reactivate,
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
                    title: S.of(context).active_node,
                    actions: [
                      ClickOvalButton(
                        S.of(context).ok,
                        () {
                          Navigator.pop(context);
                        },
                        width: 160,
                        height: 38,
                        fontSize: 16,
                      ),
                    ],
                    content: S.of(context).node_master_reactivate_contact_master,
                  );
                  break;
                case NodeJoinType.CREATOR:
                  CreateAtlasEntity entity = CreateAtlasEntity.onlyType(AtlasActionType.ACTIVE_ATLAS_NODE);
                  AtlasMessage message = ConfirmAtlasActiveMessage(nodeId: _atlasInfoEntity.nodeId, entity: entity);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Map3NodeConfirmPage(
                          message: message,
                        ),
                      ));
//                  Application.router.navigateTo(context,
//                      Routes.map3node_formal_confirm_page + "?actionEvent=${Map3NodeActionEvent.ATLAS_ACTIVE_NODE.index}");
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
    if (showMyMap3) {
      _map3NodeItems.addAll(List.generate(_atlasInfoEntity.myMap3.length, (index) {
        Map3InfoEntity map3nodeEntity = _atlasInfoEntity.myMap3[index];
        return DropdownMenuItem(
          value: index,
          child: Text(
            '${map3nodeEntity.name}',
            style: TextStyles.textC333S14,
          ),
        );
      }).toList());
    }

    Decimal leftReward = Decimal.fromInt(0);
    Decimal historyReward = Decimal.fromInt(0);
    if (_validatorInformationEntity != null && _validatorInformationEntity.redelegations != null) {
      if (showMyMap3) {
        _validatorInformationEntity.redelegations.forEach((element) {
          if (_atlasInfoEntity.myMap3[_selectedMap3NodeValue].address.toLowerCase() == element.delegatorAddress) {
            leftReward = leftReward + ConvertTokenUnit.weiToEther(weiBigInt: BigInt.from(element.reward));
          }
        });
      }
    }

    if (_validatorInformationEntity != null) {
      historyReward = ConvertTokenUnit.weiToEther(weiBigInt: BigInt.from(_validatorInformationEntity.blockReward));
    }

    var totalStaking = FormatUtil.formatPrice(double.parse(_atlasInfoEntity.getTotalStaking() ?? '0'));
    var stakingCreator = FormatUtil.formatPrice(double.parse(_atlasInfoEntity.getStakingCreator() ?? '0'));
    var rewardRate =
        "${double.parse(_atlasInfoEntity.rewardRate ?? '0') == 0 ? '--' : FormatUtil.formatPercent(double.parse(
            _atlasInfoEntity.rewardRate,
          ))}";
    return SliverToBoxAdapter(
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.topCenter,
            child: Container(
                width: double.infinity,
                child: Image.asset("res/drawable/bg_atlas_get_money.png", width: double.infinity)),
          ),
          Column(
            children: <Widget>[
              SizedBox(
                height: 40,
              ),
              InkWell(
                onTap: () {
                  if (!showMyMap3) {
                    UiUtil.showAlertView(
                      context,
                      title: S.of(context).receive_reward,
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
                      content: S.of(context).dont_join_atlas_no_reward,
                    );
                  } else {
                    var nodeJoinType =
                        NodeJoinType.values[_atlasInfoEntity.myMap3[_selectedMap3NodeValue].mine.creator];
                    switch (nodeJoinType) {
                      case NodeJoinType.CREATOR:
                        UiUtil.showAlertView(
                          context,
                          title: S.of(context).receive_reward,
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
                              S.of(context).receive,
                              () async {
                                var map3Address = _atlasInfoEntity.myMap3[_selectedMap3NodeValue].address;
                                var lastTxIsPending = await AtlasApi.checkLastTxIsPending(
                                  MessageType.typeCollectReStakingReward,
                                  map3Address: map3Address,
                                  atlasAddress: widget.atlasNodeAddress,
                                );
                                if (lastTxIsPending) {
                                  return;
                                }
                                if(leftReward <= Decimal.fromInt(0)){
                                  Fluttertoast.showToast(msg: "当前可提金额为0");
                                  return;
                                }

                                Navigator.pop(context);
                                AtlasMessage message = ConfirmAtlasReceiveAwardMessage(
                                  nodeName: _atlasInfoEntity.name,
                                  nodeId: _atlasInfoEntity.nodeId,
                                  map3Address: map3Address,
                                  atlasAddress: widget.atlasNodeAddress,
                                );
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Map3NodeConfirmPage(
                                        message: message,
                                      ),
                                    ));
                              },
                              width: 120,
                              height: 38,
                              fontSize: 16,
                            ),
                          ],
                          content: S.of(context).withdraw_atlas_reward_staking_rate_distribute,
                        );

                        break;
                      case NodeJoinType.JOINER:
                        UiUtil.showAlertView(
                          context,
                          title: S.of(context).receive_reward,
                          actions: [
                            ClickOvalButton(
                              S.of(context).ok,
                              () {
                                Navigator.pop(context);
                              },
                              width: 160,
                              height: 38,
                              fontSize: 16,
                            ),
                          ],
                          content: S.of(context).cant_receive_reward_contact_master_distribute,
                        );
                        break;
                    }
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    if (showMyMap3)
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: CustomShakeAnimationWidget(
                                shakeAnimationController: _leftTextAnimationController,
                                shakeAnimationType: ShakeAnimationType.TopBottomShake,
                                shakeRange: 0.3,
                                child: Text(
                                  S.of(context).click_receive,
                                  style: TextStyle(fontSize: 16, color: HexColor("#C68A16")),
                                )),
                          ),
                        ),
                      ),
                    CustomShakeAnimationWidget(
                        shakeAnimationController: _shakeAnimationController,
                        shakeAnimationType: ShakeAnimationType.RoateShake,
                        child:
                            Image.asset("res/drawable/ic_atlas_get_money_wallet.png", width: 86, fit: BoxFit.contain)),
                    if (showMyMap3)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: CustomShakeAnimationWidget(
                              shakeAnimationController: _rightTextAnimationController,
                              shakeAnimationType: ShakeAnimationType.TopBottomShake,
                              shakeRange: 0.3,
                              delayForward: 1000,
                              child: Text(
                                "+${FormatUtil.truncateDecimalNum(leftReward, 2)}",
                                style: TextStyle(fontSize: 16, color: HexColor("#C68A16")),
                              )),
                        ),
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
                    text: TextSpan(
                        text: "${S.of(context).node_cumulative_reward}  ",
                        style: TextStyles.textC333S10,
                        children: [
                          TextSpan(
                            text: "${FormatUtil.truncateDecimalNum(historyReward, 0)}",
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
                                Text(totalStaking, style: TextStyles.textC333S14),
                                SizedBox(
                                  height: 4,
                                ),
                                Text(S.of(context).total_staking, style: TextStyles.textC999S10)
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
                                Text(stakingCreator, style: TextStyles.textC333S14),
                                SizedBox(
                                  height: 4,
                                ),
                                Text(S.of(context).manage_node_staking, style: TextStyles.textC999S10)
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
                                Text(rewardRate, style: TextStyles.textC333S14),
                                SizedBox(
                                  height: 4,
                                ),
                                Text(S.of(context).atlas_reward_rate, style: TextStyles.textC999S10)
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (showMyMap3)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Divider(
                            height: 1,
                            indent: 15,
                            endIndent: 15,
                            color: DefaultColors.colorf2f2f2,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 14, top: 24.0, bottom: 22),
                            child: RichText(
                                text: TextSpan(
                                    text: "${S.of(context).my_map3}  ",
                                    style: TextStyles.textC333S16,
                                    children: [
                                  TextSpan(
                                    text: S.of(context).switch_view_different_map3_staking_status,
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
                                              : "${_atlasInfoEntity.myMap3[_selectedMap3NodeValue].getStaking()}",
                                          style: TextStyles.textC333S16),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(S.of(context).map3_is_mortgaged, style: TextStyles.textC999S12)
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
                                      Text("${FormatUtil.truncateDecimalNum(leftReward, 2)}",
                                          style: TextStyles.textC333S16),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(S.of(context).can_withdraw_to_map3, style: TextStyles.textC999S12)
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
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
                  S.of(context).node_info,
                  style: TextStyles.textC333S16,
                ),
                Spacer(),
                /*InkWell(
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
                ),*/
              ],
            ),
          ),
          if(infoContentList.length != 0)
            stakeInfoView(infoTitleList, infoContentList, isShowAll, () {
              setState(() {
                isShowAll = true;
              });
            }),
        ],
      ),
    );
  }

//  _joinMap3Item(int index) {
//    if (index == 0) {
//      return Padding(
//        padding: const EdgeInsets.only(left: 14, right: 14, top: 16),
//        child: Row(
//          crossAxisAlignment: CrossAxisAlignment.end,
//          children: <Widget>[
//            Text(
//              "节点记录",
//              style: TextStyles.textC333S16,
//            ),
//            Spacer(),
//            Text("共${_map3TxLogList.length}个节点", style: TextStyles.textC999S12)
//          ],
//        ),
//      );
//    }
//
//    var map3TxLogEntity = _map3TxLogList[index - 1];
//    return Column(
//      children: <Widget>[
//        SizedBox(
//          height: 17,
//        ),
//        Padding(
//          padding: const EdgeInsets.only(left: 26.0, right: 24),
//          child: Row(
//            crossAxisAlignment: CrossAxisAlignment.start,
//            children: <Widget>[
//              Padding(
//                padding: const EdgeInsets.only(right: 10),
//                child: walletHeaderWidget(map3TxLogEntity.name, isShowShape: false, address: map3TxLogEntity.map3Address),
//              ),
//              Expanded(
//                child: Column(
//                  crossAxisAlignment: CrossAxisAlignment.start,
//                  children: <Widget>[
//                    Row(
//                      children: <Widget>[
//                        Text("${map3TxLogEntity.name}", style: TextStyles.textC000S14),
//                        //todo
//                        if (map3TxLogEntity.map3Address == _atlasInfoEntity.creator)
//                          Text("（创建者）", style: TextStyles.textC999S12)
//                      ],
//                    ),
//                    Padding(
//                      padding: const EdgeInsets.only(top: 5.0),
//                      child: Text("${shortBlockChainAddress(map3TxLogEntity.map3Address)}", style: TextStyles.textC999S12),
//                    ),
//                  ],
//                ),
//              ),
//              Column(
//                children: <Widget>[
//                  Row(
//                    children: <Widget>[
//                      Text("${HYNApi.getValueByHynType(map3TxLogEntity.type)}", style: TextStyles.textC333S14),
//                      map3StatusText(map3TxLogEntity)
//                    ],
//                  ),
//                  SizedBox(
//                    height: 5,
//                  ),
//                  Text(
//                    FormatUtil.formatDateStr(map3TxLogEntity.updatedAt),
//                    style: TextStyles.textC999S10,
//                  )
//                ],
//              )
//            ],
//          ),
//        ),
//        SizedBox(
//          height: 15,
//        ),
//        Divider(
//          color: DefaultColors.colorf2f2f2,
//          indent: 26,
//          endIndent: 24,
//        )
//      ],
//    );
//  }

//  Widget map3StatusText(Map3TxLogEntity map3txLogEntity) {
//    var statusText = "";
//    var statuBgColor = "#228BA1";
//    var statuTextColor = "#FFFFFF";
//    switch (map3txLogEntity.status) {
//      case 1:
//      case 2:
//        statusText = "进行中";
//        statuBgColor = "#228BA1";
//        statuTextColor = "#FFFFFF";
//        break;
//      case Map3AtlasStatus.DELEGATE_SUCCESS_CANCEL_ING:
//        statusText = "撤销中";
//        statuBgColor = "#F2F2F2";
//        statuTextColor = "#CC2D1E";
//        break;
//      case Map3AtlasStatus.DELEGATE_SUCCESS_NO_CANCEL: //todo 在已抵押中，如果大于起始块高则是新抵押
//        statusText = "已抵押";
//        statuBgColor = "#F2F2F2";
//        statuTextColor = "#999999";
//        break;
//      default:
//        return null;
//    }
//
//    return Container(
//      padding: const EdgeInsets.only(top: 2.0, bottom: 2, left: 7, right: 7),
//      margin: EdgeInsets.only(left: 6),
//      decoration: BoxDecoration(color: HexColor(statuBgColor), borderRadius: BorderRadius.all(Radius.circular(10))),
//      child: Text(
//        statusText,
//        style: TextStyle(fontSize: 6, color: HexColor(statuTextColor)),
//      ),
//    );
//  }

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
          if (showMyMap3 && _atlasInfoEntity.myMap3[_selectedMap3NodeValue].isCreator())
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 14),
              child: ClickOvalButton(
                S.of(context).cancel_delegate,
                () async {
                  UiUtil.showAlertView(
                    context,
                    title: S.of(context).cancel_delegate,
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
                        S.of(context).confirm,
                        () async {
                          await _cancelAction();
                        },
                        width: 120,
                        height: 38,
                        fontSize: 16,
                      ),
                    ],
                    content: S.of(context).cancel_delegate_no_atlas_reward_confirm_cancel,
                  );
                },
                width: 90,
                height: 32,
                fontSize: 14,
                fontColor: DefaultColors.color999,
                btnColor: Colors.transparent,
              ),
            ),
          ClickOvalButton(
            S.of(context).staking,
            () {
              _delegateAction();
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

  _delegateAction() {
    if (showMap3List.isEmpty) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => AtlasLookOverPage(_atlasInfoEntity)));
    } else {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => AtlasStakeSelectPage(_atlasInfoEntity, showMap3List)));
    }
  }

  Future _cancelAction() async {
    var map3Address = _atlasInfoEntity.myMap3[_selectedMap3NodeValue].address;
    var lastTxIsPending = await AtlasApi.checkLastTxIsPending(
      MessageType.typeUnReDelegate,
      map3Address: map3Address,
      atlasAddress: widget.atlasNodeAddress,
    );
    if (lastTxIsPending) {
      return;
    }

    AtlasMessage message = ConfirmAtlasUnStakeMessage(
      nodeName: _atlasInfoEntity.name,
      nodeId: _atlasInfoEntity.nodeId,
      atlasAddress: widget.atlasNodeAddress,
      map3Address: _atlasInfoEntity.myMap3[_selectedMap3NodeValue].address,
    );
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Map3NodeConfirmPage(
            message: message,
          ),
        ));
  }

  _joinMap3Widget() {
    return SliverToBoxAdapter(
      child: Material(
        color: Colors.white,
        child: AtlasJoinMap3Widget(
          "${_atlasInfoEntity.nodeId}",
          isShowInviteItem: false,
          loadDataBloc: _loadDataBloc,
        ),
      ),
    );
  }

  _chartDetailWidget() {
    return SliverToBoxAdapter(
      child: Column(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(0),
            child: Container(
                height: 303,
                width: MediaQuery.of(context).size.width - 32,
                padding: const EdgeInsets.only(top: 23, bottom: 23),
                child: SlidingViewportOnSelection.withSampleData(rewardHistoryList)),
          ),
          Container(
            height: 10,
            color: HexColor("#F2F2F2"),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(0),
            child: Container(
                height: 303,
                width: MediaQuery.of(context).size.width - 32,
                padding: const EdgeInsets.only(top: 23, bottom: 23),
                child: SimpleLineChart.withSampleData(rewardHistoryList)),
          ),
          Container(
            height: 10,
            color: HexColor("#F2F2F2"),
          ),
        ],
      ),
    );
  }

  Widget _nodeRecordHeader() {
    return SliverToBoxAdapter(
      child: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
          child: Row(
            children: <Widget>[
              Text(S.of(context).account_flow, style: TextStyle(fontSize: 16, color: HexColor("#333333"))),
            ],
          ),
        ),
      ),
    );
  }
}

String getContentOrEmptyStr(String contentStr) {
  if (contentStr == null || contentStr.isEmpty) {
    return S.of(Keys.rootKey.currentContext).no_data;
  } else {
    return contentStr;
  }
}
