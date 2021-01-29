import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/pages/wallet/model/wallet_send_dialog_util.dart';
import 'package:titan/src/utils/log_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';

class WalletSendDialogPage extends StatefulWidget {
  final WalletSendDialogEntity entity;
  WalletSendDialogPage({
    @required this.entity,
  });

  @override
  State<StatefulWidget> createState() {
    return _WalletSendDialogState();
  }
}

class _WalletSendDialogState extends BaseState<WalletSendDialogPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    Widget widget1 = Container();
    Widget widget2 = Container();

    var gasValue = double?.tryParse(widget?.entity?.gas ?? '0') ?? 0;
    var gasValue1 = double?.tryParse(widget?.entity?.gas1 ?? '0') ?? 0;

    if (gasValue > 0 && gasValue1 > 0) {
      widget1 = _rowText(
        title: S.of(context).transfer_gas_fee,
        content: '${widget.entity.gas} ${widget.entity.gasUnit}',
        subContent: widget.entity.gasDesc,
        showLine: false,
      );

      widget2 = _rowText(
        title: '',
        content: '${widget.entity.gas1} ${widget.entity.gasUnit}',
        subContent: widget.entity.gas1Desc,
        showLine: false,
      );
    } else {
      if (gasValue > 0) {
        widget1 = _rowText(
          title: S.of(context).transfer_gas_fee,
          content: '${widget.entity.gas} ${widget.entity.gasUnit}',
          subContent: widget.entity.gasDesc,
          showLine: false,
        );
      }
    }

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
                            widget.entity.valueDirection == '-' ? '转账确认' : '提取确认',
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
                    if ((widget.entity?.value ?? 0) > 0)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 16,
                            ),
                            child: Text(
                              '${widget.entity?.valueDirection} ${widget.entity?.value ?? '0'} ${widget.entity.valueUnit}',
                              style: TextStyle(
                                color: HexColor('#333333'),
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    if ((widget.entity?.value1 ?? 0) > 0)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 16,
                            ),
                            child: Text(
                              '${widget.entity?.valueDirection} ${widget.entity?.value1 ?? '0'} ${widget.entity.value1Unit}',
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
                      title: '交易信息',
                      content: widget.entity.title,
                      subContent: widget.entity.titleDesc,
                    ),
                    _rowText(
                      title: S.of(context).exchange_from,
                      content: widget.entity.fromName,
                      subContent: widget.entity.fromAddress,
                    ),
                    _rowText(
                      title: S.of(context).exchange_to,
                      content: widget.entity.toName,
                      subContent: widget.entity.toAddress,
                    ),
                    widget1,
                    widget2,
                  ],
                ),
              ),
            ),
            ClickOvalButton(
              S.of(context).send,
              _sendAction,
              btnColor: [HexColor("#E7C01A"), HexColor("#F7D33D")],
              fontSize: 16,
              width: 260,
              height: 42,
              isLoading: _isLoading,
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

  void _sendAction() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    bool isFinish;
    try {
      var password = await UiUtil.showWalletPasswordDialogV2(
        context,
        WalletModelUtil.wallet,
      );

      if (password == null) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }

      isFinish = await widget.entity.action(password);
    } catch (e) {
      LogUtil.toastException(e);

      isFinish = false;
    }

    print("[$runtimeType] _sendAction, isFinish:$isFinish");

    if (isFinish) {
      Navigator.of(context).pop();

      widget.entity.finished('');
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

Future<bool> showWalletSendDialog<T>({
  @required BuildContext context,
  @required WalletSendDialogEntity entity,
}) {
  return UiUtil.showBottomDialogView(
    context,
    dialogHeight: MediaQuery.of(context).size.height - 90,
    isScrollControlled: true,
    customWidget: WalletSendDialogPage(
      entity: entity,
    ),
  );
}

typedef WalletSendEntityCallBack = Future<bool> Function(String psw);

class WalletSendDialogEntity {
  final String type;
  final double value;
  final double value1;
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

  final WalletSendEntityCallBack action;
  final WalletSendEntityCallBack finished;

  WalletSendDialogEntity({
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
    this.action,
    this.finished,
  });
}
