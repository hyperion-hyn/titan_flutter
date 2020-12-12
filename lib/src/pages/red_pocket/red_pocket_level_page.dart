import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/red_pocket/api/rp_api.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_my_level_info.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_my_rp_record_entity.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_promotion_rule_entity.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_statistics.dart';
import 'package:titan/src/pages/red_pocket/rp_level_add_staking_page.dart';
import 'package:titan/src/pages/red_pocket/rp_level_upgrade_page.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'entity/rp_util.dart';

class RedPocketLevelPage extends StatefulWidget {
  final RpMyLevelInfo rpMyLevelInfo;

  RedPocketLevelPage(this.rpMyLevelInfo);

  @override
  State<StatefulWidget> createState() {
    return _RedPocketLevelState();
  }
}

class _RedPocketLevelState extends BaseState<RedPocketLevelPage> {
  final LoadDataBloc _loadDataBloc = LoadDataBloc();
  final RPApi _rpApi = RPApi();

  var _address = "";
  RpPromotionRuleEntity _promotionRuleEntity;
  List<LevelRule> get _dynamicDataList => (_promotionRuleEntity?.dynamicList ?? []).reversed.toList();
  List<LevelRule> get _staticDataList => (_promotionRuleEntity?.static ?? []).reversed.toList();

  LevelRule _currentSelectedLevelRule;
  int get _currentLevel => widget?.rpMyLevelInfo?.currentLevel ?? 0;

  int _recommendLevel = 5;

  @override
  void initState() {
    super.initState();

    var activatedWallet = WalletInheritedModel.of(Keys.rootKey.currentContext)?.activatedWallet;
    _address = activatedWallet?.wallet?.getEthAccount()?.address ?? "";
  }

  @override
  void onCreated() {
    _loadDataBloc.add(LoadingEvent());
  }

  @override
  void dispose() {
    _loadDataBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor('#FFFFFF'),
      appBar: BaseAppBar(
        baseTitle: '量级',
        backgroundColor: HexColor('#FFFFFF'),
      ),
      body: _pageView(),
    );
  }

  _pageView() {
    return LoadDataContainer(
      bloc: _loadDataBloc,
      onLoadData: () async {
        getNetworkData();
      },
      onRefresh: () async {
        getNetworkData();
      },
      enablePullUp: false,
      child: CustomScrollView(
        slivers: [
          _levelHeaderView(),
          _levelListView(),
          _confirmButtonWidget(),
        ],
      ),
    );
  }

  Widget _columnWidget(
    String amount,
    String title,
  ) {
    return Column(
      children: <Widget>[
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            color: DefaultColors.color999,
          ),
        ),
        SizedBox(
          height: 2.0,
        ),
        Text(
          '$amount',
          style: TextStyle(
            fontSize: 14,
            color: DefaultColors.color333,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _levelHeaderView() {
    var promotionSupplyRatioValue = double.tryParse(_promotionRuleEntity?.supplyInfo?.promotionSupplyRatio ?? '0')??0;
    var promotionSupplyRatioPercent = FormatUtil.formatPercent(promotionSupplyRatioValue);

    var stepPercent = FormatUtil.formatPercent(_promotionRuleEntity?.supplyInfo?.gradientRatio ?? 0);
    //print("stepPercent:$stepPercent, promotionSupplyRatioValue:$promotionSupplyRatioValue, _promotionRuleEntity?.supplyInfo?.gradientRatio:${_promotionRuleEntity?.supplyInfo?.gradientRatio}");

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Text(
              '当前已发行 ${_promotionRuleEntity?.supplyInfo?.totalSupplyStr ?? '--'} RP，百分比Y = $promotionSupplyRatioPercent（$stepPercent为1梯度）',
              style: TextStyle(
                color: HexColor('#333333'),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _levelListView() {
    return SliverToBoxAdapter(
      child: StaggeredGridView.countBuilder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
        ),
        crossAxisCount: 4,
        itemCount: _staticDataList.length,
        itemBuilder: (BuildContext context, int index) {
          var staticModel = _staticDataList[index];

          var isOldLevel = false;
          if (_oldModelList.isNotEmpty) {
            for (var element in _oldModelList) {
              if (element.level == staticModel.level) {
                isOldLevel = true;
                break;
              }
            }
          }
          //print("[$runtimeType] _levelListView, level:${staticModel.level}, isOldLevel:$isOldLevel");

          if (isOldLevel) {
            return _itemBuilderDynamic(index);
          } else {
            return _itemBuilderStatic(index);
          }
        },
        staggeredTileBuilder: (int index) => new StaggeredTile.fit(2),
        mainAxisSpacing: 0.0,
        crossAxisSpacing: 8.0,
      ),
    );
  }

  Widget _itemBuilderStatic(int index) {
    var model = _staticDataList[index];

    bool isCurrent = _currentLevel == model.level;
    String leftTagTitle = '';
    if (isCurrent) {
      leftTagTitle = '当前量级';
    }

    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(
            top: 8,
          ),
          // height: 120,
          child: Stack(
            children: [
              InkWell(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                onTap: () => _selectedLevelAction(model),
                child: _itemContainer(model),
              ),
              _tagContainer(leftTagTitle: leftTagTitle, color: HexColor('#FF4C3B')),
              _selectedTagContainer(model),
            ],
          ),
        ),
        _recommendContainer(model),
      ],
    );
  }

  List<LevelRule> _oldModelList = [];
  void _setupOldModelList()  {

    _oldModelList.clear();

    for (int index = 0; index < _staticDataList.length; index++) {

      var zeroValue = Decimal.zero;
      var staticModel = _staticDataList[index];
      var staticBurnValue = Decimal.tryParse(staticModel?.burnStr ?? '0') ?? zeroValue;

      var dynamicModel = _dynamicDataList[index];
      var dynamicBurnValue = Decimal.tryParse(dynamicModel?.burnStr ?? '0') ?? zeroValue;

      bool isOldLevel =
          staticBurnValue > zeroValue && dynamicBurnValue >= zeroValue && staticBurnValue > dynamicBurnValue && dynamicModel.level > _currentLevel;
      print("[$runtimeType] _setupOldModelList, isOldLevel:$isOldLevel");

      if (isOldLevel) {
        _oldModelList.add(dynamicModel);
      }
    }
  }

  Widget _itemBuilderDynamic(int index) {
    var staticModel = _staticDataList[index];

    // 过滤出Old
    LevelRule dynamicModel =
        _oldModelList.firstWhere((element) => element.level == staticModel.level, orElse: () => null);

    LevelRule oldModelMax =
        _oldModelList.firstWhere((element) => element.level > dynamicModel.level, orElse: () => null);
    // for (var element in _oldModelList) {
    //   print(
    //       "[$runtimeType] oldModelList.length:${_oldModelList.length}, level:${element.level} , index:$index, oldModelMax:$oldModelMax");
    // }

    // 判断当前旧的量级是否为历史最高
    bool isNotMax = (oldModelMax != null);

    String leftTagTitle = '';
    if (!isNotMax) {
      leftTagTitle = '可恢复最高量级';
    } else {
      leftTagTitle = '可恢复量级';
    }


    var zeroValue = Decimal.zero;
    var holdValue = Decimal.tryParse(dynamicModel?.holdingStr ?? '0') ?? zeroValue;
    var currentHoldValue = Decimal.tryParse(widget?.rpMyLevelInfo?.currentHoldingStr ?? '0') ?? zeroValue;
    var remainValue = holdValue - currentHoldValue;
    remainValue = remainValue > zeroValue ? remainValue : zeroValue;
    String oldLevelDesc = '恢复至该量级需燃烧 ${dynamicModel?.burnStr ?? '0'}RP, 增持${remainValue.toString()}RP';

    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(
            top: 8,
          ),
          //height: 165,
          child: Stack(
            children: [
              InkWell(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                onTap: () => _selectedLevelAction(dynamicModel),
                child: Container(
                  decoration: BoxDecoration(
                    color: HexColor('#DEDEDE'),
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                  child: Column(
                    children: [
                      _itemContainer(staticModel),
                      Container(
                        decoration: BoxDecoration(
                          color: HexColor('#DEDEDE'),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(8.0),
                            bottomRight: Radius.circular(8.0),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            oldLevelDesc,
                            style: TextStyle(
                              color: HexColor('#999999'),
                              fontSize: 10,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _tagContainer(leftTagTitle: leftTagTitle, color: HexColor('#1F81FF')),
              _selectedTagContainer(staticModel),
            ],
          ),
        ),
        _recommendContainer(staticModel),
      ],
    );
  }

  Widget _tagContainer({String leftTagTitle, Color color}) {
    if (leftTagTitle?.isNotEmpty ?? false)
      return Positioned(
          left: 10,
          top: 6,
          child: Text(
            leftTagTitle,
            style: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 10,
              color: color,
            ),
          ));

    return Container();
  }

  Widget _selectedTagContainer(LevelRule model) {
    bool isCurrent = _currentLevel == model.level;
    bool isSelected = ((_currentSelectedLevelRule?.level ?? 0) == model.level);

    return Positioned(
      bottom: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 3, 0, 0),
        child: Center(
          child: Visibility(
            visible: isCurrent || isSelected,
            child: Image.asset(
              "res/drawable/red_pocket_level_${isSelected ? 'check' : 'un_check'}.png",
              width: 30,
              height: 30,
            ),
          ),
        ),
      ),
    );
  }

  Widget _recommendContainer(LevelRule model) {
    bool isRecommend = _recommendLevel == model.level;

    if (isRecommend)
      return Positioned(
        right: 12,
        child: Container(
          decoration: BoxDecoration(color: HexColor("#FF4C3B"), borderRadius: BorderRadius.all(Radius.circular(10.0))),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 3, 8, 3),
            child: Center(
              child: Text(
                '推荐',
                style: TextStyle(fontSize: 8, color: HexColor("#FFFFFF"), fontWeight: FontWeight.normal),
              ),
            ),
          ),
        ),
      );

    return Container();
  }

  Widget _itemContainer(LevelRule model) {
    bool isSelected = ((_currentSelectedLevelRule?.level ?? 0) == model.level);

    var levelName = '量级 ${levelValueToLevelName(model.level)}';
    var burnTitle = '需燃烧';
    var burnRpValue = '${model.burnStr} RP';

    var stakingTitle = '最低持币 ${model.holdingFormula}';
    var stakingValue = '${model.holdingStr} RP';

    return Container(
      decoration: BoxDecoration(
        color: isSelected ? HexColor('#FFEAEA') : HexColor('#F6F6F6'),
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 28,
            ),
            child: Text(
              levelName,
              style: TextStyle(
                color: HexColor('#333333'),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 16,
              bottom: 16,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _columnWidget(
                  burnRpValue,
                  burnTitle,
                ),
                _columnWidget(
                  stakingValue,
                  stakingTitle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _confirmButtonWidget() {
    return SliverToBoxAdapter(
      child: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.only(top: 60),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClickOvalButton(
                '增加持币',
                _navToLevelAddStakingAction,
                height: 34,
                width: 120,
                fontSize: 14,
                btnColor: [HexColor('#2D99FF'), HexColor('#107EDC')],
                //isLoading: !_canCancel,
              ),
              SizedBox(
                width: 20,
              ),
              ClickOvalButton(
                '提升量级',
                _navToLevelUpgradeAction,
                height: 34,
                width: 120,
                fontSize: 14,
                btnColor: [HexColor('#FF0527'), HexColor('#FF4D4D')],
                //isLoading: !_canCancel,
              ),
            ],
          ),
        ),
      ),
    );
  }

  _selectedLevelAction(LevelRule model) {
    if (_currentLevel > model.level && _currentLevel > 0) {
      if (_currentLevel == 5) {
        Fluttertoast.showToast(
          msg: '当前量级已经是最高量级！',
          gravity: ToastGravity.CENTER,
        );
        return;
      }
      Fluttertoast.showToast(
        msg: '升级的量级不能小于当前量级, 请重新选择！',
        gravity: ToastGravity.CENTER,
      );
      return;
    }

    setState(() {
      _currentSelectedLevelRule = model;
    });
  }

  _navToLevelAddStakingAction() {
    if (_currentLevel == 0) {
      Fluttertoast.showToast(
        msg: '当前量级为0, 请先提升量级！',
        gravity: ToastGravity.CENTER,
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RpLevelAddStakingPage(widget.rpMyLevelInfo),
      ),
    );
  }

  _navToLevelUpgradeAction() {
    if (_currentLevel == 5) {
      Fluttertoast.showToast(
        msg: '当前量级已经是最高量级！',
        gravity: ToastGravity.CENTER,
      );
      return;
    }

    if (_currentSelectedLevelRule == null) {
      Fluttertoast.showToast(
        msg: '请先选择想要升级的量级！',
        gravity: ToastGravity.CENTER,
      );
      return;
    }

    if (_currentLevel == (_currentSelectedLevelRule?.level ?? 0) && _currentLevel > 0) {
      Fluttertoast.showToast(
        msg: '选择的量级与当前量级相同, 请重新选择！',
        gravity: ToastGravity.CENTER,
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RpLevelUpgradePage(widget.rpMyLevelInfo, _currentSelectedLevelRule, _promotionRuleEntity),
      ),
    );
  }

  void getNetworkData() async {
    try {
      var netData = await _rpApi.getRPPromotionRule(_address);

      if (netData?.static?.isNotEmpty ?? false) {
        _promotionRuleEntity = netData;

        _setupOldModelList();

        print("[$runtimeType] getNetworkData, count:${_staticDataList.length}, old.length:${_oldModelList.length}");

        if (mounted) {
          setState(() {
            _loadDataBloc.add(RefreshSuccessEvent());
          });
        }
      } else {
        _loadDataBloc.add(LoadEmptyEvent());
      }
    } catch (e) {
      _loadDataBloc.add(LoadFailEvent());
    }
  }
}
