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
import 'package:titan/src/pages/node/model/map3_node_util.dart';
import 'package:titan/src/pages/node/model/node_item.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/routes/route_util.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/utils.dart';
import 'package:titan/src/widget/all_page_state/all_page_state.dart' as all_page_state;
import 'package:titan/src/widget/all_page_state/all_page_state_container.dart';

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
  all_page_state.AllPageState _currentState = all_page_state.LoadingState();

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

  Widget _pageWidget(BuildContext context) {
    if (_currentState != null) {
      return AllPageStateContainer(_currentState, () {
        setState(() {
          _currentState = all_page_state.LoadingState();
        });

        //_loadData();
      });
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
      color: DefaultColors.colorf5f5f5,
      child: LoadDataContainer(
        bloc: loadDataBloc,
        onLoadData: _loadData,
        onRefresh: _loadData,
        onLoadingMore: _loadMoreData,
        child: ListView.separated(
            itemBuilder: (context, index) {
              return _buildInfoItem(_dataArray[index]);
            },
            separatorBuilder: (context, index) {
              return Container(
                height: 8,
                color: DefaultColors.colorf5f5f5,
              );
            },
            itemCount: _dataArray.length),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: _pageWidget(context),
    );
  }

  Widget _buildInfoItem(ContractNodeItem contractNodeItem) {
    String address = shortBlockChainAddress(contractNodeItem.owner);
    var dateDesc = "";
    var amountPre = "";
    var amount = "";
    var hyn = "";
    var state = enumContractStateFromString(contractNodeItem.state);
    //print('[contract] _buildInfoItem, stateString:${contractNodeItem.state},state:$state');

    switch (state) {
      case ContractState.PRE_CREATE:
        dateDesc = S.of(context).task_pending;
        break;

      case ContractState.PENDING:
        dateDesc = S.of(context).time_left + FormatUtil.timeString(context, contractNodeItem.launcherSecondsLeft);
        amountPre = S.of(context).remain;
        amount = FormatUtil.amountToString(contractNodeItem.remainDelegation);
        hyn = "HYN";
        break;

      case ContractState.ACTIVE:
//        dateDesc = S.of(context).remain_day(contractNodeItem.expectDueDay);
        dateDesc = FormatUtil.timeString(context, contractNodeItem.completeSecondsLeft.toDouble());
        break;

      case ContractState.DUE:
        dateDesc = S.of(context).be_expired;
        break;

      case ContractState.CANCELLED:
      case ContractState.FAIL:
        dateDesc = S.of(context).overdue_start_failed;
        break;

      case ContractState.DUE_COMPLETED:
        dateDesc = S.of(context).be_expired;
        break;

      case ContractState.CANCELLED_COMPLETED:
        dateDesc = S.of(context).overdue_start_failed;
        break;

      default:
        break;
    }

    return InkWell(
      onTap: () {
        _pushDetailAction(contractNodeItem);
      },
      child: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 13, top: 7, bottom: 7),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text("${contractNodeItem.ownerName}", style: TextStyles.textCcc000000S14),
                  Expanded(child: Text(" $address", style: TextStyles.textC9b9b9bS12)),
                  Text(
                    dateDesc,
                    style: TextStyle(fontSize: 12, color: Map3NodeUtil.stateColor(state)),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 16),
                child: Divider(height: 1, color: DefaultColors.color2277869e),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(4.0)),
                      border: Border.all(color: Color(0x22B7B7B7), width: 1),
                    ),
                    child: Image.asset(
                      "res/drawable/ic_map3_node_item_contract.png",
                      width: 42,
                      height: 42,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(
                    width: 6,
                  ),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Expanded(
                                child:
                                    Text("${contractNodeItem.contract.nodeName}", style: TextStyles.textCcc000000S14))
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 3.0),
                          child: Row(
                            children: <Widget>[
                              Text(
                                  S.of(context).highest +
                                      " ${FormatUtil.formatTenThousandNoUnit(contractNodeItem.contract.minTotalDelegation)}" +
                                      S.of(context).ten_thousand,
                                  style: TextStyles.textC99000000S10,
                                  maxLines: 1,
                                  softWrap: true),
                              Text("  |  ", style: TextStyles.textC9b9b9bS12),
                              Text(S.of(context).n_day(contractNodeItem.contract.duration.toString()),
                                  style: TextStyles.textC99000000S10)
                            ],
                          ),
                        ),
                        Text("${FormatUtil.formatDate(contractNodeItem.instanceStartTime)}",
                            style: TextStyles.textCfffS12),
                      ],
                    ),
                  ),
                  Column(
                    children: <Widget>[
                      Text("${FormatUtil.formatPercent(contractNodeItem.contract.annualizedYield)}",
                          style: TextStyles.textCff4c3bS18),
                      Text(S.of(context).annualized_rewards, style: TextStyles.textC99000000S10)
                    ],
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 9, bottom: 9),
                child: Divider(height: 1, color: DefaultColors.color2277869e),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: RichText(
                      text: TextSpan(text: amountPre, style: TextStyles.textC9b9b9bS12, children: <TextSpan>[
                        TextSpan(text: amount, style: TextStyles.textC7c5b00S12),
                        TextSpan(text: hyn, style: TextStyles.textC9b9b9bS12),
                      ]),
                    ),
                  ),
                  SizedBox(
                    height: 28,
                    width: 84,
                    child: FlatButton(
                      color: DefaultColors.colorffdb58,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      onPressed: () {
                        _pushDetailAction(contractNodeItem);
                      },
                      child: Text(S.of(context).view_contract, style: TextStyles.textC906b00S13),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  _pushDetailAction(ContractNodeItem contractNodeItem) {
    var currentRouteName = Uri.encodeComponent(Routes.map3node_contract_detail_page);
    Application.router.navigateTo(context,
        Routes.map3node_contract_detail_page + "?entryRouteName=$currentRouteName&contractId=${contractNodeItem.id}");
  }

  _loadMoreData() async {
    List<ContractNodeItem> dataList = [];
    if (widget.title.contains(S.of(context).launch)) {
      List<ContractNodeItem> createContractList = await api.getMyCreateNodeContract(page: _currentPage);
      dataList = createContractList;
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
    try {
      _currentPage = 0;

      List<ContractNodeItem> dataList = [];
      if (widget.title.contains(S.of(context).launch)) {
        List<ContractNodeItem> createContractList = await api.getMyCreateNodeContract();
        dataList = createContractList;
      } else {
        List<ContractNodeItem> joinContractList = await api.getMyJoinNodeContract();
        dataList = joinContractList;
      }

      if (dataList.length == 0) {
        loadDataBloc.add(LoadEmptyEvent());
      } else {
        _currentPage++;
        loadDataBloc.add(RefreshSuccessEvent());

        setState(() {
          if (mounted) {
            _dataArray = dataList;
          }
        });
      }

      Future.delayed(Duration(seconds: 1), () {
        setState(() {
          _currentState = null;
        });
      });
    } catch (e) {
      setState(() {
        _currentState = all_page_state.LoadFailState();
      });
    }
  }
}
