import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';

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
  List<ContractStatsModel> _dataArray;
  LoadDataBloc loadDataBloc = LoadDataBloc();

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


  _loadData() {
    List<ContractStatsModel> list = [];
    for (var i = 0; i < 5; i++) {
      ContractStatsModel model = ContractStatsModel(
          status: ContractStatus.values[i], statusInfo: _getStatusInfo(i), resultInfo: _getResultInfo(i));
      list.add(model);
    }
    _dataArray = list;
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
          onRefresh: () async {},
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
              itemCount: ContractStatus.values.length),
        ),
      ),
    );
  }

  HexColor _getStatusColor(ContractStatus status) {
    var statusColor = HexColor('#EED097');

    switch (status) {
      case ContractStatus.SuspendRun:
        statusColor = HexColor('#EED097');
        break;

      case ContractStatus.Running:
        statusColor = HexColor('#3FF78C');
        break;

      case ContractStatus.Expired:
        statusColor = HexColor('#867B7B');
        break;

      case ContractStatus.Withdrawal:
        statusColor = HexColor('#867B7B');
        break;

      case ContractStatus.FailRun:
        statusColor = HexColor('#F22504');
        break;

      default:
        break;
    }
    return statusColor;
  }

  String _getStatusInfo(int index) {
    var statusInfo = "还差1000HYN";

    var status = ContractStatus.values[index];
    switch (status) {
      case ContractStatus.SuspendRun:
        statusInfo = "剩下3天启动";
        break;

      case ContractStatus.Running:
        statusInfo = "已运行20天";
        break;

      case ContractStatus.Expired:
        statusInfo = "已到期";
        break;

      case ContractStatus.Withdrawal:
        statusInfo = "已提币";
        break;

      case ContractStatus.FailRun:
        statusInfo = "超期启动失败";
        break;

      default:
        break;
    }
    return statusInfo;
  }

  String _getResultInfo(int index) {
    var statusInfo = "还差1000HYN";

    var status = ContractStatus.values[index];
    switch (status) {
      case ContractStatus.SuspendRun:
        statusInfo = "还差1000HYN";
        break;

      case ContractStatus.Running:
        statusInfo = "剩下80天到期";
        break;

      case ContractStatus.Expired:
        statusInfo = "点击查看收益";
        break;

      case ContractStatus.Withdrawal:
        statusInfo = "合约完成";
        break;

      case ContractStatus.FailRun:
        statusInfo = "还差1000HYN";
        break;

      default:
        break;
    }
    return statusInfo;
  }

  Widget buildInfoItem(ContractStatsModel model) {
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
                  child: FadeInImage.assetNetwork(
                    image: "",
                    //placeholder: 'res/drawable/img_placeholder.jpg',
                    placeholder: 'res/drawable/ic_map3_node_item.png',
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
                      Text(model.title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: HexColor('#FFFFFF'))),
                      Spacer(),
                      Text(model.detail, style: TextStyle(fontSize: 13, color: HexColor('#FFFFFF'))),
                      Spacer(),
                      Text(
                        model.date,
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
                                  color: _getStatusColor(model.status),
                                  border: Border.all(color: Colors.white, width: 1.0)),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Text(model.statusInfo, style: TextStyle(fontSize: 12, color: HexColor('#FFFFFF'))),
                            ),
                          ],
                        ),
                      ),
                      Spacer(),
                      InkWell(
                        onTap: () {
                          if (model.status == ContractStatus.Expired) {
                            print('[点击查看收益]');
                            Navigator.push(context, MaterialPageRoute(builder: (context) => NodeContractDetailPage()));
                          }
                        },
                        child:
                        (model.status == ContractStatus.SuspendRun || model.status ==  ContractStatus.FailRun)?

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
                        )):
                        Text(model.resultInfo, style: TextStyle(fontSize: 12, color: HexColor('#FFFFFF'))) ,
                      ),
                      if (model.status == ContractStatus.SuspendRun) FlatButton(
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

enum ContractStatus { SuspendRun, Running, Expired, Withdrawal, FailRun }

class ContractStatsModel {
  String title;
  String detail;
  String date;
  ContractStatus status;
  String statusInfo;
  String resultInfo;

  ContractStatsModel(
      {title = "Map3节点（V0.8）",
      detail = "发起账户 Moo Oxfde...fdaff",
      date = "2020-10-20",
      status = ContractStatus.SuspendRun,
      statusInfo = "",
      resultInfo = ""}) {
    this.title = title;
    this.detail = detail;
    this.date = date;
    this.status = status;
    this.statusInfo = statusInfo;
    this.resultInfo = resultInfo;
  }
}
