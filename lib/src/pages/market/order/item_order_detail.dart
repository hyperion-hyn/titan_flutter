import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/pages/market/order/entity/order_detail.dart';
import 'package:titan/src/style/titan_sytle.dart';

import 'entity/order.dart';

class OrderDetailItem extends StatefulWidget {
  final OrderDetail _orderDetail;
  final String market;

  OrderDetailItem(
    this._orderDetail, {
    this.market = 'HYN/USDT',
  });

  @override
  State<StatefulWidget> createState() {
    return OrderDetailItemState();
  }
}

class OrderDetailItemState extends State<OrderDetailItem> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 8.0,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                  left: 16.0, top: 8.0, bottom: 8.0, right: 8.0),
              child: Row(
                children: <Widget>[
                  Text(
                    true ? "买入" : "卖出",
                    style: TextStyle(
                      fontSize: 14,
                      color: true ? HexColor("#53AE86") : HexColor("#CC5858"),
                    ),
                  ),
                  Text(
                    widget.market,
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ),
          child: Column(
            children: <Widget>[
              Row(
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
                                '10:37 06/11',
                                style: TextStyle(
                                  color: DefaultColors.color333,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                          height: 4.0,
                        ),
                        Row(
                          children: <Widget>[
                            Spacer(),
                            Text(
                              "${widget._orderDetail.amount}",
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
                    child: Container(
                      child: Row(
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                '价格(${widget.market.split("/")[0]})',
                                style: TextStyle(
                                  color: DefaultColors.color999,
                                  fontSize: 12,
                                ),
                              ),
                              SizedBox(
                                height: 4.0,
                              ),
                              Text(
                                "${widget._orderDetail.price}",
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                          '${widget._orderDetail.amount != null && widget._orderDetail.price != null ? widget._orderDetail.amount * widget._orderDetail.price : null}',
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          '手续费(${widget._orderDetail.side == 1 ? widget.market.split('/')[0] : widget.market.split('/')[1]})',
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
                              "${widget._orderDetail.fee}",
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
