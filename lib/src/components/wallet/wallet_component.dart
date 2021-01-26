import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bugly/flutter_bugly.dart';
import 'package:titan/src/components/wallet/vo/token_price_view_vo.dart';
import 'package:titan/src/components/wallet/bloc/bloc.dart';
import 'package:titan/src/components/wallet/model.dart';
import 'package:titan/src/components/wallet/vo/coin_view_vo.dart';
import 'package:titan/src/components/wallet/vo/wallet_view_vo.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/cache/app_cache.dart';
import 'package:titan/src/plugins/wallet/config/tokens.dart';
import 'package:titan/src/utils/format_util.dart';

import 'bloc/bloc.dart';
import 'wallet_repository.dart';
import 'package:nested/nested.dart';

class WalletComponent extends SingleChildStatelessWidget {
  WalletComponent({Key key, Widget child}) : super(key: key, child: child);

  @override
  Widget buildWithChild(BuildContext context, Widget child) {
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
  WalletViewVo _activatedWallet;

  QuotesModel _quotesModel;
  LegalSign _legalSign;
  GasPriceRecommend _ethGasPriceRecommend;
  GasPriceRecommend _btcGasPriceRecommend;

  @override
  void initState() {
    initData();
    super.initState();
  }

  void initData() async {
    var gasPriceEntityStr = await AppCache.getValue(PrefsKey.SHARED_PREF_ETH_GAS_PRICE_KEY);
    if (gasPriceEntityStr != null) {
      _ethGasPriceRecommend = GasPriceRecommend.fromJson(json.decode(gasPriceEntityStr));
    } else {
      _ethGasPriceRecommend = GasPriceRecommend.ethDefaultValue();
    }

    var btcGasPriceEntityStr = await AppCache.getValue(PrefsKey.SHARED_PREF_BTC_GAS_PRICE_KEY);
    if (btcGasPriceEntityStr != null) {
      _btcGasPriceRecommend = GasPriceRecommend.fromJson(json.decode(btcGasPriceEntityStr));
    } else {
      _btcGasPriceRecommend = GasPriceRecommend.btcDefaultValue();
    }

    //load default wallet
    BlocProvider.of<WalletCmpBloc>(context).add(LoadLocalDiskWalletAndActiveEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WalletCmpBloc, WalletCmpState>(
      listener: (context, state) {
        /*if (state is UpdateWalletPageState) {
          if (state.walletVo != null) {
            _activatedWallet = state.walletVo;
            var balance = _calculateTotalBalance(_activatedWallet);
            if (_activatedWallet.wallet != null) {
              var ethAddress = _activatedWallet?.wallet?.getEthAccount()?.address ?? '';
              var address = _activatedWallet?.wallet?.getAtlasAccount()?.address ?? ethAddress;
              FlutterBugly.setUserId(address);
            }
            this._activatedWallet = this._activatedWallet.copyWith(WalletViewVo(balance: balance));

            ///Refresh bio-auth config
            BlocProvider.of<AppLockBloc>(context).add(RefreshBioAuthConfigEvent(
              _activatedWallet.wallet,
            ));
          }
          if (state.quoteModel != null) {
            _quotesModel = state.quoteModel;
          }
          if (state.sign != null) {
            _legalSign = state.sign;
          }
        } else */
        if (state is QuotesState) {
          if (state.status == Status.success) {
            _quotesModel = state.quotes;
          }
        } else if (state is LegalSignState) {
          _legalSign = state.sign;
        } else if (state is GasPriceState) {
          if (state.status == Status.success) {
            if (state.ethGasPriceRecommend != null) {
              _ethGasPriceRecommend = state.ethGasPriceRecommend;
            }
            if (state.btcGasPriceRecommend != null) {
              _btcGasPriceRecommend = state.btcGasPriceRecommend;
            }
          }
        } else if (state is BalanceState) {
          if (state.walletVo != null) {
            var balance = _calculateTotalBalance(state.walletVo);
            _activatedWallet = state.walletVo.copyWith(WalletViewVo(balance: balance));
          }
        } else if (state is ActivatedWalletState) {
          _activatedWallet = state.walletVo;
          if (_activatedWallet != null) {
            var balance = _calculateTotalBalance(_activatedWallet);
            // for bugly log
            if (_activatedWallet.wallet != null) {
              var ethAddress = _activatedWallet?.wallet?.getEthAccount()?.address;
              if (ethAddress != null) {
                FlutterBugly.setUserId(ethAddress);
              }
            }
            _activatedWallet = _activatedWallet.copyWith(WalletViewVo(balance: balance));
          }
        } else if (state is UpdateWalletExpandState) {
          _activatedWallet.wallet.walletExpandInfoEntity = state.walletExpandInfoEntity;
        }
      },
      child: BlocBuilder<WalletCmpBloc, WalletCmpState>(
        builder: (BuildContext context, WalletCmpState state) {
          return WalletInheritedModel(
            activatedWallet: _activatedWallet,
            quotesModel: _quotesModel,
            activeLegal: _legalSign,
            ethGasPriceRecommend: _ethGasPriceRecommend,
            btcGasPriceRecommend: _btcGasPriceRecommend,
            child: widget.child,
          );
        },
      ),
    );
  }

  /// 计算钱包法币余额
  double _calculateTotalBalance(WalletViewVo walletVo) {
    if (walletVo != null && _legalSign != null && _quotesModel?.quotes != null) {
      double totalBalance = 0;
      for (var coin in walletVo.coins) {
        var price = _getLegalPrice(_quotesModel, coin.symbol, _legalSign);
        if (price != null) {
          totalBalance += price * FormatUtil.coinBalanceDouble(coin);
        }
      }
      return totalBalance;
    }
    return 0;
  }

  /// 获取该币的法币价格
  double _getLegalPrice(QuotesModel quotesModel, String symbol, LegalSign legalSign) {
    for (var vo in quotesModel.quotes) {
      if (vo.legal.legal == legalSign.legal && vo.symbol == symbol) {
        return vo.price;
      }
    }
    return null;
  }
}

enum WalletAspect { activatedWallet, quote, legal, gasPrice }

class WalletInheritedModel extends InheritedModel<WalletAspect> {
  final WalletViewVo activatedWallet;
  final QuotesModel quotesModel;
  final LegalSign activeLegal;
  final GasPriceRecommend ethGasPriceRecommend;
  final GasPriceRecommend btcGasPriceRecommend;

  WalletInheritedModel({
    this.activatedWallet,
    this.quotesModel,
    this.activeLegal,
    this.ethGasPriceRecommend,
    this.btcGasPriceRecommend,
    Key key,
    @required Widget child,
  }) : super(key: key, child: child);

  static WalletInheritedModel of(BuildContext context, {WalletAspect aspect}) {
    return InheritedModel.inheritFrom<WalletInheritedModel>(context, aspect: aspect);
  }

  // ActiveQuoteVoAndSign activatedQuoteVoAndSign(String symbol) {
  //   if (quotesModel != null && activeQuotesSign != null) {
  //     for (var quote in quotesModel.quotes) {
  //       if (quote.symbol == symbol && quote.legal == activeQuotesSign.legal) {
  //         return ActiveQuoteVoAndSign(quoteVo: quote, sign: activeQuotesSign);
  //       }
  //     }
  //   }
  //   return null;
  // }

  /// token的法币价格
  TokenPriceViewVo tokenLegalPrice(String symbol) {
    if (activeLegal != null && quotesModel?.quotes != null) {
      for (var vo in quotesModel.quotes) {
        if (vo.legal.legal == activeLegal.legal && vo.symbol == symbol) {
          return vo;
        }
      }
    }
    return null;
  }

  /// 获取主链基础币
  CoinViewVo getBaseCoinVo(int coinType) {
    if (this.activatedWallet != null) {
      for (var coin in this.activatedWallet.coins) {
        if (coin.coinType == coinType && coin.contractAddress == null) {
          return coin;
        }
      }
    }
    return null;
  }

  String activatedHynAddress() {
    if (this.activatedWallet != null) {
      for (var coin in this.activatedWallet.coins) {
        if (coin.symbol == SupportedTokens.ETHEREUM.symbol) {
          return coin.address;
        }
      }
    }
    return null;
  }

  CoinViewVo getCoinVoBySymbol(String symbol) {
    if (this.activatedWallet != null) {
      for (var coin in this.activatedWallet.coins) {
        if (coin.symbol == symbol) {
          return coin;
        }
      }
    }
    return null;
  }

  String getCoinIconPathBySymbol(String symbol) {
    if (this.activatedWallet != null) {
      for (var coin in this.activatedWallet.coins) {
        if (coin.symbol == symbol) {
          return coin.logo;
        }
      }
    }
    return '';
  }

  CoinViewVo getCoinVoOfHyn() {
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
        activeLegal != oldWidget.activeLegal ||
        ethGasPriceRecommend != oldWidget.ethGasPriceRecommend ||
        btcGasPriceRecommend != oldWidget.btcGasPriceRecommend;
  }

  @override
  bool updateShouldNotifyDependent(WalletInheritedModel oldWidget, Set<WalletAspect> dependencies) {
    return ((activatedWallet != oldWidget.activatedWallet && dependencies.contains(WalletAspect.activatedWallet)) ||
        (quotesModel != oldWidget.quotesModel && dependencies.contains(WalletAspect.quote)) ||
        (activeLegal != oldWidget.activeLegal && dependencies.contains(WalletAspect.legal)) ||
        ethGasPriceRecommend != oldWidget.ethGasPriceRecommend && dependencies.contains(WalletAspect.gasPrice) ||
        btcGasPriceRecommend != oldWidget.btcGasPriceRecommend && dependencies.contains(WalletAspect.gasPrice));
  }

// static Future<bool> saveQuoteSign(LegalSign quotesSign) {
//   var modelStr = json.encode(quotesSign.toJson());
//   return AppCache.saveValue(PrefsKey.SETTING_QUOTE_SIGN, modelStr);
// }

//  static String formatPrice(double price) {
//    return NumberFormat("#,###.#####").format(price);
//  }
}
