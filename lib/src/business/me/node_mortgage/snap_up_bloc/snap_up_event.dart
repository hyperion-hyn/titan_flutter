import 'package:titan/src/basic/bloc/submit_bloc/bloc.dart';

abstract class SnapUpEvent {
  const SnapUpEvent();
}

class SnapUpNode extends SnapUpEvent {
  int index;

  SnapUpNode(this.index);
}

class ResetToInit extends SnapUpEvent {}
