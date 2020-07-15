import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading/indicator/ball_spin_fade_loader_indicator.dart';
import 'package:loading/loading.dart';
import 'package:titan/src/widget/progress_dialog_mask/bloc/bloc.dart';

class ProgressMaskDialog extends StatefulWidget {
  final ProgressMaskDialogBloc bloc;

  ProgressMaskDialog({@required this.bloc}) {}

  @override
  State<StatefulWidget> createState() {
    return _ProgressMaskDialogState();
  }
}

class _ProgressMaskDialogState extends State<ProgressMaskDialog> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProgressMaskDialogBloc, ProgressMaskDialogState>(
        bloc: widget.bloc,
        builder: (context, maskDialogState) {
          print("current mask:" + maskDialogState.toString());

          if (maskDialogState is CloseState) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pop(context);
              return;
            });
          }
          return Stack(
            children: <Widget>[
              Opacity(
                child: new ModalBarrier(dismissible: false, color: Colors.grey),
                opacity: 0.3,
              ),
              Center(child: Container(child: SizedBox(width: 30, height: 30, child: CupertinoActivityIndicator()))),
            ],
          );
        });
  }

  @override
  void dispose() {
    widget.bloc.close();
    super.dispose();
  }
}
