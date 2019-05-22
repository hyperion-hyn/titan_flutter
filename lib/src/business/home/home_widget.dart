import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/consts/consts.dart';
import 'package:titan/src/resource/api/api.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final LatLng center = const LatLng(23.122592, 113.327356);

  _onMapCreated(MapboxMapController controller) {
    print('map created');
  }

  Widget _drawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          DrawerHeader(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Titan'),
            ),
          ),
          ListTile(
            leading: Icon(Icons.update),
            title: RaisedButton(
              onPressed: () {
                Api().update('official', 'zh').then((data) => print(data)).catchError((err) => print(err));
              },
              child: Text(S.of(context).app_name),
            ),
          )
        ],
      ),
    );
  }

  get _mapbox => MapboxMap(
        styleString: 'https://static.hyn.space/maptiles/see-it-all.json',
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: center,
          zoom: 9.0,
        ),
        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
          Factory<OneSequenceGestureRecognizer>(
            () => EagerGestureRecognizer(),
          ),
        ].toSet(),
        rotateGesturesEnabled: false,
        tiltGesturesEnabled: false,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: _drawer(context),
        body: Stack(
          children: <Widget>[
            ///地图渲染
            _mapbox,

            ///主要是支持drawer手势划出
            Container(
              decoration: BoxDecoration(color: Colors.transparent),
              constraints: BoxConstraints.tightForFinite(width: 24.0),
            )
          ],
        ));
  }
}
