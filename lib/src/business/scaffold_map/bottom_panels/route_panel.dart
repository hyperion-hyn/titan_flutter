import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/consts/consts.dart';

import '../../../global.dart';

class RoutePanel extends StatelessWidget {
  final RouteDataModel routeDataModel;
  final String profile;

  RoutePanel({this.routeDataModel, this.profile});

  @override
  Widget build(BuildContext context) {
    try {
      var routes = json.decode(routeDataModel.directionsResponse);
      double duration = (routes['routes'][0]['duration'] as num).toDouble();
      double distance = (routes['routes'][0]['distance'] as num).toDouble();

      var navigationDataModel = NavigationDataModel(
          startLatLng: routeDataModel.startLatLng,
          endLatLng: routeDataModel.endLatLng,
          directionsResponse: routeDataModel.directionsResponse,
          profile: profile);

      return Row(
        children: <Widget>[
          Expanded(
            child: Material(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      timeString(context, duration),
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      distanceString(context, distance),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          height: 28,
                          child: MaterialButton(
                            elevation: 0,
                            highlightElevation: 0,
                            minWidth: 60,
                            onPressed: () {
                              if (Platform.isAndroid) {
                                Navigation.navigation(Keys.mapParentKey.currentContext, navigationDataModel);
                              } else {
                                Fluttertoast.showToast(msg: "敬请期待");
                              }
                            },
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            textColor: Color(0xddffffff),
                            highlightColor: Colors.black,
                            splashColor: Colors.white10,
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  Icons.navigation,
                                  color: Color(0xddffffff),
                                  size: 15,
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                Text(
                                  "导航",
                                  style: TextStyle(fontSize: 14, color: Color(0xddffffff)),
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          )
        ],
      );
    } catch (err) {
      logger.e(err);
      return buildError(context);
    }
  }

  Widget buildError(context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Material(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.all(40),
                  child: Text(S.of(context).no_recommended_route),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  String timeString(BuildContext context, double seconds) {
    if (seconds < 60) {
      return S.of(context).less_than_1_min;
    }
    final kDay = 3600 * 24;
    final kHour = 3600;
    final kMinute = 60;
    int day = 0;
    int hour = 0;
    int minute = 0;
    if (seconds > kDay) {
      day = seconds ~/ kDay;
      seconds = seconds - day * kDay;
    }
    if (seconds > kHour) {
      hour = seconds ~/ kHour;
      seconds = seconds - hour * kHour;
    }
    minute = seconds ~/ kMinute;
    seconds = seconds - minute * kMinute;

    var timeStr = '';
    if (day > 0) {
      timeStr += S.of(context).n_day('$day');
    }
    if (hour > 0) {
      timeStr += S.of(context).n_hour('$hour');
    }
    if (minute > 0) {
      timeStr += S.of(context).n_minute('$minute');
    }
    return timeStr;
  }

  String distanceString(BuildContext context, double distance) {
    var km = 0;
    if (distance > 1000) {
      km = distance ~/ 1000;
      distance -= km * 1000;
    }
    var distanceStr = '';
    if (km > 0) {
      distanceStr += S.of(context).km('$km');
    }
    distanceStr += S.of(context).distance('${distance.toInt()}');
    return distanceStr;
  }
}
