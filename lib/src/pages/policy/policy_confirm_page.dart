import 'package:flutter/material.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/cache/app_cache.dart';
import 'package:titan/src/pages/webview/inappwebview.dart';
import 'package:titan/src/pages/webview/webview.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';

class PolicyConfirmPage extends StatefulWidget {
  final PolicyType policyType;

  PolicyConfirmPage(this.policyType);

  @override
  State<StatefulWidget> createState() {
    return _PolicyConfirmPageState();
  }
}

class _PolicyConfirmPageState extends BaseState<PolicyConfirmPage> {
  bool _checked = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
        title: Text(
          '用户协议',
          style: TextStyle(
            fontSize: 18,
            color: Colors.black,
          ),
        ),
      ),
      body: _content(),
    );
  }

  _content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: _policyWebView(),
        ),
        _confirmView(),
      ],
    );
  }

  _policyWebView() {
    return InAppWebViewContainer(
      initUrl: 'https://www.baidu.com/',
      title: "",
      isShowAppBar: false,
    );
  }

  _confirmView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _checked = !_checked;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  _checked
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset(
                            'res/drawable/ic_checkbox_checked.png',
                            width: 20,
                            height: 20,
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset(
                            'res/drawable/ic_checkbox_unchecked.png',
                            width: 20,
                            height: 20,
                          ),
                        ),
                  Text(
                    '我已阅读并同意"用户协议"',
                    softWrap: true,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            child: ClickOvalButton(
              '同意并继续',
              () async {
                await _confirmPolicy();
              },
              fontSize: 16,
              isLoading: !_checked,
            ),
          ),
          SizedBox(
            height: 32,
          ),
        ],
      ),
    );
  }

  _confirmPolicy() async {
    if (widget.policyType == PolicyType.WALLET) {
      await AppCache.saveValue(
        PrefsKey.IS_CONFIRM_WALLET_POLICY,
        true,
      );
      Navigator.of(context).pop(true);
    } else if (widget.policyType == PolicyType.DEX) {
      await AppCache.saveValue(
        PrefsKey.IS_CONFIRM_DEX_POLICY,
        true,
      );
      Navigator.of(context).pop(true);
    }
  }
}

enum PolicyType {
  WALLET,
  DEX,
}
