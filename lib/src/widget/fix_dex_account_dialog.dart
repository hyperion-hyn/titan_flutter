import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/pages/market/api/exchange_api.dart';
import 'package:titan/src/pages/market/model/asset_history.dart';
import 'package:titan/src/utils/utile_ui.dart';

import 'loading_button/click_oval_button.dart';

class FixDexAccountDialog extends StatefulWidget {
  final AbnormalTransferHistory abnormalTransferHistory;

  FixDexAccountDialog(this.abnormalTransferHistory);

  @override
  State<StatefulWidget> createState() {
    return FixDexAccountDialogState();
  }
}

class FixDexAccountDialogState extends State<FixDexAccountDialog> {
  var _currentFixState = FixState.show;
  ExchangeApi _exchangeApi = ExchangeApi();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Duration insetAnimationDuration = const Duration(milliseconds: 100);
    Curve insetAnimationCurve = Curves.decelerate;
    return AnimatedPadding(
      padding: MediaQuery.of(context).viewInsets +
          const EdgeInsets.symmetric(horizontal: 32.0),
      duration: insetAnimationDuration,
      curve: insetAnimationCurve,
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                        color: Colors.white,
                      ),
                      child: _content(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _content() {
    if (_currentFixState == FixState.show) {
      return _fixView();
    } else if (_currentFixState == FixState.fixing) {
      return _fixingView();
    } else if (_currentFixState == FixState.success) {
      return _fixResultView(true);
    } else if (_currentFixState == FixState.fail) {
      return _fixResultView(false);
    }
  }

  _fixView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: 16,
          ),
          Text(
            S.of(context).dex_fix_account_dialog_title,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: HexColor("#333333"),
                decoration: TextDecoration.none),
          ),
          Padding(
              padding: EdgeInsets.only(
                top: 16,
                left: 16,
                right: 16,
              ),
              child: Text(S.of(context).dex_fix_account_balance_condition,
                  style: TextStyle(
                    fontSize: 14,
                    color: HexColor("#333333"),
                    height: 1.8,
                  ))),
          SizedBox(
            height: 14.0,
          ),
          if (Decimal.parse(widget.abnormalTransferHistory.hyn) >
              Decimal.fromInt(0))
            Text(
                'HYN ${S.of(context).not_less_than} ${widget.abnormalTransferHistory.hyn}'),
          SizedBox(
            height: 8.0,
          ),
          if (Decimal.parse(widget.abnormalTransferHistory.usdt) >
              Decimal.fromInt(0))
            Text(
                'USDT ${S.of(context).not_less_than} ${widget.abnormalTransferHistory.usdt}'),
          SizedBox(
            height: 16,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: FlatButton(
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                    child: Text(
                      S.of(context).back,
                      style:
                          TextStyle(color: HexColor("#333333"), fontSize: 16),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: ClickOvalButton(
                    S.of(context).confirm,
                    () async {
                      setState(() {
                        _currentFixState = FixState.fixing;
                      });
                      try {
                        var activatedWalletVo = WalletInheritedModel.of(
                          context,
                          aspect: WalletAspect.activatedWallet,
                        ).activatedWallet;

                        var walletPassword =
                            await UiUtil.showWalletPasswordDialogV2(
                          context,
                          activatedWalletVo.wallet,
                        );

                        var result = await _exchangeApi.fixAbnormalAccount(
                          activatedWalletVo.wallet,
                          walletPassword,
                          activatedWalletVo.wallet.getEthAccount().address,
                        );
                        if (result != null) {
                          setState(() {
                            _currentFixState = FixState.success;
                          });
                        } else {
                          setState(() {
                            _currentFixState = FixState.fail;
                          });
                        }
                      } catch (e) {
                        setState(() {
                          _currentFixState = FixState.fail;
                        });
                      }
                    },
                    width: 120,
                    height: 38,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  _fixingView() {
    return Container(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32.0),
          child: Column(
            children: [
              SizedBox(
                height: 16,
              ),
              SizedBox(
                height: 40,
                width: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                ),
              ),
              SizedBox(
                height: 32,
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  S.of(context).dex_fixing_account,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  _fixResultView(bool isSuccess) {
    return Container(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Image.asset(
                isSuccess
                    ? 'res/drawable/check_outline.png'
                    : 'res/drawable/cross_outline.png',
                width: 110,
                height: 68,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: isSuccess
                  ? Text(
                      S.of(context).dex_fix_account_success,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : Column(
                      children: [
                        Text(
                          '${S.of(context).dex_fix_accounta_fail}:',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        if (Decimal.parse(widget.abnormalTransferHistory.hyn) >
                            Decimal.fromInt(0))
                          Text(
                              'HYN ${S.of(context).not_less_than} ${widget.abnormalTransferHistory.hyn}'),
                        SizedBox(
                          height: 8.0,
                        ),
                        if (Decimal.parse(widget.abnormalTransferHistory.usdt) >
                            Decimal.fromInt(0))
                          Text(
                              'USDT ${S.of(context).not_less_than} ${widget.abnormalTransferHistory.usdt}'),
                      ],
                    ),
            ),
            SizedBox(
              height: 32,
            ),
            ClickOvalButton(
              S.of(context).confirm,
              () {
                if (isSuccess) {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                } else {
                  Navigator.of(context).pop();
                }
              },
              width: 120,
              height: 38,
              fontSize: 16,
            ),
            SizedBox(
              height: 16.0,
            )
          ],
        ),
      ),
    );
  }
}

enum FixState { show, fixing, fail, success }
