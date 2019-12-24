import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class RootPageControlEvent extends Equatable {
  RootPageControlEvent([List props = const []]) : super(props);
}

class SetRootPageEvent extends RootPageControlEvent {
  final Widget page;

  SetRootPageEvent({@required this.page}) : super([page]);
}
