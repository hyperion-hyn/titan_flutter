import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:local_auth/local_auth.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/auth/bloc/auth_bloc.dart';
import 'package:titan/src/components/auth/bloc/auth_state.dart';
import 'package:titan/src/components/wallet/vo/wallet_vo.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/cache/app_cache.dart';

import 'model.dart';

class AuthComponent extends StatelessWidget {
  final Widget child;

  AuthComponent({@required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (ctx) => AuthBloc(),
      child: _AuthManager(child: child),
    );
  }
}

class _AuthManager extends StatefulWidget {
  final Widget child;

  _AuthManager({@required this.child});

  @override
  State<StatefulWidget> createState() {
    return _AuthManagerState();
  }
}

class _AuthManagerState extends BaseState<_AuthManager> {
  AuthConfigModel authConfigModel;
  bool authorized;
  WalletVo _activatedWallet;

  @override
  void onCreated() {
    // TODO: implement onCreated
    super.onCreated();
    _activatedWallet = WalletInheritedModel.of(context).activatedWallet;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is UpdateAuthConfigState) {
          print('UpdateAuthConfigState:::: ${state.authConfigModel.toJSON()}');
          if (state.authConfigModel != null) {
            authConfigModel = state.authConfigModel;
            if (_activatedWallet != null) {
              var fileName = _activatedWallet.wallet.keystore.fileName;
              print('UpdateAuthConfigState::::  fileName: $fileName');
              AppCache.saveValue<String>(
                  '${PrefsKey.AUTH_CONFIG}_$fileName',
                  json.encode(
                    state.authConfigModel.toJSON(),
                  ));
            } else {
              print('UpdateAuthConfigState:::: _activatedWallet: null');
            }
          }
        } else if (state is RefreshBioAuthConfigState) {
          if (_activatedWallet != null) {
            var authConfigStr = await AppCache.getValue<String>(
                '${PrefsKey.AUTH_CONFIG}_${_activatedWallet.wallet.keystore.fileName}');
            if (authConfigStr != null) {
              AuthConfigModel model =
                  AuthConfigModel.fromJson(json.decode(authConfigStr));
              if (model != null) authConfigModel = model;
            }
          }
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return AuthInheritedModel(
            authorized: authorized,
            authConfigModel: authConfigModel,
            child: widget.child,
          );
        },
      ),
    );
  }
}

enum AuthAspect { authorized, config }

class AuthInheritedModel extends InheritedModel<AuthAspect> {
  ///Store quick-auth config
  final AuthConfigModel authConfigModel;

  ///Only while in app
  final bool authorized;

  AuthInheritedModel({
    Key key,
    @required this.authorized,
    @required this.authConfigModel,
    @required Widget child,
  }) : super(key: key, child: child);

  bool get bioAuthAvailable {
    if (authConfigModel != null) {
      return authConfigModel.availableBiometricTypes.length > 0;
    } else {
      return false;
    }
  }

  bool get bioAuthEnabled {
    return authConfigModel.useFace || authConfigModel.useFingerprint;
  }

  bool get bioAuthExpired {
    return authConfigModel.lastBioAuthTime + 7 * 24 * 3600 * 1000 <
        DateTime.now().millisecondsSinceEpoch;
  }

  bool get showSetBioAuthDialog {
    return bioAuthAvailable && !bioAuthEnabled;
  }

  String get info {
    return 'Config: ${authConfigModel.toJSON().toString()}';
  }

  BiometricType get currentBioMetricType {
    if (authConfigModel.availableBiometricTypes.contains(BiometricType.face)) {
      return BiometricType.face;
    } else if (authConfigModel.availableBiometricTypes
        .contains(BiometricType.fingerprint)) {
      return BiometricType.fingerprint;
    } else {
      return null;
    }
  }

  @override
  bool updateShouldNotify(AuthInheritedModel oldWidget) {
    return authConfigModel != oldWidget.authConfigModel ||
        authorized != oldWidget.authorized;
  }

  static AuthInheritedModel of(BuildContext context, {AuthAspect aspect}) {
    return InheritedModel.inheritFrom<AuthInheritedModel>(
      context,
      aspect: aspect,
    );
  }

  @override
  bool updateShouldNotifyDependent(
      AuthInheritedModel oldWidget, Set<AuthAspect> dependencies) {
    return authConfigModel != oldWidget.authConfigModel &&
            dependencies.contains(AuthAspect.config) ||
        authorized != oldWidget.authorized &&
            dependencies.contains(AuthAspect.authorized);
  }
}
