import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'spread_draw_scan_painter.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class RadarScanWidget extends StatefulWidget {

  @override
  _RadarScanWidget createState() => _RadarScanWidget();
}

class _RadarScanWidget extends State with SingleTickerProviderStateMixin {

  static NumberFormat format = new NumberFormat("####.##");

  //定义一个控制器
  AnimationController aniController;
  var aniControllerCount = 0;

  @override
  void dispose() {
    aniController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    start();
  }

  start() async {

    //初始化控制器 duration是动画执行时间
    aniController = AnimationController(duration: Duration(seconds: 5), vsync: this)
    //设置监听 有变化就刷新Widget
      ..addStatusListener((status) {
        switch (status) {
          case AnimationStatus.forward:
            print('1---------start:forward');

            break;

          case AnimationStatus.completed:

            break;

          case AnimationStatus.reverse:
            print('1---------start:reverse');

            break;

          case AnimationStatus.dismissed:
            print('1---------start:dismissed');
            break;
        }
      })
      ..addListener((){
        setState(() {
          var status = aniController.status;
          switch (status) {
            case AnimationStatus.forward:
              print('---------start:forward');

              break;

            case AnimationStatus.completed:
              aniControllerCount ++;
              print('---------start:completed: $aniControllerCount');
              if (aniControllerCount <= 3) {
                aniController.forward();
              } else {
                aniController.dispose();
              }
              break;

            case AnimationStatus.reverse:
              print('---------start:reverse');

              break;

            case AnimationStatus.dismissed:
              print('---------start:dismissed');
              break;
          }

        });
      });
      aniController.forward();
      //..repeat(min: 5, max: 15);
  }


  @override
  Widget build(BuildContext context) {

    var percent = (aniController.value) / 1.0;
    var percentText = percent * 100;
    return Center(child:
      Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(15.0),
            child: new LinearPercentIndicator(
              width: 280.0,
              lineHeight: 14.0,
              percent: percent,
              center: Text(
                "${format.format(percentText)}%",
                style: new TextStyle(fontSize: 12.0),
              ),
              trailing: Icon(Icons.mood),
              linearStrokeCap: LinearStrokeCap.roundAll,
              backgroundColor: Colors.grey,
              progressColor: Colors.blue,
            ),
          ),
          new Padding(
            padding: EdgeInsets.symmetric(vertical: 80.0),
          ),
          Container(
            padding: EdgeInsets.all(15.0),
            alignment: Alignment.bottomCenter,
            child:
              new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IgnorePointer(
                    child:
                      CustomPaint(
                        painter: SpreadDrawScanPainter(progress: aniController.value),
                        size: Size(200, 200),
                      ),
                  ),
                ],
              ),
          ),
        ]
    ),);
  }

  _showDialog(BuildContext context) {
    var text = "恭喜你，打卡完成";
//    if (checkInCount != 3) {
//      text = "打卡未完成，半小时后再来哦";
//    }

    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text("好消息"),
            actions: <Widget>[
              new FlatButton(
                child: new Text(text),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

}
