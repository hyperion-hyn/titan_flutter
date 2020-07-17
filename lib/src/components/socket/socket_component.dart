import 'package:decimal/decimal.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/src/components/quotes/bloc/bloc.dart';
import 'package:titan/src/components/quotes/model.dart';
import 'package:titan/src/components/socket/bloc/bloc.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/plugins/wallet/wallet_const.dart';

class SocketComponent extends StatelessWidget {
  final Widget child;

  SocketComponent({@required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (ctx) => SocketBloc(),
        child: _SocketManager(
          child: child,
        ));
  }
}

class _SocketManager extends StatefulWidget {
  final Widget child;

  _SocketManager({@required this.child});

  @override
  State<StatefulWidget> createState() {
    return _SocketManagerState();
  }
}

class _SocketManagerState extends State<_SocketManager> {
  QuotesModel _quotesModel;
  QuotesSign _quotesSign;
  GasPriceRecommend _gasPriceRecommend = GasPriceRecommend(
      safeLow: Decimal.fromInt(EthereumConst.LOW_SPEED),
      safeLowWait: 30,
      average: Decimal.fromInt(EthereumConst.FAST_SPEED),
      avgWait: 3,
      fast: Decimal.fromInt(EthereumConst.SUPER_FAST_SPEED),
      fastWait: 0.5);
  BTCGasPriceRecommend _btcGasPriceRecommend = BTCGasPriceRecommend.defaultValue();

  @override
  Widget build(BuildContext context) {
    return BlocListener<QuotesCmpBloc, QuotesCmpState>(
      listener: (context,state){
        print("state is UpdatedQuotesSignState 111 = ${state is UpdatedQuotesSignState}");
        if (state is UpdatedQuotesSignState) {
          _quotesSign = state.sign;
        }
      },
      child: BlocBuilder<QuotesCmpBloc, QuotesCmpState>(
        builder: (ctx, state) {
          print("state is UpdatedQuotesSignState 222 = ${state is UpdatedQuotesSignState}");
          if (state is UpdatedQuotesState) {
            _quotesModel = state.quoteModel;
          }
          if (state is UpdatedQuotesSignState) {
            _quotesSign = state.sign;
          }
          if (state is GasPriceState) {
            if (state.status == Status.success && state.gasPriceRecommend != null) {
              _gasPriceRecommend = state.gasPriceRecommend;
            }
            if (state.status == Status.success && state.btcGasPriceRecommend != null) {
              _btcGasPriceRecommend = state.btcGasPriceRecommend;
            }
          }
          return SocketInheritedModel(
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

enum SocketAspect { quote, sign, gasPrice }

class SocketInheritedModel extends InheritedModel<SocketAspect> {
  final QuotesModel quotesModel;
  final QuotesSign activeQuotesSign;
  final GasPriceRecommend gasPriceRecommend;
  final BTCGasPriceRecommend btcGasPriceRecommend;

  SocketInheritedModel({
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

  static SocketInheritedModel of(BuildContext context, {SocketAspect aspect}) {
    return InheritedModel.inheritFrom<SocketInheritedModel>(context, aspect: aspect);
  }

  @override
  bool updateShouldNotify(SocketInheritedModel oldWidget) {
    return quotesModel != oldWidget.quotesModel ||
        activeQuotesSign != oldWidget.activeQuotesSign ||
        gasPriceRecommend != oldWidget.gasPriceRecommend ||
        btcGasPriceRecommend != oldWidget.btcGasPriceRecommend;
  }

  @override
  bool updateShouldNotifyDependent(SocketInheritedModel oldWidget, Set<SocketAspect> dependencies) {
    return (quotesModel != oldWidget.quotesModel && dependencies.contains(SocketAspect.quote) ||
        activeQuotesSign != oldWidget.activeQuotesSign && dependencies.contains(SocketAspect.sign) ||
        gasPriceRecommend != oldWidget.gasPriceRecommend && dependencies.contains(SocketAspect.gasPrice) ||
        btcGasPriceRecommend != oldWidget.btcGasPriceRecommend && dependencies.contains(SocketAspect.gasPrice));
  }
}
