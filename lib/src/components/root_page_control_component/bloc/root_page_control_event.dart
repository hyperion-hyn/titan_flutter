import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class RootPageControlEvent extends Equatable {
  const RootPageControlEvent();
}

class SetRootPageEvent extends RootPageControlEvent {
  final Widget page;

  SetRootPageEvent({@required this.page});

  @override
  List<Object> get props => [page];
}
