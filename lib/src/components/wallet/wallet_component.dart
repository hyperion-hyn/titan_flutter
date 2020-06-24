import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:titan/src/components/quotes/bloc/bloc.dart';
import 'package:titan/src/components/quotes/model.dart';
import 'package:titan/src/components/quotes/vo/symbol_quote_vo.dart';
import 'package:titan/src/components/wallet/vo/coin_vo.dart';
import 'package:titan/src/components/wallet/vo/wallet_vo.dart';
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
        create: (ctx) => WalletCmpBloc(
            walletRepository: RepositoryProvider.of<WalletRepository>(ctx)),
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

  QuotesModel _quoteModel;
  QuotesSign _quotesSign;

  @override
  void initState() {
    super.initState();

    //load default wallet
    BlocProvider.of<WalletCmpBloc>(context)
        .add(LoadLocalDiskWalletAndActiveEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<QuotesCmpBloc, QuotesCmpState>(
      listener: (context, state) {
        //update WalletVo total balance
        if (state is UpdatedQuotesState || state is UpdatedQuotesSignState) {
          if (state is UpdatedQuotesState) {
            _quoteModel = state.quoteModel;
          } else if (state is UpdatedQuotesSignState) {
            print("!!!!!00011 ${state.sign}");
            _quotesSign = state.sign;
          }
          if (_activatedWallet != null) {
            var balance = _calculateTotalBalance(_activatedWallet);
            setState(() {
              this._activatedWallet =
                  this._activatedWallet.copyWith(WalletVo(balance: balance));
            });
          }
        }
      },
      child: BlocBuilder<WalletCmpBloc, WalletCmpState>(
        builder: (BuildContext context, WalletCmpState state) {
          if (state is WalletVoAwareCmpState) {
            _activatedWallet = state.walletVo;
            if (_activatedWallet != null) {
              _activatedWallet.balance =
                  _calculateTotalBalance(_activatedWallet);
            }
          } else if (state is LoadingWalletState) {
            _activatedWallet = null;
          }
          return WalletInheritedModel(
            activatedWallet: _activatedWallet,
            child: widget.child,
          );
        },
      ),
    );
  }

  double _calculateTotalBalance(WalletVo walletVo) {
    if (walletVo != null && _quotesSign != null && _quoteModel != null) {
      double totalBalance = 0;
      for (var coin in walletVo.coins) {
        var vo = _getQuoteVoPriceBySign(coin, _quoteModel, _quotesSign);
        if (vo != null) {
          totalBalance += vo.price * FormatUtil.coinBalanceDouble(coin);
        }
      }
      return totalBalance;
    }
    return 0;
  }

  SymbolQuoteVo _getQuoteVoPriceBySign(
      CoinVo coinVo, QuotesModel quotesModel, QuotesSign quotesSign) {
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
}

class WalletInheritedModel extends InheritedModel<WalletAspect> {
  final WalletVo activatedWallet;

  WalletInheritedModel({
    this.activatedWallet,
    Key key,
    @required Widget child,
  }) : super(key: key, child: child);

  static WalletInheritedModel of(BuildContext context, {WalletAspect aspect}) {
    return InheritedModel.inheritFrom<WalletInheritedModel>(context,
        aspect: aspect);
  }

  String activatedHynAddress() {
    if (this.activatedWallet != null) {
      for (var coin in this.activatedWallet.coins) {
        if (coin.symbol == SupportedTokens.HYN.symbol) {
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
        if (coin.symbol == SupportedTokens.HYN.symbol) {
          return coin;
        }
      }
    }
    return null;
  }

  @override
  bool updateShouldNotify(WalletInheritedModel oldWidget) {
    return activatedWallet != oldWidget.activatedWallet;
  }

  @override
  bool updateShouldNotifyDependent(
      WalletInheritedModel oldWidget, Set<WalletAspect> dependencies) {
    return (activatedWallet != oldWidget.activatedWallet &&
        dependencies.contains(WalletAspect.activatedWallet));
  }

//  static String formatPrice(double price) {
//    return NumberFormat("#,###.#####").format(price);
//  }
}
