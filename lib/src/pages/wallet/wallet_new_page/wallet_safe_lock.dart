import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:titan/src/utils/utile_ui.dart';

class WalletSafeLock extends StatefulWidget {
  final Function onUnlock;

  WalletSafeLock({
    @required this.onUnlock,
  });

  @override
  State<StatefulWidget> createState() {
    return _WalletSafeLockState();
  }
}

class _WalletSafeLockState extends State<WalletSafeLock> {
  final TextEditingController _pinPutController = TextEditingController();
  final FocusNode _pinPutFocusNode = FocusNode();

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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 48.0,
              bottom: 64,
            ),
            child: Image.asset(
              'res/drawable/img_safe_lock.png',
              width: 80,
              height: 80,
            ),
          ),
          Text(
            '请输入密码',
            style: TextStyle(
              fontSize: 14,
            ),
          ),
          SizedBox(
            height: 24,
          ),
          Container(
            width: 200,
            child: PinPut(
              preFilledWidget: Container(
                width: 15,
                height: 3,
                color: Colors.black,
              ),
              eachFieldConstraints: const BoxConstraints(
                minHeight: 20.0,
                minWidth: 20.0,
              ),
              obscureText: '●',
              fieldsCount: 6,
              onSubmit: (String pin) => _submit(pin),
              focusNode: _pinPutFocusNode,
              controller: _pinPutController,
              autofocus: true,
            ),
          ),
        ],
      ),
    );
  }

  _submit(String pin) async {
    if (await _checkPwdValid(pin)) {
      widget.onUnlock?.call();
    } else {
      UiUtil.showErrorTopHint(
        context,
        '密码错误，请重试',
      );
      _pinPutController.text = '';
    }
  }

  Future<bool> _checkPwdValid(String pin) async {
    if (pin == '111111') {
      return true;
    } else {
      return false;
    }
  }
}
