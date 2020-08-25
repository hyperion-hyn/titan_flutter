import 'package:floor/floor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/atlas_map/atlas/atlas_stake_select_page.dart';
import 'package:titan/src/pages/atlas_map/entity/atlas_info_entity.dart';
import 'package:titan/src/style/titan_sytle.dart';
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
  List<String> _dataList = List();
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
    _atlasInfoEntity.creator = "啦啦啦";

    _currentPage = 1;
    _dataList.clear();

    var networkList;
    await Future.delayed(Duration(milliseconds: 1000), () {
      networkList = List.generate(10, (index) {
        return index.toString();
      });
    });

    if (networkList != null) {
      _dataList.addAll(networkList);
    }

    if (mounted) setState(() {
      _currentState = null;
    });
    _loadDataBloc.add(RefreshSuccessEvent());
  }

  _loadMoreData() async {
    _currentPage++;

    var networkList;
    await Future.delayed(Duration(milliseconds: 1000), () {
      networkList = List.generate(10, (index) {
        return index.toString();
      });
    });

    if (networkList != null) {
      _dataList.addAll(networkList);
    }
    _loadDataBloc.add(LoadingMoreSuccessEvent());
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
    return SliverToBoxAdapter(
      child: Column(
        children: <Widget>[
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
                  "你已撤销抵押该Atlas节点，将在下一个纪元生效",
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

  _moneyWidget() {
    var _selectedMap3NodeValue = 'map3Node1';
    List<DropdownMenuItem> _map3NodeItems = List();
    _map3NodeItems.add(
      DropdownMenuItem(
        value: 'map3Node1',
        child: Text(
          'Lance的Map3节点-1',
          style: TextStyles.textC333S14,
        ),
      ),
    );
    _map3NodeItems.add(
      DropdownMenuItem(
        value: 'map3Node2',
        child: Text(
          'Lance的Map3节点-2',
          style: TextStyle(
            fontSize: 14,
          ),
        ),
      ),
    );

    return SliverToBoxAdapter(
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          Container(
              width: double.infinity,
              child: Image.asset("res/drawable/bg_atlas_get_money.png", width: double.infinity)),
          Column(
            children: <Widget>[
              Row(
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
                      child: Image.asset("res/drawable/ic_atlas_get_money_wallet.png", width: 86, fit: BoxFit.contain)),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: CustomShakeAnimationWidget(
                        shakeAnimationController: _rightTextAnimationController,
                        shakeAnimationType: ShakeAnimationType.TopBottomShake,
                        shakeRange: 0.3,
                        delayForward: 1000,
                        child: Text(
                          "+22,023",
                          style: TextStyle(fontSize: 16, color: HexColor("#C68A16")),
                        )),
                  ),
                ],
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
                        text: "20,230",
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
                                Text("20,209,000", style: TextStyles.textC333S14),
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
                                Text("20,209,000", style: TextStyles.textC333S14),
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
                                Text("98%", style: TextStyles.textC333S14),
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
                                Text("11.2%", style: TextStyles.textC333S14),
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
                                Text("20,209,000", style: TextStyles.textC333S16),
                                SizedBox(
                                  height: 5,
                                ),
                                Text("总抵押", style: TextStyles.textC999S12)
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
                                Text("20,209,000", style: TextStyles.textC333S16),
                                SizedBox(
                                  height: 5,
                                ),
                                Text("管理节点抵押", style: TextStyles.textC999S12)
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
            padding: const EdgeInsets.only(top: 20, left: 14, bottom: 11),
            child: Text(
              "节点信息",
              style: TextStyles.textC333S16,
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

    var statuBgColor = "#228BA1";
    var statuTextColor = "#FFFFFF";
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
                child: ClipOval(
                    child: Image.network("http://www.missyuan.net/uploads/allimg/190815/14342Q051-0.png",
                        fit: BoxFit.cover, width: 40, height: 40)),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text("Moo", style: TextStyles.textC000S14),
                        Text("（创建者）", style: TextStyles.textC999S12)
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: Text("03fklsdflksm", style: TextStyles.textC999S12),
                    ),
                  ],
                ),
              ),
              Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text("20,000", style: TextStyles.textC333S14),
                      Container(
                        padding: const EdgeInsets.only(top: 2.0, bottom: 2, left: 7, right: 7),
                        margin: EdgeInsets.only(left: 6),
                        decoration: BoxDecoration(
                            color: HexColor(statuBgColor), borderRadius: BorderRadius.all(Radius.circular(10))),
                        child: Text(
                          "新抵押",
                          style: TextStyle(fontSize: 6, color: HexColor(statuTextColor)),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text("2019-10-12 17:00", style: TextStyles.textC999S10)
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
          ClickOvalButton(
            "撤销抵押",
            () {},
            width: 90,
            height: 32,
            fontSize: 14,
            textColor: DefaultColors.color999,
            btnColor: Colors.transparent,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 14),
            child: ClickOvalButton(
              "提取奖励",
              () {},
              width: 90,
              height: 32,
              fontSize: 14,
            ),
          ),
          ClickOvalButton(
            "抵押",
            () {},
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
