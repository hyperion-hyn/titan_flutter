import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:titan/src/config/consts.dart';

import '../model.dart';

abstract class QuotesCmpState {
  const QuotesCmpState();
}

class InitialQuotesCmpState extends QuotesCmpState {}

class UpdatingQuotesState extends QuotesCmpState {}

class UpdatedQuotesState extends QuotesCmpState {
  final QuotesModel quoteModel;

  UpdatedQuotesState({@required this.quoteModel});
}

class UpdateQuotesFailState extends QuotesCmpState {}

class UpdatedQuotesSignState extends QuotesCmpState {
  final QuotesSign sign;

  UpdatedQuotesSignState({@required this.sign});
}

class GasPriceState extends QuotesCmpState with EquatableMixin {
  final Status status;
  final GasPriceRecommend gasPriceRecommend;
  final BTCGasPriceRecommend btcGasPriceRecommend;

  GasPriceState({this.status, this.gasPriceRecommend, this.btcGasPriceRecommend});

  @override
  List<Object> get props => [status, gasPriceRecommend, btcGasPriceRecommend];
}
