import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/atlas_map/entity/enum_atlas_type.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_info_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_user_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/user_map3_entity.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_public_widget.dart';
import 'package:titan/src/pages/wallet/api/etherscan_api.dart';
import 'package:titan/src/pages/webview/webview.dart';
import 'package:characters/characters.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/widget/wallet_widget.dart';

class AtlasJoinMap3Widget extends StatefulWidget {
  final String nodeId;
  final String remainDay;
  final String shareName;
  final String shareUrl;
  final bool isShowInviteItem;
  final LoadDataBloc loadDataBloc;

  AtlasJoinMap3Widget(this.nodeId, this.remainDay, this.shareName, this.shareUrl,
      {this.isShowInviteItem = true, this.loadDataBloc});

  @override
  State<StatefulWidget> createState() {
    return _AtlasJoinMap3State();
  }
}

class _AtlasJoinMap3State extends State<AtlasJoinMap3Widget> {
  LoadDataBloc loadDataBloc = LoadDataBloc();
  int _currentPage = 1;
  AtlasApi _atlasApi = AtlasApi();
  List<Map3InfoEntity> memberList = [];
  bool isRefreshed = false;

  @override
  void initState() {
    super.initState();

    if (widget.loadDataBloc != null) {
      widget.loadDataBloc.listen((state) {
        if (state is RefreshSuccessState) {
          getJoinMemberData();
        }
      });
    } else {
      getJoinMemberData();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    loadDataBloc.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _getJoinMemberView();
  }

  void getJoinMemberData() async {
    isRefreshed = false;
    print("!!!!!getJoin  1111331");
    _currentPage = 1;

    List<Map3InfoEntity> tempMemberList = await _atlasApi.postAtlasMap3NodeList(widget.nodeId, page: _currentPage);
print("!!!!!getJoin");
    // print("[widget] --> build, length:${tempMemberList.length}");
    if (mounted) {
      print("!!!!!build empty  444 ${memberList.length}");
      setState(() {
        if (tempMemberList.length > 0) {
          memberList = [];
        }
        print("!!!!!build empty  555 ${memberList.length}");
        memberList.addAll(tempMemberList);
        isRefreshed = true;
        print("!!!!!build empty  666 ${memberList.length}");
        loadDataBloc.add(RefreshSuccessEvent());
      });
    }
  }

  void getJoinMemberMoreData() async {
    try {
      _currentPage++;
      List<Map3InfoEntity> tempMemberList = await _atlasApi.postAtlasMap3NodeList(widget.nodeId, page: _currentPage);

      if (tempMemberList.length > 0) {
        memberList.addAll(tempMemberList);
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

  Widget _getJoinMemberView() {
    return Container(
      height: memberList.isNotEmpty ? 192 : 292,
      child: Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 8),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 0),
              child: Row(
                children: <Widget>[
                  Expanded(
                      child:
                      Text(S.of(context).part_member, style: TextStyle(fontSize: 16, color: HexColor("#333333")))),
                  /*Text(
                    "剩余时间：${widget.remainDay}天",
                    style: TextStyles.textC999S14,
                  ),*/
                  Text(
                    S.of(context).total_member_count(memberList.length.toString()),
                    style: TextStyles.textC999S14,
                  ),
                  SizedBox(
                    width: 14,
                  )
                ],
              ),
            ),
            SizedBox(
              height: 12,
            ),
            memberList.isNotEmpty
                ? Expanded(
              child: LoadDataContainer(
                  bloc: loadDataBloc,
                  enablePullDown: false,
                  hasFootView: false,
                  onLoadData: getJoinMemberData,
                  onLoadingMore: () {
                    getJoinMemberMoreData();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemBuilder: (context, index) {
                      var i = index;
                      var model = memberList[i];
                      return _itemBuilder(model);
                    },
                    itemCount: memberList.length,
                    scrollDirection: Axis.horizontal,
                  )),
            )
                : Expanded(child: emptyListWidget(title: "参与的Map3为空", isAdapter: false)),
            SizedBox(height: 22,),
            Container(
              height: 10,
              color: HexColor("#F2F2F2"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemBuilder(Map3InfoEntity entity) {
    return InkWell(
      onTap: () => _pushTransactionDetailAction(entity),
      child: Padding(
        padding: EdgeInsets.only(top: 4, bottom: 4.0),
        child: SizedBox(
          width: 91,
          height: 111,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey[200],
                  blurRadius: 40.0,
                ),
              ],
            ),
            margin: const EdgeInsets.only(right: 12),
            child: Stack(
              children: <Widget>[
                Align(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        child: walletHeaderWidget(entity.name, isShowShape: false, address: entity.address),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 5.0, right: 5),
                        child: Text(entity.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: HexColor("#000000"))),
                      ),
                      Text(
                          "${FormatUtil.stringFormatNum(ConvertTokenUnit.weiToEther(weiBigInt: BigInt.parse(entity.staking)).toString())}",
                          style: TextStyle(fontSize: 10, color: HexColor("#9B9B9B")))
                    ],
                  ),
                ),
                if (entity.isCreator())
                  Positioned(
                    top: 15,
                    right: 4,
                    child: Container(
                        padding: const EdgeInsets.only(left: 5, right: 5),
                        decoration: BoxDecoration(
                          color: DefaultColors.colorffdb58,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(S.of(context).sponsor, style: TextStyle(fontSize: 8, color: HexColor("#322300")))),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _pushTransactionDetailAction(Map3InfoEntity item) {
    Application.router.navigateTo(
      context,
      Routes.map3node_contract_detail_page + '?info=${FluroConvertUtils.object2string(item.toJson())}',
    );

    /*var url = EtherscanApi.getAddressDetailUrl(
        item.address, SettingInheritedModel.of(context, aspect: SettingAspect.area).areaModel.isChinaMainland);
    if (url != null) {
      *//* String webUrl = FluroConvertUtils.fluroCnParamsEncode(url);
      String webTitle = FluroConvertUtils.fluroCnParamsEncode(S.of(context).detail);
      Application.router.navigateTo(context, Routes.toolspage_webview_page
          + '?initUrl=$webUrl&title=$webTitle');*//*

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => WebViewContainer(
                    initUrl: url,
                    title: "",
                  )));
    }*/
  }
}
