import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/components/quotes/model.dart';
import 'package:titan/src/pages/market/model/asset_history.dart';

class ExchangeTransferHistoryDetailPage extends StatefulWidget {
  final AssetHistory _assetHistory;

  ExchangeTransferHistoryDetailPage(
    this._assetHistory,
  );

  @override
  State<StatefulWidget> createState() {
    return _ExchangeTransferHistoryDetailPageState();
  }
}

class _ExchangeTransferHistoryDetailPageState
    extends BaseState<ExchangeTransferHistoryDetailPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void onCreated() {
    // TODO: implement onCreated
    super.onCreated();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          centerTitle: true,
          iconTheme: IconThemeData(
            color: Colors.black,
          ),
          title: Text(
            '详情',
            style: TextStyle(color: Colors.black, fontSize: 18),
          )),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  '类型',
                  style: TextStyle(color: HexColor('#FF999999')),
                ),
                Spacer(),
                Text(widget._assetHistory.name == 'withdraw'
                    ? '钱包到交易账户'
                    : '交易账户到钱包')
              ],
            ),
            Divider(),
            Row(
              children: <Widget>[
                Text(
                  '数量',
                  style: TextStyle(color: HexColor('#FF999999')),
                ),
                Spacer(),
                Text('${widget._assetHistory.balance}')
              ],
            ),
          ],
        ),
      ),
    );
  }
}
