import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  List availableBiometricTypes = List();
  LocalAuthentication auth = LocalAuthentication();

  @override
  void onCreated() {
    // TODO: implement onCreated
    super.onCreated();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is InitAuthConfigState) {
          if (state.authConfigModel != null) {
            authConfigModel = state.authConfigModel;
          }
          print(
              'InitAuthConfigState:::: ${authConfigModel != null ? authConfigModel.toJSON() : 'null'}');
        } else if (state is RefreshBioAuthConfigState) {
          var authConfigStr = await AppCache.getValue<String>(
              '${PrefsKey.AUTH_CONFIG}_${state.walletFileName}');
          if (authConfigStr != null) {
            AuthConfigModel model =
                AuthConfigModel.fromJson(json.decode(authConfigStr));
            if (model != null) {
              authConfigModel = model;
            }
          } else {
            try {
              availableBiometricTypes = await auth.getAvailableBiometrics();
            } on PlatformException catch (e) {
              print(e);
            }
            authConfigModel = AuthConfigModel(
              walletFileName: state.walletFileName,
              setBioAuthAsked: false,
              lastBioAuthTime: 0,
              useFace: false,
              useFingerprint: false,
              availableBiometricTypes: availableBiometricTypes,
            );
          }
          print('RefreshBioAuthConfigState:::: ${authConfigModel.toJSON()}');
        } else if (state is SetBioAuthState) {
          print('SetBioAuthState::::');
          try {
            availableBiometricTypes = await auth.getAvailableBiometrics();
          } on PlatformException catch (e) {
            print(e);
          }
          if (authConfigModel != null) {
            if (authConfigModel.availableBiometricTypes
                .contains(BiometricType.face)) {
              authConfigModel.useFace = state.value;
            }
            if (authConfigModel.availableBiometricTypes
                .contains(BiometricType.fingerprint)) {
              authConfigModel.useFingerprint = state.value;
            }
            if (authConfigModel.availableBiometricTypes
                .contains(BiometricType.iris)) {
              authConfigModel.useFingerprint = state.value;
            }
            authConfigModel.lastBioAuthTime =
                DateTime.now().millisecondsSinceEpoch;
          }
//          AppCache.saveValue('${PrefsKey.AUTH_CONFIG}_${state.walletFileName}',
//              json.encode(authConfigModel.toJSON()));
          print('SetBioAuthState:::: $authConfigModel');
        } else if (state is SaveAuthConfigState) {
          print(
              '[SaveAuthConfigState] walletFileName: ${state.walletFileName} config: ${state.authConfigModel}');
          authConfigModel = state.authConfigModel;
          await AppCache.saveValue(
              '${PrefsKey.AUTH_CONFIG}_${state.walletFileName}',
              json.encode(authConfigModel.toJSON()));
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return AuthInheritedModel(
            authConfigModel: authConfigModel,
            child: widget.child,
          );
        },
      ),
    );
  }
}

enum AuthAspect { config }

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
        dependencies.contains(AuthAspect.config);
  }
}
