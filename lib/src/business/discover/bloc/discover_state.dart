import 'package:meta/meta.dart';

@immutable
abstract class DiscoverState {}

class InitialDiscoverState extends DiscoverState {}

class ActiveDMapState extends DiscoverState {
  final String dMapName;

  ActiveDMapState({@required this.dMapName});
}
