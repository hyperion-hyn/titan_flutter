import 'dart:async';

import 'package:flutter/material.dart';
import 'package:titan/config.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/cache/app_cache.dart';
import 'package:titan/src/pages/webview/inappwebview.dart';
import 'package:titan/src/pages/webview/webview.dart';
import 'package:titan/src/style/titan_sytle.dart';
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
  Timer _timer;
  int _autoConfirmCount = 5;

  @override
  void initState() {
    super.initState();
    _initTimer();
  }

  _initTimer() {
    ///refresh epoch
    ///
    _timer = Timer.periodic(Duration(seconds: 1), (t) {
      _autoConfirmCount--;
      if (_autoConfirmCount < 0) {
        _checked = true;
        _timer.cancel();
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    if (_timer != null && _timer.isActive) {
      _timer.cancel();
      _timer = null;
    }
    super.dispose();
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
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: _policyWebView(),
          ),
          _confirmView(),
        ],
      ),
    );
  }

  _policyWebView() {
    var policyUrl = '';
    if (widget.policyType == PolicyType.WALLET) {
      if (SettingInheritedModel.of(context).languageModel.isZh()) {
        policyUrl = Config.WALLET_POLICY_CN_URL;
      } else {
        policyUrl = Config.WALLET_DEX_EN_URL;
      }
    } else if (widget.policyType == PolicyType.DEX) {
      if (SettingInheritedModel.of(context).languageModel.isZh()) {
        policyUrl = Config.WALLET_DEX_CN_URL;
      } else {
        policyUrl = Config.WALLET_DEX_EN_URL;
      }
    }
    return InAppWebViewContainer(
      initUrl: policyUrl,
      title: "",
      isShowAppBar: false,
    );
  }

  _confirmView() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20.0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 8,
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  if (_autoConfirmCount < 0) {
                    _checked = !_checked;
                  }
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    _checked
                        ? Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Image.asset(
                              'res/drawable/ic_checkbox_checked.png',
                              width: 20,
                              height: 20,
                            ),
                          )
                        : Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
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
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 8,
            ),
            _autoConfirmCount > 0
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text(
                      '还需 $_autoConfirmCount 秒',
                      softWrap: true,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: DefaultColors.color999,
                      ),
                    ),
                  )
                : SizedBox(),
            SizedBox(
              height: 2,
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
