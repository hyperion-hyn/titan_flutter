import 'package:flutter/widgets.dart';

abstract class BaseState<T extends StatefulWidget> extends State<T> {
  bool created = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!created) {
      created = true;
      onCreated();
    }
  }

  void onCreated() {}
}
