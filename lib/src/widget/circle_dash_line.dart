import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

enum CircleDashDirection { VERTICAL, HORIZONTAL }

class CircleDashLine extends CustomPainter {
  final CircleDashDirection direction;
  final double dotRadius;
  final Color dotColor;

  CircleDashLine({
    this.direction = CircleDashDirection.HORIZONTAL,
    this.dotColor = Colors.grey,
    this.dotRadius = 4,
  });

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    paint.color = dotColor;
    var startY = 0.0;
    var startX = 0.0;
    var dashSpace = dotRadius;
    if (direction == CircleDashDirection.VERTICAL) {
//      canvas.drawRect(Rect.fromLTRB(0, 0, size.width, size.height), Paint()..color = Color(0x88ff0000));
      var max = size.height;
      startX = (size.width) / 2;
      while (max >= 0) {
        canvas.drawCircle(Offset(startX, dotRadius + startY), dotRadius, paint);
        final space = dashSpace + 4 * dotRadius;
        startY += space;
        max -= space;
      }
    } else {
      var max = size.width;
      startY = (size.height) / 2;
      while (max >= 0) {
        canvas.drawCircle(Offset(dotRadius + startX, startY), dotRadius, paint);
        final space = dashSpace + 4 * dotRadius;
        startX += space;
        max -= space;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
