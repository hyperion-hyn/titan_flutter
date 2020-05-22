import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/node/api/node_api.dart';
import 'package:titan/src/pages/node/model/contract_delegator_item.dart';
import 'package:titan/src/pages/wallet/api/etherscan_api.dart';
import 'package:titan/src/pages/webview/webview.dart';
import 'package:characters/characters.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/widget/wallet_widget.dart';

class NodeJoinMemberWidget extends StatefulWidget {
  final String contractId;
  final String remainDay;
  final String shareName;
  final String shareUrl;
  final bool isShowInviteItem;
  final LoadDataBloc loadDataBloc;

  NodeJoinMemberWidget(this.contractId, this.remainDay, this.shareName, this.shareUrl, {this.isShowInviteItem = true, this.loadDataBloc});

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

    if (widget.loadDataBloc != null) {
      widget.loadDataBloc.listen((state){
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
    _currentPage = 0;
    List<ContractDelegatorItem> tempMemberList =
    await _nodeApi.getContractDelegator(int.parse(widget.contractId), page: _currentPage);

    // print("[widget] --> build, length:${tempMemberList.length}");
    if (mounted) {
      setState(() {
        if (tempMemberList.length > 0) {
          memberList = [];
        }
        memberList.addAll(tempMemberList);
      });
    }
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
        padding: const EdgeInsets.only(top: 16, bottom: 8),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 0),
              child: Row(
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
            ),
            SizedBox(
              height: 12,
            ),
            Expanded(
              child: LoadDataContainer(
                  bloc: loadDataBloc,
                  enablePullDown: false,
                  hasFootView: false,
                  //onLoadData: getJoinMemberData,
                  onLoadingMore: () {
                    getJoinMemberMoreData();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemBuilder: (context, index) {
                      var i = index;
                      var delegatorItem = memberList[i];
                      return _item(delegatorItem, i == 0);
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

  Widget _item(ContractDelegatorItem item, bool isFirst) {
    String showName = item.userName;
    if (item.userName.isNotEmpty) {
      showName = item.userName.characters.first;
    }
     return InkWell(
      onTap: ()=> _pushTransactionDetailAction(item),
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
//                      height: 50,
//                      width: 50,
                        child: walletHeaderWidget(showName, isShowShape: false, address: item.userAddress)
                        ,
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 5.0, right: 5),
                        child: Text("${item.userName}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: HexColor("#000000"))),
                      ),
//                    SizedBox(
//                      height: 4,
//                    ),
                      Text("${FormatUtil.stringFormatNum(item.amountDelegation)}",
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


  void _pushTransactionDetailAction(ContractDelegatorItem item) {
    var url = EtherscanApi.getAddressDetailUrl(item.userAddress,
        SettingInheritedModel.of(context, aspect: SettingAspect.area).areaModel.isChinaMainland);
    if (url != null) {
      /* String webUrl = FluroConvertUtils.fluroCnParamsEncode(url);
      String webTitle = FluroConvertUtils.fluroCnParamsEncode(S.of(context).detail);
      Application.router.navigateTo(context, Routes.toolspage_webview_page
          + '?initUrl=$webUrl&title=$webTitle');*/

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => WebViewContainer(
                initUrl: url,
                title: "",
              )));
    }
  }

}