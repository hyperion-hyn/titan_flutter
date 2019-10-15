import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/business/scaffold_map/bloc/bloc.dart';
import 'package:titan/src/model/gaode_poi.dart';
import 'package:titan/src/model/poi.dart';
import 'package:titan/src/widget/draggable_bottom_sheet.dart';

import '../../../global.dart';

class GaodePoiPanel extends StatefulWidget {
  final GaodePoi poi;
  final ScrollController scrollController;

  GaodePoiPanel({this.poi, this.scrollController});

  @override
  State<StatefulWidget> createState() {
    return _GaodePoiPanelState();
  }
}

class _GaodePoiPanelState extends State<GaodePoiPanel> {
  final GlobalKey _poiHeaderKey = GlobalKey(debugLabel: 'poiHeaderKey');

  double getHeaderHeight() {
    RenderBox renderBox = _poiHeaderKey.currentContext?.findRenderObject();
    var h = renderBox?.size?.height ?? 0;
    if (h > 0) {
      if (MediaQuery.of(context).padding.bottom > 0) {
        h += safeAreaBottomPadding;
      }
      return h + 76; //76 is hack options height;
    }
    return 0;
  }

  @override
  void initState() {
    super.initState();

    //动态设置收缩高度
    SchedulerBinding.instance.addPostFrameCallback((_) {
      HeaderHeightNotification(height: getHeaderHeight()).dispatch(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: widget.scrollController,
      child: WillPopScope(
        onWillPop: () async {
          BlocProvider.of<ScaffoldMapBloc>(context).dispatch(ClearSelectPoiEvent());
          return false;
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            //header
            Container(
//          color: Colors.blue,
              padding: EdgeInsets.all(16),
              child: Column(
                key: _poiHeaderKey,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          widget.poi.name,
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          BlocProvider.of<ScaffoldMapBloc>(context).dispatch(ClearSelectPoiEvent());
                        },
                        borderRadius: BorderRadius.all(Radius.circular(32.0)),
                        highlightColor: Colors.transparent,
                        child: Ink(
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xffececec),
                          ),
                          child: Icon(
                            Icons.close,
                            color: Colors.grey,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  buildHeadItem(Icons.location_on, widget.poi.address, hint: '暂无详细地址'),
                  if (widget.poi.remark != null && widget.poi.remark.length > 0)
                    buildHeadItem(Icons.message, widget.poi.remark, hint: '无备注'),
                ],
              ),
            ),
            Divider(
              height: 0,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: FadeInImage.assetNetwork(
                image: widget.poi.photo,
                placeholder: 'res/drawable/img_placeholder.jpg',
                width: 160,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
            buildInfoItem(S.of(context).label, ''),
            buildInfoItem(S.of(context).telphone, ''),
          ],
        ),
      ),
    );
  }

  Widget buildHeadItem(IconData icon, String info, {String hint}) {
    if (hint == null || hint.isEmpty) {
      hint = S.of(context).search_empty_data;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Icon(
            icon,
            color: Colors.grey[600],
            size: 18,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(info != null && info.isNotEmpty ? info : hint,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            ),
          )
        ],
      ),
    );
  }

  Widget buildInfoItem(String tag, String info, {String hint}) {
    if (hint == null || hint.isEmpty) {
      hint = S.of(context).search_empty_data;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16, top: 16),
          child: Text(
            tag,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16, top: 8),
          child: Text((info != null && info.isNotEmpty) ? info : hint, style: TextStyle(fontSize: 15)),
        ),
      ],
    );
  }
}
