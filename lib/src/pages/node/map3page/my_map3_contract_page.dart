import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/node/api/node_api.dart';
import 'package:titan/src/pages/node/model/contract_node_item.dart';
import 'package:titan/src/pages/node/model/enum_state.dart';
import 'package:titan/src/pages/node/model/node_item.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/utils.dart';

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
  Wallet _wallet;

  var api = NodeApi();

  @override
  void initState() {
    super.initState();

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_wallet == null) {
      _wallet = WalletInheritedModel.of(context).activatedWallet?.wallet;

      loadDataBloc.add(LoadingEvent());
      _loadData();
    }
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

    // todo: test_jison_0411
   /*
   setState(() {
      if (mounted) {
        var item = NodeItem(1, "aaa", 1, "0", 0.0, 0.0, 0.0, 1, 0, 0.0, false, "0.5", "", "");
        var model = ContractNodeItem(
            1,
            item,
            "0xaaaaa",
            "bbbbbbb",
            "0",
            "0",
            "",
            "",
            "",
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            "",
            "ACTIVE"
        );
        _dataArray = [model];
      }
    });

    loadDataBloc.add(RefreshSuccessEvent());

    return
    */

    _currentPage = 0;

    List<ContractNodeItem> dataList = [];
    if (widget.title.contains("发起")) {
      List<ContractNodeItem> createContractList = await api.getMyCreateNodeContract(address: _wallet.getEthAccount().address);
      dataList  = createContractList;
    } else {
      List<ContractNodeItem> joinContractList = await api.getMyJoinNodeContract(address: _wallet.getEthAccount().address);
      dataList = joinContractList;
    }

    if (dataList.length == 0) {
      loadDataBloc.add(LoadEmptyEvent());
    } else {
      _currentPage ++;
      loadDataBloc.add(RefreshSuccessEvent());

      // todo: test_jison_0413
      /*if (dataList.length >= ContractState.values.length) {
        for (int i=0; i< ContractState.values.length; i++) {
          dataList[i].state = ContractState.values[i].toString().split(".").last;
        }
      }*/

      setState(() {
        if (mounted) {
          _dataArray = dataList;
        }
      });
    }

    print('[map3] widget.title:${widget.title}, _loadData, dataList.length:${dataList.length}');
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
          onLoadingMore: _loadMoreData,
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

      case ContractState.ACTIVE:
        statusColor = HexColor('#3FF78C');
        break;

      case ContractState.DUE:
        statusColor = HexColor('#867B7B');
        break;

      case ContractState.CANCELLED:
        statusColor = HexColor('#F22504');
        break;

      default:
        break;
    }
    return statusColor;
  }

  Widget _buildInfoItem(ContractNodeItem contractNodeItem) {
    String address = shortBlockChainAddress(contractNodeItem.owner);
    var dateDesc = "";
    var amountPre = "";
    var amount = "";
    var hyn = "HYN";
    var state = enumContractStateFromString(contractNodeItem.state);
    //print('[contract] _buildInfoItem, stateString:${contractNodeItem.state},state:$state');

    switch (state) {
      case ContractState.PENDING:
        dateDesc = "剩余时间：${contractNodeItem.remainDay}天";
        amountPre = "还差";
        amount = FormatUtil.amountToString(contractNodeItem.remainDelegation);
        hyn = "HYN";
        break;

      case ContractState.ACTIVE:
        dateDesc = "剩余${contractNodeItem.expectDueDay}天";
        amountPre = "可提取";
        amount = FormatUtil.amountToString("${contractNodeItem.contract.commission}");
        hyn = "HYN";
        break;

      case ContractState.DUE:
        dateDesc = "已到期";
        amountPre = "可提取";
        amount = FormatUtil.amountToString("${contractNodeItem.contract.commission}");
        hyn = "HYN";
        break;

      case ContractState.CANCELLED:
        dateDesc = "超期启动失败";
        amountPre = "";
        amount = "";
        hyn = "";
        break;

      case ContractState.DUE_COMPLETED:
        dateDesc = "已到期";
        amountPre = "";
        amount = "";
        hyn = "";
        break;

      case ContractState.CANCELLED_COMPLETED:
        dateDesc = "超期启动失败";
        amountPre = "";
        amount = "";
        hyn = "";
        break;

      default:
        break;
    }


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
                    child: Text(" $address",
                        style: TextStyles.textC9b9b9bS12)),
                Text(dateDesc, style: TextStyles.textC9b9b9bS12)
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
                        text: amountPre,
                        style: TextStyles.textC9b9b9bS12,
                        children: <TextSpan>[
                          TextSpan(
                              text: amount,
                              style: TextStyles.textC7c5b00S12),
                          TextSpan(
                              text: hyn,
                              style: TextStyles.textC9b9b9bS12),
                        ]),
                  ),
                ),
                SizedBox(
                  height: 28,
                  width: 84,
                  child: FlatButton(
                    color: DefaultColors.colorffdb58,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28)),
                    onPressed: (){
                      Application.router.navigateTo(context, Routes.map3node_contract_detail_page + "?contractId=${contractNodeItem.id}");
                    },
                    child: Text("查看合约", style: TextStyles.textC906b00S13),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

}
