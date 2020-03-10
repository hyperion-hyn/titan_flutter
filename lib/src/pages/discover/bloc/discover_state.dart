import 'package:meta/meta.dart';
import 'package:titan/src/pages/news/model/focus_response.dart';

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
