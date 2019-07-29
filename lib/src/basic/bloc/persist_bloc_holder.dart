import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PersistBlocHolder<T extends Bloc<dynamic, dynamic>> extends StatefulWidget {
  final Widget child;
  final T Function() createBloc;

  PersistBlocHolder({@required this.child, @required this.createBloc});

  @override
  State<StatefulWidget> createState() {
    return _PersistBlocHolderState<T>();
  }
}

class _PersistBlocHolderState<T extends Bloc<dynamic, dynamic>> extends State<PersistBlocHolder> {
  T _bloc;

  Function hello;

  @override
  void initState() {
    super.initState();
    _bloc = widget.createBloc();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<T>(
      child: widget.child,
      bloc: _bloc,
    );
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }
}
