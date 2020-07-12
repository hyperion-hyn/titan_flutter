import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/config/consts.dart';

class VerifyPositionPage extends StatefulWidget {
  final LatLng initLocation;
  final String addressName;
  
  VerifyPositionPage({this.initLocation, this.addressName});

  @override
  State<StatefulWidget> createState() {
    return _VerifyPositionState();
  }
}

class _VerifyPositionState extends State<VerifyPositionPage> {
  MapboxMapController _mapController;
  LatLng userPosition;
  double defaultZoom = 18;

  var trackingMode = MyLocationTrackingMode.None;
  var enableLocation = true;
  var _addMarkerSubject = PublishSubject<dynamic>();

  @override
  void initState() {
    userPosition = widget.initLocation ?? Application.recentlyLocation;

    _addMarkerSubject.debounceTime(Duration(milliseconds: 500)).listen((_) {
      var latlng = userPosition;
      _mapController?.addSymbol(
        SymbolOptions(
          textField: widget.addressName,
          textOffset: Offset(0, 1),
          textColor: "#333333",
          textSize: 16,
          geometry: latlng,
          iconImage: "hyn_marker_big",
          iconAnchor: "bottom",
          //iconOffset: Offset(0.0, 3.0),
        ),
      );
      _mapController?.animateCamera(CameraUpdate.newLatLng(latlng));
    });

    super.initState();
  }

  void _onStyleLoaded(MapboxMapController controller) {
    _mapController = controller;
    _addMarkerAndMoveToPoi();
  }

  void _addMarkerAndMoveToPoi() {
    if (_mapController != null) {
      _addMarkerSubject.sink.add(1);
    }
  }

  @override
  void dispose() {
    _addMarkerSubject.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          S.of(context).confirm_location,
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
      ),
      body: _mapView(),
    );
  }


  Widget _mapView() {
    var style;
    if (SettingInheritedModel.of(context).areaModel.isChinaMainland) {
      style = Const.kWhiteWithoutMapStyleCn;
    } else {
      style = Const.kWhiteWithoutMapStyle;
    }
    var languageCode = Localizations.localeOf(context).languageCode;

    return Stack(
      children: <Widget>[
        MapboxMap(
          compassEnabled: false,
          initialCameraPosition: CameraPosition(
            target: Application.recentlyLocation,
            zoom: 16,
          ),
          styleString: style,
          onMapCreated: (controller) {
            Future.delayed(Duration(milliseconds: 500)).then((value) {
              _onStyleLoaded(controller);
            });
          },
          myLocationTrackingMode: MyLocationTrackingMode.None,
          rotateGesturesEnabled: true,
          scrollGesturesEnabled: true,
          zoomGesturesEnabled: true,
          tiltGesturesEnabled: false,
          enableLogo: false,
          enableAttribution: false,
          minMaxZoomPreference: MinMaxZoomPreference(1.1, 21.0),
          myLocationEnabled: false,
          languageCode: languageCode,
        ),

      ],
    );
  }
}
