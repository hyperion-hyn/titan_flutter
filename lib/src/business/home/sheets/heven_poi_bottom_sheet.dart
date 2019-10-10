import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/model/heaven_map_poi_info.dart';
import 'package:titan/src/model/poi.dart';
import 'package:titan/src/widget/draggable_bottom_sheet.dart';

import '../../../global.dart';

class HeavenPoiBottomSheet extends StatefulWidget {
  final HeavenMapPoiInfo selectedPoiEntity;
  final ScrollController scrollController;

  HeavenPoiBottomSheet({this.selectedPoiEntity, this.scrollController});

  @override
  State<StatefulWidget> createState() {
    return _HeavenPoiBottomSheetState();
  }
}

class _HeavenPoiBottomSheetState extends State<HeavenPoiBottomSheet> {
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
    SchedulerBinding.instance.addPostFrameCallback((_) {
      HeaderHeightNotification(height: getHeaderHeight()).dispatch(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: widget.scrollController,
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
                Text(
                  widget.selectedPoiEntity.name,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  height: 8,
                ),
                buildHeadItem(Icons.location_on, widget.selectedPoiEntity.address, hint: '暂无详细地址'),
                if (widget.selectedPoiEntity.remark != null && widget.selectedPoiEntity.remark.length > 0)
                  buildHeadItem(Icons.message, widget.selectedPoiEntity.remark, hint: '无备注'),
              ],
            ),
          ),
          Divider(
            height: 0,
          ),
          buildInfoItem(S.of(context).telphone, widget.selectedPoiEntity.phone),
          if (widget.selectedPoiEntity.time != null && widget.selectedPoiEntity.time.isNotEmpty)
            buildInfoItem(S.of(context).time, widget.selectedPoiEntity.time),
          if (widget.selectedPoiEntity.service != null && widget.selectedPoiEntity.service.isNotEmpty)
            buildInfoItem(S.of(context).services, widget.selectedPoiEntity.service),
          if (widget.selectedPoiEntity.remark != null && widget.selectedPoiEntity.remark.isNotEmpty)
            buildInfoItem(S.of(context).remark, widget.selectedPoiEntity.remark),
        ],
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
