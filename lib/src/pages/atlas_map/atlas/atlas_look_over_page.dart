import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/atlas_map/atlas/atlas_stake_list_page.dart';
import 'package:titan/src/pages/atlas_map/atlas/atlas_stake_select_page.dart';
import 'package:titan/src/pages/atlas_map/entity/atlas_info_entity.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/widget/all_page_state/all_page_state_container.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'package:titan/src/widget/all_page_state/all_page_state.dart' as all_page_state;

import 'atlas_detail_page.dart';

class AtlasLookOverPage extends StatefulWidget {
  final AtlasInfoEntity _atlasInfoEntity;

  AtlasLookOverPage(this._atlasInfoEntity);

  @override
  State<StatefulWidget> createState() {
    return _AtlasLookOverPageState();
  }
}

class _AtlasLookOverPageState extends State<AtlasLookOverPage> {
  var infoTitleList = [
    S.of(Keys.rootKey.currentContext).total_staking,
    S.of(Keys.rootKey.currentContext).atlas_reward_rate,
    S.of(Keys.rootKey.currentContext).current_management_fee,
    S.of(Keys.rootKey.currentContext).description,
    S.of(Keys.rootKey.currentContext).setting_max_management_fee,
    S.of(Keys.rootKey.currentContext).epoch_management_fee_trim,
    S.of(Keys.rootKey.currentContext).max_staking_num,
    S.of(Keys.rootKey.currentContext).website,
    S.of(Keys.rootKey.currentContext).contact,
  ];
  List<String> infoContentList = [];
  bool isShowAll = false;

//  all_page_state.AllPageState _currentState = all_page_state.LoadingState();
  all_page_state.AllPageState _currentState;
  AtlasApi _atlasApi = AtlasApi();

  @override
  void initState() {
    _refreshData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.black),
          title: Text(
            S.of(context).staking_atlas_node,
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
            ),
          ),
        ),
        body: _pageWidget(context));
  }

  Widget _pageWidget(BuildContext context) {
    if (_currentState != null) {
      return AllPageStateContainer(_currentState, () {
        _refreshData();
        /*setState(() {
          _currentState = all_page_state.LoadingState();
        });*/
      });
    }

    return Column(
      children: <Widget>[
        Expanded(
            child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 18,
              ),
              stakeHeaderInfo(context, widget._atlasInfoEntity),
              Padding(
                padding: const EdgeInsets.only(top: 19.0, bottom: 7),
                child: Divider(
                  color: DefaultColors.colorf2f2f2,
                  height: 0.5,
                  indent: 14,
                  endIndent: 14,
                ),
              ),
              stakeInfoView(infoTitleList, infoContentList, isShowAll, () {
                setState(() {
                  isShowAll = true;
                });
              }),
              Padding(
                padding: const EdgeInsets.only(left: 14.0, right: 14, top: 19),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(S.of(context).staking_atlas_need_unstaking_map3_follow_operation, style: TextStyles.textC333S14),
                    Padding(
                      padding: const EdgeInsets.only(top: 28, bottom: 10),
                      child: Text(S.of(context).create_start_map3_stake_atlas_reward, style: TextStyles.textC333S12),
                    ),
                    Text("", style: TextStyle(color: HexColor("#1F81FF"), fontSize: 12)),
                    Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 10),
                      child: Text(S.of(context).stake_staked_map3_atlas_reward, style: TextStyles.textC333S12),
                    ),
                    InkWell(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => AtlasStakeListPage(widget._atlasInfoEntity)));
                        },
                        child: Text("", style: TextStyle(color: HexColor("#1F81FF"), fontSize: 12))),
                  ],
                ),
              ),
            ],
          ),
        )),
        Padding(
          padding: const EdgeInsets.only(bottom: 36.0, top: 22),
          child: ClickOvalButton(
            S.of(context).back,
            () {
              Navigator.pop(context);
            },
            width: 300,
            height: 46,
          ),
        )
      ],
    );
  }

  _refreshData() async {
    var atlasInfo = widget._atlasInfoEntity;
    infoContentList = [
      "${atlasInfo.getTotalStaking()}",
      "${atlasInfo.rewardRate}",
      "${FormatUtil.formatPercent(double.parse(atlasInfo.getFeeRate()))}",
      "${getContentOrEmptyStr(atlasInfo.describe)}",
      "${FormatUtil.formatPercent(double.parse(atlasInfo.getFeeRateMax()))}",
      "${FormatUtil.formatPercent(double.parse(atlasInfo.getFeeRateTrim()))}",
      "${atlasInfo.getMaxStaking()}",
      "${getContentOrEmptyStr(atlasInfo.home)}",
      "${getContentOrEmptyStr(atlasInfo.contact)}",
    ];

    Future.delayed(Duration(milliseconds: 2000), () {
      if (mounted)
        setState(() {
          _currentState = null;
        });
    });
  }
}
