import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:titan/config.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/cache/app_cache.dart';
import 'package:titan/src/pages/webview/inappwebview.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';

class PolicyConfirmPage extends StatefulWidget {
  final PolicyType policyType;
  final bool isShowConfirm;
  final bool isDialog;

  PolicyConfirmPage(
    this.policyType, {
    this.isShowConfirm = true,
    this.isDialog = false,
  });

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
      appBar: widget.isDialog
          ? null
          : AppBar(
              backgroundColor: Colors.white,
              centerTitle: true,
              iconTheme: IconThemeData(color: Colors.black),
              elevation: 0,
              title: Text(
                S.of(context).user_policy,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (widget.isDialog)
            Container(
              child: Stack(
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16.0, bottom: 8),
                      child: Text(
                        '服务条款',
                        style: TextStyle(
                          fontSize: 14,
                          color: DefaultColors.color999,
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Image.asset(
                        'res/drawable/ic_close.png',
                        width: 10,
                        height: 10,
                      ),
                    ),
                  )
                ],
              ),
            ),
          Expanded(
            child: Padding(
              padding: widget.isDialog
                  ? const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    )
                  : EdgeInsets.symmetric(
                      horizontal: 0.0,
                      vertical: 0.0,
                    ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _policyWebView(),
              ),
            ),
          ),
          if (widget.isShowConfirm) _confirmView(),
        ],
      ),
    );
  }

  _policyWebView() {
    var policyUrl = '';
    if (widget.policyType == PolicyType.WALLET) {
      if (SettingInheritedModel.of(context)?.languageModel?.isZh() ?? true) {
        policyUrl = Config.WALLET_POLICY_CN_URL;
      } else {
        policyUrl = Config.WALLET_POLICY_EN_URL;
      }
    } else if (widget.policyType == PolicyType.DEX) {
      if (SettingInheritedModel.of(context)?.languageModel?.isZh() ?? true) {
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                if (_autoConfirmCount < 0) {
                  _checked = !_checked;
                }
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              child: Container(
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
                      '${S.of(context).i_hava_read_and_agree_policy}"${S.of(context).user_policy}"',
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
          ),
          SizedBox(
            height: 8,
          ),
          _autoConfirmCount > 0
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Text(
                    S.of(context).still_need_secs(_autoConfirmCount),
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
          ClickOvalButton(
            S.of(context).agree_and_continue,
            () async {
              await _confirmPolicy();
            },
            width: 300,
            height: 46,
            btnColor: [
              HexColor("#F7D33D"),
              HexColor("#E7C01A"),
            ],
            fontSize: 16,
            fontColor: DefaultColors.color333,
            isDisable: !_checked,
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
