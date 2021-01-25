import 'dart:math';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/components/wallet/bloc/bloc.dart';
import 'package:titan/src/components/wallet/vo/coin_view_vo.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/plugins/wallet/cointype.dart';
import 'package:titan/src/plugins/wallet/config/ethereum.dart';
import 'package:titan/src/plugins/wallet/config/tokens.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/config/extends_icon_font.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';

import '../../global.dart';

class WalletGasSettingPage extends StatefulWidget {
  final CoinViewVo coinVo;
  final String toAddress;

  WalletGasSettingPage(String coinVo, [String toAddress])
      : this.coinVo = CoinViewVo.fromJson(FluroConvertUtils.string2map(coinVo)),
        this.toAddress = toAddress;

  @override
  State<StatefulWidget> createState() {
    return _WalletGasSettingState();
  }
}

class _WalletGasSettingState extends BaseState<WalletGasSettingPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _gasLimitController = TextEditingController();
  final TextEditingController _gasPriceController = TextEditingController();

  final _gasPriceKey = GlobalKey<FormState>();
  final _gasLimitKey = GlobalKey<FormState>();

  double _notionalValue = 0;
  bool _isCustom = false;
  int _selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    // _amountController.addListener(() {
    //   if (_amountController.text.trim() != null && _amountController.text.trim().length > 0) {
    //     var inputAmount = _amountController.text.trim();
    //     var activatedQuoteSign =
    //         WalletInheritedModel.of(context).tokenLegalPrice(widget.coinVo.symbol);
    //     var quotePrice = activatedQuoteSign?.price ?? 0;
    //     setState(() {
    //       _notionalValue = double.parse(inputAmount) * quotePrice;
    //     });
    //   }
    // });
  }

  @override
  void onCreated() {
    BlocProvider.of<WalletCmpBloc>(context).add(UpdateActivatedWalletBalanceEvent());
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor('#F6F6F6'),
      appBar: BaseAppBar(
        baseTitle: '矿工费设置',
        backgroundColor: HexColor('#F6F6F6'),
      ),
      body: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: _contentWidget(),
          ),
        ),
        _confirmButtonWidget(),
      ],
    );
  }

  Widget _lineWidget({double vertical = 12}) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: vertical,
      ),
      height: 0.5,
      color: HexColor('#F2F2F2'),
    );
  }

  Widget _contentWidget() {
    var activatedQuoteSign = WalletInheritedModel.of(context).tokenLegalPrice(widget.coinVo.symbol);
    var activatedWallet = WalletInheritedModel.of(context).activatedWallet;
    var quotePrice = activatedQuoteSign?.price ?? 0;
    var quoteSign = activatedQuoteSign?.legal?.legal;

    var addressHint = "";
    RegExp _basicAddressReg = RegExp(r'^([13]|bc)[a-zA-Z0-9]{25,42}$', caseSensitive: false);
    String addressErrorHint = "";
    if (widget.coinVo.coinType == CoinType.BITCOIN) {
      _basicAddressReg = RegExp(r'^([13]|bc)[a-zA-Z0-9]{25,42}$', caseSensitive: false);
      addressHint = S.of(context).example + ': bc1q7fhqwluhcrs2ek...';
      addressErrorHint = S.of(context).legal_address_starting_1_or_bc_or_3;
    } else {
      _basicAddressReg = RegExp(r'^(0x)?[0-9a-f]{40}', caseSensitive: false);
      var addressExample = widget.coinVo.coinType == CoinType.HYN_ATLAS
          ? 'hyn1ntjklkvx9jlkrz9'
          : '0x81e7A0529AC1726e';
      addressHint = S.of(context).example + ': $addressExample...';
      addressErrorHint = S.of(context).input_valid_address;
    }

    return Padding(
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 18,
      ),
      child: Column(
        children: <Widget>[
          _clipRectWidget(
            paddingH: 16,
            paddingV: 10,
            marginV: 0,
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      S.of(context).transfer_gas_fee,
                      style: TextStyle(
                        color: HexColor('#333333'),
                        fontSize: 14,
                      ),
                    ),
                    Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '0.006 HYN',
                          style: TextStyle(
                            color: HexColor('#333333'),
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(
                          height: 2,
                        ),
                        Text(
                          '¥ 0.03',
                          style: TextStyle(
                            color: HexColor('#999999'),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                _lineWidget(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      'Gas Price（74.00 GWEI）* Gas（60,000）',
                      style: TextStyle(
                        color: Color(0xFF999999),
                        fontSize: 10,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    Image.asset(
                      'res/drawable/wallet_gas_info.png',
                      height: 12,
                      width: 12,
                      color: HexColor('#999999'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Row(
            children: <Widget>[
              Text(
                'Gas Price',
                style: TextStyle(
                  color: Color(0xFF333333),
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
              Spacer(),
              Text(
                '预计交易时间',
                style: TextStyle(
                  color: Color(0xFF999999),
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
          _clipRectWidget(
            child: ListView.separated(
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    if (mounted) {
                      setState(() {
                        _selectedIndex = index;
                      });
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(
                      right: 12,
                      top: 12,
                      bottom: 12,
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 12,
                          ),
                          child: _selectedIndex == index
                              ? Image.asset(
                                  'res/drawable/wallet_gas_selected.png',
                                  height: 20,
                                  width: 20,
                                )
                              : SizedBox(
                                  width: 20,
                                ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '最快',
                              style: TextStyle(
                                color: HexColor('#333333'),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(
                              height: 2,
                            ),
                            Text(
                              '167.00GWEI',
                              style: TextStyle(
                                color: HexColor('#999999'),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        Text(
                          '< 0.5 分钟',
                          style: TextStyle(
                            color: HexColor('#999999'),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 12,
                  ),
                  child: _lineWidget(vertical: 8),
                );
              },
              itemCount: 4,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
            ),
            paddingV: 4,
          ),

          _customWidget(),
        ],
      ),
    );
  }

  Widget _customWidget() {
    return _clipRectWidget(
      paddingH: 16,
      paddingV: 4,
      marginV: 0,
      child: Column(
        children: <Widget>[
          InkWell(
            onTap: () {
              if (mounted) {
                setState(() {
                  _selectedIndex = -1;
                });
              }
            },
            child: Padding(
              padding: const EdgeInsets.only(
                right: 12,
                top: 12,
                bottom: 12,
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      right: 12,
                    ),
                    child: _selectedIndex == -1
                        ? Image.asset(
                            'res/drawable/wallet_gas_selected.png',
                            height: 20,
                            width: 20,
                          )
                        : SizedBox(
                            width: 20,
                          ),
                  ),
                  Text(
                    '自定义',
                    style: TextStyle(
                      color: HexColor('#333333'),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_selectedIndex == -1) _customInputWidget(),
        ],
      ),
    );
  }

  Widget _customInputWidget() {
    return Column(
      children: [
        _lineWidget(vertical: 8),
        Padding(
          padding: const EdgeInsets.only(
            top: 8,
          ),
          child: Row(
            children: <Widget>[
              Text(
                'Gas Price',
                style: TextStyle(
                  color: Color(0xFF333333),
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Image.asset(
                  'res/drawable/wallet_gas_info.png',
                  height: 12,
                  width: 12,
                  color: HexColor('#999999'),
                ),
              ),
            ],
          ),
        ),
        _clipRectWidget(
          child: _gasPriceEditWidget(),
          color: Color(0xFFF6F6F6),
          paddingV: 0,
        ),
        Padding(
          padding: const EdgeInsets.only(
            top: 8,
          ),
          child: Row(
            children: <Widget>[
              Text(
                'Gas',
                style: TextStyle(
                  color: Color(0xFF333333),
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Image.asset(
                  'res/drawable/wallet_gas_info.png',
                  height: 12,
                  width: 12,
                  color: HexColor('#999999'),
                ),
              ),
            ],
          ),
        ),
        _clipRectWidget(
          child: _gasLimitEditWidget(),
          color: Color(0xFFF6F6F6),
          paddingV: 0,
        ),
      ],
    );
  }

  Widget _clipRectWidget({
    Widget child,
    double paddingV = 12,
    double paddingH = 0,
    double marginV = 12,
    Color color = Colors.white,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: paddingH,
        vertical: paddingV,
      ),
      margin: EdgeInsets.symmetric(
        vertical: marginV,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.all(
          Radius.circular(6),
        ),
      ),
      child: child,
    );
  }

  Widget _gasLimitEditWidget() {
    return Form(
      key: _gasLimitKey,
      child: Container(
        child: TextFormField(
          controller: _gasLimitController,
          textAlign: TextAlign.start,
          validator: (value) {
            value = value.trim();
            if (value == "0") {
              return S.of(context).input_corrent_count_hint;
            }
            return null;
          },
          onChanged: (String inputValue) {},
          onFieldSubmitted: (String inputText) {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: HexColor('#333333'),
          ),
          cursorColor: Theme.of(context).primaryColor,
          //光标圆角
          cursorRadius: Radius.circular(5),
          //光标宽度
          cursorWidth: 1.8,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            border: InputBorder.none,
            hintText: '0',
            errorStyle: TextStyle(fontSize: 14, color: Colors.blue),
            hintStyle: TextStyle(
              fontSize: 16,
              color: HexColor('#999999'),
              fontWeight: FontWeight.w500,
            ),
          ),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
        ),
      ),
    );
  }

  Widget _gasPriceEditWidget() {
    return Form(
      key: _gasPriceKey,
      child: Container(
        child: TextFormField(
          controller: _gasPriceController,
          textAlign: TextAlign.start,
          validator: (value) {
            value = value.trim();
            if (value == "0") {
              return S.of(context).input_corrent_count_hint;
            }
            return null;
          },
          onChanged: (String inputValue) {},
          onFieldSubmitted: (String inputText) {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: HexColor('#333333'),
          ),
          cursorColor: Theme.of(context).primaryColor,
          //光标圆角
          cursorRadius: Radius.circular(5),
          //光标宽度
          cursorWidth: 1.8,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            border: InputBorder.none,
            hintText: '0',
            errorStyle: TextStyle(fontSize: 14, color: Colors.blue),
            hintStyle: TextStyle(
              fontSize: 16,
              color: HexColor('#999999'),
              fontWeight: FontWeight.w500,
            ),
          ),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
        ),
      ),
    );
  }

  Widget _confirmButtonWidget() {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 36,
        top: 20,
      ),
      child: ClickOvalButton(
        S.of(context).confirm,
        _confirmAction,
        btnColor: [
          HexColor("#F7D33D"),
          HexColor("#E7C01A"),
        ],
        fontColor: HexColor("#333333"),
        fontSize: 16,
        width: 260,
        height: 42,
      ),
    );
  }

  void _confirmAction() {}
}
