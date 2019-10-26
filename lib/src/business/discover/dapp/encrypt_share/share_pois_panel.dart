import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/business/me/service/user_service.dart';
import 'package:titan/src/business/scaffold_map/bottom_panels/common_panel.dart';
import 'package:titan/src/business/scaffold_map/map.dart';
import 'package:titan/src/consts/consts.dart';
import 'package:titan/src/model/gaode_poi.dart';
import 'package:titan/src/model/poi.dart';
import 'package:titan/src/model/poi_interface.dart';
import 'package:titan/src/utils/utils.dart';

import '../../../../global.dart';
import 'event.dart';

class SharePoisPanel extends StatefulWidget {
  final ScrollController scrollController;

  SharePoisPanel({this.scrollController});

  @override
  State<StatefulWidget> createState() {
    return SharePoisPanelState();
  }
}

class SharePoisPanelState extends BaseState<SharePoisPanel> {
  UserService _userService = UserService();
  LatLng _lastPosition;

  CancelToken cancelToken;
  List<GaodePoi> nearPois;

  int selectedId = 0;

  bool isLoading = false;

  @override
  void onCreated() {
    super.onCreated();

    mapController?.addListener(mapListener);
  }

  void mapListener() {
    if (mapController?.isCameraMoving == false) {
      var position = mapController?.cameraPosition?.target;
      if (position != null && position != _lastPosition) {
        if (_lastPosition != null) {
          var distance = position.distanceTo(_lastPosition);
          if (distance < 10) {
            //小于10米不更新
            return;
          }
        }
        _lastPosition = position;
        debounce(() {
          print('位置更新了, $_lastPosition');
          loadPois(position.latitude, position.longitude);
        }, 500)();
      }
    }
  }

  void loadPois(double lat, double lon) async {
    if (cancelToken?.isCancelled == false) {
      cancelToken?.cancel();
      cancelToken = null;
    }

    setState(() {
      isLoading = true;
    });

    try {
      cancelToken = CancelToken();
      var gaodeModel = await _userService.searchByGaode(
        lat: _lastPosition.latitude,
        lon: _lastPosition.longitude,
        cancelToken: cancelToken,
      );
      List<GaodePoi> pois = gaodeModel.data;
      setState(() {
        nearPois = pois;
        isLoading = false;
        selectedId = 0;
        activeSelectPoiCallback();
      });
    } catch (e) {
      logger.e(e);
//      Fluttertoast.showToast(msg: '加载数据失败！');
    }
  }

  void activeSelectPoiCallback() {
    if (nearPois != null && nearPois.length > selectedId) {
      eventBus.fire(SelectedSharePoiEvent(poi: nearPois[selectedId]));
    }
  }

  @override
  void dispose() {
    cancelToken?.cancel();
    mapController?.removeListener(mapListener);
    super.dispose();
  }

  MapboxMapController get mapController {
    return (Keys.mapKey.currentState as MapContainerState)?.mapboxMapController;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return LoadingPanel();
    }

    if (nearPois == null || nearPois.isEmpty) {
      return buildEmptyView(context);
    }

    return ListView.separated(
        controller: widget.scrollController,
        itemBuilder: (context, index) {
          IPoi poi = nearPois[index];
          return InkWell(
            onTap: () {
              setState(() {
                selectedId = index;
                activeSelectPoiCallback();
              });
              mapController?.disableLocation();
              mapController?.moveCamera(CameraUpdate.newLatLng(poi.latLng));
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          poi.name,
                          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                  child: Text(
                                poi.address,
                                style: TextStyle(color: Colors.grey, fontSize: 13),
                              )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                      width: 60,
                      child: Visibility(
                          visible: index == selectedId,
                          child: Icon(
                            Icons.check,
                            color: Theme.of(context).primaryColor,
                          )))
                ],
              ),
            ),
          );
        },
        separatorBuilder: (context, index) {
          return Divider(
            height: 24,
          );
        },
        itemCount: nearPois.length);
  }

  Widget buildEmptyView(context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Text('暂无数据'),
    );
  }
}
