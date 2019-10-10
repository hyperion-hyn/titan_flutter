import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/business/home/map/bloc/bloc.dart';

class RouteSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapBloc, MapState>(
      builder: (BuildContext context, MapState state) {
        if (state is RouteSceneState) {
          return buildRouteInfo(context, state);
        }
        return SizedBox.shrink();
      },
    );
  }

  Widget buildRouteInfo(BuildContext context, RouteSceneState state) {
    var model = state.routeDataModel;
    if (model != null && !state.isLoading && !state.isError) {
      try {
        var routes = json.decode(model.directionsResponse);
        double duration = (routes['routes'][0]['duration'] as num).toDouble();
        double distance = (routes['routes'][0]['distance'] as num).toDouble();

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
                    vertical: 24,
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
                    ],
                  ),
                ),
              ),
            )
          ],
        );
      } catch (err) {
        print(err);
        return buildError(context);
      }
    } else if (state.isError) {
      return buildError(context);
    }

    return buildLoadingInfo();
  }

  Widget buildLoadingInfo() {
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
                  width: 40,
                  height: 40,
                  margin: EdgeInsets.all(30),
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
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
