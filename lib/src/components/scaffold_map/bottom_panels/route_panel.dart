import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/widget/header_height_notification.dart';

import '../../../global.dart';

class RoutePanel extends StatefulWidget {
  final RouteDataModel routeDataModel;
  final String profile;
  final ScrollController scrollController;

  RoutePanel({this.routeDataModel, this.profile, this.scrollController});

  @override
  State<StatefulWidget> createState() {
    return RoutePanelState();
  }
}

class RoutePanelState extends State<RoutePanel> {
  final GlobalKey headerKey = GlobalKey(debugLabel: 'poiHeaderKey');

  double getHeaderHeight() {
    RenderBox renderBox = headerKey.currentContext?.findRenderObject();
    var h = renderBox?.size?.height ?? 0;
    if (h > 0) {
      if (MediaQuery.of(context).padding.bottom > 0) {
        h += safeAreaBottomPadding;
      }
      return h;
    }
    return h;
  }

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      var panelInitHeight = getHeaderHeight();
      if(panelInitHeight > 0) {
        HeaderHeightNotification(height: panelInitHeight).dispatch(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    try {
      var routes = json.decode(widget.routeDataModel.directionsResponse);
      double duration = (routes['routes'][0]['duration'] as num).toDouble();
      double distance = (routes['routes'][0]['distance'] as num).toDouble();

      // todo: jison_test_0507
      var startNavigationTips = S.of(context).start_navigation_tips;
      var language = Localizations.localeOf(context).languageCode;
      switch (language) {
        case 'en':
          //startNavigationTips = "Start navigation";
          break;

        case 'ko':
          //startNavigationTips = "탐색 시작";
          break;

        default:
          //startNavigationTips = "开始导航";
          language = "zh-Hans";
          break;
      }
      print("[navigation] language:$language");

      var navigationDataModel = NavigationDataModel(
          startLatLng: widget.routeDataModel.startLatLng,
          endLatLng: widget.routeDataModel.endLatLng,
          directionsResponse: widget.routeDataModel.directionsResponse,
          profile: widget.profile,
          language: language,
          startNavigationTips: startNavigationTips,
      );

      return Container(
//        padding: const EdgeInsets.only(top: 4),
        decoration: BoxDecoration(
//          borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 20.0,
            ),
          ],
        ),
        child: SingleChildScrollView(
          controller: widget.scrollController,
          physics: NeverScrollableScrollPhysics(),
          child: Row(
            key: headerKey,
            children: <Widget>[
              Expanded(
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
                                Navigation.navigation(Keys.mapParentKey.currentContext, navigationDataModel);
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
                                    S.of(context).navigation,
                                    style: TextStyle(fontSize: 14, color: Color(0xddffffff)),
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      );
    } catch (err) {
      logger.e(err);
      return buildError(context);
    }
  }

  Widget buildError(context) {
    return Container(
      //        padding: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
//          borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20.0,
          ),
        ],
      ),
      child: SingleChildScrollView(
        controller: widget.scrollController,
        physics: NeverScrollableScrollPhysics(),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.all(40),
                    child: Text(S.of(context).no_recommended_route),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
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