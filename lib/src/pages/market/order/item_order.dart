import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/style/titan_sytle.dart';

import 'entity/order_entity.dart';

class OrderItem extends StatefulWidget {
  final OrderEntity _order;

  OrderItem(this._order);

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
          height: 8.0,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                  left: 16.0, top: 8.0, bottom: 8.0, right: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    widget._order.type == 0
                        ? "买入"
                        : "卖出",
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          widget._order.type == 0 ? HexColor("#53AE86") : HexColor("#CC5858"),
                    ),
                  ),
                  SizedBox(
                    width: 8.0,
                  ),
                  Text(
                    '10:37 06/11',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  )
                ],
              ),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                width: 50,
                height: 22,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(3.0)),
                  color: HexColor('#F2F2F2')
                ),
                child: FlatButton(
                  padding: EdgeInsets.only(left: 13.0,right: 13,bottom: 2),
                  textColor: HexColor('#FF1F81FF'),
                  child: Text(
                    '撤销',
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                  onPressed: () {},
                ),
              ),
            )
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  child: Row(
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            '价格(USDT)',
                            style: TextStyle(
                              color: DefaultColors.color999,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(
                            height: 4.0,
                          ),
                          Text(
                            '9090.42',
                            style: TextStyle(
                              color: DefaultColors.color333,
                                fontWeight: FontWeight.w500, fontSize: 12),
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
                      '数量(HYN)',
                      style: TextStyle(
                        color: DefaultColors.color999,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(
                      height: 4.0,
                    ),
                    Text(
                      '0.002',
                      style:
                          TextStyle(color:DefaultColors.color333,fontWeight: FontWeight.w500, fontSize: 12),
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
                      '实际成交(HYN)',
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
                          '0',
                          style: TextStyle(
                            color:DefaultColors.color333,
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