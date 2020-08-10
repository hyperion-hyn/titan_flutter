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
  final String market;
  final Function revokeOrder;

  OrderItem(this._order, {this.revokeOrder, this.market = 'HYN/USDT'});

  @override
  State<StatefulWidget> createState() {
    return OrderItemState();
  }
}

class OrderItemState extends State<OrderItem> {
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
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  widget._order.side == ExchangeType.BUY.toString()
                      ? '买入'
                      : '卖出',
                  style: TextStyle(
                    fontSize: 16,
                    color: widget._order.side == ExchangeType.BUY.toString()
                        ? HexColor("#53AE86")
                        : HexColor("#CC5858"),
                  ),
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
                            '价格(${widget.market.split("/")[1]})',
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
                        '数量(${widget.market.split('/')[0]})',
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
                      '实际成交(${widget.market.split('/')[0]})',
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
        child: ClickLoadingButton('撤销',() async {
          await widget.revokeOrder(widget._order);
        },height: 27,width: 60,fontSize: 12,fontColor: HexColor('#1F81FF'),btnColor: HexColor('#F2F2F2'),radius: 3,),
        /*child: Container(
          width: 60,
          height: 27,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(3.0)),
              color: HexColor('#F2F2F2')),
          child: FlatButton(
            padding: EdgeInsets.only(left: 13.0, right: 13, bottom: 2),
            textColor: HexColor('#FF1F81FF'),
            child: Text(
              '撤销',
              style: TextStyle(
                fontSize: 12,
              ),
            ),
            onPressed: () {
              widget.revokeOrder(widget._order);
            },
          ),
        ),*/
      );
    } else if (widget._order.status == '2') {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(
          '已完成',
          style: TextStyle(
            color: DefaultColors.color999,
          ),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(
          '已撤单',
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
