import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/node/api/node_api.dart';
import 'package:titan/src/pages/node/model/contract_node_item.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'node_contract_detail_page.dart';

class MyMap3ContractPage extends StatefulWidget {
  final String title;
  MyMap3ContractPage(this.title);

  @override
  State<StatefulWidget> createState() {
    return _MyMap3ContractState();
  }
}

class _MyMap3ContractState extends State<MyMap3ContractPage> {
  List<ContractNodeItem> _dataArray = [];
  LoadDataBloc loadDataBloc = LoadDataBloc();
  var _currentPage = 0;

  var api = NodeApi();

  @override
  void initState() {
    super.initState();

    loadDataBloc.add(LoadingEvent());
    _loadData();
  }

  @override
  void dispose() {
    loadDataBloc.close();
    super.dispose();
  }

  _loadMoreData() async {

    List<ContractNodeItem> dataList = [];
    if (widget.title.contains("发起")) {
      List<ContractNodeItem> createContractList = await api.getMyCreateNodeContract(page: _currentPage);
      dataList  = createContractList;
    } else {
      List<ContractNodeItem> joinContractList = await api.getMyJoinNodeContract(page: _currentPage);
      dataList = joinContractList;
    }

    if (dataList.length == 0) {
      loadDataBloc.add(LoadMoreEmptyEvent());
    } else {
      _currentPage += 1;
      loadDataBloc.add(LoadingMoreSuccessEvent());

      setState(() {
        _dataArray.addAll(dataList);
      });
    }

    print('[map3] _loadMoreData, list.length:${dataList.length}');

  }

  _loadData() async {

    _currentPage = 0;

    List<ContractNodeItem> dataList = [];
    if (widget.title.contains("发起")) {
      List<ContractNodeItem> createContractList = await api.getMyCreateNodeContract();
      dataList  = createContractList;
    } else {
      List<ContractNodeItem> joinContractList = await api.getMyJoinNodeContract();
      dataList = joinContractList;
    }

    if (dataList.length == 0) {
      loadDataBloc.add(LoadEmptyEvent());
    } else {
      _currentPage ++;
      loadDataBloc.add(RefreshSuccessEvent());

      // todo: 测试写死
      dataList.first.state = "Running";

      setState(() {
        _dataArray = dataList;
      });
    }


    print('[map3] widget.title:${widget.title}, _loadData, dataList.length:${dataList.length}');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Container(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
        color: HexColor('#E2E0E3'),
        child: LoadDataContainer(
          bloc: loadDataBloc,
          onLoadData: _loadData,
          onRefresh: _loadData,
          // todo: 服务器暂时没支持page分页
          //onLoadingMore: _loadMoreData,
          child: ListView.separated(
              itemBuilder: (context, index) {
                return _buildInfoItem(_dataArray[index]);
              },
              separatorBuilder: (context, index) {
                return Container(
                  height: 8,
                  color: Colors.white10,
                );
              },
              itemCount: _dataArray.length),
        ),
      ),
    );
  }

  HexColor _getStatusColor(String stateString) {
    var state = enumContractStateFromString(stateString);
    var statusColor = HexColor('#EED097');

    switch (state) {
      case ContractState.PENDING:
        statusColor = HexColor('#EED097');
        break;

      case ContractState.Running:
        statusColor = HexColor('#3FF78C');
        break;

      case ContractState.Expired:
        statusColor = HexColor('#867B7B');
        break;

      case ContractState.Withdrawal:
        statusColor = HexColor('#867B7B');
        break;

      case ContractState.FailRun:
        statusColor = HexColor('#F22504');
        break;

      default:
        break;
    }
    return statusColor;
  }

  Widget _buildInfoItem(ContractNodeItem contractNodeItem) {
    String startAccount = "${contractNodeItem.owner}";
    startAccount = startAccount.substring(0,startAccount.length > 25 ? 25 : startAccount.length);
    startAccount = startAccount + "...";
    return Container(
      color: Colors.white,
      child: Padding(
        padding:
        const EdgeInsets.only(left: 20.0, right: 13, top: 7, bottom: 7),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text("${contractNodeItem.ownerName}",
                    style: TextStyles.textCcc000000S14),
                Expanded(
                    child: Text(" $startAccount",
                        style: TextStyles.textC9b9b9bS12)),
                Text("剩余时间：${contractNodeItem.remainDay}天", style: TextStyles.textC9b9b9bS12)
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top:8,bottom: 16),
              child: Divider(height: 1,color: DefaultColors.color1177869e),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Image.asset(
                  "res/drawable/ic_map3_node_item_contract.png",
                  width: 42,
                  height: 42,
                  fit:BoxFit.cover,
                ),
                SizedBox(width: 6,),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Expanded(
                              child: Text("${contractNodeItem.contract.nodeName}",
                                  style: TextStyles.textCcc000000S14))
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 3.0),
                        child: Row(
                          children: <Widget>[
                            Text("最高 ${FormatUtil.formatTenThousand(contractNodeItem.contract.minTotalDelegation)}",
                                style: TextStyles.textC99000000S10,maxLines:1,softWrap: true),
                            Text("  |  ",style: TextStyles.textC9b9b9bS12),
                            Text("${contractNodeItem.contract.duration}天",style: TextStyles.textC99000000S10)
                          ],
                        ),
                      ),
                      Text("${FormatUtil.formatDate(contractNodeItem.instanceStartTime)}", style: TextStyles.textCfffS12),
                    ],
                  ),
                ),
                Column(
                  children: <Widget>[
                    Text("${FormatUtil.formatPercent(contractNodeItem.contract.annualizedYield)}", style: TextStyles.textCff4c3bS18),
                    Text("年化奖励", style: TextStyles.textC99000000S10)
                  ],
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top:9,bottom: 9),
              child: Divider(height: 1,color: DefaultColors.color1177869e),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: RichText(
                    text: TextSpan(
                        text: "还差",
                        style: TextStyles.textC9b9b9bS12,
                        children: <TextSpan>[
                          TextSpan(
                              text: "${FormatUtil.formatNum(int.parse(contractNodeItem.remainDelegation))}",
                              style: TextStyles.textC7c5b00S12),
                          TextSpan(
                              text: "HYN",
                              style: TextStyles.textC9b9b9bS12),
                        ]),
                  ),
                ),
                SizedBox(
                  height: 24,
                  width: 78,
                  child: FlatButton(
                    color: DefaultColors.colorffdb58,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                    onPressed: () {
                      Application.router.navigateTo(context, Routes.map3node_join_contract_page
                          + "?contractId=${contractNodeItem.id}");
                    },
                    child: Text("参与", style: TextStyles.textC906b00S13),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  /*
  Widget _buildInfoItem_old(ContractNodeItem model) {
    return Container(
      //color: HexColor('#7275A2'),
      decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(5),
          color: HexColor('#7275A2')),
      child: IntrinsicHeight(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8),
                child: Container(
                  child: Image.asset(
                    "res/drawable/ic_map3_node_item.png",
                    width: 55,
                    height: 55,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Expanded(
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Spacer(),
                      Text(model.contract.nodeName, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: HexColor('#FFFFFF'))),
                      Spacer(),
                      Text("发起账户 ${model.ownerName} ${shortBlockChainAddress(model.owner, limitCharsLength: 6)}", style: TextStyle(fontSize: 13, color: HexColor('#FFFFFF'))),
                      Spacer(),
                      Text(
                        FormatUtil.formatDate(model.instanceStartTime),
                        style: TextStyle(fontSize: 12, color: HexColor('#FFFFFF')),
                      ),
                      Spacer(),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Spacer(),
                            Container(
                              width: 8,
                              height: 8,
                              //color: Colors.red,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  // todo:
                                  color: _getStatusColor(model.state),
                                  border: Border.all(color: Colors.white, width: 1.0)),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Text("剩下7天启动", style: TextStyle(fontSize: 12, color: HexColor('#FFFFFF'))),
                            ),
                          ],
                        ),
                      ),
                      Spacer(),
                      InkWell(
                        onTap: () {
                          //if (model.state == ContractState.Expired) {
                          //print('[点击查看收益] id:${model.id}');

                          String jsonString = FluroConvertUtils.object2string(model.toJson());
                          //print('[xx] param:${jsonString}');

                          Application.router.navigateTo(context, Routes.map3node_contract_detail_page + "?model=${jsonString}");

                          //Navigator.push(context, MaterialPageRoute(builder: (context) => NodeContractDetailPage(model)));
                          //}
                        },
                        child:
                        (enumContractStateFromString(model.state) == ContractState.PENDING || enumContractStateFromString(model.state) ==  ContractState.FailRun)?

                        Text.rich(TextSpan(
                            children: [
                              TextSpan(
                                  text: "还差",
                                  style: TextStyle(fontSize: 12, color: HexColor('#FFFFFF'))
                              ),
                              TextSpan(
                                text: "${FormatUtil.formatNum(int.parse(model.remainDelegation))}",
                                style: TextStyle(fontSize: 12, color: HexColor('#E39F2D')),
                              ),
                              TextSpan(
                                  text: "HYN",
                                  style: TextStyle(fontSize: 12, color: HexColor('#FFFFFF'))
                              ),
                            ]
                        )): // todo:
                        Text("合约完成", style: TextStyle(fontSize: 12, color: HexColor('#FFFFFF'))) ,
                      ),
                      if (enumContractStateFromString(model.state) == ContractState.PENDING) FlatButton(
                        padding: EdgeInsets.symmetric(horizontal: 4,vertical: 2),
                        color: Colors.white,
//                        highlightColor: Colors.black,
//                        splashColor: Colors.white10,
                        textColor: HexColor('#3C99FA'),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        onPressed: (){
                          //print('加快启动');
                          Application.router.navigateTo(context, Routes.map3node_join_contract_page + "?pageType=${Map3NodeCreateContractPage.CONTRACT_PAGE_TYPE_JOIN}" + "&contractId=${model.id}");
                        },
                        child: Text("加快启动", style: TextStyle(fontSize: 12)),
                      ),
                      Spacer(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  */

}

enum ContractState { PENDING, Running, Expired, Withdrawal, FailRun }

ContractState enumContractStateFromString(String fruit) {
  fruit = 'ContractState.$fruit';
  return ContractState.values.firstWhere((f)=> f.toString() == fruit, orElse: () => null);
}
