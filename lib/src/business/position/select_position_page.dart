import 'package:flutter/material.dart';
import 'package:titan/generated/i18n.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:titan/src/business/my/app_area.dart';
import 'package:titan/src/business/position/add_ncov_page.dart';
import 'package:titan/src/consts/consts.dart';
import 'package:titan/src/consts/extends_icon_font.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/business/position/add_position_page.dart';

class SelectPositionPage extends StatefulWidget {
  final LatLng initLocation;
  final String type;
  static const String SELECT_PAGE_TYPE_POI = "select_page_type_poi";
  static const String SELECT_PAGE_TYPE_NCOV = "select_page_type_ncov";

  SelectPositionPage({this.initLocation, this.type});

  @override
  State<StatefulWidget> createState() {
    return _SelectPositionState();
  }
}

class _SelectPositionState extends State<SelectPositionPage> {

  MapboxMapController mapController;
  LatLng userPosition;
  double defaultZoom = 18;

  var trackingMode = MyLocationTrackingMode.Tracking;
  var enableLocation = true;

  @override
  void initState() {
    userPosition = widget.initLocation ?? recentlyLocation;
    super.initState();
  }

  void _mapMoveListener() {
    //change tracking mode to none if user drag the map
    if (mapController?.isGesture == true) {
      _updateMyLocationTrackingMode(MyLocationTrackingMode.None);
    }
  }

  bool _updateMyLocationTrackingMode(MyLocationTrackingMode mode) {
    if (mode != trackingMode) {
      setState(() {
        trackingMode = mode;
      });
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    mapController?.removeListener(_mapMoveListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          widget.type == SelectPositionPage.SELECT_PAGE_TYPE_NCOV?S.of(context).selecte_confirmed_position:S.of(context).select_position,
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
              var latLng = mapController?.cameraPosition?.target;
              print('[add] --> 确认中...,latLng: $latLng');
              if (latLng == null) {
                AlertDialog(
                  title: Text(S.of(context).select_position_please_again_hint),
                  actions: <Widget>[
                    FlatButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(S.of(context).confirm))
                  ],
                );
              } else {
                if (widget.type == SelectPositionPage.SELECT_PAGE_TYPE_NCOV) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddNcovPage(latLng),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddPositionPage(latLng),
                    ),
                  );
                }
              }
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
      style = Const.kWhiteMapStyleCn;
    } else {
      style = Const.kWhiteMapStyle;
    }
    var languageCode = Localizations.localeOf(context).languageCode;

    return Stack(
      children: <Widget>[
        MapboxMap(
          compassEnabled: false,
          initialCameraPosition: CameraPosition(
            target: userPosition,
            zoom: defaultZoom,
          ),
          styleString: style,
          onStyleLoaded: (mapboxController) {
            mapController = mapboxController;
            mapController.removeListener(_mapMoveListener);
            mapController.addListener(_mapMoveListener);
          },
          myLocationEnabled: enableLocation,
          myLocationTrackingMode: trackingMode,
          trackCameraPosition: true,
          rotateGesturesEnabled: false,
          tiltGesturesEnabled: false,
          enableLogo: false,
          enableAttribution: false,
          minMaxZoomPreference: MinMaxZoomPreference(1.1, 21.0),
          languageCode: languageCode,
        ),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                ExtendsIconFont.position_marker,
                size: 64,
                color: Theme.of(context).primaryColor,
              ),
              SizedBox(height: 68)
            ],
          ),
        )
      ],
    );
  }
}
