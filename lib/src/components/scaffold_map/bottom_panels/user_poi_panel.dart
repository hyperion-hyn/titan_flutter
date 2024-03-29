import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:image_pickers/image_pickers.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/data/entity/poi/user_contribution_poi.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/widget/drag_tick.dart';
import 'package:titan/src/widget/header_height_notification.dart';

import '../../../global.dart';

class UserPoiPanel extends StatefulWidget {
  final UserContributionPoi selectedPoiEntity;
  final ScrollController scrollController;

  final Function onClose;

  UserPoiPanel({this.selectedPoiEntity, this.scrollController, this.onClose});

  @override
  State<StatefulWidget> createState() {
    return _UserPoiPanelState();
  }
}

class _UserPoiPanelState extends State<UserPoiPanel> {
  final GlobalKey _poiHeaderKey = GlobalKey(debugLabel: 'poiHeaderKey');
  var picItemWidth;
  var childAspectRatio = (105.0 / 74.0);
  var itemHeight;

  double getHeaderHeight() {
    RenderBox renderBox = _poiHeaderKey.currentContext?.findRenderObject();
    var h = renderBox?.size?.height ?? 0;
    if (h > 0) {
      if (MediaQuery.of(context).padding.bottom > 0) {
        h += safeAreaBottomPadding;
      }
      return h + 48; //48 is hack options height;
    }
    return h;
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
    picItemWidth = (MediaQuery.of(context).size.width - 15 * 3.0) / 2.6;
    itemHeight = picItemWidth / childAspectRatio;
    return Container(
      padding: const EdgeInsets.only(top: 4),
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
        controller: widget.scrollController,
        child: WillPopScope(
          onWillPop: () async {
            if (widget.onClose != null) {
              widget.onClose();
            }
            return false;
          },
          child: Stack(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  //header
                  Container(
                    key: _poiHeaderKey,
                    padding: EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        //tick
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(top: 8, bottom: 8),
                              child: DragTick(),
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                widget.selectedPoiEntity.name,
                                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        buildHeadItem(context, Icons.location_on, widget.selectedPoiEntity.address,
                            hint: S.of(context).no_detail_address),
                        if (widget.selectedPoiEntity.remark != null && widget.selectedPoiEntity.remark.length > 0)
                          buildHeadItem(context, Icons.message, widget.selectedPoiEntity.remark,
                              hint: S.of(context).no_remark),
                      ],
                    ),
                  ),
                  Divider(
                    height: 0,
                  ),
                  if (widget.selectedPoiEntity.images != null && widget.selectedPoiEntity.images.length > 0)
                    buildPicList(picItemWidth, 29, widget.selectedPoiEntity.images),
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Divider(
                      height: 1.0,
                      color: HexColor('#E9E9E9'),
                    ),
                  ),
                  buildBottomInfoList(context, widget.selectedPoiEntity),
                  SizedBox(
                    height: 80,
                    width: 1,
                  )
                ],
              ),
              Positioned(
                top: 4,
                right: 8,
                child: InkWell(
                  onTap: widget.onClose,
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
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /*Widget buildHeadItem(IconData icon, String info, {String hint}) {
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
  }*/

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

/*Widget _buildPicList() {
    return Container(
      padding: const EdgeInsets.only(left: 15.0, bottom: 14, top: 29),
      height: 138,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: InkWell(
                onTap: () {},
                child: Container(
                  width: picItemWidth,
                  decoration: BoxDecoration(
                    color: HexColor('#D8D8D8'),
                    borderRadius: BorderRadius.circular(3.0),
                  ),
                  child: Center(
                    child: FadeInImage.assetNetwork(
                      placeholder: 'res/drawable/img_placeholder.jpg',
                      image: "",
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
            );
          },
          itemCount: 10),
    );
  }*/

/*Widget buildBottomInfoList(List<UserInfoItem> _infoList) {
    return Container(
      height: 235,
      padding: const EdgeInsets.only(top: 0, left: 15.0, right: 15),
      child: ListView.builder(
          padding: const EdgeInsets.only(top: 0),
          itemBuilder: (context, index) {
            UserInfoItem userInfoItem = _infoList[index];
            return Column(
              children: <Widget>[
                Container(
                  child: Row(
                    children: <Widget>[
                      Image.asset(
                        userInfoItem.icon,
                        width: 18,
                        height: 18,
                      ),
                      SizedBox(
                        width: 14,
                        height: 1,
                      ),
                      Text(userInfoItem.infoStr)
                    ],
                  ),
                ),
                _divider()
              ],
            );
          },
          itemCount: _infoList.length),
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 15),
      child: Divider(
        height: 1.0,
        color: HexColor('#E9E9E9'),
      ),
    );
  }*/
}

Widget buildHeadItem(BuildContext context, IconData icon, String info, {String hint}) {
  if (hint == null || hint.isEmpty) {
    hint = S.of(context).search_empty_data;
  }
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(
          icon,
          color: Colors.grey[600],
          size: 18,
        ),
        SizedBox(
          width: 8,
        ),
        Expanded(
          child: Text(info != null && info.isNotEmpty ? info : hint,
              style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        )
      ],
    ),
  );
}

Widget buildPicList(double itemWidth, double topValue, List<String> images) {
  //print("image = hahaha");
  //print("image = " + confirmPoiItem.images.toString());
  return Container(
    padding: EdgeInsets.only(left: 15.0, bottom: 14, top: topValue),
    height: 138,
    child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: InkWell(
              onTap: () {
                ImagePickers.previewImages(images, index);
              },
              child: Container(
                width: itemWidth,
                /*decoration: BoxDecoration(
                  color: HexColor('#D8D8D8'),
                  borderRadius: BorderRadius.circular(3.0),
                ),*/
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3.0),
                  child: FadeInImage.assetNetwork(
                    placeholder: 'res/drawable/img_placeholder.jpg',
                    image: images[index],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          );
        },
        itemCount: images.length),
  );
}

Widget buildBottomInfoList(BuildContext context, UserContributionPoi confirmPoiItem) {
  List<UserInfoItem> _infoList = [];

  if (confirmPoiItem.category.isNotEmpty) {
    _infoList.add(UserInfoItem("res/drawable/ic_user_poi_category_name.png", confirmPoiItem.category));
  } else {
    _infoList.add(UserInfoItem("res/drawable/ic_user_poi_category_name.png", S.of(context).search_empty_data));
  }

  if (confirmPoiItem.postcode.isNotEmpty) {
    _infoList.add(UserInfoItem("res/drawable/ic_user_poi_zip_code.png", confirmPoiItem.postcode));
  } else {
    _infoList.add(UserInfoItem("res/drawable/ic_user_poi_zip_code.png", S.of(context).search_empty_data));
  }

  if (confirmPoiItem.workTime.isNotEmpty) {
    _infoList.add(UserInfoItem("res/drawable/ic_user_poi_business_time.png", confirmPoiItem.workTime));
  } else {
    _infoList.add(UserInfoItem("res/drawable/ic_user_poi_business_time.png", S.of(context).search_empty_data));
  }

  if (confirmPoiItem.phone.isNotEmpty) {
    _infoList.add(UserInfoItem("res/drawable/ic_user_poi_phone_num.png", confirmPoiItem.phone));
  } else {
    _infoList.add(UserInfoItem("res/drawable/ic_user_poi_phone_num.png", S.of(context).search_empty_data));
  }

  if (confirmPoiItem.website.isNotEmpty) {
    _infoList.add(UserInfoItem("res/drawable/ic_user_poi_web_site.png", confirmPoiItem.website));
  } else {
    _infoList.add(UserInfoItem("res/drawable/ic_user_poi_web_site.png", S.of(context).search_empty_data));
  }

  return Container(
    padding: EdgeInsets.only(left: 15.0, right: 15),
    child: Column(
      children: _infoList.map((userInfoItem) {
        return Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Image.asset(
                  userInfoItem.icon,
                  width: 18,
                  height: 18,
                ),
                SizedBox(
                  width: 14,
                  height: 1,
                ),
                Expanded(
                    child: Text(
                  userInfoItem.infoStr,
                  style: TextStyles.textC333S14,
                ))
              ],
            ),
            if (_infoList.last != userInfoItem) _divider()
          ],
        );
      }).toList(),
    ),
  );
}

Widget _divider() {
  return Padding(
    padding: const EdgeInsets.only(top: 15, bottom: 15),
    child: Divider(
      height: 1.0,
      color: HexColor('#E9E9E9'),
    ),
  );
}

class UserInfoItem {
  String icon;
  String infoStr;

  UserInfoItem(this.icon, this.infoStr);
}
