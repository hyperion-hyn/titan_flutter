import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/pages/node/api/node_api.dart';
import 'package:titan/src/pages/node/map3page/map3_node_page.dart';
import 'package:titan/src/pages/node/model/contract_node_item.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/widget/all_page_state/all_page_state.dart' as all_page_state;
import 'package:titan/src/widget/all_page_state/all_page_state_container.dart';

class Map3NodeMyPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _Map3NodeMyState();
  }
}

class _Map3NodeMyState extends State<Map3NodeMyPage> with TickerProviderStateMixin {
  TabController _tabController;
  List<MyContractModel> _contractTypeModels;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_contractTypeModels?.isEmpty ?? true) {
      _contractTypeModels = [
        MyContractModel(S.of(context).my_initiated_map_contract, MyContractType.create),
        MyContractModel(S.of(context).my_join_map_contract, MyContractType.join)
      ];
      _tabController = TabController(length: _contractTypeModels.length, vsync: this);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        centerTitle: true,
        title: Text(
          S.of(context).my_contract,
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
          ),
        ),
      ),

      body: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: TabBar(
                      isScrollable: true,
                      //indicatorColor: Theme.of(context).primaryColor,
                      indicatorPadding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
                      indicatorColor: HexColor("#228BA1"),
                      indicatorWeight: 3,
                      controller: _tabController,
                      labelColor: Theme.of(context).primaryColor,
                      unselectedLabelColor: HexColor("#333333"),
                      indicatorSize: TabBarIndicatorSize.label,
                      tabs: _contractTypeModels
                          .map((MyContractModel model) => Tab(
                                child: Text(
                                  model.name,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: RefreshConfiguration.copyAncestor(
                enableLoadingWhenFailed: true,
                context: context,
                headerBuilder: () => WaterDropMaterialHeader(
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                footerTriggerDistance: 30.0,
                child: TabBarView(
                  controller: _tabController,
                  //physics: NeverScrollableScrollPhysics(),
                  children: _contractTypeModels.map((model) => MyMap3ContractPage(model)).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyMap3ContractPage extends StatefulWidget {
  final MyContractModel model;
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

      color: Colors.white,
      child: LoadDataContainer(
        bloc: loadDataBloc,
        onLoadData: _loadData,
        onRefresh: _loadData,
        onLoadingMore: _loadMoreData,
        child: ListView.builder(
            itemBuilder: (context, index) {
              return getMap3NodeWaitItem(context, _dataArray[index]);
            },

            itemCount: _dataArray.length),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.model.type != MyContractType.active) {
      return _pageWidget(context);
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        centerTitle: true,
        title: Text(
          widget.model.name,
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
          ),
        ),
      ),


      body: _pageWidget(context),
    );
  }

  _loadMoreData() async {
    List<ContractNodeItem> dataList = [];
    if (widget.model.type == MyContractType.create) {
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
      switch (widget.model.type) {
        case MyContractType.join:
          List<ContractNodeItem> joinContractList = await api.getMyJoinNodeContract();
          dataList = joinContractList;
          break;

        case MyContractType.create:
          List<ContractNodeItem> createContractList = await api.getMyCreateNodeContract();
          dataList = createContractList;
          break;

        default:
          List<ContractNodeItem> createContractList = await api.getContractActiveList();
          dataList = createContractList;
          break;
      }
      // todo: test_jison_0813
      if (_dataArray.isEmpty) {
        for (int i = 0; i < 3; i++) {
          ContractNodeItem item = ContractNodeItem.onlyNodeId(i);
          dataList.add(item);
          dataList.add(item);
          dataList.add(item);
        }
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

enum MyContractType {
  join,
  create,
  active,
}

class MyContractModel {
  String name;
  MyContractType type;
  MyContractModel(this.name, this.type);
}
