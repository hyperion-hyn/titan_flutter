import 'package:flutter/material.dart';

class LoadDataWidget extends StatefulWidget {
  final Widget child;
  final bool isLoading;

  LoadDataWidget({this.child, this.isLoading});

  @override
  State<StatefulWidget> createState() {
    return _LoadDataState();
  }
}

class _LoadDataState extends State<LoadDataWidget> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        if (!widget.isLoading) widget.child,
        if (widget.isLoading)
          Center(
            child: Container(width: 36, height: 36, child: CircularProgressIndicator(
              strokeWidth: 1.5,
            )),
          )
      ],
    );
  }
}
