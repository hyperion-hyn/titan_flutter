import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/widget/auth_dialog/bio_auth_dialog_bloc.dart';
import 'package:titan/src/widget/auth_dialog/bio_auth_dialog_event.dart';
import 'package:titan/src/widget/auth_dialog/bio_auth_dialog_state.dart';
import 'package:titan/src/widget/enter_wallet_password.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

class BioAuthDialog extends StatefulWidget {
  @override
  BaseState<StatefulWidget> createState() {
    return _BioAuthDialogState();
  }
}

class _BioAuthDialogState extends BaseState<BioAuthDialog> {
  final LocalAuthentication auth = LocalAuthentication();

  BioAuthDialogBloc authDialogBloc = BioAuthDialogBloc();

  bool _showContent = true;

  void initState() {
    super.initState();
    // TODO: implement initState
    authDialogBloc.add(CheckAuthConfigEvent());
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    authDialogBloc.close();
  }

  @override
  void onCreated() {
    // TODO: implement onCreated
    super.onCreated();
  }

  @override
  Widget build(BuildContext context) {
    Duration insetAnimationDuration = const Duration(milliseconds: 100);
    Curve insetAnimationCurve = Curves.decelerate;
    return BlocListener<BioAuthDialogBloc, BioAuthDialogState>(
      bloc: authDialogBloc,
      listener: (context, state) {
        if (state is AuthCompletedState) {
          if (mounted)
            setState(() {
              _showContent = false;
            });
          Navigator.of(context).pop(state.result);
        }
      },
      child: BlocBuilder<BioAuthDialogBloc, BioAuthDialogState>(
        bloc: authDialogBloc,
        builder: (ctx, state) {
          var content;
          if (state is ShowFaceAuthState) {
            content = _faceAuthWidget(
              state.remainCount,
              state.maxCount,
            );
          } else if (state is ShowFingerprintAuthState) {
            content = _fingerprintAuthWidget(
              state.remainCount,
              state.maxCount,
            );
          }
          return AnimatedPadding(
            padding: MediaQuery.of(context).viewInsets +
                const EdgeInsets.symmetric(horizontal: 32.0),
            duration: insetAnimationDuration,
            curve: insetAnimationCurve,
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: _showContent
                    ? SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15)),
                                color: Colors.white,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      '钱包授权登陆',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (content != null) content
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    : SizedBox(),
              ),
            ),
          );
        },
      ),
    );
  }

  _resultView(bool result) {
    return Container(
      width: 300,
      height: 300,
      //      child: Center(
      //        child: Column(
      //          children: <Widget>[
      //            Text(result ? '验证成功' : '验证失败'),
      //            Text('当前钱包密码: $_currentWalletPwd'),
      //          ],
      //        ),
      //      ),
    );
  }

  _faceAuthWidget(int remainCount, int maxCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'res/drawable/ic_face_id.png',
            width: 80,
            height: 80,
            color: Theme.of(context).primaryColor,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            '钱包的Face ID',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Text('请验证已有的Face ID'),
        if (remainCount < maxCount)
          InkWell(
            onTap: () {
              authDialogBloc.add(BioAuthStartEvent());
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '重新识别',
                style: TextStyle(
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        SizedBox(
          height: 16,
        ),
        if (remainCount < maxCount) _bioAuthRemainCountHint(remainCount),
      ],
    );
  }

  _fingerprintAuthWidget(int remainCount, int maxCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'res/drawable/ic_fingerprint.png',
            width: 80,
            height: 80,
            color: Theme.of(context).primaryColor,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            '钱包的Touch ID',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        if (remainCount < maxCount)
          InkWell(
            onTap: () {
              authDialogBloc.add(BioAuthStartEvent());
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '重新识别',
                style: TextStyle(
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        Text('请验证已有的指纹'),
        if (remainCount < maxCount) _bioAuthRemainCountHint(remainCount)
      ],
    );
  }

  _bioAuthRemainCountHint(int remainCount) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Wrap(
        children: <Widget>[
          Text('识别失败，剩余$remainCount次'),
          SizedBox(
            width: 8,
          ),
          InkWell(
            child: Text(
              '取消',
              style: TextStyle(color: Colors.blue),
            ),
            onTap: () {
              //authDialogBloc.add(ShowPasswordAuthEvent());
              authDialogBloc.add(AuthCompletedEvent(false));
            },
          )
        ],
      ),
    );
  }
//
//  _onAuthorized() async {
//    Wallet wallet = WalletInheritedModel.of(context).activatedWallet.wallet;
//    String address = wallet.getEthAccount().address;
//    FlutterSecureStorage flutterSecureStorage = FlutterSecureStorage();
//    String pwd = await flutterSecureStorage.read(
//        key: '${SecurePrefsKey.WALLET_PWD_KEY_PREFIX}$address');
//    setState(() {
//      _currentWalletPwd = pwd;
//    });
//    // Navigator.of(context).pop(true);
//  }
}
