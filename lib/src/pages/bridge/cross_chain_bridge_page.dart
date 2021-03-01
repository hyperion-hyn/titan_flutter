import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/components/wallet/vo/coin_view_vo.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/plugins/wallet/cointype.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/image_util.dart';

class CrossChainBridgePage extends StatefulWidget {
  CrossChainBridgePage();

  @override
  State<StatefulWidget> createState() {
    return _CrossChainBridgePageState();
  }
}

class _CrossChainBridgePageState extends State<CrossChainBridgePage> {
  bool isLockAndMine = false;
  String selectedSymbol = 'HYN';
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
          _amount(),
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
                  ImageUtil.getGeneralTokenLogo(selectedSymbol),
                  width: 32,
                  height: 32,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(selectedSymbol),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _direction() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text('跨链方向')],
        ),
      ),
    );
  }

  _amount() {
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
                    text: _availableAmount(),
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

                        if (Decimal.parse(value) > Decimal.parse(_availableAmount())) {
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
                                    _amountController.text = _availableAmount();

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

  _availableAmount() {
    var chainType = isLockAndMine ? CoinType.HB_HT : CoinType.HYN_ATLAS;

    var coinVo = WalletInheritedModel.of(
      context,
      aspect: WalletAspect.activatedWallet,
    ).getCoinVoBySymbolAndCoinType('HYN', chainType);
    if (coinVo != null) {
      return FormatUtil.coinBalanceByDecimal(coinVo, 6);
    } else {
      return '0';
    }
  }
}
