import 'package:flutter/widgets.dart';
import 'package:titan/src/data/api/api.dart';
import 'package:titan/src/data/db/search_history_dao.dart';
import 'package:titan/src/data/repository/repository.dart';
import 'package:titan/src/domain/domain.dart';

class Injector extends InheritedWidget {
  final SearchHistoryDao searchDao;
  final Api api;
  final SearchInteractor searchInteractor;
  final Repository repository;

  final Widget child;

  Injector({Key key, @required this.searchInteractor, @required this.repository, @required this.searchDao, @required this.api, @required this.child})
      : super(key: key, child: child);

  static Injector of(BuildContext context) =>
      context.inheritFromWidgetOfExactType(Injector);

  @override
  bool updateShouldNotify(Injector oldWidget) {
    return searchDao != oldWidget.searchDao ||
        api != oldWidget.api ||
        searchInteractor != oldWidget.searchInteractor ||
        repository != oldWidget.repository;
  }
}
