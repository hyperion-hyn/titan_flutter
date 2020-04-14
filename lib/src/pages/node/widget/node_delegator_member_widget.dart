
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/pages/node/api/node_api.dart';
import 'package:titan/src/pages/node/model/contract_delegator_item.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/utils.dart';

class NodeDelegatorMemberWidget extends StatefulWidget {
  final String contractId;
  final String amountDelegation;
  NodeDelegatorMemberWidget(this.contractId, this.amountDelegation);

  @override
  State<StatefulWidget> createState() {
    return _NodeDelegatorMemberState();
  }
}

class _NodeDelegatorMemberState extends State<NodeDelegatorMemberWidget> {

  LoadDataBloc loadDataBloc = LoadDataBloc();
  int _currentPage = 0;
  NodeApi _nodeApi = NodeApi();
  List<ContractDelegateRecordItem> memberList = [];
  double _viewHeight = 135;

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
    try {
      _currentPage = 0;
      memberList = [];
      List<ContractDelegateRecordItem> tempMemberList =
      await _nodeApi.getContractDelegateRecord(int.parse(widget.contractId),
          page: _currentPage);

      if (tempMemberList.length > 0) {
        memberList.addAll(tempMemberList);
        loadDataBloc.add(LoadingMoreSuccessEvent());

        _viewHeight = 80.0 + memberList.length * 60;

      } else {
        loadDataBloc.add(LoadMoreEmptyEvent());

        _viewHeight = 180.0 + memberList.length * 60;
      }

      setState(() {
      });

    } catch (e) {
      setState(() {
        loadDataBloc.add(LoadMoreFailEvent());
      });
    }
  }


  void getJoinMemberMoreData() async {
    try {
      _currentPage++;
      List<ContractDelegateRecordItem> tempMemberList =
      await _nodeApi.getContractDelegateRecord(int.parse(widget.contractId),
          page: _currentPage);

      if (tempMemberList.length > 0) {
        memberList.addAll(tempMemberList);
        loadDataBloc.add(LoadingMoreSuccessEvent());
      } else {
        loadDataBloc.add(LoadMoreEmptyEvent());
      }

      setState(() {
        _viewHeight = 80.0 + memberList.length * 60;
      });
    } catch (e) {
      setState(() {
        loadDataBloc.add(LoadMoreFailEvent());
      });
    }
  }

  Widget _getJoinMemberView() {
    return Container(
      height: _viewHeight > 300 ? 300:_viewHeight,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
            child: Row(
              children: <Widget>[
                Text("入账流水", style: TextStyle(fontSize: 16, color: HexColor("#333333"))),
                Spacer(),
                Text("总额：${widget.amountDelegation} (HYN)", style: TextStyle(fontSize: 14, color: HexColor("#999999")))
              ],
            ),
          ),
          Expanded(
            child: LoadDataContainer(
                bloc: loadDataBloc,
                enablePullDown: true,
                //onLoadData: getJoinMemberData,
                onLoadingMore: () {
                  getJoinMemberMoreData();
                },
                child: ListView.separated(
                  itemBuilder: (context, index) {
                    var model = memberList[index];
                    return _item(model);
                  },
                  separatorBuilder: (context, index) {
                    return _lineSpacer();
                  },
                  itemCount: memberList.length,
                  scrollDirection: Axis.vertical,
                )),
          ),
        ],
      ),
    );
  }


  Widget _lineSpacer() {
    return Container(
      height: 0.5,
      padding: const EdgeInsets.fromLTRB(280, 0, 18, 0),
      color: DefaultColors.colorf5f5f5,
    );
  }

  Widget _item(ContractDelegateRecordItem delegatorItem) {

    String showName =
    delegatorItem.userName.substring(0, 1);
    String userAddress = shortBlockChainAddress(" ${delegatorItem.userAddress}", limitCharsLength: 8);
    String txHash = shortBlockChainAddress(delegatorItem.txHash, limitCharsLength: 6);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 40,
            width: 40,
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(13.0)),
              ),
              child: Center(
                  child: Text(
                    showName,
                    style: TextStyle(fontSize: 15, color: HexColor("#000000")),
                  )),
            ),
          ),
          Flexible(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: <Widget>[
                  RichText(
                    text: TextSpan(
                        text: "${delegatorItem.userName}",
                        style: TextStyle(fontSize: 14, color: HexColor("#000000")),
                        children: [
                          TextSpan(
                            text: userAddress,
                            style: TextStyle(fontSize: 12, color: HexColor("#9B9B9B")),
                          )
                        ]),
                  ),
                  Container(
                    height: 6.0,
                  ),
                  Text("${FormatUtil.formatDate(delegatorItem.createAt)}", style: TextStyle(fontSize: 12, color: HexColor("#333333")))
                ],
              ),
            ),
          ),
          //Spacer(),
          Container(width: 8,),
          Flexible(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                RichText(
                  text: TextSpan(
                    text: FormatUtil.amountToString(delegatorItem.amount),
                    style: TextStyle(fontSize: 14, color: HexColor("#333333"), fontWeight: FontWeight.bold),
                  ),
                ),
                  Container(
                    height: 6.0,
                  ),
                  Text(txHash, style: TextStyle(fontSize: 12, color: HexColor("#333333")))
              ],
            ),
          ),
        ],
      ),
    );
  }

}
