
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/pages/node/api/node_api.dart';
import 'package:titan/src/pages/node/model/contract_delegator_item.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';

class NodeJoinMemberWidget extends StatefulWidget {
  final String contractId;
  final String remainDay;
  NodeJoinMemberWidget(this.contractId, this.remainDay);

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
    List<ContractDelegatorItem> tempMemberList = await _nodeApi
        .getContractDelegator(int.parse(widget.contractId), page: _currentPage);


   // print("[widget] --> build, length:${tempMemberList.length}");

    setState(() {
      memberList.addAll(tempMemberList);
    });
  }

  void getJoinMemberMoreData() async {
    try {
      _currentPage++;
      List<ContractDelegatorItem> tempMemberList =
      await _nodeApi.getContractDelegator(int.parse(widget.contractId),
          page: _currentPage);

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
      height: 176,
      child: Padding(
        padding: const EdgeInsets.only(left: 20.0, top: 15, bottom: 15),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                    child: Text("参与成员",
                        style: TextStyle(
                            fontSize: 16, color: HexColor("#333333")))),
                Text(
                  "剩余时间：${widget.remainDay}天",
                  style: TextStyles.textC999S14,
                ),
                SizedBox(
                  width: 16,
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
                      if (index == 0) {
                        return Container(
                          width: 90,
                          margin: const EdgeInsets.only(right: 12,top:2,bottom:2.0),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: HexColor("#7B766A"),
                                  width: 1,
                                  style: BorderStyle.solid)),
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
                                "邀请好友\n参加",
                                style: TextStyle(
                                    fontSize: 12, color: HexColor("#7B766A")),
                                textAlign: TextAlign.center,
                              )
                            ],
                          ),
                        );
                      } else {
                        var delegatorItem = memberList[index - 1];
                        String showName =
                        delegatorItem.userName.substring(0, 1);
                        return Padding(
                          padding: EdgeInsets.only(top:2,bottom:2.0),
                          child: SizedBox(
                            width: 100,
                            height: 100,
                            child: Card(
                              margin: const EdgeInsets.only(right: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.all(Radius.circular(20.0)),
                              ),
                              child: Stack(
                                children: <Widget>[
                                  Align(
                                    alignment: Alignment.center,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        SizedBox(
                                          height: 40,
                                          width: 40,
                                          child: Card(
                                            elevation: 3,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(13.0)),
                                            ),
                                            child: Center(
                                                child: Text(
                                                  "$showName",
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      color: HexColor("#000000")),
                                                )),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text("${delegatorItem.userName}",
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: HexColor("#000000"))),
                                        SizedBox(
                                          height: 3,
                                        ),
                                        Text("${FormatUtil.stringFormatNum(delegatorItem.amountDelegation)}",
                                            style: TextStyle(
                                                fontSize: 10,
                                                color: HexColor("#9B9B9B")))
                                      ],
                                    ),
                                  ),
                                  if (index == 1)
                                    Positioned(
                                      top: 20,
                                      right: 4,
                                      child: Container(
                                          padding: const EdgeInsets.only(
                                              left: 5, right: 5),
                                          decoration: BoxDecoration(
                                            color: DefaultColors.colorffdb58,
                                            borderRadius:
                                            BorderRadius.circular(6),
                                          ),
                                          child: Text("发起人",
                                              style: TextStyle(
                                                  fontSize: 8,
                                                  color: HexColor("#322300")))),
                                    )
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                    },
                    itemCount: memberList.length + 1,
                    scrollDirection: Axis.horizontal,
                  )),
            ),
          ],
        ),
      ),
    );
  }

}
