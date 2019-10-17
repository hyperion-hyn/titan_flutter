import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/src/business/scaffold_map/bloc/bloc.dart';
import 'package:titan/src/model/gaode_poi.dart';
import 'package:titan/src/model/poi.dart';
import 'package:titan/src/model/poi_interface.dart';

class SearchListPanel extends StatelessWidget {
  final List<IPoi> pois;
  final ScrollController scrollController;
  final double listHeight;

  SearchListPanel({this.pois, this.scrollController, this.listHeight = 300});

  @override
  Widget build(BuildContext context) {
    if (pois == null || pois.isEmpty) {
      return Container(
        margin: EdgeInsets.all(16),
        child: Text('暂无数据'),
      );
    }

    return Container(
      height: listHeight,
      child: Stack(
        children: <Widget>[
          ListView.separated(
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
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0, top: 16),
              child: InkWell(
                onTap: () {
                  BlocProvider.of<ScaffoldMapBloc>(context).dispatch(InitMapEvent());
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
            ),
          ),
        ],
      ),
    );
  }

  Widget buildItem(context, IPoi poi) {
    if (poi is PoiEntity) {
      return buildCommonPoiItem(context, poi);
    } else if (poi is GaodePoi) {
      return buildGaodePoiItem(context, poi);
    } else {
      return Text('not implemented');
    }
  }

  Widget buildCommonPoiItem(context, PoiEntity poi) {
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
            Text(
              poi.name,
              style: TextStyle(fontSize: 17),
            ),
            SizedBox(height: 8),
            Text(
              poi.address,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildGaodePoiItem(context, GaodePoi poi) {
    return InkWell(
      onTap: () {
        onTapPoi(context, poi);
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: <Widget>[
            FadeInImage.assetNetwork(
              image: poi.photo,
              placeholder: 'res/drawable/img_placeholder.jpg',
              width: 80,
              height: 60,
              fit: BoxFit.cover,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            poi.name,
                            style: TextStyle(fontSize: 17),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      poi.address,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onTapPoi(context, IPoi poi) {
    BlocProvider.of<ScaffoldMapBloc>(context).dispatch(ShowPoiEvent(poi: poi));
  }
}
