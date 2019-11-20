import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:titan/src/basic/http/http.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/business/scaffold_map/bloc/bloc.dart';
import 'package:titan/src/business/scaffold_map/map.dart';
import 'package:titan/src/consts/consts.dart';

import '../../../../global.dart';

class HotArea extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HotAreaState();
  }
}

class HotAreaState extends BaseState<HotArea> {
  bool isExpanded;

//  String selectedName;

  List<dynamic> hotModels;
  List<dynamic> otherModels;

  @override
  void onCreated() async {
    _loadData();
  }

  void _loadData() async {
    if (hotModels == null || otherModels == null) {
      try {
        var data = await recommendArea();
        hotModels = data['hot'].map((data) => AreaModel.fromJson(context, data)).toList();
        otherModels = data['others'].map((data) => AreaModel.fromJson(context, data)).toList();
        setState(() {});
      } catch (err) {
        logger.e(err);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (isExpanded == true) {
      child = buildExpanded();
    } else {
      child = buildCollapased();
    }
    return BlocBuilder<ScaffoldMapBloc, ScaffoldMapState>(
        bloc: BlocProvider.of<ScaffoldMapBloc>(context),
        builder: (context, state) {
          if (state is InitDMapState) {
            return child;
          } else {
            return SizedBox.shrink();
          }
        });
  }

  Widget buildCollapased() {
    return Positioned(
      left: 16,
      bottom: 24,
      child: Material(
        borderRadius: BorderRadius.circular(4),
        elevation: 2,
        child: InkWell(
          onTap: () {
            setState(() {
              isExpanded = true;
              _loadData();
            });
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 8, top: 4, right: 4, bottom: 4),
            child: Row(
              children: <Widget>[
                Text('热门地区'),
                Icon(Icons.keyboard_arrow_right),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildExpanded() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Material(
        color: Colors.white,
        elevation: 2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(
                top: 8,
                left: 8,
                right: 8,
                bottom: 4,
              ),
              height: 24,
              child: Row(
                children: <Widget>[
                  Text('推荐地区'),
                  Expanded(
                      child: Align(
                    child: InkWell(
                      child: Icon(Icons.clear),
                      onTap: () {
                        setState(() {
                          isExpanded = false;
                        });
                      },
                    ),
                    alignment: Alignment.centerRight,
                  )),
                ],
              ),
            ),
            if (hotModels != null)
              Container(
                height: 120,
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(left: index > 0 ? 0 : 8, right: 8, top: 8, bottom: 8),
                      child: buildHotItem(context, hotModels[index]),
                    );
                  },
                  scrollDirection: Axis.horizontal,
                  itemCount: hotModels.length,
                ),
              )
            else
              Container(
                height: 130,
                child: Center(
                    child: CircularProgressIndicator(
                  strokeWidth: 3,
                )),
              ),
            if (otherModels != null) buildNormalItems(context, otherModels)
          ],
        ),
      ),
    );
  }

  Widget buildHotItem(context, data) {
    var areaModel = data;
    return InkWell(
      onTap: () => _onSelectItem(areaModel),
      child: Container(
        width: 126,
        height: 90,
//        decoration: BoxDecoration(
//            border: Border.all(
//          width: selectedName == areaModel.name ? 2 : 0,
//          color: Colors.blue,
//        )),
//      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Stack(
          children: <Widget>[
            Container(
              constraints: BoxConstraints.expand(),
              child: Image.network(
                areaModel.pic,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[100],
                  );
                },
                fit: BoxFit.cover,
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                constraints: BoxConstraints.expand(height: 40),
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                  colors: [Color(0x00000000), Color(0x88000000)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )),
                child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        areaModel.name,
                        style: TextStyle(color: Colors.white),
                      ),
                    )),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildNormalItems(context, data) {
    return Container(
      margin: EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 16),
      child: Wrap(
        children: <Widget>[
          for (var model in data)
            Padding(
              padding: EdgeInsets.only(right: 8),
              child: RaisedButton(
                onPressed: () => _onSelectItem(model),
                child: Text(model.name),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                color: Colors.grey[100],
                elevation: 1.0,
              ),
            )
        ],
      ),
    );
  }

  void _onSelectItem(AreaModel model) {
    zoomToHotArea(model.latLng, model.zoomLevel);
    setState(() {
      isExpanded = false;
    });
//    if (model.name != selectedName) {
//      eventBus.fire(ZoomToHotAreaEvent(zoom: model.zoomLevel, coordinate: model.latLng));
//      setState(() {
//        selectedName = model.name;
//      });
//    }
  }

  void zoomToHotArea(LatLng coordinate, double zoom) {
    mapboxMapController?.disableLocation();
    mapboxMapController?.animateCamera(CameraUpdate.newLatLngZoom(coordinate, zoom));
  }

  MapboxMapController get mapboxMapController {
    return (Keys.mapContainerKey.currentState as MapContainerState)?.mapboxMapController;
  }

  ///推荐区域
  Future<dynamic> recommendArea() async {
    return await HttpCore.instance.get('https://hmap.s3.ap-east-1.amazonaws.com/hmap_info.json');
//    return Future.delayed(Duration(milliseconds: 300)).then((value) {
//      return {
//        'hot': [
//          {
//            'name_zh': "香港",
//            'name_en': "HongKong",
//            'pic': "https://hmap.s3.ap-east-1.amazonaws.com/images/hot_hongkong.jpg",
//            'latLng': [22.330618837319477, 114.16221125523612],
//            'zoomLevel': 16.0
//          },
//          {
//            'name_zh': "日本",
//            'name_en': "Japan",
//            'pic': "https://hmap.s3.ap-east-1.amazonaws.com/images/hot_japan.jpg",
//            'latLng': [35.19433573777792, 136.884316054441],
//            'zoomLevel': 10.0
//          },
//          {
//            'name_zh': "泰国",
//            'name_en': "Thailand",
//            'pic': "https://hmap.s3.ap-east-1.amazonaws.com/images/hot_thailand.jpg",
//            'latLng': [13.743615234236714, 100.57313866245795],
//            'zoomLevel': 12.0
//          }
//        ],
//        'others': [
//          {
//            'name_zh': "印尼",
//            'name_en': "Indonesia",
//            'pic': "",
//            'latLng': [-6.253274, 106.831215],
//            'zoomLevel': 12.0
//          },
//          {
//            'name_zh': "印尼",
//            'name_en': "Indonesia",
//            'pic': "",
//            'latLng': [-6.253274, 106.831215],
//            'zoomLevel': 12.0
//          },
//          {
//            'name_zh': "印尼",
//            'name_en': "Indonesia",
//            'pic': "",
//            'latLng': [-6.253274, 106.831215],
//            'zoomLevel': 12.0
//          },
//          {
//            'name_zh': "印尼",
//            'name_en': "Indonesia",
//            'pic': "",
//            'latLng': [-6.253274, 106.831215],
//            'zoomLevel': 12.0
//          },
//          {
//            'name_zh': "印尼",
//            'name_en': "Indonesia",
//            'pic': "",
//            'latLng': [-6.253274, 106.831215],
//            'zoomLevel': 12.0
//          }
//        ]
//      };
//    });
  }
}

class AreaModel {
  final String name;
  final String pic;
  final LatLng latLng;
  final double zoomLevel;

  AreaModel._({this.latLng, this.name, this.pic, this.zoomLevel});

  factory AreaModel.fromJson(BuildContext context, dynamic json) {
    var languageCode = Localizations.localeOf(context).languageCode;
    var name = json['name_$languageCode}'] ?? json['name_en'];
    var latLng = LatLng(json['latLng'][0], json['latLng'][1]);
    var pic = json['pic'] ?? '';
    var zoomLevel = json['zoomLevel'] ?? 8.0;
    return AreaModel._(
      latLng: latLng,
      name: name,
      pic: pic,
      zoomLevel: zoomLevel,
    );
  }
}
