import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/pages/market/order/entity/order_detail.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';

import 'entity/order.dart';

class OrderDetailItem extends StatefulWidget {
  final OrderDetail _orderDetail;
  final String market;

  OrderDetailItem(
    this._orderDetail,
    this.market,
  );

  @override
  State<StatefulWidget> createState() {
    return OrderDetailItemState();
  }
}

class OrderDetailItemState extends State<OrderDetailItem> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: 16.0,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: RichText(
            text: TextSpan(children: [
              TextSpan(
                  text: widget._orderDetail.side == '1' ? "买入 " : "卖出 ",
                  style: TextStyle(
                    fontSize: 16,
                    color: widget._orderDetail.side == '1'
                        ? HexColor("#53AE86")
                        : HexColor("#CC5858"),
                  )),
              TextSpan(
                  text: widget.market,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ))
            ]),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 16.0,
          ),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '时间',
                          style: TextStyle(
                            color: DefaultColors.color999,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(
                          height: 4.0,
                        ),
                        Text(
                          FormatUtil.formatMarketOrderDate(
                            int.parse(widget._orderDetail.time),
                          ),
                          style: TextStyle(
                            color: DefaultColors.color333,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Row(
                        children: <Widget>[
                          SizedBox(
                            width: 16,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                '方式',
                                style: TextStyle(
                                  color: DefaultColors.color999,
                                  fontSize: 12,
                                ),
                              ),
                              SizedBox(
                                height: 4.0,
                              ),
                              Text(
                                '限价',
                                style: TextStyle(
                                  color: DefaultColors.color333,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ],
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
                          '成交价(${widget.market.split('/')[1]})',
                          style: TextStyle(
                            color: DefaultColors.color999,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(
                          height: 4.0,
                        ),
                        Row(
                          children: <Widget>[
                            Spacer(),
                            Text(
                              "${Decimal.parse(widget._orderDetail.price ?? '0')}",
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
              SizedBox(
                height: 8.0,
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '成交量(${widget.market.split("/")[0]})',
                          style: TextStyle(
                            color: DefaultColors.color999,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(
                          height: 4.0,
                        ),
                        Text(
                          "${Decimal.parse(widget._orderDetail.amount ?? '0')}",
                          style: TextStyle(
                              color: DefaultColors.color333,
                              fontWeight: FontWeight.w500,
                              fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Row(
                      children: <Widget>[
                        SizedBox(
                          width: 16,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              '成交额(${widget.market.split('/')[1]})',
                              style: TextStyle(
                                color: DefaultColors.color999,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(
                              height: 4.0,
                            ),
                            Text(
                              '${Decimal.parse(widget._orderDetail.turnover ?? '0')}',
                              style: TextStyle(
                                color: DefaultColors.color333,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          '手续费(${widget._orderDetail.side == '1' ? widget.market.split('/')[0] : widget.market.split('/')[1]})',
                          style: TextStyle(
                            color: DefaultColors.color999,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(
                          height: 4.0,
                        ),
                        Row(
                          children: <Widget>[
                            Spacer(),
                            Text(
                              "${Decimal.parse(widget._orderDetail.fee ?? '0')}",
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
