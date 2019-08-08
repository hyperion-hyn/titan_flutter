import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/src/business/home/bloc/bloc.dart';
import 'package:titan/src/model/poi.dart';
import 'package:titan/src/model/poi_interface.dart';

class PoiListSheet extends StatelessWidget {
  final List<IPoi> pois;
  final ScrollController scrollController;
  final double listHeight;

  PoiListSheet({this.pois, this.scrollController, this.listHeight = 300});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: listHeight,
      child: ListView.separated(
        controller: scrollController,
        padding: EdgeInsets.only(top: 8, bottom: 16),
        itemBuilder: (context, index) {
          return buildItem(context, pois[index]);
        },
        separatorBuilder: (context, index) {
          return Container(
            color: Colors.grey[200],
            height: 1,
          );
        },
        itemCount: pois.length,
      ),
    );
  }

  Widget buildItem(context, PoiEntity poi) {
    return InkWell(
      onTap: () {
        onTapPoi(context, poi);
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(poi.name, style: TextStyle(fontSize: 17),),
            SizedBox(height: 8),
            Text(poi.address, style: TextStyle(color: Colors.grey[600]),),
          ],
        ),
      ),
    );
  }

  void onTapPoi(context, PoiEntity poi) {
    BlocProvider.of<HomeBloc>(context).dispatch(ShowPoiEvent(poi: poi));
  }
}
