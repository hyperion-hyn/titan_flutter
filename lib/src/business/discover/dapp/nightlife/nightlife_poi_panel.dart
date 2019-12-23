import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/business/scaffold_map/bloc/bloc.dart';
import 'package:titan/src/model/heaven_map_poi_info.dart';
import 'package:titan/src/widget/header_height_notification.dart';

class NightLifePanel extends StatefulWidget {
  final HeavenMapPoiInfo poi;
  final ScrollController scrollController;

  NightLifePanel({this.poi, this.scrollController});

  @override
  State<StatefulWidget> createState() {
    return NightLifePanelState();
  }
}

class NightLifePanelState extends State<NightLifePanel> {
  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      HeaderHeightNotification(height: 180).dispatch(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: widget.scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16, right: 16),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    widget.poi.name,
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                  ),
                ),
                InkWell(
                  onTap: () {
                    BlocProvider.of<ScaffoldMapBloc>(context).add(ClearSelectPoiEvent());
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
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16, top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Icon(
                  IconData(0xe601, fontFamily: 'iconfont'),
                  color: Colors.purple[300],
                  size: 20,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      widget.poi.service?.replaceAll('141', 'night-life') ?? S.of(context).private_service,
                      style: TextStyle(color: Colors.purple, fontSize: 15),
                    ),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16, top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Icon(
                  Icons.phone,
                  color: Colors.green,
                  size: 20,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                        (widget.poi.phone != null && widget.poi.phone.isNotEmpty)
                            ? widget.poi.phone?.replaceAll('141', 'night-life')
                            : S.of(context).no_fill_in,
                        style: TextStyle(fontSize: 15)),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16, top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Icon(
                  Icons.location_on,
                  color: Colors.grey[600],
                  size: 20,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      (widget.poi.address != null && widget.poi.address.isNotEmpty)
                          ? widget.poi.address
                          : S.of(context).no_fill_in,
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Divider(
              height: 16,
            ),
          ),
          buildInfoItem(S.of(context).service_hours, widget.poi.time, hint: S.of(context).no_fill_in),
          buildInfoItem(S.of(context).service_area, widget.poi.area, hint: S.of(context).no_fill_in),
          buildInfoItem(S.of(context).service_description, widget.poi.desc, hint: S.of(context).no_fill_in),
          SizedBox(
            height: 56,
          ),
        ],
      ),
    );
  }

  Widget buildInfoItem(String tag, String info, {String hint = ''}) {
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
