import 'package:flutter/material.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/pages/market/balances_page.dart';
import 'package:titan/src/pages/market/order/item_order.dart';
import 'package:titan/src/pages/market/order/order_mangement_page.dart';
import 'package:titan/src/plugins/wallet/token.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/click_oval_button.dart';
import 'package:titan/src/widget/click_oval_icon_button.dart';

import '../order/entity/order_entity.dart';

class ExchangePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ExchangePageState();
  }
}

class _ExchangePageState extends State<ExchangePage> {
  var _selectedCoin = 'usdt';
  var _exchangeType = ExchangeType.SELL;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          _banner(),
          _exchange(),
          _openOrderListWidget(),
          Spacer(),
          _bottom()
        ],
      ),
    );
  }

  _banner() {
    return Container(
      color: HexColor('#141FB9C7'),
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Icon(
                Icons.hearing,
                size: 20,
              ),
            ),
            Expanded(
              child: Text(
                '由于网络拥堵，近期闪兑交易矿工费较高',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
              ),
            )
          ],
        ),
      ),
    );
  }

  _exchange() {
    return Padding(
      padding: EdgeInsets.all(4.0),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => BalancesPage()));
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 8.0,
                  ),
                  child: Image.asset(
                    'res/drawable/ic_market_account.png',
                    width: 15,
                    height: 15,
                  ),
                ),
                Text(
                  '交易账户',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 17,
                  ),
                ),
                Spacer(),
                Text.rich(
                  TextSpan(children: [
                    TextSpan(text: '******'),
                    TextSpan(
                        text: '(CNY)',
                        style: TextStyle(color: Colors.grey, fontSize: 13))
                  ]),
                  textAlign: TextAlign.center,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Material(
              borderRadius: BorderRadius.circular(16),
              elevation: 5.0,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  children: <Widget>[
                    _exchangeItem(_exchangeType == ExchangeType.SELL),
                    Expanded(
                      flex: 1,
                      child: IconButton(
                        icon: Image.asset(
                          'res/drawable/market_exchange_btn_icon.png',
                          width: 25,
                          height: 25,
                        ),
                        onPressed: () {
                          setState(() {
                            _exchangeType = _exchangeType == ExchangeType.BUY
                                ? ExchangeType.SELL
                                : ExchangeType.BUY;
                          });
                        },
                      ),
                    ),
                    _exchangeItem(_exchangeType == ExchangeType.BUY),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '汇率',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
                Text(
                  '1HYN = 242.8880303 USDT',
                ),
                Spacer(),
                ClickOvalIconButton(
                  '交易',
                  () {},
                  width: 80,
                  child: Icon(
                    Icons.arrow_forward,
                    size: 15,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.all(Radius.circular(4.0))),
            margin: EdgeInsets.all(8.0),
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Text(
                  '24H 量 ¥8.89M',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                Spacer(),
                Text(
                  '最新兑换0.8HYN — 194.20USDT',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  _exchangeItem(bool isHynCoin) {
    return isHynCoin
        ? Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: _coinItem(
                'HYN',
                'res/drawable/hyn_logo.png',
                false,
              ),
            ),
          )
        : Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: _coinList(),
            ),
          );
  }

  _coinItem(
    String name,
    String logoPath,
    bool isOnlinePath,
  ) {
    return Row(
      children: <Widget>[
        Container(
          alignment: Alignment.center,
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            border: Border.all(color: Color(0xFF9B9B9B), width: 0),
            shape: BoxShape.circle,
          ),
          child: isOnlinePath
              ? FadeInImage.assetNetwork(
                  placeholder: 'res/drawable/img_placeholder_circle.png',
                  image: logoPath,
                  fit: BoxFit.cover,
                )
              : Image.asset(logoPath),
        ),
        SizedBox(
          width: 8.0,
        ),
        Text(
          name,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 22,
          ),
        )
      ],
    );
  }

  _coinList() {
    List<DropdownMenuItem> availableCoinItemList = List();
    availableCoinItemList.add(
      DropdownMenuItem(
        value: 'usdt',
        child: _coinItem(
          'USDT',
          'res/drawable/usdt_logo.png',
          false,
        ),
      ),
    );
    availableCoinItemList.add(
      DropdownMenuItem(
        value: 'eth',
        child: _coinItem(
          'ETH',
          'res/drawable/eth_logo.png',
          false,
        ),
      ),
    );

    return DropdownButtonHideUnderline(
      child: DropdownButton(
        onChanged: (value) {
          setState(() {
            _selectedCoin = value;
          });
        },
        value: _selectedCoin,
        items: availableCoinItemList,
      ),
    );
  }

  _openOrderListWidget() {
    return Column(
      children: [
        Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                '当前委托',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            Spacer(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => OrderManagementPage()));
                },
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.table_chart,
                      color: Colors.grey,
                      size: 20,
                    ),
                    SizedBox(
                      width: 4.0,
                    ),
                    Text(
                      '全部',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Divider(
            height: 2,
            thickness: 1.0,
          ),
        ),
        _openOrderListView(),
      ],
    );
  }

  _openOrderListView() {
    return Column(
      children: List.generate(2, (index) => OrderItem(ExchangeType.BUY)),
    );
  }

  _bottom() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          Spacer(),
          Image.asset(
            'res/drawable/manwu_logo.png',
            width: 30,
            height: 30,
          ),
          SizedBox(
            width: 8.0,
          ),
          Text(
            '经过权威安全认证',
            style: TextStyle(color: HexColor('#FF999999')),
          ),
          Spacer(),
        ],
      ),
    );
  }
}
