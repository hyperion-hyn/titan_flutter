import 'package:flutter/widgets.dart';

class DragTick extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints.tightFor(width: 48.0, height: 4.0),
      decoration: BoxDecoration(color: Color(0xffdcdcdc), borderRadius: BorderRadius.all(Radius.circular(4.0))),
    );
  }
}
