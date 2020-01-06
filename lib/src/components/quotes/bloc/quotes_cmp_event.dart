import 'package:equatable/equatable.dart';

import '../model.dart';

abstract class QuotesCmpEvent extends Equatable {
  const QuotesCmpEvent();

  @override
  List<Object> get props => null;
}

class UpdateQuotesEvent extends QuotesCmpEvent {}

class UpdateQuotesSignEvent extends QuotesCmpEvent {
  final QuotesSign sign;

  UpdateQuotesSignEvent({this.sign});
}
