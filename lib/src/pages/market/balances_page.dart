import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/components/exchange/bloc/bloc.dart';
import 'package:titan/src/components/exchange/exchange_component.dart';
import 'deposit_page.dart';
import 'withdraw_page.dart';

class BalancesPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _BalancesPageState();
  }
}

class _BalancesPageState extends State<BalancesPage> {
  double total = 9876.00;

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
            '交易账户',
            style: TextStyle(color: Colors.black, fontSize: 18),
          )),
      body: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 16,
            ),
            _totalBalances(),
            _divider(),
            Expanded(
              child: _coinList(),
            ),
          ],
        ),
      ),
    );
  }

  _totalBalances() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '交易账户总资产折合(CNY)',
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    ExchangeInheritedModel.of(context)
                            .exchangeModel
                            .isShowBalances
                        ? '≈￥9876.00'
                        : '*****',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 16,
              ),
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 30,
                      child: OutlineButton(
                        child: Text(
                          '充币',
                          style: TextStyle(color: HexColor('#FF1095B0')),
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DepositPage()));
                        },
                        borderSide: BorderSide(
                          color: HexColor('#FF1095B0'),
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0)),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 30,
                      child: OutlineButton(
                        child: Text(
                          '提币',
                          style: TextStyle(color: HexColor('#FF1095B0')),
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => WithdrawPage()));
                        },
                        borderSide: BorderSide(
                          color: HexColor('#FF1095B0'),
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0)),
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
          Spacer(),
          InkWell(
            onTap: () async {
              BlocProvider.of<ExchangeCmpBloc>(context).add(
                  SetShowBalancesEvent(!ExchangeInheritedModel.of(context)
                      .exchangeModel
                      .isShowBalances));
              setState(() {});
            },
            child:
                ExchangeInheritedModel.of(context).exchangeModel.isShowBalances
                    ? Image.asset(
                        'res/drawable/ic_wallet_show_balances.png',
                        height: 20,
                        width: 20,
                        color: HexColor('#FF228BA1'),
                      )
                    : Image.asset(
                        'res/drawable/ic_wallet_hide_balances.png',
                        height: 20,
                        width: 20,
                        color: HexColor('#FF228BA1'),
                      ),
          )
        ],
      ),
    );
  }

  _coinList() {
    return ListView.builder(
        itemCount: 4,
        itemBuilder: (ctx, index) {
          return CoinItem('USDT');
        });
  }

  _divider() {
    return Container(
      height: 8,
      color: HexColor('#FFF5F5F5'),
    );
  }
}

class CoinItem extends StatefulWidget {
  final String _symbol;

  CoinItem(this._symbol);

  @override
  State<StatefulWidget> createState() {
    return CoinItemState();
  }
}

class CoinItemState extends State<CoinItem> {
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
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'USDT',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: HexColor('#FF228BA1'),
                    ),
                  ),
                ],
              ),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 15,
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '可用',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(
                            height: 8.0,
                          ),
                          Text(
                            '9090.42',
                            style: TextStyle(
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
                      '冻结',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Text(
                      '0.002',
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
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
                      '折合(CNY)',
                      style: TextStyle(
                        color: Colors.grey,
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
                          '0',
                          style: TextStyle(
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
