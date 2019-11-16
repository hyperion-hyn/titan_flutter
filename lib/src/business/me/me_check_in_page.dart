
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:titan/src/business/me/service/user_service.dart';
import 'package:titan/src/utils/exception_process.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'dart:async';
import 'dart:collection';
import '../../widget/spread_draw_scan_painter.dart';
import '../../widget/spread_widget.dart';
import '../../widget/radio_scan_widget.dart';

class MeCheckIn extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MeCheckIn();
  }
}


int checkInCount = 0;

class _MeCheckIn extends State<MeCheckIn> {

  UserService _userService = UserService();
  MapboxMapController mapController;
  int timerCount = 4;
  Timer timer;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
//        backgroundColor: Colors.white,
        title: Text(
          "打卡任务",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Center(
        child: new Stack(
          alignment:Alignment.center,
          children: <Widget>[
            mapView(),
            RadarScanWidget(),
          ],
        ),
      ),
    );
  }

  Widget mapView() {
    return MapboxMapParent(
      controller: mapController,
      child: MapboxMap(
        compassEnabled: false,
        initialCameraPosition: const CameraPosition(
          target: LatLng(23.12076, 113.322058),
          zoom: 15.0,
        ),
        styleString: 'https://static.hyn.space/maptiles/see-it-all.json',
        onStyleLoaded: (mapboxController) {
          setState(() {
            mapController = mapboxController;
            //setupTimer();
            _checkIn();
          });
        },
        myLocationTrackingMode: MyLocationTrackingMode.Tracking,
        rotateGesturesEnabled: false,
        tiltGesturesEnabled: false,
        enableLogo: false,
        enableAttribution: false,
        compassMargins: CompassMargins(left: 0, top: 88, right: 16, bottom: 0),
        minMaxZoomPreference: MinMaxZoomPreference(1.1, 19.0),
        myLocationEnabled: false,
      ),
    );
  }


//  I/flutter (13432): 23.12076
//  I/flutter (13432): 113.32205799999997

  Future setupTimer() async {
    print("[me_check_in] --> setupTimer");

    LatLng start = await mapController?.lastKnownLocation();
    if (start == null) {
      start = LatLng(23.12076, 113.32205799999997);
    }
    print(start.latitude);
    print(start.longitude);

    var paddingValue = 5;
    var paddingXY = 10000.0;

    timer = Timer.periodic(Duration(seconds: 9), (timer)
    {
      setState(() {
        timerCount--;
        print(timerCount);

        switch (timerCount) {
          case 3:

            var latLng = LatLng(start.latitude, start.longitude+paddingValue);
            //_moveAnimation(latLng);
            _moveAnimationPosition(paddingXY, 0.0);
            _zoomAnimation();

            break;

          case 2:

            var latLng = LatLng(start.latitude-paddingValue, start.longitude);
            //_moveAnimation(latLng);
            _moveAnimationPosition(0.0, -paddingXY);

            _zoomAnimation();

            break;

          case 1:

            var latLng = LatLng(start.latitude, start.longitude-paddingValue);
            //_moveAnimation(latLng);
            _moveAnimationPosition(-paddingXY, 0.0);
            _zoomAnimation();

            break;

          case 0:
            var latLng = LatLng(start.latitude+paddingValue, start.longitude+paddingValue);
            //_moveAnimation(latLng);
            _moveAnimationPosition(paddingXY, paddingXY);
            _zoomAnimation();

            timer.cancel();

            //_showDialog(context);

            break;
        }
      });
    });
  }

  Future _zoomAnimation() async {

    _zoomInAnimation();
    _zoomOutAnimation();
  }

  Future _moveAnimation(LatLng latLng) async {
    mapController.animateCameraWithTime(
        CameraUpdate.newLatLng(latLng),
        3000
    );
  }

  Future _moveAnimationPosition(double x, double y) async {
    mapController.animateCameraWithTime(
        CameraUpdate.scrollBy(x, y),
        3000
    );
  }

  Future _zoomInAnimation() async {
    mapController.animateCameraWithTime(
        CameraUpdate.zoomTo(16),
        3000
    );
  }

  Future _zoomOutAnimation() async {
    mapController.animateCameraWithTime(
        CameraUpdate.zoomTo(1),
        3000
    );
  }

  /*
  Future _zoomInAnimation() async {
    var zoomTimerCount = 1;
    var zoomTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      zoomTimerCount ++;
      if (zoomTimerCount == 3) {
        timer.cancel();
      }
      mapController.animateCamera(
        CameraUpdate.zoomTo(zoomTimerCount * 1.0),
      );
    });
  }

  Future _zoomOutAnimation() async {
    var zoomTimerCount = 3;
    var zoomTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      zoomTimerCount --;
      if (zoomTimerCount == 0) {
        timer.cancel();
      }
      mapController.animateCamera(
        CameraUpdate.zoomTo(zoomTimerCount * 1.0),
      );
    });
  }
  */


  Future _checkIn() async {
    try {
      await _userService.checkIn();
      checkInCount = await _userService.checkInCount();
      setState(() {});
      Fluttertoast.showToast(msg: "打卡成功");
    } catch (_) {
      ExceptionProcess.process(_);
      throw _;
    }
  }

  Future _updateCheckInCount() async {
    try {
      checkInCount = await _userService.checkInCount();

      _showDialog(context);

      setState(() {});
    } catch (_) {
      ExceptionProcess.process(_);
      throw _;
    }
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
