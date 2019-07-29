import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/src/model/poi.dart';

class PoiBottomSheet extends StatelessWidget {
  final PoiEntity selectedPoiEntity;

  PoiBottomSheet(this.selectedPoiEntity);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 16, right: 16),
          child: Text(
            selectedPoiEntity.name,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16, top: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Icon(
                Icons.location_on,
                size: 18,
                color: Colors.grey[600],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  selectedPoiEntity.address,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              )
            ],
          ),
        ),
        if (selectedPoiEntity.remark != null && selectedPoiEntity.remark.length > 0)
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16, top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Icon(
                  Icons.message,
                  color: Colors.grey[600],
                  size: 18,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                      selectedPoiEntity.remark != null && selectedPoiEntity.remark.length > 0
                          ? selectedPoiEntity.remark
                          : '无备注',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                )
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Divider(
            height: 40,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Text(
            '标签',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16, top: 8),
          child: Text(
              selectedPoiEntity.tags != null && selectedPoiEntity.tags.length > 0 ? selectedPoiEntity.tags : '暂无标签数据',
              style: TextStyle(fontSize: 14, color: Colors.grey[700])),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16, top: 16),
          child: Text(
            '电话',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16, top: 8),
          child: Text(
              selectedPoiEntity.phone != null && selectedPoiEntity.phone.length > 0
                  ? selectedPoiEntity.phone
                  : '暂无联系方式',
              style: TextStyle(fontSize: 14, color: Colors.grey[700])),
        ),
      ],
    );
  }
}
