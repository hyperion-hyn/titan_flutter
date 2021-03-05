import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/components/socket/socket_component.dart';
import 'package:titan/src/components/wallet/vo/coin_view_vo.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/market/entity/exchange_coin_list_v2.dart';
import 'package:titan/src/pages/wallet/api/hb_api.dart';
import 'package:titan/src/pages/wallet/api/hyn_api.dart';
import 'package:titan/src/plugins/wallet/cointype.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/image_util.dart';
import 'package:titan/src/utils/log_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'dart:math' as math;

class CrossChainBridgePage extends StatefulWidget {
  CrossChainBridgePage();

  @override
  State<StatefulWidget> createState() {
    return _CrossChainBridgePageState();
  }
}

class _CrossChainBridgePageState extends State<CrossChainBridgePage> {
  String _currentTokenSymbol = 'HYN';
  var _fromChain = CoinType.HYN_ATLAS;
  var _toChain = CoinType.HB_HT;
  TextEditingController _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  HYNApi _hynApi = HYNApi();
  HbApi _hbApi = HbApi();

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
      appBar: BaseAppBar(
        baseTitle: '跨链',
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
                onTap: () {
                  AtlasApi.goToAtlasMap3HelpPage(context);
                },
              ),
            ),
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  _chainSelection(),
                  _tokenSelection(),
                  _amount(),
                ],
              ),
            ),
            _confirmButton(),
          ],
        ),
      ),
    );
  }

  _chainSelection() {
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
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text('跨链方向'),
            ),
            Container(
              decoration: BoxDecoration(
                color: DefaultColors.colorf6f6f6,
                borderRadius: BorderRadius.all(Radius.circular(6.0)),
              ),
              child: Row(
                children: [
                  _chainItem(_fromChain, true),
                  button,
                  _chainItem(_toChain, false),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _chainItem(int chainType, bool isFromChain) {
    var name = chainType == CoinType.HYN_ATLAS ? 'ATLAS' : 'HECO';
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                decoration: BoxDecoration(
                  color: DefaultColors.colordedede,
                  borderRadius: BorderRadius.all(Radius.circular(2.0)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Text(
                    isFromChain ? '从' : '到',
                    style: TextStyle(fontSize: 9),
                  ),
                )),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Container(
                    alignment: Alignment.center,
                    width: 20,
                    height: 20,
                    child: Image.asset(
                      '${ImageUtil.getGeneralChainLogo(name)}',
                    ),
                  ),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '$name 链',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _tokenBalance() {
    var chainType = _fromChain;
    var coinVo = WalletInheritedModel.of(
      context,
      aspect: WalletAspect.activatedWallet,
    ).getCoinVoBySymbolAndCoinType(_currentTokenSymbol, chainType);
    if (coinVo != null) {
      return FormatUtil.coinBalanceByDecimal(coinVo, 6);
    } else {
      return '0';
    }
  }

  _tokenItem(Token token) {
    var coinVo = WalletInheritedModel.of(
      context,
      aspect: WalletAspect.activatedWallet,
    ).getCoinVoBySymbolAndCoinType(token.symbol, token.coinType);
    return Column(
      children: [
        InkWell(
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                child: Container(
                  width: 48,
                  height: 48,
                  child: ImageUtil.getCoinImage(coinVo.logo),
                ),
              ),
              Text(
                '${token.symbol}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Spacer(),
              Text(
                '${token.chain.toUpperCase()}',
                style: TextStyle(
                  color: HexColor('#FF777777'),
                  fontSize: 14,
                ),
              ),
              SizedBox(
                width: 16,
              )
            ],
          ),
          onTap: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  _tokenSelection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                '资产',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: DefaultColors.colorf6f6f6,
                borderRadius: BorderRadius.all(Radius.circular(6.0)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: InkWell(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        alignment: Alignment.center,
                        width: 30,
                        height: 30,
                        child: Image.asset(
                          '${ImageUtil.getGeneralTokenLogo(_currentTokenSymbol)}',
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'HYN',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                        ),
                      ),
                      Spacer(),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 0),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          size: 18,
                          color: HexColor('#FF999999'),
                        ),
                      )
                    ],
                  ),
                  onTap: () {
                    _showTokenListDialog();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _showTokenListDialog() async {
    var tokens = MarketInheritedModel.of(
      context,
      aspect: SocketAspect.marketItemList,
    ).activeTokens();

    UiUtil.showBottomDialogView(
      context,
      dialogHeight: MediaQuery.of(context).size.height - 80,
      isScrollControlled: true,
      customWidget: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Center(
              child: Text(S.of(context).choose_currency, style: TextStyles.textC333S14bold),
            ),
          ),
          Expanded(
            child: CustomScrollView(
              semanticChildCount: tokens.length,
              slivers: <Widget>[
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      final int itemIndex = index ~/ 2;
                      if (index.isEven) {
                        return _tokenItem(tokens[itemIndex]);
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Divider(height: 1),
                      );
                    },
                    semanticIndexCallback: (Widget widget, int localIndex) {
                      if (localIndex.isEven) {
                        return localIndex ~/ 2;
                      }
                      return null;
                    },
                    childCount: math.max(0, tokens.length * 2 - 1),
                  ),
                ),
              ],
            ),
          ),
        ],
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
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: <Widget>[
                  Text(
                    '数量',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Spacer(),
                  Text.rich(TextSpan(children: [
                    TextSpan(
                      text: _tokenBalance(),
                      style: TextStyle(
                        color: HexColor('#FFAAAAAA'),
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
            ),
            Column(
              children: [
                Container(
                  child: Stack(
                    children: [
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: DefaultColors.colorf6f6f6,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Form(
                              key: _formKey,
                              child: Container(
                                child: TextFormField(
                                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                                  validator: (value) {
                                    value = value.trim();
                                    try {
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
                                    } catch (e) {
                                      return S.of(context).input_corrent_count_hint;
                                    }
                                    return null;
                                  },
                                  controller: _amountController,
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                  onChanged: (data) {
                                    _formKey.currentState.validate();
                                    setState(() {});
                                  },
                                  decoration: InputDecoration(
                                    hintText: '0.0',
                                    hintStyle: TextStyles.textCaaaS14,
                                    filled: true,
                                    fillColor: Colors.transparent,
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            height: 50,
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Center(
                              child: InkWell(
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
                                child: Text(
                                  '全部',
                                  style: TextStyle(color: Colors.blue, fontSize: 14),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ClickOvalButton(
        S.of(context).confirm,
        () async {
          if (_formKey.currentState.validate()) {
            await _operate();
          } else {
            return;
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
    );
  }

  ///only support atlas-heco now
  _operate() {
    if (_fromChain == CoinType.HYN_ATLAS) {
      _lockTokens();
    } else {
      _burnTokens(_fromChain);
    }
  }

  ///Lock tokens on ATLAS
  _lockTokens() async {
    var coinVo = WalletInheritedModel.of(
      context,
      aspect: WalletAspect.activatedWallet,
    ).getCoinVoBySymbolAndCoinType(_currentTokenSymbol, CoinType.HYN_ATLAS);

    var wallet = WalletInheritedModel.of(context).activatedWallet;
    var pwd = await UiUtil.showWalletPasswordDialogV2(context, wallet?.wallet);

    if (pwd == null) {
      return;
    }

    try {
      if (_currentTokenSymbol == 'HYN') {
        _hynApi.postBridgeLockHYN(
          activeWallet: wallet,
          password: pwd,
          amount: ConvertTokenUnit.strToBigInt(_amountController.text),
        );
      } else {
        _hynApi.postBridgeLockToken(
          contractAddress: coinVo.contractAddress,
          activeWallet: wallet,
          password: pwd,
          amount: ConvertTokenUnit.strToBigInt(_amountController.text),
        );
      }
    } catch (e) {
      LogUtil.toastException(e);
    }
  }

  ///To unlock tokens on ATLAS, burn tokens on other chain.
  _burnTokens(int chainType) async {
    if (chainType == CoinType.HB_HT) {
      var coinVo = WalletInheritedModel.of(
        context,
        aspect: WalletAspect.activatedWallet,
      ).getCoinVoBySymbolAndCoinType(_currentTokenSymbol, chainType);

      var wallet = WalletInheritedModel.of(context).activatedWallet;
      var pwd = await UiUtil.showWalletPasswordDialogV2(context, wallet?.wallet);

      if (pwd == null) {
        return;
      }

      try {
        _hbApi.postBridgeBurnToken(
          contractAddress: coinVo.contractAddress,
          activeWallet: wallet,
          password: pwd,
          burnAmount: ConvertTokenUnit.strToBigInt(_amountController.text),
        );
      } catch (e) {
        LogUtil.toastException(e);
      }
    }
  }
}
