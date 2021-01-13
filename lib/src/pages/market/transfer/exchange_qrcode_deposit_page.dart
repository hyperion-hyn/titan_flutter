import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_save/image_save.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/exchange/exchange_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/market/api/exchange_api.dart';
import 'package:titan/src/plugins/wallet/token.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/all_page_state/all_page_state.dart';
import 'package:titan/src/widget/all_page_state/all_page_state_container.dart';

import 'exchange_transfer_history_list_page.dart';

class ExchangeQrcodeDepositPage extends StatefulWidget {
  final String coinSymbol;

  ExchangeQrcodeDepositPage(this.coinSymbol);

  @override
  State<StatefulWidget> createState() {
    return ExchangeQrcodeDepositPageState();
  }
}

class ExchangeQrcodeDepositPageState
    extends BaseState<ExchangeQrcodeDepositPage> {
  String _selectedCoinSymbol = SupportedTokens.HYN_Atlas.symbol;
  Map symbolToChain = {
    SupportedTokens.HYN_Atlas.symbol: S.of(Keys.rootKey.currentContext).atlas_main_chain,
    SupportedTokens.USDT_ERC20.symbol: "ERC20",
    SupportedTokens.HYN_RP_HRC30.symbol: "HRC30"
  };
  GlobalKey _qrImageBoundaryKey = GlobalKey();
  AllPageState _currentState = LoadingState();
  ExchangeApi _exchangeApi = ExchangeApi();
  String exchangeAddress;

  @override
  void initState() {
    _selectedCoinSymbol = widget.coinSymbol ?? SupportedTokens.HYN_Atlas.symbol;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void onCreated() {
    loadData();
    super.onCreated();
  }

  Future loadData() async {
    var ret = await _exchangeApi.getAddress(_selectedCoinSymbol);
    exchangeAddress = ret['address'];
    setState(() {
      _currentState = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: BaseAppBar(
        baseTitle: S.of(context).recharge_coin,
        actions: [
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ExchangeTransferHistoryListPage(
                            _selectedCoinSymbol,
                          )));
            },
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Image.asset(
                'res/drawable/ic_transfer_history.png',
                width: 20,
                height: 20,
              ),
            ),
          )
        ],
      ),
      body: _pageView(),
    );
  }

  Widget _pageView() {
    if (_currentState != null || exchangeAddress == null) {
      return Scaffold(
        body: AllPageStateContainer(_currentState, () {
          setState(() {
            _currentState = LoadingState();
          });
          loadData();
        }),
      );
    }

    var changeAddress = _selectedCoinSymbol == SupportedTokens.USDT_ERC20.symbol
        ? exchangeAddress
        : WalletUtil.ethAddressToBech32Address(exchangeAddress);

    return Padding(
      padding: const EdgeInsets.only(left: 14, right: 14, top: 10, bottom: 10),
      child: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: InkWell(
              onTap: () {
                _showCoinSelectDialog();
              },
              child: Container(
                  height: 40,
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 16),
                  padding: EdgeInsets.only(left: 13, right: 13),
                  decoration: BoxDecoration(
                    color: DefaultColors.colorf5f5f5,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        _selectedCoinSymbol,
                        style: TextStyle(
                            color: HexColor(
                              '#333333',
                            ),
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                      ),
                      Spacer(),
                      Text(
                        S.of(context).choose_currency,
                        style: TextStyle(
                            color: HexColor(
                              '#777777',
                            ),
                            fontSize: 12),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 11,
                        color: HexColor('#FF999999'),
                      )
                    ],
                  )),
            ),
          ),
          SliverToBoxAdapter(
            child: Text(
              S.of(context).chain_name,
              style: TextStyle(
                  color: HexColor(
                    '#777777',
                  ),
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            ),
          ),
          SliverToBoxAdapter(
            child: Row(
              children: [
                Container(
                    margin: EdgeInsets.only(top: 8, bottom: 12),
                    padding:
                        EdgeInsets.only(left: 12, right: 12, top: 3, bottom: 3),
                    decoration: BoxDecoration(
                      border: Border.all(
                          width: 0.5, color: Theme.of(context).primaryColor),
                      borderRadius: BorderRadius.all(Radius.circular(2)),
                    ),
                    child: Text(
                      symbolToChain[_selectedCoinSymbol],
                      style: TextStyle(
                          color: Theme.of(context).primaryColor, fontSize: 10),
                    )),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.only(bottom: 17),
              padding:
                  EdgeInsets.only(left: 10, right: 10, top: 30, bottom: 26),
              decoration: BoxDecoration(
                color: DefaultColors.colorf5f5f5,
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    margin: EdgeInsets.only(bottom: 12),
                    child: RepaintBoundary(
                      key: _qrImageBoundaryKey,
                      child: QrImage(
                        padding: const EdgeInsets.all(9),
                        data: changeAddress,
                        size: 84,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      _saveQrImage(changeAddress);
                    },
                    child: Container(
                      padding: EdgeInsets.only(
                          left: 15, right: 15, top: 4, bottom: 4),
                      decoration: BoxDecoration(
                        color: HexColor("#e5e5e5"),
                        borderRadius: BorderRadius.all(Radius.circular(2)),
                      ),
                      child: Text(
                        S.of(context).save_qr_code,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 18, bottom: 10),
                    child: Text(
                      S.of(context).deposit_address,
                      style: TextStyle(
                          color: HexColor(
                            '#999999',
                          ),
                          fontSize: 10),
                    ),
                  ),
                  Text(
                    changeAddress,
                    style: TextStyle(
                        color: HexColor(
                          '#333333',
                        ),
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  ),
                  InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: changeAddress));
                      UiUtil.toast(S.of(context).copyed);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(top: 10),
                      padding: EdgeInsets.only(
                          left: 15, right: 15, top: 4, bottom: 4),
                      decoration: BoxDecoration(
                        color: HexColor("#e5e5e5"),
                        borderRadius: BorderRadius.all(Radius.circular(2)),
                      ),
                      child: Text(
                        S.of(context).copy_address,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _remainders(_selectedCoinSymbol),
          )
        ],
      ),
    );
  }

  Future _saveQrImage(String address) async {
    bool result = false;
    try {
      RenderRepaintBoundary boundary =
          _qrImageBoundaryKey.currentContext.findRenderObject();
      var image = await boundary.toImage();
      ByteData byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData.buffer.asUint8List();
      result = await ImageSave.saveImage(pngBytes, "png",
          albumName: 'exchange_address_$address');
    } catch (e) {
      result = false;
    }
    Fluttertoast.showToast(
      msg: result ? S.of(context).successfully_saved_album : S.of(context).save_fail,
    );
  }

  _showCoinSelectDialog() {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15.0),
            topRight: Radius.circular(15.0),
          ),
        ),
        builder: (BuildContext context) {
          return Container(
            height: 210,
            child: Column(
              children: <Widget>[
                _coinItem(SupportedTokens.HYN_Atlas.symbol),
                // _coinItem('ETH'),
                _coinItem(SupportedTokens.USDT_ERC20.symbol),
                _coinItem(SupportedTokens.HYN_RP_HRC30.symbol),

                InkWell(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        S.of(context).cancel,
                        style: TextStyle(
                          color: HexColor('#FF777777'),
                        ),
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            ),
          );
        });
  }

  _coinItem(String symbol) {
    return Column(
      children: [
        InkWell(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                symbol,
                style: TextStyle(
                    color: _selectedCoinSymbol == symbol
                        ? Theme.of(context).primaryColor
                        : HexColor('#FF777777')),
              ),
            ),
          ),
          onTap: () {
            setState(() {
              _selectedCoinSymbol = symbol;
              // _gasFeeFullStrFunc();
            });
            Navigator.of(context).pop();
          },
        ),
        _divider(1)
      ],
    );
  }

  _divider(double height) {
    return Container(
      width: double.infinity,
      height: height,
      color: HexColor('#FFEEEEEE'),
    );
  }

  _remainders(String tokenSymbol) {
    var assetList = ExchangeInheritedModel.of(context)
        .exchangeModel
        .activeAccount
        ?.assetList;

    var minHyn = assetList?.HYN?.rechargeMin ?? '0';
    var minUsdt = assetList?.USDT?.rechargeMin ?? '0';
    var minRp = assetList?.RP?.rechargeMin ?? '0';

    if (tokenSymbol == SupportedTokens.HYN_Atlas.symbol) {
      return RichText(
        text: TextSpan(
          children: [
            TextSpan(
                text: S.of(context).do_not_recharge_not,
                style: TextStyle(
                  fontSize: 10,
                  color: DefaultColors.color777,
                )),
            TextSpan(
              text: 'Atlas-HYN',
              style: TextStyle(
                  fontSize: 10,
                  color: DefaultColors.color333,
                  fontWeight: FontWeight.bold),
            ),
            TextSpan(
                text: S.of(context).assets_otherwise_not_recovered_wait_confirm,
                style: TextStyle(
                  fontSize: 10,
                  color: DefaultColors.color777,
                )),
            TextSpan(
              text: '$minHyn',
              style: TextStyle(
                  fontSize: 10,
                  color: DefaultColors.color333,
                  fontWeight: FontWeight.bold),
            ),
            TextSpan(
                text: S.of(context).hyn_deposits_minimum_amount_not_to_account,
                style: TextStyle(
                  fontSize: 10,
                  color: DefaultColors.color777,
                )),
          ],
        ),
      );
    } else if (tokenSymbol == SupportedTokens.USDT_ERC20.symbol) {
      return RichText(
        text: TextSpan(
          children: [
            TextSpan(
                text: S.of(context).do_not_recharge_not,
                style: TextStyle(
                  fontSize: 10,
                  color: DefaultColors.color777,
                )),
            TextSpan(
              text: ' ERC20-USDT ',
              style: TextStyle(
                  fontSize: 10,
                  color: DefaultColors.color333,
                  fontWeight: FontWeight.bold),
            ),
            TextSpan(
                text: S.of(context).assets_otherwise_not_recovered_wait_confirm,
                style: TextStyle(
                  fontSize: 10,
                  color: DefaultColors.color777,
                )),
            TextSpan(
              text: '$minUsdt ',
              style: TextStyle(
                fontSize: 10,
                color: DefaultColors.color333,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
                text: S.of(context).usdt_minimum_not_to_account,
                style: TextStyle(
                  fontSize: 10,
                  color: DefaultColors.color777,
                )),
          ],
        ),
      );
    } else if (tokenSymbol == SupportedTokens.HYN_RP_HRC30.symbol) {
      return RichText(
        text: TextSpan(
          children: [
            TextSpan(
                text: S.of(context).do_not_recharge_not,
                style: TextStyle(
                  fontSize: 10,
                  color: DefaultColors.color777,
                )),
            TextSpan(
              text: ' HRC30-RP ',
              style: TextStyle(
                  fontSize: 10,
                  color: DefaultColors.color333,
                  fontWeight: FontWeight.bold),
            ),
            TextSpan(
                text: S.of(context).assets_otherwise_not_recovered_wait_confirm,
                style: TextStyle(
                  fontSize: 10,
                  color: DefaultColors.color777,
                )),
            TextSpan(
              text: '$minRp',
              style: TextStyle(
                  fontSize: 10,
                  color: DefaultColors.color333,
                  fontWeight: FontWeight.bold),
            ),
            TextSpan(
                text: S.of(context).rp_deposits_minimum_amount_not_to_account,
                style: TextStyle(
                  fontSize: 10,
                  color: DefaultColors.color777,
                )),
          ],
        ),
      );
    } else {
      return Container();
    }
  }
}
