import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/scaffold_map/bottom_panels/common_panel.dart';
import 'package:titan/src/components/scaffold_map/map.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/api/api.dart';
import 'package:titan/src/data/entity/poi/photo_simple_poi.dart';
import 'package:titan/src/data/entity/poi/poi_interface.dart';
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
  Api _api = Api();
  LatLng _lastPosition;

  CancelToken cancelToken;
  List<SimplePoiWithPhoto> nearPois;

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
      var gaodeModel;

      if (SettingInheritedModel.of(context)?.areaModel?.isChinaMainland??true) {
        gaodeModel = await _api.searchByGaode(
          lat: _lastPosition.latitude,
          lon: _lastPosition.longitude,
          cancelToken: cancelToken,
        );
      } else {
        gaodeModel = await _api.searchNearByHyn(
          lat: _lastPosition.latitude,
          lon: _lastPosition.longitude,
          cancelToken: cancelToken,
        );
      }

      List<SimplePoiWithPhoto> pois = gaodeModel.data;
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
      Application.eventBus.fire(SelectedSharePoiEvent(poi: nearPois[selectedId]));
    }
  }

  @override
  void dispose() {
    cancelToken?.cancel();
    mapController?.removeListener(mapListener);
    super.dispose();
  }

  MapboxMapController get mapController {
    return (Keys.mapContainerKey.currentState as MapContainerState)?.mapboxMapController;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return LoadingPanel(scrollController: widget.scrollController);
    }

    if (nearPois == null || nearPois.isEmpty) {
      return buildEmptyView(context, widget.scrollController);
    }

    return Container(
      padding: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20.0,
          ),
        ],
      ),
      child: ListView.separated(
          padding: EdgeInsets.symmetric(vertical: 16),
          controller: widget.scrollController,
          itemBuilder: (context, index) {
            IPoi poi = nearPois[index];
            return InkWell(
              onTap: () {
                setState(() {
                  selectedId = index;
                  activeSelectPoiCallback();
                });
                mapController?.moveCamera(CameraUpdate.newLatLng(poi.latLng));
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
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
          itemCount: nearPois.length),
    );
  }

  Widget buildEmptyView(context, ScrollController controller) {
    return Container(
//      padding: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
//        borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20.0,
          ),
        ],
      ),
      child: SingleChildScrollView(
        controller: controller,
        physics: NeverScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(S.of(context).no_data),
            ],
          ),
        ),
      ),
    );
  }
}
