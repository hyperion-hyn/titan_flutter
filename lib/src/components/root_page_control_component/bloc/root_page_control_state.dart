import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class RootPageControlState extends Equatable {
  RootPageControlState([List props = const []]) : super(props);
}

class InitialRootPageControlState extends RootPageControlState {
  @override
  List<Object> get props => [];
}

class UpdateRootPageState extends RootPageControlState {
  final Widget child;

  UpdateRootPageState({this.child}) : super([child]);
}
