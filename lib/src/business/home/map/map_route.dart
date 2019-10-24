import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/business/home/bloc/bloc.dart' as home;
import 'package:titan/src/business/home/bloc/bloc.dart';
import 'package:titan/src/widget/circle_dash_line.dart';

import '../../../global.dart';
import 'bloc/bloc.dart';

class MapRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapBloc, MapState>(builder: (context, state) {
      var model = (state is RouteSceneState) ? state.routeDataModel : null;
      return Stack(
        children: <Widget>[
          RoutePlugin(model: model),
          if (state is RouteSceneState)
            Column(
              children: <Widget>[buildHeader(context, state)],
            ),
        ],
      );
    });
  }

  Widget buildHeader(BuildContext context, RouteSceneState state) {
    return WillPopScope(
      onWillPop: () async {
        BlocProvider.of<MapBloc>(context).add(CloseRouteEvent());
        if (state.selectedPoi != null) {
          BlocProvider.of<home.HomeBloc>(context).add(home.ShowPoiEvent(poi: state.selectedPoi));
        }
        return false;
      },
      child: Material(
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.only(top: 32),
          child: Column(
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  InkWell(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(Icons.arrow_back_ios),
                    ),
                    onTap: () {
                      BlocProvider.of<MapBloc>(context).add(CloseRouteEvent());
                      if (state.selectedPoi != null) {
                        BlocProvider.of<home.HomeBloc>(context).add(home.ShowPoiEvent(poi: state.selectedPoi));
                      }
                    },
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(color: Color(0xfff7f7f7), borderRadius: BorderRadius.circular(8)),
                      margin: EdgeInsets.only(left: 8, top: 8, right: 16, bottom: 0),
                      padding: EdgeInsets.all(8),
                      child: Row(
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                decoration:
                                    BoxDecoration(color: Color(0xff2ebc57), borderRadius: BorderRadius.circular(24)),
                                width: 8,
                                height: 8,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4),
                                child: CustomPaint(
                                  size: Size(8, 20),
                                  painter: CircleDashLine(
                                    direction: CircleDashDirection.VERTICAL,
                                    dotRadius: 1.6,
                                  ),
                                ),
                              ),
                              Container(
                                decoration:
                                    BoxDecoration(color: Color(0xffe6162f), borderRadius: BorderRadius.circular(24)),
                                width: 8,
                                height: 8,
                              )
                            ],
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8, right: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    state.startName ?? "",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  Divider(
                                    height: 16,
                                  ),
                                  Text(
                                    state.endName ?? "",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  FlatButton.icon(
                    onPressed: () {
                      if (state.profile != 'driving') {
                        eventBus.fire(RouteClickEvent(
                          profile: 'driving',
                          toPoi: state.selectedPoi,
                        ));
                      }
                    },
                    icon: Icon(
                      Icons.drive_eta,
                      size: 20,
                    ),
                    label: Text(
                      S.of(context).driving,
                      style: TextStyle(fontSize: 14),
                    ),
                    color: state.profile == 'driving' ? Colors.blue[100] : null,
                  ),
                  FlatButton.icon(
                    onPressed: () {
                      if (state.profile != 'cycling') {
                        eventBus.fire(RouteClickEvent(
                          profile: 'cycling',
                          toPoi: state.selectedPoi,
                        ));
                      }
                    },
                    icon: Icon(
                      Icons.directions_bike,
                      size: 20,
                    ),
                    label: Text(
                      S.of(context).cycling,
                      style: TextStyle(fontSize: 14),
                    ),
                    color: state.profile == 'cycling' ? Colors.blue[100] : null,
                  ),
                  FlatButton.icon(
                    onPressed: () {
                      if (state.profile != 'walking') {
                        eventBus.fire(RouteClickEvent(
                          profile: 'walking',
                          toPoi: state.selectedPoi,
                        ));
                      }
                    },
                    icon: Icon(
                      Icons.directions_walk,
                      size: 20,
                    ),
                    label: Text(
                      S.of(context).walking,
                      style: TextStyle(fontSize: 14),
                    ),
                    color: state.profile == 'walking' ? Colors.blue[100] : null,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
