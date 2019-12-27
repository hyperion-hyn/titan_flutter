import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/bloc.dart';

class SettingComponent extends StatefulWidget {
  final Widget child;

  SettingComponent({Key key, this.child}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SettingComponentState();
  }
}

class SettingComponentState extends State<SettingComponent> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<SettingBloc>(
      create: (context) => SettingBloc(),
      child: widget.child,
    );
  }
}
