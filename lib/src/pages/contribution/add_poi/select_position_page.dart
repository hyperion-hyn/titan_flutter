import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/config/extends_icon_font.dart';
import 'package:titan/src/pages/contribution/add_poi/add_ncov_page.dart';

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

class _SelectPositionState extends BaseState<SelectPositionPage> {
  MapboxMapController mapController;
  LatLng userPosition;
  double defaultZoom = 16;

  var trackingMode = MyLocationTrackingMode.Tracking;
  bool get enableLocation => widget.initLocation == null;

  bool _isLoadedFinish = false;

  GlobalKey _globalKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  void onCreated() async {
    userPosition = widget.initLocation ?? Application.recentlyLocation;
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
      key: _globalKey,
      appBar: BaseAppBar(
        baseTitle: widget.type == SelectPositionPage.SELECT_PAGE_TYPE_NCOV
            ? S.of(context).selecte_confirmed_position
            : S.of(context).select_position,
        backgroundColor: Colors.white,
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
          FlatButton(
            onPressed: () {
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
                  Navigator.pop(context, latLng);
                }
              }
            },
            child: Text(
              S.of(context).confirm,
              style: TextStyle(
                color: HexColor("#1F81FF"),
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
      body: _mapView(),
    );
  }

  Widget _mapView() {
    var style;
    if (widget.type == SelectPositionPage.SELECT_PAGE_TYPE_NCOV) {
      style = Const.kNCovMapStyle;
    } else {
      if (SettingInheritedModel.of(context)?.areaModel?.isChinaMainland ?? true) {
        style = Const.kWhiteMapStyleCn;
      } else {
        style = Const.kWhiteMapStyle;
      }
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
          onStyleLoadedCallback: () {
            mapController.removeListener(_mapMoveListener);
            mapController.addListener(_mapMoveListener);
          },
          onMapCreated: (mapboxController) {
            Future.delayed(Duration(milliseconds: 500)).then((value) {
              mapController = mapboxController;

              _showSnackBar();
            });
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

  _showSnackBar() {
    if (widget.type == SelectPositionPage.SELECT_PAGE_TYPE_NCOV) return;

    if (!_isLoadedFinish) {
      _isLoadedFinish = true;
      if (_globalKey.currentState is ScaffoldState) {
        var _scaffoldState = _globalKey.currentState as ScaffoldState;
        _scaffoldState.showSnackBar(SnackBar(
          content: Text(S.of(context).verify_location_hint),
          duration: Duration(seconds: 10),
        ));
      }
    }
  }
}
