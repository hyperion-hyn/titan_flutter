import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/widgets.dart';

class FireBaseLogic extends InheritedWidget {
  final FirebaseAnalytics analytics;
//  final FirebaseAnalyticsObserver observer;

  final Crashlytics crashlytics;

  final Widget child;

  FireBaseLogic({
    Key key,
    @required this.child,
    this.analytics,
    this.crashlytics,
//    this.observer,
  });

  static FireBaseLogic of(BuildContext context) => context.inheritFromWidgetOfExactType(FireBaseLogic);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return false;
  }
}
