import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/src/business/scaffold_map/bloc/bloc.dart';

class LoadingPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: SizedBox(
            height: 32,
            width: 32,
            child: CircularProgressIndicator(
              strokeWidth: 3,
            ),
          ),
        ),
      ],
    );
  }
}

class FailPanel extends StatelessWidget {
  final String message;
  final bool showCloseBtn;

  FailPanel({this.message, this.showCloseBtn});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(message ?? 'search fault'),
          ),
        ),
        if (showCloseBtn)
          Positioned(
            right: 16,
            top: 16,
            child: InkWell(
              onTap: () {
                BlocProvider.of<ScaffoldMapBloc>(context).dispatch(ClearSelectPoiEvent());
              },
              borderRadius: BorderRadius.all(Radius.circular(32.0)),
              highlightColor: Colors.transparent,
              child: Ink(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xffececec),
                ),
                child: Icon(
                  Icons.close,
                  color: Colors.grey,
                  size: 18,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
