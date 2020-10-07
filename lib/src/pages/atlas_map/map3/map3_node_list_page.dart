import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_info_entity.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/widget/all_page_state/all_page_state.dart' as all_page_state;
import 'package:titan/src/widget/all_page_state/all_page_state_container.dart';
import 'map3_node_public_widget.dart';

class Map3NodeListPage extends StatefulWidget {
  final MyContractModel model;
  Map3NodeListPage(this.model);

  @override
  State<StatefulWidget> createState() {
    return _Map3NodeListState();
  }
}

class _Map3NodeListState extends State<Map3NodeListPage> {
  List<Map3InfoEntity> _dataArray = [];
  LoadDataBloc loadDataBloc = LoadDataBloc();
  var _currentPage = 0;
  int _pageSize = 30;
  Wallet _wallet;
  AtlasApi api = AtlasApi();

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
      appBar: BaseAppBar(
        baseTitle: widget.model.name,
      ),
      body: _pageWidget(context),
    );
  }

  _loadMoreData() async {
    List<Map3InfoEntity> dataList = await api.getMap3NodeList(
      'address',
      page: _currentPage + 1,
      size: _pageSize,
    );

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

      List<Map3InfoEntity> dataList = await api.getMap3NodeList(
        'address',
        page: _currentPage + 1,
        size: _pageSize,
      );

      switch (widget.model.type) {
        case MyContractType.join:
          break;

        case MyContractType.create:
          break;

        default:
          break;
      }

      // todo: test_jison_0813
      /*
      if (_dataArray.isEmpty) {
        for (int i = 0; i < 3; i++) {
          Map3InfoEntity item = Map3InfoEntity.onlyId(i);
          dataList.add(item);
          dataList.add(item);
          dataList.add(item);
        }
      }*/

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

class MyContractModel {
  String name;
  MyContractType type;
  MyContractModel(this.name, this.type);
}

enum MyContractType {
  join,
  create,
  active,
}
