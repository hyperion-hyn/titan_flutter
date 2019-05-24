import 'package:flutter/widgets.dart';
import 'package:titan/src/resource/api/api.dart';
import 'package:titan/src/resource/repository/repository.dart';

class Injector extends InheritedWidget {
  final Repository repository;

  Injector({Key key, @required Widget child, @required this.repository}) : super(key: key, child: child);

  static Injector of(BuildContext context) => context.inheritFromWidgetOfExactType(Injector);

  @override
  bool updateShouldNotify(Injector oldWidget) {
    return repository != oldWidget.repository;
  }
}
