import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/pages/market/order/entity/order.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/widget/loading_button/click_loading_button.dart';

class OrderItem extends StatefulWidget {
  final Order _order;
  final Function revokeOrder;

  OrderItem(
    this._order, {
    this.revokeOrder,
  });

  @override
  State<StatefulWidget> createState() {
    return OrderItemState();
  }
}

class OrderItemState extends State<OrderItem> {
  bool _isBuy = true;
  var _base = '';
  var _quote = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _isBuy = widget._order.side == '1';
    if (widget._order.market.split('/').length == 2) {
      _base = widget._order.market.split('/')[0];
      _quote = widget._order.market.split('/')[1];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 16.0,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 16.0,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                RichText(
                  text: TextSpan(children: [
                    TextSpan(
                        text: _isBuy ? "买入 " : "卖出 ",
                        style: TextStyle(
                          fontSize: 16,
                          color: widget._order.side == '1'
                              ? HexColor("#53AE86")
                              : HexColor("#CC5858"),
                        )),
                    TextSpan(
                        text: widget._order.market,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ))
                  ]),
                ),
                SizedBox(
                  width: 8.0,
                ),
                Text(
                  "${FormatUtil.formatMarketOrderDate(int.parse(widget._order.ctime))}",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            Spacer(),
            _orderStatus()
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 16.0,
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  child: Row(
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            S.of(context).price_market(_quote),
                            style: TextStyle(
                              color: DefaultColors.color999,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(
                            height: 8.0,
                          ),
                          Text(
                            "${Decimal.parse(widget._order.price ?? '0')}",
                            style: TextStyle(
                                color: DefaultColors.color333,
                                fontWeight: FontWeight.w500,
                                fontSize: 12),
                          ),
                        ],
                      ),
                      Spacer()
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Align(
                  alignment: Alignment.center,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        S.of(context).count_market(_base),
                        style: TextStyle(
                          color: DefaultColors.color999,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(
                        height: 8.0,
                      ),
                      Text(
                        "${Decimal.parse(widget._order.amount ?? '0')}",
                        style: TextStyle(
                            color: DefaultColors.color333,
                            fontWeight: FontWeight.w500,
                            fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      S.of(context).actual_transaction_market(_base),
                      style: TextStyle(
                        color: DefaultColors.color999,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Row(
                      children: <Widget>[
                        Spacer(),
                        Text(
                          "${Decimal.parse(widget._order.amountDeal ?? '0')}",
                          style: TextStyle(
                            color: DefaultColors.color333,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        SizedBox(
          height: 4.0,
        ),
        _divider()
      ],
    );
  }

  _orderStatus() {
    if (widget._order.status == '0' || widget._order.status == '1') {
      return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ClickLoadingButton(
            S.of(context).revoke,
            () async {
              await widget.revokeOrder(widget._order);
              setState(() {});
            },
            height: 27,
            width: 60,
            fontSize: 12,
            fontColor: HexColor('#1F81FF'),
            btnColor: HexColor('#F2F2F2'),
            radius: 3,
          ));
      /*child: Container(
          width: 60,
          height: 27,
          width: 60,
          fontSize: 12,
          fontColor: HexColor('#1F81FF'),
          btnColor: HexColor('#F2F2F2'),
          radius: 3,
        ),
      );*/
    } else if (widget._order.status == '-1') {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(
          S.of(context).revoking,
          style: TextStyle(
            color: DefaultColors.color999,
          ),
        ),
      );
    } else if (widget._order.status == '2') {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(
          S.of(context).completed,
          style: TextStyle(
            color: DefaultColors.color999,
          ),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(
          S.of(context).has_revoked,
          style: TextStyle(
            color: DefaultColors.color999,
          ),
        ),
      );
    }
  }

  _divider() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16.0,
      ),
      child: Divider(
        height: 2,
      ),
    );
  }
}
