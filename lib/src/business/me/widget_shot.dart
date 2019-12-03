import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:logger/logger.dart';
//import 'package:fluwx/fluwx.dart';
import 'package:path/path.dart' as path;

class WidgetShot extends StatefulWidget {
  final Widget child;
  final ShotController controller;

  WidgetShot({@required this.child, this.controller});

  @override
  _WidgetShotState createState() => _WidgetShotState();
}

class _WidgetShotState extends State<WidgetShot> {

  GlobalKey globalKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    //print('[Shot] --> initState');
  }

  @override
  Widget build(BuildContext context) {
    //print('[Shot] --> build');

    if (widget.controller != null) {
      widget.controller.setGlobalKey(globalKey);
    }

    return RepaintBoundary(
      key: globalKey,
      child: widget.child,
    );
  }
}


class ShotController {
  GlobalKey globalKey;

  Future<Uint8List> makeImageUint8List() async {
    RenderRepaintBoundary boundary = globalKey.currentContext.findRenderObject();
    // 这个可以获取当前设备的像素比
    var dpr = ui.window.devicePixelRatio;
    ui.Image image = await boundary.toImage(pixelRatio: dpr);
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData.buffer.asUint8List();

    return pngBytes;
  }

  setGlobalKey(GlobalKey globalKey) {
    this.globalKey = globalKey;
  }
}