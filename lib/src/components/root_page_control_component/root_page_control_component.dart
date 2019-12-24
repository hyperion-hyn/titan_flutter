import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/src/components/root_page_control_component/bloc/bloc.dart';

class RootPageControlComponent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RootPageControlBloc, RootPageControlState>(
      builder: (ctx, state) {
        if (state is UpdateRootPageState) {
          return state.child;
        }
        return Container();
      },
    );
  }
}
