import 'package:equatable/equatable.dart';

abstract class PositionState {
  const PositionState();
}

class InitialPositionState extends PositionState {
  @override
  List<Object> get props => [];
}

class AddPositionState extends PositionState {
  AddPositionState();
}