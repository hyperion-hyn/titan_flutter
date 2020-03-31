import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/pages/node/api/node_api.dart';
import 'package:titan/src/pages/node/model/contract_node_item.dart';
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

  var api = NodeApi();

  @override
  void initState() {
    super.initState();

    _loadData();
  }

  @override
  void dispose() {
    loadDataBloc.close();
    super.dispose();
  }

  _loadData() async {

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
      loadDataBloc.add(RefreshSuccessEvent());
    }

    setState(() {
      _dataArray = dataList;
    });

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
        padding: const EdgeInsets.all(8),
        color: HexColor('#05095F'),
        child: LoadDataContainer(
          bloc: loadDataBloc,
          onRefresh: () async {
            _loadData();
          },
          child: ListView.separated(
              itemBuilder: (context, index) {
                return buildInfoItem(_dataArray[index]);
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

  Widget buildInfoItem(ContractNodeItem model) {
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
                  /*child: FadeInImage.assetNetwork(
                    image: "",
                    //placeholder: 'res/drawable/img_placeholder.jpg',
                    placeholder: 'res/drawable/ic_map3_node_item.png',
                    width: 55,
                    height: 55,
                    fit: BoxFit.cover,
                  ),*/
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
                      Text("发起账户 ${model.ownerName} ${model.owner}", style: TextStyle(fontSize: 13, color: HexColor('#FFFFFF'))),
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
                            print('[点击查看收益] id:${model.id}');
                            Navigator.push(context, MaterialPageRoute(builder: (context) => NodeContractDetailPage(model)));
                          //}
                        },
                        child:
                        (model.state == ContractState.PENDING || model.state ==  ContractState.FailRun)?

                        Text.rich(TextSpan(
                            children: [
                              TextSpan(
                                  text: "还差",
                                  style: TextStyle(fontSize: 12, color: HexColor('#FFFFFF'))
                              ),
                              TextSpan(
                                text: "1000",
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
                      if (model.state == ContractState.PENDING) FlatButton(
                        padding: EdgeInsets.symmetric(horizontal: 4,vertical: 2),
                        color: Colors.white,
//                        highlightColor: Colors.black,
//                        splashColor: Colors.white10,
                        textColor: HexColor('#3C99FA'),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        onPressed: (){
                          print('加快启动');
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
}

enum ContractState { PENDING, Running, Expired, Withdrawal, FailRun }

ContractState enumContractStateFromString(String fruit) {
  fruit = 'ContractState.$fruit';
  return ContractState.values.firstWhere((f)=> f.toString() == fruit, orElse: () => null);
}
