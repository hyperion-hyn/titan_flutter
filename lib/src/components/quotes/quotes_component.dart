import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/src/components/quotes/bloc/bloc.dart';
import 'package:titan/src/components/quotes/model.dart';

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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuotesCmpBloc, QuotesCmpState>(
      builder: (ctx, state) {
        if (state is UpdatedQuotesState) {
          _quotesModel = state.quoteModel;
        }
        if (state is UpdatedQuotesSignState) {
          _quotesSign = state.sign;
        }
        return QuotesViewModel(
          quotesModel: _quotesModel,
          activeQuotesSign: _quotesSign,
          child: widget.child,
        );
      },
    );
  }
}

enum QuotesAspect { quote, sign }

class QuotesViewModel extends InheritedModel<QuotesAspect> {
  final QuotesModel quotesModel;
  final QuotesSign activeQuotesSign;

  QuotesViewModel({
    this.quotesModel,
    this.activeQuotesSign,
    Key key,
    @required Widget child,
  }) : super(key: key, child: child);

  SymbolQuote currentSymbolQuote(String symbol) {
    if (quotesModel != null && activeQuotesSign != null) {
      for (var quote in quotesModel.quotes) {
        if (quote.symbol == symbol) {
          return SymbolQuote(quoteVo: quote, sign: activeQuotesSign);
        }
      }
    }
    return null;
  }

  static QuotesViewModel of(BuildContext context, {QuotesAspect aspect}) {
    return InheritedModel.inheritFrom<QuotesViewModel>(context, aspect: aspect);
  }

  @override
  bool updateShouldNotify(QuotesViewModel oldWidget) {
    return quotesModel != oldWidget.quotesModel || activeQuotesSign != oldWidget.activeQuotesSign;
  }

  @override
  bool updateShouldNotifyDependent(QuotesViewModel oldWidget, Set<QuotesAspect> dependencies) {
    return (quotesModel != oldWidget.quotesModel && dependencies.contains(QuotesAspect.quote) ||
        activeQuotesSign != oldWidget.activeQuotesSign && dependencies.contains(QuotesAspect.sign));
  }
}
