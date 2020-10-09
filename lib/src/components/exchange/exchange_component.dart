import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:titan/src/basic/http/http_exception.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/auth/bloc/auth_bloc.dart';
import 'package:titan/src/components/auth/bloc/auth_state.dart';
import 'package:titan/src/components/exchange/model.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/contribution/verify_poi/verify_poi_page_v2.dart';
import 'package:titan/src/pages/market/api/exchange_api.dart';
import 'package:titan/src/pages/market/model/asset_list.dart';
import 'package:titan/src/pages/market/model/exchange_account.dart';
import 'package:titan/src/utils/utile_ui.dart';

import 'bloc/bloc.dart';

class ExchangeComponent extends StatelessWidget {
  final Widget child;

  ExchangeComponent({@required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ExchangeCmpBloc>(
      create: (ctx) => ExchangeCmpBloc(),
      child: _ExchangeManager(child: child),
    );
  }
}

class _ExchangeManager extends StatefulWidget {
  final Widget child;

  _ExchangeManager({@required this.child});

  @override
  State<StatefulWidget> createState() {
    return _ExchangeManagerState();
  }
}

class _ExchangeManagerState extends BaseState<_ExchangeManager> {
  ExchangeModel exchangeModel = ExchangeModel();
  ExchangeApi _exchangeApi = ExchangeApi();

  @override
  void onCreated() {
    // TODO: implement onCreated
    super.onCreated();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ExchangeCmpBloc, ExchangeCmpState>(
      listener: (context, state) async {
        if (state is CheckAccountState) {
          try {
            var sharePref = await SharedPreferences.getInstance();
            var accountJson = sharePref.getString(PrefsKey.EXCHANGE_ACCOUNT);
            var account = ExchangeAccount.fromJson(json.decode(accountJson));
            var lastAuthTime =
                sharePref.getInt(PrefsKey.EXCHANGE_ACCOUNT_LAST_AUTH_TIME);
            bool expired = lastAuthTime + 3 * 24 * 3600 * 1000 <
                DateTime.now().millisecondsSinceEpoch;
            if (account != null && !expired) {
              exchangeModel.activeAccount = account;

              ///update assets
              var ret = await _exchangeApi.getAssetsList();
              exchangeModel.activeAccount.assetList = AssetList.fromJson(ret);
            }
          } catch (e) {}
        } else if (state is LoginState) {
          try {
            ///Clear previous account
            exchangeModel.activeAccount = null;

            var ret = await _exchangeApi.walletLogin(
                wallet: state.wallet,
                password: state.password,
                address: state.address);
            var account = ExchangeAccount.fromJson(ret);

            print('使用钱包授权登录: account: $account');

            if (account != null) {
              exchangeModel.activeAccount = account;
              var ret = await _exchangeApi.getAssetsList();
              exchangeModel.activeAccount.assetList = AssetList.fromJson(ret);

              BlocProvider.of<ExchangeCmpBloc>(context)
                  .add(LoginSuccessEvent());

              ///cache
              var sharePref = await SharedPreferences.getInstance();
              var accountStr =
                  json.encode(exchangeModel.activeAccount.toJson());
              sharePref.setString(PrefsKey.EXCHANGE_ACCOUNT, accountStr);

              sharePref.setInt(PrefsKey.EXCHANGE_ACCOUNT_LAST_AUTH_TIME,
                  DateTime.now().millisecondsSinceEpoch);
            } else {
              BlocProvider.of<ExchangeCmpBloc>(context).add(LoginFailEvent());
            }
          } catch (e) {
            BlocProvider.of<ExchangeCmpBloc>(context).add(LoginFailEvent());
          }
        } else if (state is SetShowBalancesState) {
          exchangeModel.isShowBalances = state.isShow;
        } else if (state is UpdateExchangeAccountState) {
          exchangeModel.activeAccount = state.account;
        } else if (state is ClearExchangeAccountState) {
          exchangeModel.activeAccount = null;

          ///clear account cache
          var sharePref = await SharedPreferences.getInstance();
          sharePref.remove(PrefsKey.EXCHANGE_ACCOUNT);
          sharePref.remove(PrefsKey.EXCHANGE_ACCOUNT_LAST_AUTH_TIME);
        } else if (state is UpdateAssetsState) {
          try {
            var ret = await _exchangeApi.getAssetsList();
            print("[object] ---> ret:$ret");
            exchangeModel.activeAccount.assetList = AssetList.fromJson(ret);
          } catch (e) {
            if (e is HttpResponseCodeNotSuccess) {
              Fluttertoast.showToast(msg: e.message);
              if (e.code == ERROR_CODE_EXCHANGE_NOT_LOGIN) {
                ///clear current account if not login
                BlocProvider.of<ExchangeCmpBloc>(context)
                    .add(ClearExchangeAccountEvent());
              }
            }
          }
          setState(() {});
        }
      },
      child: BlocBuilder<ExchangeCmpBloc, ExchangeCmpState>(
        builder: (context, state) {
          print('ExchangeComponent[builder]: ${state}');
          return ExchangeInheritedModel(
            exchangeModel: exchangeModel,
            child: widget.child,
          );
        },
      ),
    );
  }
}

class ExchangeInheritedModel extends InheritedModel<String> {
  final ExchangeModel exchangeModel;

  const ExchangeInheritedModel({
    Key key,
    @required this.exchangeModel,
    @required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(ExchangeInheritedModel oldWidget) {
    return true;
  }

  static ExchangeInheritedModel of(BuildContext context) {
    return InheritedModel.inheritFrom<ExchangeInheritedModel>(
      context,
    );
  }

  @override
  bool updateShouldNotifyDependent(
    ExchangeInheritedModel old,
    Set<String> dependencies,
  ) {
    return exchangeModel != old.exchangeModel &&
        dependencies.contains('ExchangeModel');
  }
}
