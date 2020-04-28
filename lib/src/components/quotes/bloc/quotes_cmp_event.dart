import 'package:equatable/equatable.dart';

import '../model.dart';

abstract class QuotesCmpEvent {
  const QuotesCmpEvent();
}

class UpdateQuotesEvent extends QuotesCmpEvent {
  final bool isForceUpdate;

  UpdateQuotesEvent({this.isForceUpdate});
}

class UpdateQuotesSignEvent extends QuotesCmpEvent {
  final QuotesSign sign;

  UpdateQuotesSignEvent({this.sign});
}

class UpdateGasPriceEvent extends QuotesCmpEvent {}
