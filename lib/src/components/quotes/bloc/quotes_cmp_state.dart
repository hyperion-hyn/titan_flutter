import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

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
