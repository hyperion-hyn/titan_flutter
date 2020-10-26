import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/atlas_map/atlas/atlas_detail_page.dart';
import 'package:titan/src/pages/atlas_map/entity/atlas_message.dart';
import 'package:titan/src/pages/atlas_map/entity/enum_atlas_type.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_info_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_node_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/pledge_atlas_entity.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_confirm_page.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_public_widget.dart';
import 'package:titan/src/pages/node/model/enum_state.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/utils/utils.dart';
import 'package:titan/src/widget/all_page_state/all_page_state_container.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'package:titan/src/pages/atlas_map/entity/atlas_info_entity.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/widget/all_page_state/all_page_state.dart' as all_page_state;
import 'package:titan/src/widget/wallet_widget.dart';

class AtlasStakeSelectPage extends StatefulWidget {
  final AtlasInfoEntity _atlasInfoEntity;
  final List<Map3InfoEntity> myMap3List;

  AtlasStakeSelectPage(this._atlasInfoEntity, this.myMap3List);

  @override
  State<StatefulWidget> createState() {
    return _AtlasStakeSelectPageState();
  }
}

class _AtlasStakeSelectPageState extends State<AtlasStakeSelectPage> {
  var infoTitleList = [
    "总抵押",
    "签名率",
    "最近回报率",
    "最大抵押量",
    "网址",
    "安全联系",
    "描述",
    "费率",
    "最大费率",
    "费率幅度",
  ];
  List<String> infoContentList = [];
  bool isShowAll = false;

//  all_page_state.AllPageState _currentState = all_page_state.LoadingState();
  all_page_state.AllPageState _currentState;
  var _selectedMap3NodeValue = 0;
  AtlasApi _atlasApi = AtlasApi();
  var _address;

  @override
  void initState() {
    var activatedWallet = WalletInheritedModel.of(Keys.rootKey.currentContext)?.activatedWallet;
    _address = activatedWallet?.wallet?.getAtlasAccount()?.address ?? "";

    _refreshData();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white, appBar: BaseAppBar(baseTitle: "抵押Atlas节点"), body: _pageWidget(context));
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
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                _map3NodeSelection(),
                Container(
                  height: 10,
                  color: HexColor("#F2F2F2"),
                ),
                _atlasStakeRemindInfo(),
              ],
            ),
          ),
        ),
        _bottomBtn()
      ],
    );
  }

  _map3NodeSelection() {
    List<DropdownMenuItem> _map3NodeItems = List();
    if (widget.myMap3List.length > 0) {
      _map3NodeItems.addAll(List.generate(widget.myMap3List.length, (index) {
        Map3InfoEntity map3nodeEntity = widget.myMap3List[index];
        return DropdownMenuItem(
          value: index,
          child: Text(
            '${map3nodeEntity.name}',
            style: TextStyles.textC333S14,
          ),
        );
      }).toList());
    } else {
      return Container();
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '选择需要抵押的Map3节点',
            style: TextStyles.textC333S14,
          ),
          SizedBox(
            height: 16,
          ),
          Container(
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
          )
        ],
      ),
    );
  }

  _atlasStakeRemindInfo() {
    return Padding(
      padding: const EdgeInsets.only(left: 14.0, right: 14, top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("注意事项", style: TextStyles.textC333S16),
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 10),
            child: Text("· 抵押后下一个纪元当选才会产生收益"),
          ),
          Text("· 撤销抵押需要等下一个纪元才能生效，期间可以继续享受出块收益回报"),
        ],
      ),
    );
  }

  _refreshData() async {
    var atlasInfo = widget._atlasInfoEntity;
    infoContentList = [
      "${atlasInfo.getTotalStaking()}",
      "${atlasInfo.signRate}",
      "${atlasInfo.rewardRate}",
      "${atlasInfo.getMaxStaking()}",
      "${getContentOrEmptyStr(atlasInfo.home)}",
      "${getContentOrEmptyStr(atlasInfo.contact)}",
      "${getContentOrEmptyStr(atlasInfo.describe)}",
      "${FormatUtil.formatPercent(double.parse(atlasInfo.getFeeRate()))}",
      "${FormatUtil.formatPercent(double.parse(atlasInfo.getFeeRateMax()))}",
      "${FormatUtil.formatPercent(double.parse(atlasInfo.getFeeRateTrim()))}",
      "${atlasInfo.blsKey}",
      "${atlasInfo.blsSign}"
    ];

    if (mounted)
      setState(() {
        _currentState = null;
      });
  }

  _bottomBtn() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 36.0, top: 22),
      child: ClickOvalButton(
        S.of(context).confirm,
        () async {
          AtlasMessage message = ConfirmAtlasStakeMessage(
            nodeId: widget._atlasInfoEntity.nodeId,
            atlasAddress: widget._atlasInfoEntity.address,
            map3Address: widget.myMap3List[_selectedMap3NodeValue].address,
          );
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Map3NodeConfirmPage(
                  message: message,
                ),
              ));
//          Application.router.navigateTo(
//              context, Routes.map3node_formal_confirm_page + "?actionEvent=${Map3NodeActionEvent.ATLAS_STAKE.index}");
          /*var atlasEntity = widget._atlasInfoEntity;
          var map3Entity = widget._atlasInfoEntity.myMap3[_selectedMap3NodeValue];
          await _atlasApi.postPledgeAtlas(PledgeAtlasEntity(
              map3Entity.staking,
              map3Entity.address,
              111,
              111,
              AtlasPayload(atlasEntity.nodeId, map3Entity.nodeId),
              "1111",
              "11111",
              atlasEntity.address,
              AtlasActionType.JOIN_DELEGATE_ALAS));*/
        },
        width: 300,
        height: 46,
      ),
    );
  }
}

Widget stakeHeaderInfo(BuildContext buildContext, AtlasInfoEntity atlasInfoEntity) {
  return Row(
    children: <Widget>[
      Padding(
        padding: const EdgeInsets.only(left: 14.0, right: 8),
        child: iconAtlasWidget(atlasInfoEntity),
      ),
      Expanded(
        child: Column(
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  atlasInfoEntity.name,
                  style: TextStyles.textC333S16,
                ),
                SizedBox(
                  width: 6,
                ),
                /*Text(
                  '${atlasInfoEntity.rank}',
                  style: TextStyle(color: HexColor("#228BA1"), fontSize: 16),
                ),*/
                Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2.0),
                  child: Text(
                    "节点号：${atlasInfoEntity.nodeId}",
                    style: TextStyles.textC333S12,
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Text(
                    shortBlockChainAddress(WalletUtil.ethAddressToBech32Address(
                      atlasInfoEntity.address,
                    )),
                    style: TextStyles.textC999S11),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(
                        text: WalletUtil.ethAddressToBech32Address(
                      atlasInfoEntity.address,
                    )));
                    UiUtil.toast(S.of(buildContext).copyed);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8, top: 3, bottom: 3),
                    child: Image.asset(
                      "res/drawable/ic_copy.png",
                      width: 16,
                      height: 16,
                    ),
                  ),
                ),
                Spacer(),
                Container(
                    padding: EdgeInsets.only(left: 6.0, right: 6),
                    color: HexColor("#e3fafb"),
                    child: Text("${getAtlasNodeType(atlasInfoEntity.type)}", style: TextStyles.textC333S12)),
              ],
            )
          ],
        ),
      ),
      SizedBox(
        width: 14,
      )
    ],
  );
}

Widget stakeInfoView(List<String> infoTitleList, List<String> infoContentList, bool isShowAll, Function showAllInfo) {
  return Column(
    children: <Widget>[
      Column(
        children: List.generate(
            isShowAll ? infoTitleList.length : 3,
            (index) => Padding(
                  padding: const EdgeInsets.only(top: 9.0, bottom: 9),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 14),
                          child: Text(
                            infoTitleList[index],
                            style: TextStyle(fontSize: 14, color: HexColor("#999999")),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 14),
                          child: Text(
                            infoContentList[index],
                            style: TextStyle(fontSize: 14, color: HexColor("#333333")),
                          ),
                        ),
                      )
                    ],
                  ),
                )).toList(),
      ),
      if (!isShowAll)
        InkWell(
            onTap: () {
              showAllInfo();
            },
            child: Padding(
              padding: const EdgeInsets.all(7.0),
              child: Image.asset(
                "res/drawable/ic_down_triangle.png",
                width: 10,
              ),
            )),
      SizedBox(
        height: 8,
      ),
      Container(
        height: 10,
        color: HexColor("#F2F2F2"),
      ),
    ],
  );
}
