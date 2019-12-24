import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

class SelectPoiLocationScene extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SelectPoiLocationSceneState();
  }
}

class SelectPoiLocationSceneState extends State<SelectPoiLocationScene> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(child: Icon(Icons.close), onTap: () {
          Navigator.maybePop(context);
        },),
        title: Text('选择位置'),
        centerTitle: true,
        actions: <Widget>[
          FlatButton(
            onPressed: () {},
            child: Text('下一步', style: TextStyle(color: Colors.white),),
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
//          MapboxMap(
//            compassEnabled: false,
//            trackCameraPosition: true,
//            styleString: widget.style,
//            onStyleLoaded: onStyleLoaded,
//            initialCameraPosition: CameraPosition(
//              target: widget.defaultCenter,
//              zoom: widget.defaultZoom,
//            ),
//            rotateGesturesEnabled: false,
//            tiltGesturesEnabled: false,
//            enableLogo: false,
//            enableAttribution: false,
//            compassMargins: CompassMargins(left: 0, top: 88, right: 16, bottom: 0),
//            minMaxZoomPreference: MinMaxZoomPreference(1.1, 19.0),
//            myLocationEnabled: true,
//            myLocationTrackingMode: locationTrackingMode,
//            languageCode: widget.languageCode,
//            children: <Widget>[
//              ///active plugins
//              HeavenPlugin(models: widget.heavenDataList),
//              RoutePlugin(model: widget.routeDataModel),
//            ],
//          )
        ],
      ),
    );
  }
}
