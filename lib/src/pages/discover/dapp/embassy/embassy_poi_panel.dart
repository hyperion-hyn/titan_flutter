import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/components/scaffold_map/bloc/bloc.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/discover/dapp/embassy/entities.dart';
import 'package:titan/src/pages/webview/webview.dart';
import 'package:titan/src/widget/drag_tick.dart';
import 'package:titan/src/widget/header_height_notification.dart';

import '../../../../global.dart';

class EmbassyPoiPanel extends StatefulWidget {
  final EmbassyPoi poi;
  final ScrollController scrollController;

  EmbassyPoiPanel({this.poi, this.scrollController});

  @override
  State<StatefulWidget> createState() {
    return EmbassyPoiPanelState();
  }
}

class EmbassyPoiPanelState extends State<EmbassyPoiPanel> {
  final GlobalKey _poiHeaderKey = GlobalKey(debugLabel: 'poiHeaderKey');

  double getHeaderHeight() {
    RenderBox renderBox = _poiHeaderKey.currentContext?.findRenderObject();
    var h = renderBox?.size?.height ?? 0;
    if (h > 0) {
      if (MediaQuery.of(context).padding.bottom > 0) {
        h += safeAreaBottomPadding;
      }
      return h + 84; //48 is hack options height;
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
    return Container(
//      padding: const EdgeInsets.only(top: 4),
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
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: DragTick(),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: widget.scrollController,
                  child: WillPopScope(
                    onWillPop: () async {
//                      BlocProvider.of<ScaffoldMapBloc>(context).add(ClearSelectedPoiEvent());
                      Application.eventBus.fire(ClearSelectedPoiEvent());
                      return false;
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        //header
                        Container(
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
                                ],
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              buildHeadItem(Icons.location_on, widget.poi.address,
                                  hint: S.of(context).no_detail_address),
//                  if (widget.poi.remark != null && widget.poi.remark.length > 0)
//                    buildHeadItem(Icons.message, widget.poi.remark, hint: '-无备注'),
                            ],
                          ),
                        ),
                        Divider(
                          height: 0,
                        ),
                        buildInfoItem(S.of(context).department, widget.poi.department),
                        buildInfoItem(S.of(context).operating_hours, widget.poi.remark),
                        buildInfoItem(S.of(context).telphone, widget.poi.telephone),
                        buildInfoItem(S.of(context).official_website, widget.poi.website, textColor: Colors.blue,
                            onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => WebViewContainer(
                                        initUrl: widget.poi.website,
                                        title: widget.poi.name,
                                      )));
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 8,
            right: 8,
            child: InkWell(
              onTap: () {
//                BlocProvider.of<ScaffoldMapBloc>(context).add(ClearSelectedPoiEvent());
                Application.eventBus.fire(ClearSelectedPoiEvent());
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
                  Icons.cancel,
                  color: Colors.grey,
                ),
              ),
            ),
          )
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

  Widget buildInfoItem(String tag, String info, {String hint, Color textColor, onTap}) {
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
          child: InkWell(
              onTap: onTap,
              child: Text((info != null && info.isNotEmpty) ? info : hint,
                  style: TextStyle(fontSize: 15, color: (info != null && info.isNotEmpty) ? textColor : null))),
        ),
      ],
    );
  }
}
