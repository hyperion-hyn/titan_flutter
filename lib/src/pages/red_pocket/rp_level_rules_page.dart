import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/rp/bloc/bloc.dart';
import 'package:titan/src/components/rp/redpocket_component.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_my_level_info.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_promotion_rule_entity.dart';
import 'package:titan/src/pages/red_pocket/rp_level_deposit_page.dart';
import 'package:titan/src/pages/red_pocket/rp_level_upgrade_page.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'entity/rp_util.dart';

class RpLevelRulesPage extends StatefulWidget {
  RpLevelRulesPage();

  @override
  State<StatefulWidget> createState() {
    return _RpLevelRulesState();
  }
}

class _RpLevelRulesState extends BaseState<RpLevelRulesPage> {
  final LoadDataBloc _loadDataBloc = LoadDataBloc();

  RpPromotionRuleEntity _promotionRuleEntity;

  List<LevelRule> get _dynamicDataList => (_promotionRuleEntity?.dynamicList ?? []).reversed.toList();
  List<LevelRule> get _staticDataList => (_promotionRuleEntity?.static ?? []).reversed.toList();

  List<LevelRule> get _oldModelList {
    List<LevelRule> list = [];

    for (int index = 0; index < _staticDataList.length; index++) {
      var zeroValue = Decimal.zero;

      var staticModel = _staticDataList[index];
      var dynamicModel = _dynamicDataList[index];

      //  burn
      var staticBurnValue = Decimal.tryParse(staticModel?.burnStr ?? '0') ?? zeroValue;
      var dynamicBurnValue = Decimal.tryParse(dynamicModel?.burnStr ?? '0') ?? zeroValue;

      // hold
      var staticHoldValue = Decimal.tryParse(staticModel?.holdingStr ?? '0') ?? zeroValue;
      var dynamicHoldValue = Decimal.tryParse(dynamicModel?.holdingStr ?? '0') ?? zeroValue;

      bool isOldLevel = staticBurnValue > zeroValue &&
          dynamicBurnValue >= zeroValue &&
          staticBurnValue > dynamicBurnValue &&

          staticHoldValue > zeroValue &&
          dynamicHoldValue >= zeroValue &&
          staticHoldValue > dynamicHoldValue &&

          dynamicModel.level > _currentLevel;
      //print("[$runtimeType] _setupOldModelList, isOldLevel:$isOldLevel");

      if (isOldLevel) {
        list.add(dynamicModel);
      }
    }
    return list;
  }

  LevelRule _currentSelectedLevelRule;
  RpMyLevelInfo _myLevelInfo;

  int get _currentLevel => _myLevelInfo?.currentLevel ?? 0;

  int _recommendLevel = 5;

  @override
  void initState() {
    super.initState();
  }

  @override
  void onCreated() {
    _loadDataBloc.add(LoadingEvent());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _myLevelInfo = RedPocketInheritedModel.of(context).rpMyLevelInfo;
    _promotionRuleEntity = RedPocketInheritedModel.of(context).rpPromotionRule;
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
        baseTitle: S.of(context).rp_level,
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
    var promotionSupplyRatioValue = double.tryParse(_promotionRuleEntity?.supplyInfo?.promotionSupplyRatio ?? '0') ?? 0;
    var promotionSupplyRatioPercent = FormatUtil.formatPercent(promotionSupplyRatioValue);

    var stepPercent = FormatUtil.formatPercent(_promotionRuleEntity?.supplyInfo?.gradientRatio ?? 0);
    //print("stepPercent:$stepPercent, promotionSupplyRatioValue:$promotionSupplyRatioValue, _promotionRuleEntity?.supplyInfo?.gradientRatio:${_promotionRuleEntity?.supplyInfo?.gradientRatio}");

    var totalSupplyStr = FormatUtil.stringFormatCoinNum(
      _promotionRuleEntity?.supplyInfo?.totalSupplyStr ?? '0',
    );
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(
          left: 16,
          top: 16,
          bottom: 16,
          right: 16,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 2,
                right: 10,
              ),
              child: Image.asset(
                "res/drawable/volume.png",
                width: 15,
                height: 14,
                color: HexColor('#333333'),
              ),
            ),
            Expanded(
              child: Text(
                S.of(context).rp_level_total_supply_func(totalSupplyStr, promotionSupplyRatioPercent, stepPercent),
                style: TextStyle(
                  color: HexColor('#333333'),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
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
      leftTagTitle = S.of(context).rp_current_level;
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
                onTap: () => _selectedLevelAction(index),
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

  Widget _itemBuilderDynamic(int index) {
    var staticModel = _staticDataList[index];

    // 判断当前旧的量级是否为历史最高
    String leftTagTitle = '';

    // 过滤出Old
    LevelRule dynamicModel =
    _oldModelList.firstWhere((element) => element.level == staticModel.level, orElse: () => null);

    String oldLevelDesc = S.of(context).rp_level_upgrade_func(dynamicModel?.burnStr ?? '0', dynamicModel?.holdingStr ?? '0');

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
                onTap: () => _selectedLevelAction(index),
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
                S.of(context).recommend,
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

    var level = model.level ?? 0;
    var levelName = '${S.of(context).rp_level} ${levelValueToLevelName(level)}';

    var burnTitle = S.of(context).rp_need_burn_amount_abc;
    var burnRpValue = '${model.burnStr} RP';

    var formula = model.holdingFormula;

    var stakingTitle = S.of(context).rp_min_holding_abc;
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
              top: 8,
            ),
            child: Text(
              '${S.of(context).rp_level_formula}: $formula',
              style: TextStyle(
                color: HexColor('#999999'),
                fontSize: 10,
                fontWeight: FontWeight.normal,
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
          padding: const EdgeInsets.symmetric(
            vertical: 30,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClickOvalButton(
                S.of(context).rp_add_holding,
                _navToLevelAddStakingAction,
                height: 34,
                width: 120,
                fontSize: 14,
                btnColor: [HexColor('#2D99FF'), HexColor('#107EDC')],
              ),
              SizedBox(
                width: 20,
              ),
              ClickOvalButton(
                S.of(context).rp_level_up,
                _navToLevelUpgradeAction,
                height: 34,
                width: 120,
                fontSize: 14,
                btnColor: [HexColor('#FF0527'), HexColor('#FF4D4D')],
              ),
            ],
          ),
        ),
      ),
    );
  }

  _selectedLevelAction(int index) {
    var model = _dynamicDataList[index];
    if (_currentLevel > model.level && _currentLevel > 0) {
      if (_currentLevel == 5) {
        Fluttertoast.showToast(
          msg: S.of(context).rp_already_highest_level,
          gravity: ToastGravity.CENTER,
        );
        return;
      }
      Fluttertoast.showToast(
        msg: S.of(context).rp_upgrade_level_less_then_current,
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
        msg: S.of(context).rp_level_zero_toast,
        gravity: ToastGravity.CENTER,
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RpLevelDepositPage(),
      ),
    );
  }

  _navToLevelUpgradeAction() {
    if (_currentLevel == 5) {
      Fluttertoast.showToast(
        msg: S.of(context).rp_already_highest_level,
        gravity: ToastGravity.CENTER,
      );
      return;
    }

    if (_currentSelectedLevelRule == null) {
      Fluttertoast.showToast(
        msg: S.of(context).rp_select_upgrade_level,
        gravity: ToastGravity.CENTER,
      );
      return;
    }

    if (_currentLevel == (_currentSelectedLevelRule?.level ?? 0) && _currentLevel > 0) {
      Fluttertoast.showToast(
        msg: S.of(context).rp_select_same_level,
        gravity: ToastGravity.CENTER,
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RpLevelUpgradePage(
          _currentSelectedLevelRule,
          _promotionRuleEntity,
        ),
      ),
    );
  }

  void getNetworkData() async {
    if (context != null) {
      BlocProvider.of<RedPocketBloc>(context).add(UpdatePromotionRuleEvent());
    }

    if (mounted) {
      _loadDataBloc.add(RefreshSuccessEvent());
    }
  }
}
