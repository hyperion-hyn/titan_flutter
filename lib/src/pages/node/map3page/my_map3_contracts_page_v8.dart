import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/node/api/node_api.dart';
import 'package:titan/src/pages/node/map3page/map3_node_page.dart';
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

class MyContractsPageV8 extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyContractsStateV8();
  }
}

class _MyContractsStateV8 extends State<MyContractsPageV8> {
  List<MyContractModelV8> _contractTypeModels;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_contractTypeModels?.isEmpty ?? true) {
      _contractTypeModels = [
        MyContractModelV8(S.of(context).my_initiated_map_contract, MyContractTypeV8.create),
        MyContractModelV8(S.of(context).my_join_map_contract, MyContractTypeV8.join)
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: BaseAppBar(
          baseTitle: "旧版Map3",
        ),
        body: Scaffold(
          appBar: new PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: new Container(
              width: double.infinity,
              height: 50.0,
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 10,
                    child: TabBar(
                      labelColor: HexColor('#FF228BA1'),
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      indicatorSize: TabBarIndicatorSize.label,
                      indicatorColor: HexColor('#FF228BA1'),
                      indicatorWeight: 2,
                      indicatorPadding: EdgeInsets.only(
                        bottom: 2,
                        right: 12,
                        left: 12,
                      ),
                      unselectedLabelColor: HexColor("#FF333333"),
                      tabs: [
                        Tab(
                          child: Text(
                            '我发起的',
                          ),
                        ),
                        Tab(
                          child: Text(
                            '我参与的',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: Container(),
                  )
                ],
              ),
            ),
          ),
          body: TabBarView(
            children: _contractTypeModels.map((model) => MyMap3ContractPage(model)).toList(),
          ),
        ),
      ),
    );
  }
}

class MyMap3ContractPage extends StatefulWidget {
  final MyContractModelV8 model;
  MyMap3ContractPage(this.model);

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
              return getMap3NodeWaitItem(context, _dataArray[index]);
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
    if (widget.model.type != MyContractTypeV8.active) {
      return _pageWidget(context);
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        title: Text(
          widget.model.name,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: _pageWidget(context),
    );
  }

  _loadMoreData() async {
    List<ContractNodeItem> dataList = [];
    if (widget.model.type == MyContractTypeV8.create) {
      List<ContractNodeItem> createContractList = await api.getMyCreateNodeContract(page: _currentPage);
      dataList = createContractList;
    } else if (widget.model.type == MyContractTypeV8.join) {
      List<ContractNodeItem> joinContractList = await api.getMyJoinNodeContract(page: _currentPage);
      dataList = joinContractList;
    } else {
      List<ContractNodeItem> activeContractList = await api.getContractActiveList(page: _currentPage);
      dataList = activeContractList;
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
      switch (widget.model.type) {
        case MyContractTypeV8.join:
          List<ContractNodeItem> joinContractList = await api.getMyJoinNodeContract();
          dataList = joinContractList;
          break;

        case MyContractTypeV8.create:
          List<ContractNodeItem> createContractList = await api.getMyCreateNodeContract();
          dataList = createContractList;
          break;

        default:
          List<ContractNodeItem> activeContractList = await api.getContractActiveList();
          dataList = activeContractList;
          break;
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

enum MyContractTypeV8 {
  join,
  create,
  active,
}

class MyContractModelV8 {
  String name;
  MyContractTypeV8 type;
  MyContractModelV8(this.name, this.type);
}
