import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/src/components/quotes/bloc/bloc.dart';
import 'package:titan/src/components/quotes/model.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/cache/app_cache.dart';
import 'package:titan/src/plugins/wallet/wallet_const.dart';

class QuotesComponent extends StatelessWidget {
  final Widget child;

  QuotesComponent({@required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (ctx) => QuotesCmpBloc(),
        child: _QuotesManager(
          child: child,
        ));
  }
}

class _QuotesManager extends StatefulWidget {
  final Widget child;

  _QuotesManager({@required this.child});

  @override
  State<StatefulWidget> createState() {
    return _QuotesManagerState();
  }
}

class _QuotesManagerState extends State<_QuotesManager> {
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
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<QuotesCmpBloc, QuotesCmpState>(
      listener: (context, state) {
        print(
            "state is UpdatedQuotesSignState 111 = ${state is UpdatedQuotesSignState}");
        if (state is UpdatedQuotesSignState) {
          _quotesSign = state.sign;
        }
      },
      child: BlocBuilder<QuotesCmpBloc, QuotesCmpState>(
        builder: (ctx, state) {
          print(
              "state is UpdatedQuotesSignState 222 = ${state is UpdatedQuotesSignState}");
          if (state is UpdatedQuotesState) {
            _quotesModel = state.quoteModel;
            print('QuotesComponent UpdatedQuotesState === receive');
          }
          if (state is UpdatedQuotesSignState) {
            _quotesSign = state.sign;
          }
          if (state is GasPriceState) {
            if (state.status == Status.success &&
                state.gasPriceRecommend != null) {
              _gasPriceRecommend = state.gasPriceRecommend;
            }
            if (state.status == Status.success &&
                state.btcGasPriceRecommend != null) {
              _btcGasPriceRecommend = state.btcGasPriceRecommend;
            }
          }
          return QuotesInheritedModel(
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
}

enum QuotesAspect { quote, sign, gasPrice }

class QuotesInheritedModel extends InheritedModel<QuotesAspect> {
  final QuotesModel quotesModel;
  final QuotesSign activeQuotesSign;
  final GasPriceRecommend gasPriceRecommend;
  final BTCGasPriceRecommend btcGasPriceRecommend;

  QuotesInheritedModel({
    this.quotesModel,
    this.activeQuotesSign,
    this.gasPriceRecommend,
    this.btcGasPriceRecommend,
    Key key,
    @required Widget child,
  }) : super(key: key, child: child);

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

  ActiveQuoteVoAndSign selectedQuoteVoAndSign(
      {String symbol, QuotesSign quotesSign}) {
    if (quotesModel != null && quotesSign != null) {
      for (var quote in quotesModel.quotes) {
        if (quote.symbol == symbol && quote.quote == quotesSign.quote) {
          return ActiveQuoteVoAndSign(quoteVo: quote, sign: quotesSign);
        }
      }
    }
    return null;
  }

  static QuotesInheritedModel of(BuildContext context, {QuotesAspect aspect}) {
    return InheritedModel.inheritFrom<QuotesInheritedModel>(context,
        aspect: aspect);
  }

  @override
  bool updateShouldNotify(QuotesInheritedModel oldWidget) {
    return quotesModel != oldWidget.quotesModel ||
        activeQuotesSign != oldWidget.activeQuotesSign ||
        gasPriceRecommend != oldWidget.gasPriceRecommend ||
        btcGasPriceRecommend != oldWidget.btcGasPriceRecommend;
  }

  @override
  bool updateShouldNotifyDependent(
      QuotesInheritedModel oldWidget, Set<QuotesAspect> dependencies) {
    return (quotesModel != oldWidget.quotesModel &&
            dependencies.contains(QuotesAspect.quote) ||
        activeQuotesSign != oldWidget.activeQuotesSign &&
            dependencies.contains(QuotesAspect.sign) ||
        gasPriceRecommend != oldWidget.gasPriceRecommend &&
            dependencies.contains(QuotesAspect.gasPrice) ||
        btcGasPriceRecommend != oldWidget.btcGasPriceRecommend &&
            dependencies.contains(QuotesAspect.gasPrice));
  }
}
