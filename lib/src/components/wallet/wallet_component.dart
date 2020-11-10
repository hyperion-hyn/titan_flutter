import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bugly/flutter_bugly.dart';
import 'package:intl/intl.dart';
import 'package:titan/src/components/auth/bloc/auth_bloc.dart';
import 'package:titan/src/components/auth/bloc/auth_event.dart';
import 'package:titan/src/components/exchange/bloc/bloc.dart';
import 'package:titan/src/components/exchange/exchange_component.dart';
import 'package:titan/src/components/wallet/vo/symbol_quote_vo.dart';
import 'package:titan/src/components/wallet/bloc/bloc.dart';
import 'package:titan/src/components/wallet/model.dart';
import 'package:titan/src/components/wallet/vo/coin_vo.dart';
import 'package:titan/src/components/wallet/vo/wallet_vo.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/cache/app_cache.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/plugins/wallet/token.dart';
import 'package:titan/src/utils/format_util.dart';

import 'bloc/bloc.dart';
import 'wallet_repository.dart';

class WalletComponent extends StatelessWidget {
  final Widget child;

  WalletComponent({@required this.child});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (ctx) => WalletRepository(),
      child: BlocProvider<WalletCmpBloc>(
        create: (ctx) => WalletCmpBloc(walletRepository: RepositoryProvider.of<WalletRepository>(ctx)),
        child: _WalletManager(child: child),
      ),
    );
  }
}

class _WalletManager extends StatefulWidget {
  final Widget child;

  _WalletManager({@required this.child});

  @override
  State<StatefulWidget> createState() {
    return _WalletManagerState();
  }
}

class _WalletManagerState extends State<_WalletManager> {
  WalletVo _activatedWallet;

  QuotesModel _quotesModel;
  QuotesSign _quotesSign;
  GasPriceRecommend _gasPriceRecommend;
  BTCGasPriceRecommend _btcGasPriceRecommend;

  @override
  void initState() {
    initData();
    super.initState();
  }

  void initData() async {
    var gasPriceEntityStr =
    await AppCache.getValue(PrefsKey.SHARED_PREF_GAS_PRICE_KEY);
    if (gasPriceEntityStr != null) {
      _gasPriceRecommend =
          GasPriceRecommend.fromJson(json.decode(gasPriceEntityStr));
    } else {
      _gasPriceRecommend = GasPriceRecommend.defaultValue();
    }

    var btcGasPriceEntityStr =
    await AppCache.getValue(PrefsKey.SHARED_PREF_BTC_GAS_PRICE_KEY);
    if (btcGasPriceEntityStr != null) {
      _btcGasPriceRecommend =
          BTCGasPriceRecommend.fromJson(json.decode(btcGasPriceEntityStr));
    } else {
      _btcGasPriceRecommend = BTCGasPriceRecommend.defaultValue();
    }

    //load default wallet
    BlocProvider.of<WalletCmpBloc>(context).add(LoadLocalDiskWalletAndActiveEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WalletCmpBloc, WalletCmpState>(
      listener: (context, state) {
        if(state is UpdateWalletPageState){
          _activatedWallet = state.walletVo;
          if (_activatedWallet != null) {
            var balance = _calculateTotalBalance(_activatedWallet);
            if (_activatedWallet.wallet != null) {
              var ethAddress = _activatedWallet?.wallet?.getEthAccount()?.address ?? '';
              var address = _activatedWallet?.wallet?.getAtlasAccount()?.address ?? ethAddress;
              FlutterBugly.setUserId(address);
            }
            this._activatedWallet = this._activatedWallet.copyWith(WalletVo(balance: balance));

            ///Refresh bio-auth config
            BlocProvider.of<AuthBloc>(context).add(RefreshBioAuthConfigEvent(
              _activatedWallet.wallet,
            ));
          }
          if (state.quoteModel != null) {
            _quotesModel = state.quoteModel;
          }
          if (state.sign != null) {
            _quotesSign = state.sign;
          }
        }else if (state is UpdatedQuotesState) {//基本不用,一般使用UpdateWalletPageState
          _quotesModel = state.quoteModel;
          print('QuotesComponent UpdatedQuotesState === receive');
        }else if (state is UpdatedQuotesSignState) {//基本不用,一般使用UpdateWalletPageState
          _quotesSign = state.sign;
        }else if (state is GasPriceState) {
          if (state.status == Status.success && state.gasPriceRecommend != null) {
            _gasPriceRecommend = state.gasPriceRecommend;
          }
          if (state.status == Status.success &&
              state.btcGasPriceRecommend != null) {
            _btcGasPriceRecommend = state.btcGasPriceRecommend;
          }
        } else if (state is UpdatedWalletBalanceState) {
        } else if (state is WalletVoAwareCmpState) {//基本不用,一般使用UpdateWalletPageState
          _activatedWallet = state.walletVo;
          if (_activatedWallet != null) {
            var balance = _calculateTotalBalance(_activatedWallet);
            if (_activatedWallet.wallet != null) {
              var ethAddress = _activatedWallet?.wallet?.getEthAccount()?.address ?? '';
              var address = _activatedWallet?.wallet?.getAtlasAccount()?.address ?? ethAddress;
              FlutterBugly.setUserId(address);
            }

            this._activatedWallet = this._activatedWallet.copyWith(WalletVo(balance: balance));
          }
        } else if (state is LoadingWalletState) {
          _activatedWallet = null;
        }
      },
      child: BlocBuilder<WalletCmpBloc, WalletCmpState>(
        builder: (BuildContext context, WalletCmpState state) {
          return WalletInheritedModel(
            activatedWallet: _activatedWallet,
            quotesModel: _quotesModel,
            activeQuotesSign: _quotesSign,
            gasPriceRecommend: _gasPriceRecommend,
            btcGasPriceRecommend: _btcGasPriceRecommend,
            child: widget.child,
          );
        },
      ),
    );
  }

  double _calculateTotalBalance(WalletVo walletVo) {
    if (walletVo != null && _quotesSign != null && _quotesModel != null) {
      double totalBalance = 0;
      for (var coin in walletVo.coins) {
        var vo = _getQuoteVoPriceBySign(coin, _quotesModel, _quotesSign);
        if (vo != null) {
          totalBalance += vo.price * FormatUtil.coinBalanceDouble(coin);
        }
      }
      return totalBalance;
    }
    return 0;
  }

  SymbolQuoteVo _getQuoteVoPriceBySign(CoinVo coinVo, QuotesModel quotesModel, QuotesSign quotesSign) {
    for (var vo in quotesModel.quotes) {
      if (vo.quote == quotesSign.quote && vo.symbol == coinVo.symbol) {
        return vo;
      }
    }
    return null;
  }
}

enum WalletAspect {
  activatedWallet,
  quote,
  sign,
  gasPrice
}

class WalletInheritedModel extends InheritedModel<WalletAspect> {
  final WalletVo activatedWallet;
  final QuotesModel quotesModel;
  final QuotesSign activeQuotesSign;
  final GasPriceRecommend gasPriceRecommend;
  final BTCGasPriceRecommend btcGasPriceRecommend;

  WalletInheritedModel({
    this.activatedWallet,
    this.quotesModel,
    this.activeQuotesSign,
    this.gasPriceRecommend,
    this.btcGasPriceRecommend,
    Key key,
    @required Widget child,
  }) : super(key: key, child: child);

  static WalletInheritedModel of(BuildContext context, {WalletAspect aspect}) {
    return InheritedModel.inheritFrom<WalletInheritedModel>(context, aspect: aspect);
  }

  ActiveQuoteVoAndSign activatedQuoteVoAndSign(String symbol) {
    if (quotesModel != null && activeQuotesSign != null) {
      for (var quote in quotesModel.quotes) {
        if (quote.symbol == symbol && quote.quote == activeQuotesSign.quote) {
          return ActiveQuoteVoAndSign(quoteVo: quote, sign: activeQuotesSign);
        }
      }
    }
    return null;
  }

  String activatedHynAddress() {
    if (this.activatedWallet != null) {
      for (var coin in this.activatedWallet.coins) {
        if (coin.symbol == SupportedTokens.HYN_ERC20.symbol) {
          return coin.address;
        }
      }
    }
    return null;
  }

  CoinVo getCoinVoBySymbol(String symbol) {
    if (this.activatedWallet != null) {
      for (var coin in this.activatedWallet.coins) {
        if (coin.symbol == symbol) {
          return coin;
        }
      }
    }
    return null;
  }

  CoinVo getCoinVoOfHyn() {
    if (this.activatedWallet != null) {
      for (var coin in this.activatedWallet.coins) {
        if (coin.symbol == SupportedTokens.HYN_ERC20.symbol) {
          return coin;
        }
      }
    }
    return null;
  }

  @override
  bool updateShouldNotify(WalletInheritedModel oldWidget) {
    return activatedWallet != oldWidget.activatedWallet ||
        quotesModel != oldWidget.quotesModel ||
        activeQuotesSign != oldWidget.activeQuotesSign ||
        gasPriceRecommend != oldWidget.gasPriceRecommend ||
        btcGasPriceRecommend != oldWidget.btcGasPriceRecommend;
  }

  @override
  bool updateShouldNotifyDependent(
      WalletInheritedModel oldWidget, Set<WalletAspect> dependencies) {
    return ((activatedWallet != oldWidget.activatedWallet &&
        dependencies.contains(WalletAspect.activatedWallet)) ||
        (quotesModel != oldWidget.quotesModel &&
            dependencies.contains(WalletAspect.quote)) ||
        (activeQuotesSign != oldWidget.activeQuotesSign &&
                dependencies.contains(WalletAspect.sign)) ||
        gasPriceRecommend != oldWidget.gasPriceRecommend &&
            dependencies.contains(WalletAspect.gasPrice) ||
        btcGasPriceRecommend != oldWidget.btcGasPriceRecommend &&
            dependencies.contains(WalletAspect.gasPrice));
  }

  static Future<bool> saveQuoteSign(QuotesSign quotesSign) {
    var modelStr = json.encode(quotesSign.toJson());
    return AppCache.saveValue(PrefsKey.SETTING_QUOTE_SIGN, modelStr);
  }

//  static String formatPrice(double price) {
//    return NumberFormat("#,###.#####").format(price);
//  }
}
