import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/node/api/node_api.dart';
import 'package:titan/src/pages/node/model/contract_delegator_item.dart';
import 'package:titan/src/pages/wallet/api/etherscan_api.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';

class NodeJoinMemberWidget extends StatefulWidget {
  final String contractId;
  final String remainDay;
  final String shareName;
  final String shareUrl;
  final bool isShowInviteItem;

  NodeJoinMemberWidget(this.contractId, this.remainDay, this.shareName, this.shareUrl, {this.isShowInviteItem = true});

  @override
  State<StatefulWidget> createState() {
    return _NodeJoinMemberState();
  }
}

class _NodeJoinMemberState extends State<NodeJoinMemberWidget> {
  LoadDataBloc loadDataBloc = LoadDataBloc();
  int _currentPage = 0;
  NodeApi _nodeApi = NodeApi();
  List<ContractDelegatorItem> memberList = [];

  @override
  void initState() {
    super.initState();

    getJoinMemberData();
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
    _currentPage = 0;
    List<ContractDelegatorItem> tempMemberList =
        await _nodeApi.getContractDelegator(int.parse(widget.contractId), page: _currentPage);

    // print("[widget] --> build, length:${tempMemberList.length}");

    setState(() {
      memberList.addAll(tempMemberList);
    });
  }

  void getJoinMemberMoreData() async {
    try {
      _currentPage++;
      List<ContractDelegatorItem> tempMemberList =
          await _nodeApi.getContractDelegator(int.parse(widget.contractId), page: _currentPage);

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
      height: 160,
      child: Padding(
        padding: const EdgeInsets.only(left: 20.0, top: 15, bottom: 8),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                    child: Text(S.of(context).part_member, style: TextStyle(fontSize: 16, color: HexColor("#333333")))),
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
            SizedBox(
              height: 13,
            ),
            Expanded(
              child: LoadDataContainer(
                  bloc: loadDataBloc,
                  enablePullDown: false,
                  //onLoadData: getJoinMemberData,
                  onLoadingMore: () {
                    getJoinMemberMoreData();
                  },
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      var i = index;
                      var delegatorItem = memberList[i];
                      return _item(delegatorItem, i == 0);
//                      if (widget.isShowInviteItem) {
//                        if (index == 0) {
//                          return _firstItem();
//                        } else {
//                          var i = index - 1;
//                          var delegatorItem = memberList[i];
//                          return _item(delegatorItem,i==1);
//                        }
//                      }
//                      else {
//                        var i = index;
//                        var delegatorItem = memberList[i];
//                        return _item(delegatorItem, i==0);
//                      }
                    },
                    itemCount: widget.isShowInviteItem ? memberList.length : memberList.length,
                    scrollDirection: Axis.horizontal,
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _firstItem() {
    return Container(
      width: 90,
      margin: const EdgeInsets.only(right: 12, top: 2, bottom: 2.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: HexColor("#7B766A"), width: 1, style: BorderStyle.solid)),
      child: InkWell(
        onTap: () async {
          final ByteData imageByte = await rootBundle.load("res/drawable/hyn.png");
          Share.file(S.of(context).nav_share_app, 'app.png', imageByte.buffer.asUint8List(), 'image/jpeg',
              text: "${widget.shareUrl}?name=${widget.shareName}");

//          Share.text(S.of(context).share, widget.shareUrl,'text/plain');
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              "res/drawable/ic_map3_node_join_add_member.png",
              width: 26,
              height: 26,
            ),
            SizedBox(
              height: 12,
            ),
            Text(
              S.of(context).invite_friend_join,
              style: TextStyle(fontSize: 12, color: HexColor("#7B766A")),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }

  Widget _item(ContractDelegatorItem delegatorItem, bool isFirst) {
    String showName = delegatorItem.userName.substring(0, 1);
    Color color;
    int index = memberList.indexOf(delegatorItem);
    if (index % 3 == 0) {
      color = HexColor("#CAF0FF");
    } else if (index % 3 == 1) {
      color = HexColor("#FFD7D7");
    } else {
      color = HexColor("#FFE87D");
    }
    return InkWell(
      onTap: () {
        var url = EtherscanApi.getAddressDetailUrl(delegatorItem.userAddress,
            SettingInheritedModel.of(context, aspect: SettingAspect.area).areaModel.isChinaMainland);
        url = FluroConvertUtils.fluroCnParamsEncode(url);
        Application.router.navigateTo(context,
            Routes.toolspage_webview_page + '?initUrl=$url');
      },
      child: Padding(
        padding: EdgeInsets.only(top: 2, bottom: 2.0),
        child: SizedBox(
          width: 91,
          height: 111,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey[300],
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
//                      height: 50,
//                      width: 50,
                        child: circleIconWidget(showName, isShowShape: false, color: color)
                        /*Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                                Radius.circular(13.0)),
                          ),
                          child: Center(
                              child: Text(
                            "$showName",
                            style: TextStyle(fontSize: 15, color: HexColor("#000000")),
                          )),
                        )*/
                        ,
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 5.0, right: 5),
                        child: Text("${delegatorItem.userName}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: HexColor("#000000"))),
                      ),
//                    SizedBox(
//                      height: 4,
//                    ),
                      Text("${FormatUtil.stringFormatNum(delegatorItem.amountDelegation)}",
                          style: TextStyle(fontSize: 10, color: HexColor("#9B9B9B")))
                    ],
                  ),
                ),
                if (isFirst)
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
}

Widget circleIconWidget(String shortName, {bool isShowShape = true, Color color = Colors.white}) {
  return Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: Colors.grey[300],
          blurRadius: 8.0,
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Text(
          shortName,
          style: TextStyle(fontSize: 15, color: HexColor("#000000"), fontWeight: FontWeight.w500),
        ),
      ),
    ),
  );
}
