import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/atlas_map/atlas/atlas_stake_select_page.dart';
import 'package:titan/src/pages/atlas_map/entity/atlas_info_entity.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/widget/all_page_state/all_page_state_container.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'package:titan/src/widget/all_page_state/all_page_state.dart' as all_page_state;

class AtlasLookOverPage extends StatefulWidget {
  AtlasLookOverPage();

  @override
  State<StatefulWidget> createState() {
    return _AtlasLookOverPageState();
  }
}

class _AtlasLookOverPageState extends State<AtlasLookOverPage> {
  var infoTitleList = ["总抵押", "签名率", "最近回报率", "总抵押11", "签名率11", "最近回报率11"];
  var infoContentList = ["总抵押", "98%", "11.23%1", "129309031", "98%1", "11.23%1"];
  bool isShowAll = false;
  AtlasInfoEntity _atlasInfoEntity;
  all_page_state.AllPageState _currentState = all_page_state.LoadingState();
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
            "抵押Atlas节点",
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
                  stakeHeaderInfo(context,_atlasInfoEntity),
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
                        Text("抵押Atlas节点，你需要先拥有Map3节点，现在你可以进行以下操作参与抵押Atlas节点：", style: TextStyles.textC333S14),
                        Padding(
                          padding: const EdgeInsets.only(top: 28, bottom: 10),
                          child: Text("1、创建并启动一个Map3节点，然后抵押到Atlas节点并享受节点出块奖励", style: TextStyles.textC333S12),
                        ),
                        Text("马上创建Map3节点", style: TextStyle(color: HexColor("#1F81FF"), fontSize: 12)),
                        Padding(
                          padding: const EdgeInsets.only(top: 20, bottom: 10),
                          child: Text("2、抵押一个已经抵押到Atlas节点的Map3节点，这样也能享受到Atlas区块出块的奖励", style: TextStyles.textC333S12),
                        ),
                        Text("查看当前Atlas的Map3抵押节点", style: TextStyle(color: HexColor("#1F81FF"), fontSize: 12)),
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
    _atlasInfoEntity = await _atlasApi.postAtlasInfo("","");
    _atlasInfoEntity.creator = "派大星11";

    Future.delayed(Duration(milliseconds: 2000),(){
      if (mounted) setState(() {
        _currentState = null;
      });
    });
  }

}
