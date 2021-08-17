import 'dart:async';
import 'dart:typed_data';

import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/pages/wallet/model/wallet_send_dialog_util.dart';
import 'package:titan/src/plugins/wallet/cointype.dart';
import 'package:titan/src/plugins/wallet/config/ethereum.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/log_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/utils/utils.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'package:web3dart/credentials.dart';
import 'package:web3dart/crypto.dart';
import 'package:titan/src/widget/common_page_view/loading_view.dart';

class TransferDialogPage extends StatefulWidget {
  final SendDialogEntity entity;

  TransferDialogPage({
    @required this.entity,
  });

  @override
  State<StatefulWidget> createState() {
    return _TransferDialogPageState();
  }
}

class _TransferDialogPageState extends BaseState<TransferDialogPage> {
  final ScrollController _scrollController = ScrollController();

  final StreamController<Map> _gasPriceStream = StreamController.broadcast();
  TextEditingController _gasPriceController = TextEditingController();
  TextEditingController _gasLimitController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  final int contrOptionsTypeGasFees = 0;

  static int stateLoading = 0;
  static int stateSuccess = 1;
  static int stateFail = 2;
  var currentState = stateLoading;

  @override
  void onCreated() {
    super.onCreated();

    initGasPriceAndLimit();
  }

  @override
  void dispose() {
    _gasPriceStream.close();

    super.dispose();
  }

  void initGasPriceAndLimit() async {
    try {
      var gasPrice = widget.entity.gasPrice;
      if (gasPrice == null) {
        gasPrice = await WalletUtil.ethGasPrice(widget.entity.coinType);
      }

      var gasLimit = widget.entity.gas;
      if (gasLimit == 0 && !widget.entity.isMainCoin) {
        var transData;
        if(widget.entity.transData != null){
          transData = bytesToHex(widget.entity.transData, include0x: true);
        }else{
          transData = WalletUtil.getErc20FuncAbiHex(
              contractAddress: widget.entity.contractAddress,
              funName: 'transfer',
              params: [
                EthereumAddress.fromHex(widget.entity.toAddress),
                widget.entity.value,
              ]);
        }
        var wallet = WalletInheritedModel
            .of(context)
            .activatedWallet
            .wallet;
        var estimateGasLimit = await wallet.estimateGasLimit(
          widget.entity.coinType,
          toAddress: widget.entity.toAddress,
          value: widget.entity.isMainCoin ? widget.entity.value : BigInt.zero,
          gasPrice: gasPrice,
          gasLimit: BigInt.from(widget.entity.gas),
          data: transData,
        );
        //print('888888, 3333, estimateGasLimit:${estimateGasLimit}');

        gasLimit = (estimateGasLimit.toInt() * 3).toInt();
        //print('888888, 4444, gasLimit:${gasLimit}');

      }else if(gasLimit == 0){
        gasLimit = 21000;
      }

      currentState = stateSuccess;
      widget.entity.gas = gasLimit;
      widget.entity.gasPrice = gasPrice;
      _gasPriceController.text =
          (Decimal.parse(gasPrice.toString()) / Decimal.fromInt(EthereumUnitValue.G_WEI))
              .toString();
      _gasLimitController.text = gasLimit.toString();
      if (mounted) {
        setState(() {});
      }
    }catch(error){
      currentState = stateFail;
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: BaseGestureDetector(
                context: context,
                child: Column(
                  children: [
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
                              '${widget.entity?.valueDirection} ${widget.entity.value == BigInt.zero ? widget.entity.value : ConvertTokenUnit.weiToEther(weiBigInt: widget.entity.value)} ${widget.entity.valueUnit}',
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
                    if(widget.entity.contractAddress?.isNotEmpty == true)
                      _rowText(
                        title: S.of(context).contract_address,
                        content: shortBlockChainAddress(widget.entity.contractAddress),
                      ),
                    _rowText(
                      // title: S.of(context).exchange_from,
                      title: S.of(context).operation_address,
                      content: widget.entity.fromAddress,
                      subContent: widget.entity.fromName,
                    ),
                    _rowText(
                      // title: S.of(context).exchange_to,
                      title: S.of(context).receiver_address,
                      content: widget.entity.toName,
                    ),
                    _gasWidget(),
                  ],
                ),
              ),
            ),
          ),
          if(currentState != stateLoading && currentState != stateFail)
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

  Widget _gasWidget() {
    if(currentState == stateLoading){
      return Column(
        children: [
          SizedBox(height: 50,),
          LoadingView(null),
        ],
      );
    }

    if(currentState == stateFail){
      return Column(
        children: [
          SizedBox(height: 50,),
          Text("数据检验失败",style: TextStyle(fontSize: 16,color: Colors.red),),
        ],
      );
    }
    return StreamBuilder<Object>(
        stream: _gasPriceStream.stream,
        builder: (context, snapshot) {
          var gasPrice = _gasPriceController.text;
          var gasLimit = _gasLimitController.text;
          var gasFeesStr = "";
          if(gasPrice?.isNotEmpty == true && gasLimit?.isNotEmpty == true){
            gasFeesStr = ConvertTokenUnit.weiToEther(weiBigInt: widget.entity.gasPrice * BigInt.from(widget.entity.gas)).toString();
          }
          return Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                _rowText(
                  title: S.of(context).transfer_gas_fee,
                  content: '$gasFeesStr ${widget.entity.gasUnit}',
                  subContent: widget.entity.gasDesc,
                  showLine: true,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: <Widget>[
                      SizedBox(
                        width: 100,
                        child: Text(
                          "燃料价格",
                          style: TextStyle(
                            fontSize: 14,
                            color: HexColor('#999999'),
                          ),
                        ),
                      ),
                      Container(
                        width: 80,
                        height: 64,
                        child: TextFormField(
                          controller: _gasPriceController,
                          validator: (value) {
                            if (value == null || value.trim().length == 0) {
                              return "不能为空";
                            } else {
                              return null;
                            }
                          },
                          onChanged: (String inputText) {
                            // _formKey.currentState.validate();
                            widget.entity.gasPrice = BigInt.parse((Decimal.parse(inputText) * Decimal.fromInt(EthereumUnitValue.G_WEI)).toString());
                            _gasPriceStream.add({contrOptionsTypeGasFees: ""});
                          },
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            hintStyle: TextStyle(
                                fontSize: 14,
                                color: DefaultColors.color333,
                                fontWeight: FontWeight.w500),
                          ),
                          keyboardType: TextInputType.text,
                        ),
                      ),
                      Text(
                        "GWEI",
                        style: TextStyle(
                          fontSize: 14,
                          color: HexColor('#333333'),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 0.5,
                  indent: 16,
                  endIndent: 16,
                  color: HexColor('#F2F2F2'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: <Widget>[
                      SizedBox(
                        width: 100,
                        child: Text(
                          "燃料限制",
                          style: TextStyle(
                            fontSize: 14,
                            color: HexColor('#999999'),
                          ),
                        ),
                      ),
                      Container(
                        width: 80,
                        height: 64,
                        child: TextFormField(
                          controller: _gasLimitController,
                          validator: (value) {
                            if (value == null || value.trim().length == 0) {
                              return "不能为空";
                            } else {
                              return null;
                            }
                          },
                          onChanged: (String inputText) {
                            // _formKey.currentState.validate();
                            widget.entity.gas = int.parse(inputText);
                            _gasPriceStream.add({contrOptionsTypeGasFees: ""});
                          },
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14),
                          decoration: InputDecoration(
                            hintStyle: TextStyle(
                                fontSize: 14,
                                color: DefaultColors.color333,
                                fontWeight: FontWeight.w500),
                          ),
                          keyboardType: TextInputType.text,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 0.5,
                  indent: 16,
                  endIndent: 16,
                  color: HexColor('#F2F2F2'),
                ),
              ],
            ),
          );
        });
  }

  void _cancelAction() {
    widget.entity.cancelAction();
    Navigator.pop(context);
  }

  void _sendAction() async {
    if (!_formKey.currentState.validate()) {
      return;
    }

    var password = await UiUtil.showWalletPasswordDialogV2(
      context,
      WalletModelUtil.wallet,
    );
    if (password == null || password.isEmpty) {
      setState(() {});
      return;
    }

    try {
      await widget.entity.confirmAction(password, widget.entity.gasPrice, widget.entity.gas);
    } catch (e, stack) {
      print("!!!00 $e $stack");
      LogUtil.toastException(e, stack: null);
      setState(() {});
    }
  }
}

Future<bool> showTransferDialog<T>({
  @required BuildContext context,
  @required SendDialogEntity entity,
  bool isDismissible,
}) {
  return UiUtil.showBottomDialogView(
    context,
    dialogHeight: MediaQuery.of(context).size.height - 90,
    isScrollControlled: true,
    enableDrag: false,
    isDismissible: isDismissible,
    customWidget: TransferDialogPage(
      entity: entity,
    ),
  );
}

typedef DAppSendCancelCallBack = Future<bool> Function();
typedef DAppSendConfirmCallBack = Future<bool> Function(String psw, BigInt gasPrice, int gasLimit);

class SendDialogEntity {
  final BigInt value;
  final String valueUnit;
  final String valueDirection;
  final String title;
  final String titleDesc;
  final String fromName;
  final String fromAddress;
  final String toName;
  final String toAddress;
  int gas;
  final String gasDesc;
  final String gasUnit;
  final String contractAddress;
  final Uint8List transData;
  final DAppSendCancelCallBack cancelAction;
  final DAppSendConfirmCallBack confirmAction;
  final bool isEnableEditGas;
  final int coinType;
  BigInt gasPrice;
  bool isMainCoin;

  SendDialogEntity({
    this.value,
    this.valueUnit,
    this.valueDirection = '-',
    this.title,
    this.titleDesc = '',
    this.fromName,
    this.fromAddress,
    this.toName,
    this.toAddress,
    this.gas,
    this.gasDesc = '',
    this.gasUnit,
    this.contractAddress,
    this.transData,
    this.cancelAction,
    this.confirmAction,
    this.isEnableEditGas = false,
    this.coinType,
    this.gasPrice,
    this.isMainCoin = false
  });
}
