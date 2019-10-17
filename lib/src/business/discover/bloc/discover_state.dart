import 'package:meta/meta.dart';
import 'package:titan/src/business/infomation/model/focus_response.dart';
import 'package:titan/src/business/scaffold_map/dmap/dmap.dart';

@immutable
abstract class DiscoverState {}

class InitialDiscoverState extends DiscoverState {}

class ActiveDMapState extends DiscoverState {
  final String name;

  ActiveDMapState({@required this.name});
}

class LoadedFocusState extends DiscoverState {
  final List<FocusImage> focusImages;

  LoadedFocusState({@required this.focusImages});
}
