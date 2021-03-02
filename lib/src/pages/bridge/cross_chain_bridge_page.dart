import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/components/wallet/vo/coin_view_vo.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/plugins/wallet/cointype.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/image_util.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';

class CrossChainBridgePage extends StatefulWidget {
  CrossChainBridgePage();

  @override
  State<StatefulWidget> createState() {
    return _CrossChainBridgePageState();
  }
}

class _CrossChainBridgePageState extends State<CrossChainBridgePage> {
  String _selectedSymbol = 'HYN';
  var _fromChain = CoinType.HYN_ATLAS;
  var _toChain = CoinType.HB_HT;
  TextEditingController _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
        title: null,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: InkWell(
                child: Text(
                  '跨链帮助',
                  style: TextStyle(
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
      body: CustomScrollView(
        slivers: [
          _title(),
          _tokenInfo(),
          _direction(),
          _transferAmount(),
          _confirmButton(),
        ],
      ),
    );
  }

  _title() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          '跨链',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  _tokenInfo() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text('资产'),
            ),
            Row(
              children: [
                Image.asset(
                  ImageUtil.getGeneralTokenLogo(_selectedSymbol),
                  width: 32,
                  height: 32,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(_selectedSymbol),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _direction() {
    var button = InkWell(
      onTap: () {},
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: RotatedBox(
          quarterTurns: 1,
          child: IconButton(
            icon: Image.asset(
              'res/drawable/ic_wallet_account_list_exchange.png',
              width: 50,
              height: 50,
            ),
            onPressed: () {
              setState(() {
                var temp = _fromChain;
                _fromChain = _toChain;
                _toChain = temp;
              });
            },
          ),
        ),
      ),
    );
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('跨链方向'),
            Row(
              children: [
                _chainItem(_fromChain),
                button,
                _chainItem(_toChain),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _chainItem(int chainType) {
    var name = chainType == CoinType.HYN_ATLAS ? 'ATLAS' : 'HECO';
    return Expanded(
        child: Center(
      child: Text(
        name,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ),
    ));
  }

  _tokenBalance() {
    var chainType = _fromChain;
    var coinVo = WalletInheritedModel.of(
      context,
      aspect: WalletAspect.activatedWallet,
    ).getCoinVoBySymbolAndCoinType(_selectedSymbol, chainType);
    if (coinVo != null) {
      return FormatUtil.coinBalanceByDecimal(coinVo, 6);
    } else {
      return '0';
    }
  }

  _transferAmount() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Spacer(),
                Text.rich(TextSpan(children: [
                  TextSpan(
                    text: _tokenBalance(),
                    style: TextStyle(
                      color: HexColor('#FF333333'),
                      fontSize: 12,
                    ),
                  ),
                  TextSpan(
                    text: ' HYN',
                    style: TextStyle(
                      color: HexColor('#FFAAAAAA'),
                      fontSize: 12,
                    ),
                  ),
                ])),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: TextFormField(
                      controller: _amountController,
                      validator: (value) {
                        value = value.trim();
                        if (value.isEmpty) {
                          return S.of(context).input_corrent_count_hint;
                        }
                        if (Decimal.parse(value) <= Decimal.zero) {
                          return S.of(context).input_corrent_count_hint;
                        }
                        if (!RegExp(r"\d+(\.\d+)?$").hasMatch(value)) {
                          return S.of(context).input_corrent_count_hint;
                        }

                        if (Decimal.parse(value) > Decimal.parse(_tokenBalance())) {
                          return S.of(context).input_count_over_balance;
                        }

                        return null;
                      },
                      onChanged: (data) {
                        _formKey.currentState.validate();
                      },
                      decoration: InputDecoration(
                          border: UnderlineInputBorder(
                              borderSide: BorderSide(
                            color: HexColor('#FFD7D7D7'),
                          )),
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                            color: HexColor('#FFD7D7D7'),
                          )),
                          hintStyle: TextStyle(
                            color: HexColor('#FF999999'),
                            fontSize: 12,
                          ),
                          suffixIcon: Container(
                            child: Container(
                              width: 65,
                              child: Center(
                                child: InkWell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      S.of(context).all,
                                      style: TextStyle(
                                          color: HexColor('#FF333333'),
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  onTap: () {
                                    _amountController.text = _tokenBalance();
                                    _amountController.selection =
                                        TextSelection.fromPosition(TextPosition(
                                      affinity: TextAffinity.downstream,
                                      offset: _amountController.text.length,
                                    ));
                                    _formKey.currentState.validate();
                                    setState(() {});
                                  },
                                ),
                              ),
                            ),
                          )),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _confirmButton() {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          SizedBox(
            height: 150,
          ),
          ClickOvalButton(
            S.of(context).confirm,
            () async {
              FocusScope.of(context).requestFocus(FocusNode());
              if (_formKey.currentState.validate()) {
                await _transfer();
              }
            },
            height: 46,
            width: 300,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            btnColor: [
              HexColor("#F7D33D"),
              HexColor("#E7C01A"),
            ],
          ),
        ],
      ),
    );
  }

  _transfer() {
    if (_fromChain == CoinType.HYN_ATLAS) {
      _lockTokens();
    } else {
      _burnTokens(_fromChain);
    }
  }

  ///Lock tokens on ATLAS
  _lockTokens() {

  }

  ///To unlock tokens on ATLAS, burn tokens on other chain.
  _burnTokens(int chainType) {
    if (chainType == CoinType.HB_HT) {}
  }
}
