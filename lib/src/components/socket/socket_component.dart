import 'package:decimal/decimal.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/src/components/quotes/bloc/bloc.dart';
import 'package:titan/src/components/quotes/model.dart';
import 'package:titan/src/components/socket/bloc/bloc.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/plugins/wallet/wallet_const.dart';

class SocketComponent extends StatelessWidget {
  final Widget child;

  SocketComponent({@required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (ctx) => SocketBloc(),
        child: _SocketManager(
          child: child,
        ));
  }
}

class _SocketManager extends StatefulWidget {
  final Widget child;

  _SocketManager({@required this.child});

  @override
  State<StatefulWidget> createState() {
    return _SocketManagerState();
  }
}

class _SocketManagerState extends State<_SocketManager> {

  @override
  Widget build(BuildContext context) {
    return BlocListener<QuotesCmpBloc, QuotesCmpState>(
      listener: (context,state){
        print("[_SocketManagerState] listener, state: ${state}");

      },
      child: BlocBuilder<QuotesCmpBloc, QuotesCmpState>(
        builder: (ctx, state) {
          print("[_SocketManagerState] builder, state: ${state}");

          return widget.child;
        },
      ),
    );
  }
}

