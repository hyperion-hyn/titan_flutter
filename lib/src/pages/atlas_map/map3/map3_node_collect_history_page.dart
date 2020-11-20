import 'dart:async';
import 'package:flutter/material.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/data_list_state.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/wallet/model/hyn_transfer_history.dart';
import 'package:titan/src/pages/wallet/model/transtion_detail_vo.dart';
import 'package:titan/src/utils/format_util.dart';

class Map3NodeCollectHistoryPage extends StatefulWidget {
  Map3NodeCollectHistoryPage();

  @override
  State<StatefulWidget> createState() {
    return _Map3NodeCollectHistoryState();
  }
}

class _Map3NodeCollectHistoryState extends DataListState<Map3NodeCollectHistoryPage> {
  AtlasApi api = AtlasApi();
  StreamSubscription _eventBusSubscription;
  var _address = "";

  @override
  void initState() {
    super.initState();

    setupData();
  }

  setupData() async {
    var activatedWallet = WalletInheritedModel.of(Keys.rootKey.currentContext)?.activatedWallet;
    _address = activatedWallet?.wallet?.getEthAccount()?.address ?? "";
  }

  @override
  void postFrameCallBackAfterInitState() {
    loadDataBloc.add(LoadingEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: BaseAppBar(
        baseTitle: '提取记录',
      ),
      body: LoadDataContainer(
        bloc: loadDataBloc,
        onLoadData: onWidgetLoadDataCallback,
        onRefresh: onWidgetRefreshCallback,
        onLoadingMore: onWidgetLoadingMoreCallback,
        child: ListView.separated(
            physics: ClampingScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              return _buildItem(item: dataList[index]);
            },
            separatorBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Divider(
                  thickness: 0.5,
                  color: Colors.black12,
                ),
              );
            },
            itemCount: dataList.length),
      ),
    );
  }

  Widget _buildItem({HynTransferHistory item}) {
    var title = '';
    if (item.type == 5) {
      title = '提取Atlas奖励到Map3';
    } else if (item.type == 11) {
      title = '提取Map3奖励到钱包';
    }
    TransactionDetailVo transactionDetail = TransactionDetailVo.fromHynTransferHistory(item, 0, "HYN");

    //transactionDetail = null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 12, color: HexColor("#333333")),
                  ),
                ),
                SizedBox(
                  child: Container(
                    child: Text(
                      '+ ${FormatUtil.formatPrice(double.parse(transactionDetail.getMap3RewardAmount()))} HYN',
                      style: TextStyle(
                        fontSize: 16,
                        color: HexColor("#333333"),
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  width: 180,
                )
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  //time,
                  Const.DATE_FORMAT.format(DateTime.fromMillisecondsSinceEpoch(transactionDetail.time)),
                  style: TextStyle(fontSize: 12, color: HexColor("#9B9B9B")),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Future<List> onLoadData(int page) async {
    var list = await api.getRewardTxsList(_address, page: page+1);
    return list;
  }

  @override
  void dispose() {
    _eventBusSubscription?.cancel();
    loadDataBloc.close();
    super.dispose();
  }
}
