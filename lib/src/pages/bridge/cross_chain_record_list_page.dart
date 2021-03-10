import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/data_list_state.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_public_widget.dart';
import 'package:titan/src/pages/bridge/entity/cross_chain_record.dart';
import 'package:titan/src/pages/wallet/model/wallet_send_dialog_util.dart';
import 'package:titan/src/utils/log_util.dart';

class CrossChainRecordListPage extends StatefulWidget {
  CrossChainRecordListPage();

  @override
  State<StatefulWidget> createState() {
    return _CrossChainRecordListPageState();
  }
}

class _CrossChainRecordListPageState extends DataListState<CrossChainRecordListPage> {
  AtlasApi _atlasApi = AtlasApi();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(baseTitle: '跨链记录'),
      body: LoadDataContainer(
        bloc: loadDataBloc,
        onLoadData: onWidgetLoadDataCallback,
        onRefresh: onWidgetRefreshCallback,
        onLoadingMore: onWidgetLoadingMoreCallback,
        child: SingleChildScrollView(
          child: dataList.length > 1
              ? ListView.builder(
                  primary: false,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    if (index == 0) {
                      return SizedBox.shrink();
                    } else {
                      var record = dataList[index];
                      return _crossChainRecordItem(record);
                    }
                  },
                  itemCount: max<int>(0, dataList.length),
                )
              : Padding(
                  padding: const EdgeInsets.only(
                    top: 20,
                  ),
                  child: Container(
                    width: double.infinity,
                    child: emptyListWidget(
                      title: S.of(context).no_data,
                      isAdapter: false,
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  _crossChainRecordItem(CrossChainRecord record) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Text(record.symbol),
    );
  }

  @override
  Future<List<dynamic>> onLoadData(int page) async {
    var retList = [];
    try {
      // List<CrossChainRecord> recordList = await _atlasApi.getCrossChainRecord(
      //   WalletModelUtil.walletEthAddress,
      // );
      List<CrossChainRecord> recordList = List.generate(
          20, (index) => CrossChainRecord('HYN', '', '', '', '', '', '', '', '', 1, 1));
      retList.addAll(recordList);
    } catch (e) {
      LogUtil.toastException(e);
    }
    return retList;
  }
}
