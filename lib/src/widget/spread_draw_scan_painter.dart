import 'package:flutter/material.dart';
import 'dart:math';


class SpreadDrawScanPainter extends CustomPainter {

  final double progress;
  SpreadDrawScanPainter({this.progress});

  @override
  void paint(Canvas canvas, Size size) {

    Rect gradientRect = new Rect.fromCircle(
      center: new Offset(100, 100),
      radius: 180.0,
    );


//    final Gradient gradient = new RadialGradient(
//      colors: <Color>[
//        Colors.green.withOpacity(1.0),
//        Colors.green.withOpacity(0.3),
//        Colors.yellow.withOpacity(0.2),
//        Colors.red.withOpacity(0.1),
//        Colors.red.withOpacity(0.0),
//      ],
//      stops: [
//        0.0,
//        0.5,
//        0.7,
//        0.9,
//        1.0,
//      ],
//    );


    final Gradient gradient = new RadialGradient(
      colors: <Color>[
        Colors.blue.withOpacity(0.8),
        Colors.blue.withOpacity(0.7),
        Colors.blue.withOpacity(0.6),
        Colors.blue.withOpacity(0.5),
        Colors.blue.withOpacity(0.0),
      ],
      stops: [
        0.0,
        0.4,
        0.5,
        0.6,
        1.0,
      ],
    );

    final double center = size.width * 0.5;
    final double radius = size.width * 1.0;
    // 画笔
    Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.blue.withOpacity(0.5)
      ..shader = gradient.createShader(gradientRect);

    //CGContextAddArc(context, CenterX, CenterY, _sectorRadius, startAngle * M_PI / 180, (startAngle-1) * M_PI / 180, 1);

    // 圆的中心点位置
    final Offset centerOffset = Offset(center, center);
    final Rect rect = Rect.fromCircle(center: centerOffset, radius: radius);

    final double angle = 360.0 * progress;
    final double startAngle = 0;
    final double sweepAngle = (angle * (pi / 180.0));

//    final double startAngle = ((angle -1) * (pi / 180.0));
//    final double sweepAngle = (angle * (pi / 180.0));;

    // 画圆弧 按照角度来画圆弧，后面看效果图会发现起点从0开始画的时候是3点钟方向开始的
    canvas.drawArc(rect, startAngle, sweepAngle, true, paint);
  }

  @override
  bool shouldRepaint(SpreadDrawScanPainter oldDelegate) {
    return oldDelegate != this;
    //return true;
  }
}

