import 'package:equatable/equatable.dart';

import '../model.dart';

abstract class QuotesCmpEvent {
  const QuotesCmpEvent();
}

class UpdateQuotesEvent extends QuotesCmpEvent {}

class UpdateQuotesSignEvent extends QuotesCmpEvent {
  final QuotesSign sign;

  UpdateQuotesSignEvent({this.sign});
}
