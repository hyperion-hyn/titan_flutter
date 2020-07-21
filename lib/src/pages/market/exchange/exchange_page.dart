import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/env.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/exchange/exchange_component.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/pages/market/api/exchange_api.dart';
import 'package:titan/src/pages/market/balances_page.dart';
import 'package:titan/src/pages/market/exchange/bloc/exchange_bloc.dart';
import 'package:titan/src/pages/market/exchange/bloc/exchange_state.dart';
import 'package:titan/src/pages/market/exchange/exchange_auth_page.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/click_oval_icon_button.dart';

import '../quote/kline_detail_page.dart';
import '../order/entity/order_entity.dart';
import 'bloc/bloc.dart';

class ExchangePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ExchangePageState();
  }
}

class _ExchangePageState extends BaseState<ExchangePage> {
  var _selectedCoin = 'usdt';
  var _exchangeType = ExchangeType.SELL;
  ExchangeBloc _exchangeBloc = ExchangeBloc();
  ExchangeApi _exchangeApi = ExchangeApi();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _exchangeBloc.close();
  }

  @override
  void onCreated() {
    // TODO: implement onCreated
    super.onCreated();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ExchangeBloc, ExchangeState>(
      bloc: _exchangeBloc,
      listener: (context, state) {},
      child: BlocBuilder<ExchangeBloc, ExchangeState>(
        bloc: _exchangeBloc,
        builder: (context, state) {
          if (state is SwitchToAuthState) {
            return ExchangeAuthPage(_exchangeBloc);
          } else if (state is SwitchToContentState) {
            return _contentView();
          }
          return _contentView();
        },
      ),
    );
  }

  _contentView() {
    return Column(
      children: <Widget>[
        _banner(),
        _account(),
        _exchange(),
        _divider(),
        _quotesView(),
        _authorizedView()
      ],
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
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Material(
            borderRadius: BorderRadius.circular(16),
            elevation: 3.0,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 8.0,
              ),
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
          padding: const EdgeInsets.symmetric(
            vertical: 16.0,
            horizontal: 8.0,
          ),
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
                width: 88,
                height: 38,
                radius: 22,
                child: Icon(
                  Icons.arrow_forward,
                  size: 15,
                  color: Colors.white,
                ),
              ),
              SizedBox(
                width: 8,
              )
            ],
          ),
        ),
      ],
    );
  }

  _account() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          if (ExchangeInheritedModel.of(context).exchangeModel.activeAccount !=
              null) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => BalancesPage()));
          } else {
            _exchangeBloc.add(SwitchToAuthEvent());
          }
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
                width: 20,
                height: 20,
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
            _assetView(),
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
    );
  }

  _assetView() {
    if (ExchangeInheritedModel.of(context).exchangeModel.activeAccount !=
        null) {
      return Text.rich(
        TextSpan(children: [
          TextSpan(
              text: ExchangeInheritedModel.of(context)
                      .exchangeModel
                      .isShowBalances
                  ? '1231231'
                  : '******'),
          TextSpan(
              text: '(CNY)', style: TextStyle(color: Colors.grey, fontSize: 13))
        ]),
        textAlign: TextAlign.center,
      );
    } else {
      return Text('未授权登录');
    }
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
            flex: 3,
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

  _quotesView() {
    return Expanded(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 16.0,
            ),
            child: Row(
              children: <Widget>[
                Text(
                  '名称',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                Spacer(
                  flex: 5,
                ),
                Text(
                  '最新价',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                Spacer(
                  flex: 4,
                ),
                Text(
                  '跌涨幅',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                SizedBox(
                  width: 8,
                ),
              ],
            ),
          ),
          _quotesItemList()
        ],
      ),
    );
  }

  _quotesItemList() {
    return Expanded(
      child: ListView(
        children: List.generate(3, (index) => _quotesItem()),
      ),
    );
  }

  _quotesItem() {
    return InkWell(
      onTap: (){
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => KLineDetailPage()));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text.rich(TextSpan(children: [
                  TextSpan(
                      text: 'HYN',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 20,
                      )),
                  TextSpan(
                      text: '/ETH',
                      style: TextStyle(
                        fontWeight: FontWeight.w300,
                        color: Colors.grey,
                        fontSize: 16,
                      )),
                ])),
                SizedBox(
                  height: 4,
                ),
                Text(
                  '24H量 12313',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                )
              ],
            ),
            Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  '0.1223',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 4,
                ),
                Text(
                  '\$100',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: Colors.grey,
                  ),
                )
              ],
            ),
            Spacer(),
            Container(
              width: 80,
              height: 39,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.0),
                color: HexColor('#FF53AE86'),
              ),
              child: Center(
                child: Text(
                  '+99.99%',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _authorizedView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: <Widget>[
          Spacer(),
          Image.asset(
            'res/drawable/logo_manwu.png',
            width: 23,
            height: 23,
            color: Colors.grey[500],
          ),
          SizedBox(
            width: 4.0,
          ),
          Text(
            S.of(context).safety_certification_by_organizations,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12.0,
            ),
          ),
          Spacer()
        ],
      ),
    );
  }

  _divider() {
    return Container(
      height: 8,
      color: HexColor('#FFF5F5F5'),
    );
  }
}
