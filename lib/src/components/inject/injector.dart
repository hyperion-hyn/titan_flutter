import 'package:flutter/widgets.dart';
import 'package:titan/src/data/repository/repository.dart';
import 'package:titan/src/domain/domain.dart';
import 'package:titan/src/domain/transaction_interactor.dart';

class Injector extends InheritedWidget {
  final SearchInteractor searchInteractor;
  final TransactionInteractor transactionInteractor;
  final Repository repository;

//  final ScaffoldMapStore mapStore;

  final Widget child;

  Injector({
    Key key,
    @required this.child,
    @required this.searchInteractor,
    @required this.transactionInteractor,
    @required this.repository,
//    @required this.mapStore,
  }) : super(key: key, child: child);

  static Injector of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<Injector>();

  @override
  bool updateShouldNotify(Injector oldWidget) {
    return searchInteractor != oldWidget.searchInteractor || repository != oldWidget.repository
    || transactionInteractor != oldWidget.transactionInteractor;
  }
}
