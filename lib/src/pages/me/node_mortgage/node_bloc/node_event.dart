
abstract class NodeEvent {
  const NodeEvent();
}

class LoadNodes extends NodeEvent {}

class SwitchNode extends NodeEvent {
  int index;

  SwitchNode(this.index);
}
