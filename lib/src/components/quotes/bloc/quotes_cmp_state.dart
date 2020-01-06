import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

import '../model.dart';

abstract class QuotesCmpState extends Equatable {
  const QuotesCmpState();

  @override
  List<Object> get props => null;
}

class InitialQuotesCmpState extends QuotesCmpState {
  @override
  List<Object> get props => [];
}

class UpdatingQuotesState extends QuotesCmpState {}

class UpdatedQuotesState extends QuotesCmpState {
  final QuotesModel quoteModel;

  UpdatedQuotesState({@required this.quoteModel});

  @override
  List<Object> get props => [quoteModel];
}

class UpdateQuotesFailState extends QuotesCmpState {}

class UpdatedQuotesSignState extends QuotesCmpState {
  final QuotesSign sign;

  UpdatedQuotesSignState({@required this.sign});

  @override
  List<Object> get props => [sign];
}
