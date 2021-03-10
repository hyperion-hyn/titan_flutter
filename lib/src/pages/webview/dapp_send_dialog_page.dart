import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/pages/wallet/model/wallet_send_dialog_util.dart';
import 'package:titan/src/plugins/wallet/cointype.dart';
import 'package:titan/src/plugins/wallet/config/ethereum.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';

class DAppSendDialogPage extends StatefulWidget {
  final DAppSendDialogEntity entity;
  DAppSendDialogPage({
    @required this.entity,
  });

  @override
  State<StatefulWidget> createState() {
    return _DAppSendDialogState();
  }
}

class _DAppSendDialogState extends BaseState<DAppSendDialogPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  final StreamController<double> _gasPriceController = StreamController.broadcast();

  Decimal _minGasPrice = Decimal.fromInt(1 * EthereumUnitValue.G_WEI);
  Decimal _maxGasPrice = Decimal.fromInt(100 * EthereumUnitValue.G_WEI);
  Decimal get _gasPrice {
    if(widget.entity.gasPrice != null){
      return widget.entity.gasPrice;
    } else {
      return _minGasPrice;
    }
  }
  set _setGasPrice(Decimal gasPrice) {
    widget.entity.gasPrice = gasPrice;
  }

  int get _defaultGasLimit {
    var defaultValue = widget.entity.gasUnit == "ETH"
        ? SettingInheritedModel.ofConfig(context).systemConfigEntity.ethTransferGasLimit
        : SettingInheritedModel.ofConfig(context).systemConfigEntity.erc20TransferGasLimit;
    return defaultValue;
  }

  int get _gasLimit {
    var gasLimit;

    // 1.BTC
    if (widget.entity.coinType == CoinType.BITCOIN) {
      gasLimit = 78;
    }
    // 2.ETH
    else if (widget.entity.coinType == CoinType.ETHEREUM) {
      var initGasLimit = _defaultGasLimit;
      gasLimit = initGasLimit;
    }
    // 3.ATLAS
    else if (widget.entity.coinType == CoinType.HYN_ATLAS) {
      if (widget.entity.gasUnit == 'HYN') {
        gasLimit = SettingInheritedModel.ofConfig(context).systemConfigEntity.ethTransferGasLimit;
      } else {
        gasLimit = SettingInheritedModel.ofConfig(context).systemConfigEntity.erc20TransferGasLimit;
      }
    }
    // 3.HB
    else if (widget.entity.coinType == CoinType.HB_HT) {
      if (widget.entity.gasUnit == 'HT') {
        gasLimit = SettingInheritedModel.ofConfig(context).systemConfigEntity.ethTransferGasLimit;
      } else {
        gasLimit = SettingInheritedModel.ofConfig(context).systemConfigEntity.erc20TransferGasLimit;
      }
    }

    return gasLimit;
  }

  Decimal get _gasFees {
    var fees = Decimal.zero;


    // 1.BTC
    if (widget.entity.coinType == CoinType.BITCOIN) {
      fees = ConvertTokenUnit.weiToDecimal(
          BigInt.parse((_gasPrice * Decimal.fromInt(_gasLimit)).toString()), 8);
    }
    // 2.ETH
    else if (widget.entity.coinType == CoinType.ETHEREUM) {
      fees = ConvertTokenUnit.weiToEther(
          weiBigInt: BigInt.parse((_gasPrice * Decimal.fromInt(_gasLimit)).toStringAsFixed(0)));
    }
    // 3.ATLAS
    else if (widget.entity.coinType == CoinType.HYN_ATLAS) {
      fees = ConvertTokenUnit.weiToEther(
          weiBigInt: BigInt.parse((_gasPrice * Decimal.fromInt(_gasLimit)).toStringAsFixed(0)));
    }
    // 3.HB
    else if (widget.entity.coinType == CoinType.HB_HT) {
      fees = ConvertTokenUnit.weiToEther(
          weiBigInt: BigInt.parse((_gasPrice * Decimal.fromInt(_gasLimit)).toStringAsFixed(0)));
    }
    //print("[dDpp] _gasLimit:$_gasLimit, fees:$fees");

    return fees;
  }

  String get _gasFeesStr => FormatUtil.formatNumDecimal(_gasFees.toDouble(), decimal: 6);

  @override
  void dispose() {
    _gasPriceController.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget gas = _rowText(
      title: S.of(context).transfer_gas_fee,
      content: '${widget.entity.gas} ${widget.entity.gasUnit}',
      subContent: widget.entity.gasDesc,
      showLine: false,
    );

    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    // SizedBox(height: 200,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 14,
                          ),
                          child: Text(
                            widget.entity.valueDirection == '-'
                                ? S.of(context).transfer_confirm
                                : S.of(context).extract_confirmation,
                            style: TextStyle(
                              color: HexColor('#999999'),
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 32,
                          ),
                          child: Image.asset(
                            'res/drawable/wallet_send_dialog.png',
                            width: 44,
                            height: 44,
                            fit: BoxFit.cover,
                            // color: HexColor('#E7C01A'),
                          ),
                        ),
                      ],
                    ),
                    if (widget.entity.value != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 16,
                            ),
                            child: Text(
                              '${widget.entity?.valueDirection} ${widget.entity.value == BigInt.zero ? widget.entity.value
                                  : ConvertTokenUnit.weiToEther(weiBigInt: widget.entity.value)} ${widget.entity.valueUnit}',
                              style: TextStyle(
                                color: HexColor('#333333'),
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    if (widget.entity.value1 != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 16,
                            ),
                            child: Text(
                              '${widget.entity?.valueDirection} ${widget.entity.value1 == BigInt.zero ? widget.entity.value1
                                  : ConvertTokenUnit.weiToEther(weiBigInt: widget.entity.value1)} ${widget.entity.value1Unit}',
                              style: TextStyle(
                                color: HexColor('#333333'),
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    SizedBox(
                      height: 40,
                    ),
                    _rowText(
                      title: S.of(context).trading_information,
                      content: widget.entity.title,
                      subContent: widget.entity.titleDesc,
                    ),
                    _rowText(
                      title: "合约地址",
                      content: widget.entity.toName,
                      subContent: widget.entity.toAddress,
                    ),
                    _rowText(
                      // title: S.of(context).exchange_from,
                      title: "操作地址",
                      content: widget.entity.fromAddress,
                      subContent: widget.entity.fromName,
                    ),
                    _rowText(
                      // title: S.of(context).exchange_to,
                      title: "接收地址",
                      content: widget.entity.toName,
                      subContent: widget.entity.toAddress,
                    ),
                    !widget.entity.isEnableEditGas ? gas : _gasPriceWidget(),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClickOvalButton(
                  S.of(context).cancel,
                  _cancelAction,
                  width: 160,
                  height: 42,
                  fontSize: 14,
                  fontColor: Theme.of(context).primaryColor,
                  btnColor: [Colors.transparent],
                  borderColor: Theme.of(context).primaryColor,
                ),
                SizedBox(
                  width: 20,
                ),
                ClickOvalButton(
                  S.of(context).confirm,
                  _sendAction,
                  btnColor: [HexColor("#E7C01A"), HexColor("#F7D33D")],
                  fontSize: 14,
                  width: 160,
                  height: 42,
                ),
              ],
            ),
            SizedBox(
              height: 40,
            ),
          ],
        ),
      ),
    );
  }

  Widget _rowText({
    String title = '',
    String content = '',
    String subContent = '',
    bool showLine = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: title.isNotEmpty ? 20 : 2,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: HexColor('#999999'),
                    ),
                  ),
                ),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 14,
                    color: HexColor('#333333'),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  (subContent?.isEmpty ?? true) ? '' : '（$subContent）',
                  style: TextStyle(
                    fontSize: 14,
                    color: HexColor('#999999'),
                  ),
                ),
              ],
            ),
          ),
          if (showLine)
            Container(
              margin: const EdgeInsets.only(top: 10),
              height: 0.5,
              color: HexColor('#F2F2F2'),
            ),
        ],
      ),
    );
  }

  Widget _gasPriceWidget() {
    return StreamBuilder<Object>(
        stream: _gasPriceController.stream,
        builder: (context, snapshot) {

          return Column(
            children: <Widget>[
              _rowText(
                title: S.of(context).transfer_gas_fee,
                content: '$_gasFeesStr ${widget.entity.gasUnit}',
                subContent: widget.entity.gasDesc,
                showLine: false,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: <Widget>[
                    Image.asset(
                      'res/drawable/slow_speed.png',
                      fit: BoxFit.cover,
                      width: 19,
                      height: 16,
                    ),
                    Flexible(
                      flex: 3,
                      child: Slider(
                        value: _gasPrice.toDouble(),
                        activeColor: Theme.of(context).primaryColor,
                        inactiveColor: Colors.grey[300],
                        min: _minGasPrice.toDouble(),
                        max: _maxGasPrice.toDouble(),
                        label: '${ConvertTokenUnit.weiToGWei(weiInt: _gasPrice.toInt())} gwei',
                        onChanged: (double newValue) {
                          _gasPriceController.add(newValue);
                          _setGasPrice = Decimal.parse(newValue.toString());
                        },
                        semanticFormatterCallback: (double newValue) {
                          return '$newValue gwei';
                        },
                      ),
                    ),
                    Image.asset(
                      'res/drawable/quickly_speed.png',
                      fit: BoxFit.cover,
                      width: 19,
                      height: 19,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: <Widget>[
                    Spacer(),
                    Text(
                      "${ConvertTokenUnit.weiToGWei(weiInt: _gasPrice.toInt()).toStringAsPrecision(4)} gwei",
                      style: TextStyle(
                        fontSize: 14,
                        color: HexColor('#999999'),
                      ),
                    ),
                    Spacer(),
                  ],
                ),
              ),
            ],
          );
        });
  }

  void _cancelAction() {
    widget.entity.cancelAction('', Decimal.zero);
    Navigator.pop(context);
  }

  void _sendAction() async {
    var password = await UiUtil.showWalletPasswordDialogV2(
      context,
      WalletModelUtil.wallet,
    );
    await widget.entity.confirmAction(password, _gasPrice);
  }
}

Future<bool> showDAppSendDialog<T>({
  @required BuildContext context,
  @required DAppSendDialogEntity entity,
  bool isDismissible,
}) {
  return UiUtil.showBottomDialogView(
    context,
    dialogHeight: MediaQuery.of(context).size.height - 90,
    isScrollControlled: true,
    isDismissible: isDismissible,
    customWidget: DAppSendDialogPage(
      entity: entity,
    ),
  );
}

typedef DAppSendEntityCallBack = Future<bool> Function(String psw, Decimal gasPrice);

class DAppSendDialogEntity {
  final String type;
  final BigInt value;
  final BigInt value1;
  final String valueUnit;
  final String value1Unit;
  final String valueDirection;
  final String title;
  final String titleDesc;
  final String fromName;
  final String fromAddress;
  final String toName;
  final String toAddress;
  final String gas;
  final String gas1;
  final String gasDesc;
  final String gas1Desc;
  final String gasUnit;
  final String contractAddress;
  final DAppSendEntityCallBack cancelAction;
  final DAppSendEntityCallBack confirmAction;
  final bool isEnableEditGas;
  final int coinType;
  Decimal gasPrice;

  DAppSendDialogEntity({
    this.type,
    this.value,
    this.value1,
    this.valueUnit,
    this.value1Unit,
    this.valueDirection = '-',
    this.title,
    this.titleDesc = '',
    this.fromName,
    this.fromAddress,
    this.toName,
    this.toAddress,
    this.gas,
    this.gas1,
    this.gasDesc = '',
    this.gas1Desc = '',
    this.gasUnit,
    this.cancelAction,
    this.confirmAction,
    this.contractAddress,
    this.isEnableEditGas = false,
    this.coinType,
    this.gasPrice,
  });
}
