import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/http/entity.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/components/wallet/bloc/bloc.dart';
import 'package:titan/src/components/wallet/vo/wallet_view_vo.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/bridge/cross_chain_record_list_page.dart';
import 'package:titan/src/pages/bridge/entity/cross_chain_token.dart';
import 'package:titan/src/pages/wallet/api/hb_api.dart';
import 'package:titan/src/pages/wallet/api/hyn_api.dart';
import 'package:titan/src/plugins/wallet/cointype.dart';
import 'package:titan/src/plugins/wallet/config/ethereum.dart';
import 'package:titan/src/plugins/wallet/config/hyperion.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
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
  ///default token list
  CrossChainToken _currentToken = CrossChainToken('HYN', '', '');

  var _fromChain = CoinType.HYN_ATLAS;
  var _toChain = CoinType.HB_HT;

  TextEditingController _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  HYNApi _hynApi = HYNApi();
  HbApi _hbApi = HbApi();
  AtlasApi _atlasApi = AtlasApi();

  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    _updateTokenList();
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
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        title: Wrap(
          children: [
            Text(
              "跨链",
              style: TextStyle(
                color: Colors.black,
                fontSize: 15,
              ),
            ),
            InkWell(
              onTap: () {
                AtlasApi.goToAtlasMap3HelpPage(context);
              },
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Image.asset(
                  'res/drawable/ic_tooltip.png',
                  width: 10,
                  height: 10,
                ),
              ),
            )
          ],
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CrossChainRecordListPage(_currentToken)),
              );
            },
            child: Text(
              '跨链记录',
              style: TextStyle(
                color: HexColor("#1F81FF"),
                fontSize: 14,
                fontWeight: FontWeight.normal,
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
              width: 30,
              height: 30,
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
              padding: const EdgeInsets.symmetric(vertical: 16.0),
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

  _chainItem(int chainType, bool isFromChain) {
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
              padding: const EdgeInsets.symmetric(vertical: 8.0),
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
    ).getCoinVoBySymbolAndCoinType(_currentToken.symbol, chainType);
    if (coinVo != null) {
      return FormatUtil.coinBalanceByDecimalStr(coinVo, 6);
    } else {
      return '0';
    }
  }

  _tokenSelection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                          '${ImageUtil.getGeneralTokenLogo(_currentToken.symbol)}',
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        _currentToken.symbol,
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
    var crossChainTokens = WalletInheritedModel.of(context).getCrossChainTokenList();
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
              semanticChildCount: crossChainTokens.length,
              slivers: <Widget>[
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      final int itemIndex = index ~/ 2;
                      if (index.isEven) {
                        return _tokenItem(crossChainTokens[itemIndex]);
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
                    childCount: math.max(0, crossChainTokens.length * 2 - 1),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _tokenItem(CrossChainToken token) {
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
                  child: Image.asset(
                    ImageUtil.getGeneralTokenLogo(token.symbol),
                  ),
                ),
              ),
              Text(
                '${token.symbol}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(
                width: 16,
              )
            ],
          ),
          onTap: () {
            _currentToken = token;
            setState(() {});
            Navigator.of(context).pop();
          },
        ),
      ],
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
                      text: '${_fromChain == CoinType.HYN_ATLAS ? 'ATLAS' : 'HECO'}链可用 ',
                      style: TextStyle(
                        color: HexColor('#FFAAAAAA'),
                        fontSize: 12,
                      ),
                    ),
                    TextSpan(
                      text: _tokenBalance(),
                      style: TextStyle(
                        color: HexColor('#FFAAAAAA'),
                        fontSize: 12,
                      ),
                    ),
                    TextSpan(
                      text: ' ${_currentToken.symbol}',
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
          if (isProcessing) {
            return;
          }
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
        isDisable: isProcessing,
        btnColor: [
          HexColor("#F7D33D"),
          HexColor("#E7C01A"),
        ],
      ),
    );
  }

  ///only support atlas-heco now
  _operate() async {
    setState(() {
      isProcessing = true;
    });

    if (_fromChain == CoinType.HYN_ATLAS) {
      await _lockTokens();
    } else {
      await _burnTokens(_fromChain);
    }
    setState(() {
      isProcessing = false;
    });
  }

  ///Lock tokens on ATLAS
  _lockTokens() async {
    var coinVo = WalletInheritedModel.of(
      context,
      aspect: WalletAspect.activatedWallet,
    ).getCoinVoBySymbolAndCoinType(
      _currentToken.symbol,
      CoinType.HYN_ATLAS,
    );

    var wallet = WalletInheritedModel.of(context).activatedWallet;
    var pwd = await UiUtil.showWalletPasswordDialogV2(context, wallet?.wallet);

    if (pwd == null) {
      return;
    }

    UiUtil.showLoadingDialog(
      context,
      '处理中...',
      (context) {},
    );

    var result = false;
    try {
      String rawTxHash;
      String tokenAddress;
      if (_currentToken.symbol == 'HYN') {
        tokenAddress = '0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE';

        var gasLimit = Decimal.fromInt(HyperionGasLimit.BRIDGE_CONTRACT_LOCK_HYN_CALL);
        var gasPrice = Decimal.fromInt(1 * EthereumUnitValue.G_WEI);
        var gasFee = ConvertTokenUnit.weiToEther(
            weiBigInt: BigInt.parse((gasPrice * gasLimit).toStringAsFixed(0)));

        var balance = WalletInheritedModel.of(context).getBalanceBySymbolAndCoinType(
          'HYN',
          CoinType.HYN_ATLAS,
        );
        var value = Decimal.tryParse('${_amountController.text}') ?? Decimal.zero;

        if (value + gasFee > balance) {
          value = value - gasFee;
        }

        rawTxHash = await _hynApi.postBridgeLockHYN(
          activeWallet: wallet,
          password: pwd,
          amount: ConvertTokenUnit.strToBigInt('$value'),
        );
      } else {
        tokenAddress = coinVo.contractAddress;
        rawTxHash = await _hynApi.postBridgeLockToken(
          contractAddress: coinVo.contractAddress,
          activeWallet: wallet,
          password: pwd,
          amount: ConvertTokenUnit.strToBigInt(_amountController.text),
        );
      }

      if (rawTxHash != null) {
        result = await _postBridgeRequest(
          wallet,
          tokenAddress,
          1,
          ConvertTokenUnit.strToBigInt(_amountController.text).toString(),
          rawTxHash,
        );
      }
    } catch (e) {
      result = false;
      LogUtil.toastException(e);
    }

    ///pop loading dialog
    Navigator.pop(context);

    if (result) {
      _submitFinish();
    }
  }

  ///To unlock tokens on ATLAS, burn tokens on other chain.
  _burnTokens(int chainType) async {
    if (chainType == CoinType.HB_HT) {
      var coinVo = WalletInheritedModel.of(
        context,
        aspect: WalletAspect.activatedWallet,
      ).getCoinVoBySymbolAndCoinType(_currentToken.symbol, chainType);

      var wallet = WalletInheritedModel.of(context).activatedWallet;
      var pwd = await UiUtil.showWalletPasswordDialogV2(context, wallet?.wallet);

      if (pwd == null) {
        return;
      }

      UiUtil.showLoadingDialog(
        context,
        '处理中...',
        (context) {},
      );

      String rawTxHash;
      var result = false;
      try {
        rawTxHash = await _hbApi.postBridgeBurnToken(
          contractAddress: coinVo.contractAddress,
          activeWallet: wallet,
          password: pwd,
          burnAmount: ConvertTokenUnit.strToBigInt(_amountController.text),
        );

        if (rawTxHash != null) {
          result = await _postBridgeRequest(
            wallet,
            coinVo.contractAddress,
            2,
            ConvertTokenUnit.strToBigInt(_amountController.text).toString(),
            rawTxHash,
          );
        }
      } catch (e) {
        result = false;
        LogUtil.toastException(e);
      }

      ///pop loading dialog
      Navigator.pop(context);

      if (result) {
        _submitFinish();
      }
    }
  }

  Future<bool> _postBridgeRequest(
    WalletViewVo wallet,
    String tokenAddress,
    int type,
    String amount,
    String rawTxHash,
  ) async {
    var ownerAddress = wallet?.wallet?.getEthAccount()?.address ?? '';
    try {
      var data = await _atlasApi.postBridgetApply(
        walletAddress: ownerAddress,
        tokenAddress: tokenAddress,
        type: type,
        amount: amount,
        rawTxHash: rawTxHash,
      );

      if (data != null) {
        _amountController.clear();
        return true;
      } else {
        Fluttertoast.showToast(msg: '提交失败', gravity: ToastGravity.CENTER);
        _amountController.clear();
        return false;
      }
    } catch (e) {
      LogUtil.toastException(e);
      return false;
    }
  }

  _updateTokenList() async {
    BlocProvider.of<WalletCmpBloc>(context)?.add(UpdateCrossChainTokenListEvent());
  }

  _submitFinish() {
    var msg = '您的跨链转账已广播，请等待区块链确认，大约需要15秒左右时间';
    msg = FluroConvertUtils.fluroCnParamsEncode(msg);
    Application.router.navigateTo(context, Routes.confirm_success_papge + '?msg=$msg');
  }
}
