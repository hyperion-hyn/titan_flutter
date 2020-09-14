import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/components/quotes/model.dart';
import 'package:titan/src/pages/market/model/asset_history.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/utile_ui.dart';

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
            S.of(context).exchange_detail,
            style: TextStyle(color: Colors.black, fontSize: 18),
          )),
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              _item(
                S.of(context).exchange_type,
                Text(
                  widget._assetHistory.getTypeText(),
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
              ),
              _item(
                S.of(context).exchange_amount,
                Text.rich(TextSpan(children: [
                  TextSpan(
                      text: '${Decimal.parse(widget._assetHistory.balance)}',
                      style: TextStyle(
                          color: DefaultColors.color333, fontSize: 14)),
                  TextSpan(
                      text: ' (${widget._assetHistory.type})',
                      style: TextStyle(
                          color: DefaultColors.color999, fontSize: 12))
                ])),
              ),
              _item(
                S.of(context).exchange_network_fee,
                Text.rich(TextSpan(children: [
                  TextSpan(
                      text: '${Decimal.parse(widget._assetHistory.fee)}',
                      style: TextStyle(
                        fontSize: 14,
                      )),
                  TextSpan(
                      text:
                          ' (${widget._assetHistory.name == 'withdraw' ? widget._assetHistory.type : 'ETH'})',
                      style: TextStyle(
                        color: DefaultColors.color999,
                        fontSize: 12,
                      ))
                ])),
              ),
              _item(
                S.of(context).exchange_transfer_history_detail_time,
                Text(
                  FormatUtil.formatUTCDateStr(widget._assetHistory.ctime),
                  style: TextStyle(fontSize: 14),
                ),
              ),
              _item(
                '${S.of(context).blockchain_transaction}ID',
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      widget._assetHistory.txId,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    InkWell(
                      onTap: () {
                        Clipboard.setData(
                          ClipboardData(text: widget._assetHistory.txId),
                        );
                        UiUtil.toast(S.of(context).copyed);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Image.asset(
                            'res/drawable/ic_copy.png',
                            height: 20,
                            width: 20,
                          ),
                          SizedBox(
                            width: 8.0,
                          ),
                          Text(
                            S.of(context).copy,
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  _item(String title, Widget child) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(
                  color: HexColor('#FF999999'),
                  fontSize: 14,
                ),
              ),
              Expanded(
                  child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                    padding: EdgeInsets.only(
                      left: 48,
                    ),
                    child: child),
              ))
            ],
          ),
        ),
        _divider()
      ],
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1.0,
        color: HexColor('#FFF2F2F2'),
      ),
    );
  }
}
