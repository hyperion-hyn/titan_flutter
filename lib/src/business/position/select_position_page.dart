import 'package:flutter/material.dart';
import 'package:titan/generated/i18n.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:titan/src/business/my/app_area.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/business/position/add_position_page.dart';

class SelectPositionPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SelectPositionState();
  }
}

class _SelectPositionState extends State<SelectPositionPage> {

  MapboxMapController mapController;
  LatLng userPosition;
  double defaultZoom = 18;

  @override
  void initState() {
    userPosition = LatLng(23.12076, 113.322058);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          "选择位置",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                Navigator.pop(context);
              },
            );
          },
        ),
        actions: <Widget>[
          InkWell(
            onTap: () {
              print('[add] --> 确认中。。。');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => AddPositionPage(userPosition),
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              alignment: Alignment.centerRight,
              child: Text(
                S.of(context).confirm,
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          )
        ],
      ),
      body: _mapView(),
    );
  }

  Widget _mapView() {
    var style;
    if (currentAppArea.key == AppArea.MAINLAND_CHINA_AREA.key) {
      style = "https://cn.tile.map3.network/fiord-color.json";
    } else {
      style = "https://static.hyn.space/maptiles/fiord-color.json";
    }

//    style = 'https://static.hyn.space/maptiles/see-it-all.json';

    return MapboxMap(
      compassEnabled: false,
      initialCameraPosition: CameraPosition(
        target: userPosition ?? LatLng(23.12076, 113.322058),
        zoom: defaultZoom,
      ),
      styleString: style,
      onStyleLoaded: (mapboxController) {
        mapController = mapboxController;

      },
      myLocationTrackingMode: MyLocationTrackingMode.Tracking,
      rotateGesturesEnabled: false,
      tiltGesturesEnabled: false,
      enableLogo: false,
      enableAttribution: false,
      minMaxZoomPreference: MinMaxZoomPreference(1.1, 19.0),
      myLocationEnabled: false,
    );
  }
}