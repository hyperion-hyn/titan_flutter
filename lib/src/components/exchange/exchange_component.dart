import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/auth/bloc/auth_bloc.dart';
import 'package:titan/src/components/auth/bloc/auth_state.dart';
import 'package:titan/src/components/exchange/model.dart';
import 'package:titan/src/pages/market/api/exchange_api.dart';
import 'package:titan/src/pages/market/model/asset_list.dart';

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
        if (state is SetShowBalancesState) {
          exchangeModel.isShowBalances = state.isShow;
        } else if (state is UpdateExchangeAccountState) {
          exchangeModel.activeAccount = state.account;
        } else if (state is UpdateAssetsState) {
          if (exchangeModel.activeAccount != null) {
            var ret = await _exchangeApi.getAssetsList();
            exchangeModel.activeAccount.assetList = AssetList.fromJson(ret);
            setState(() {});
          }
        }
      },
      child: BlocBuilder<ExchangeCmpBloc, ExchangeCmpState>(
        builder: (context, state) {
          print('ExchangeComponent[builder]: ${state}');
          return ExchangeInheritedModel(
            exchangeModel: exchangeModel,
            exchangeApi: _exchangeApi,
            child: widget.child,
          );
        },
      ),
    );
  }
}

class ExchangeInheritedModel extends InheritedModel<String> {
  final ExchangeModel exchangeModel;
  final ExchangeApi exchangeApi;

  const ExchangeInheritedModel({
    Key key,
    @required this.exchangeModel,
    @required this.exchangeApi,
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
