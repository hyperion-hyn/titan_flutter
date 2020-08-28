import 'package:flutter/material.dart';
import 'package:titan/src/basic/utils/hex_color.dart';

class Popup extends StatelessWidget{
  final Widget child;
  final Function onClick; //点击child事件
  final double left; //距离左边位置
  final double top; //距离上面位置
  final String colorStr; //距离上面位置

  Popup({
    @required this.child,
    this.onClick,
    this.left,
    this.top,
    this.colorStr = "#1a000000",
  });

  @override
  Widget build(BuildContext context) {
    return Material(color: Colors.transparent, child: GestureDetector(child: Stack(
      children: <Widget>[
        Container(width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height, color: HexColor(colorStr),),
        Positioned(child: GestureDetector(child: child, onTap: (){ //点击子child
          if(onClick != null){
            Navigator.of(context).pop();
            onClick();
          }
        }),
          left: left,
          top: top,),
      ],
    ),
      onTap: (){ //点击空白处
        Navigator.of(context).pop();
      },
    ),);
  }

}