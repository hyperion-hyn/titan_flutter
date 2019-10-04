import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:titan/src/business/home/bloc/bloc.dart';

class Map extends StatefulWidget {
  final List<HeavenDataModel> heavenDataList;
  final RouteDataModel routeDataModel;
  final String style;
  final double defaultZoom;
  final LatLng defaultCenter;

  Map({
    this.heavenDataList,
    this.routeDataModel,
    this.style,
    this.defaultZoom = 9.0,
    this.defaultCenter = const LatLng(23.122592, 113.327356),
  });

  @override
  State<StatefulWidget> createState() {
    return _MapState();
  }
}

class _MapState extends State<Map> {
  MapboxMapController _mapController;

  _onMapClick(Point<double> point, LatLng coordinates) async {
    //TODO
    print('click map ${point.toString()}');
    //test
    BlocProvider.of<HomeBloc>(context).dispatch(HomeInitEvent());
  }

  _onMapLongPress(Point<double> point, LatLng coordinates) async {
    //TODO
    print('long press map ${point.toString()}');
  }

  void onStyleLoaded(controller) async {
    setState(() {
      _mapController = controller;
    });

//    _toMyLocation();
//    _loadPurchasedMap();
  }

  @override
  Widget build(BuildContext context) {
    return MapboxMapParent(
        controller: _mapController,
        child: MapboxMap(
          onMapClick: _onMapClick,
          onMapLongPress: _onMapLongPress,
          styleString: widget.style,
          onStyleLoaded: onStyleLoaded,
          initialCameraPosition: CameraPosition(
            target: widget.defaultCenter,
            zoom: widget.defaultZoom,
          ),
          rotateGesturesEnabled: true,
          tiltGesturesEnabled: false,
          enableLogo: false,
          enableAttribution: false,
          compassMargins: CompassMargins(left: 0, top: 88, right: 16, bottom: 0),
          minMaxZoomPreference: MinMaxZoomPreference(1.1, 19.0),
          myLocationEnabled: true,
          myLocationTrackingMode: MyLocationTrackingMode.None,
          children: <Widget>[
            ///active plugins
            HeavenPlugin(models: widget.heavenDataList),
            RoutePlugin(model: widget.routeDataModel),
          ],
        ));
  }
}
