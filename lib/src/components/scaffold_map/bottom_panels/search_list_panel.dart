import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/data/entity/poi/user_contribution_poi.dart';
import 'package:titan/src/data/entity/poi/photo_simple_poi.dart';
import 'package:titan/src/data/entity/poi/mapbox_poi.dart';
import 'package:titan/src/data/entity/poi/poi_interface.dart';

typedef OnTapPoi = void Function(IPoi);

class SearchListPanel extends StatelessWidget {
  final List<IPoi> pois;
  final ScrollController scrollController;
  final double listHeight;

  final Function onClose;
  final OnTapPoi onTapPoi;


  SearchListPanel({this.pois, this.scrollController, this.onClose, this.onTapPoi, this.listHeight = 300});

  @override
  Widget build(BuildContext context) {
    if (pois == null || pois.isEmpty) {
      return Container(
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
        child: SingleChildScrollView(
          controller: scrollController,
          physics: NeverScrollableScrollPhysics(),
          child: Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: EdgeInsets.only(top: 32),
                  child: Text(S.of(context).search_empty_data),
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: InkWell(
                  onTap: onClose,
                  borderRadius: BorderRadius.all(Radius.circular(32.0)),
                  highlightColor: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
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
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: listHeight,
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
            child: InkWell(
              onTap: onClose,
              borderRadius: BorderRadius.all(Radius.circular(32.0)),
              highlightColor: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.all(8),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget buildItem(context, IPoi poi) {
    if (poi is MapBoxPoi) {
      return buildCommonPoiItem(context, poi);
    } else if (poi is SimplePoiWithPhoto) {
      return buildGaodePoiItem(context, poi);
    } else if (poi is UserContributionPoi) {
      return buildCommonPoiItem(context, poi);
    } else {
      return Text('not implemented');
    }
  }

  Widget buildCommonPoiItem(context, IPoi poi) {
    return InkWell(
      onTap: () {
        onTapPoi(poi);
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

  Widget buildGaodePoiItem(context, SimplePoiWithPhoto poi) {
    return InkWell(
      onTap: () {
        onTapPoi(poi);
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
}
