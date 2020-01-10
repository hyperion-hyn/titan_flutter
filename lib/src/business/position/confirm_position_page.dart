import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_pickers/Media.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/business/my/app_area.dart';
import 'package:titan/src/business/scaffold_map/bottom_panels/user_poi_panel.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/widget/load_data_widget.dart';
import 'package:titan/src/widget/radio_checkbox_widget.dart';

import 'bloc/bloc.dart';
import 'model/confirm_poi_item.dart';
import 'position_finish_page.dart';

class ConfirmPositionPage extends StatefulWidget {
  final LatLng userPosition;

  ConfirmPositionPage({this.userPosition});

  @override
  State<StatefulWidget> createState() {
    return _ConfirmPositionState();
  }
}

class _ConfirmPositionState extends State<ConfirmPositionPage> {
  PositionBloc _positionBloc = PositionBloc();
  MapboxMapController mapController;
  double defaultZoom = 15;
  bool _isLoading = false;

  List<Media> _listImagePaths = List();
  final int _listImagePathsMaxLength = 9;
//  List<String> _detailTextList = List();
  String currentResult = S.of(globalContext).confirm_info_wrong;
  ConfirmPoiItem confirmPoiItem;
  bool _isPostData = false;

//  var picItemWidth;
//  final List<UserInfoItem> _userInfoList = [
//    (UserInfoItem("res/drawable/ic_user_poi_category_name.png", "中餐馆")),
//    (UserInfoItem("res/drawable/ic_user_poi_zip_code.png", "510000")),
//    (UserInfoItem("res/drawable/ic_user_poi_phone_num.png", "13645793930")),
//    (UserInfoItem("res/drawable/ic_user_poi_web_site.png", "www.13645793930")),
//    (UserInfoItem("res/drawable/ic_user_poi_business_time.png", "09:00-22:00"))
//  ];

  @override
  void initState() {
    super.initState();
//    picItemWidth = (MediaQuery.of(context).size.width - 15 * 3.0) / 2.6;
    _positionBloc.add(ConfirmPositionLoadingEvent());
    _positionBloc.add(ConfirmPositionPageEvent(widget.userPosition));
  }

//  @override
//  void didChangeDependencies() {
//    _setupData();
//    super.didChangeDependencies();
//  }
//
//  void _setupData() {
//    _detailTextList = [
//      S.of(context).category + " " + "中餐馆",
//      S.of(context).postal_code + " " + "510000",
//      S.of(context).phone_number + " " + "13667510000",
//      S.of(context).website + " " + "www.hyn.space",
//      S.of(context).work_time + " " + "09:00-22:00"
//    ];
//
//    setState(() {});
//  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          S.of(context).position_info_confirm,
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: _buildView(),
    );
  }

  Future<bool> showConfirmDialog(String content) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(S.of(context).position_info_confirm),
            content: Text(content),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text(S.of(context).cancel)),
              FlatButton(
                  onPressed: () {
                    int answer;
                    if (currentResult == S.of(context).confirm_info_wrong) {
                      answer = 0;
                    } else {
                      answer = 1;
                    }
                    _isPostData = true;
                    _positionBloc.add(ConfirmPositionResultLoadingEvent());
                    Navigator.of(context).pop(true);
//                    _positionBloc.add(
//                        ConfirmPositionResultEvent(answer, confirmPoiItem));
                  },
                  child: Text(S.of(context).confirm))
            ],
          );
        },
        barrierDismissible: true);
  }

  Widget _buildView() {
    return BlocBuilder<PositionBloc, PositionState>(
        bloc: _positionBloc,
        builder: (BuildContext context, PositionState state) {
          if (state is ConfirmPositionLoadingState) {
            return LoadDataWidget(
              isLoading: true,
            );
          } else if (state is ConfirmPositionPageState) {
            confirmPoiItem = state.confirmPoiItem;
            return _buildListBody();
          } else if (state is ConfirmPositionResultLoadingState) {
            return _buildListBody();
          } else if (state is ConfirmPositionResultState) {
//            createWalletPopUtilName = '/data_contribution_page';
            _isPostData = false;
            print("result = " + state.confirmResult.toString());
            if (state.confirmResult) {
              Navigator.of(context).pop();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => FinishAddPositionPage(FinishAddPositionPage.FINISH_PAGE_TYPE_CONFIRM)),
              );
              return Container(
                width: 0.0,
                height: 0.0,
              );
            } else {
              Fluttertoast.showToast(msg: S.of(context).info_is_wrong_please_again_submit_hint);
              return _buildListBody();
            }
          } else {
            return Container(
              width: 0.0,
              height: 0.0,
            );
          }
        });
  }

  Widget _buildListBody() {
    var picItemWidth = (MediaQuery.of(context).size.width - 15 * 3.0) / 2.6;

    return Stack(
      children: <Widget>[
        Column(children: <Widget>[
          _mapView(),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 20.0,
                  ),
                ],
              ),
              child: ListView(
                children: <Widget>[
                  _nameView(),
                  if (confirmPoiItem.images != null) buildPicList(picItemWidth, 10, confirmPoiItem),
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Divider(
                      height: 1.0,
                      color: HexColor('#E9E9E9'),
                    ),
                  ),
                  buildBottomInfoList(confirmPoiItem),
                ],
              ),
            ),
          ),
          Divider(
            height: 1.0,
            color: HexColor('#E9E9E9'),
          ),
          _confirmView(),
        ]),
        _buildLoading()
      ],
    );
  }

  Widget _buildLoading() {
    return Visibility(
      visible: _isPostData,
      child: Center(
        child: SizedBox(
          height: 40,
          width: 40,
          child: CircularProgressIndicator(
            strokeWidth: 3,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _positionBloc.close();
    super.dispose();
  }

  Widget _mapView() {
    var style;
    if (currentAppArea.key == AppArea.MAINLAND_CHINA_AREA.key) {
      style = "https://cn.tile.map3.network/see-it-all-boundary-cdn-en.json";
    } else {
      style = "https://static.hyn.space/maptiles/see-it-all-boundary-cdn-en.json";
    }

    return SizedBox(
      height: 150,
      child: MapboxMap(
        compassEnabled: false,
        initialCameraPosition: CameraPosition(
          target: LatLng(23.12076, 113.322058),
          zoom: defaultZoom,
        ),
        styleString: style,
        onStyleLoaded: (mapboxController) {
          onStyleLoaded(mapboxController);
        },
        myLocationTrackingMode: MyLocationTrackingMode.None,
        rotateGesturesEnabled: false,
        tiltGesturesEnabled: false,
        enableLogo: false,
        enableAttribution: false,
        minMaxZoomPreference: MinMaxZoomPreference(1.1, 19.0),
        myLocationEnabled: false,
      ),
    );
  }

  void onStyleLoaded(MapboxMapController controller) {
    mapController = controller;
    mapController.addSymbol(
      SymbolOptions(
        geometry: LatLng(23.12076, 113.322058),
        iconImage: "hyn_marker_big",
        iconAnchor: "bottom",
        iconOffset: Offset(0.0, 3.0),
      ),
    );
  }

  Widget _nameView() {
    return Container(
      padding: EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(bottom: 15),
            child: Text(
              S.of(context).confirm_position_name_func(confirmPoiItem.name),
              textAlign: TextAlign.left,
              style: TextStyle(
                color: HexColor('#333333'),
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          Text(
            S.of(context).confirm_position_func(confirmPoiItem.address),
            textAlign: TextAlign.left,
            style: TextStyle(
              color: HexColor('#333333'),
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosCell() {
    var size = MediaQuery.of(context).size;
    var itemWidth = (size.width - 16 * 2.0 - 15 * 2.0) / 3.0;
    var childAspectRatio = (105.0 / 74.0);
    var itemHeight = itemWidth / childAspectRatio;
    var itemCount = 1;
    if (_listImagePaths.length == 0) {
      itemCount = 1;
    } else if (_listImagePaths.length > 0 && _listImagePaths.length < _listImagePathsMaxLength) {
      itemCount = 1 + _listImagePaths.length;
    } else if (_listImagePaths.length >= _listImagePathsMaxLength) {
      itemCount = _listImagePathsMaxLength;
    }
    double containerHeight = 2 + (10 + itemHeight) * ((itemCount / 3).ceil());
    //print('[add] _buildPhotosCell, itemWidth:${itemWidth}, itemHeight:${itemHeight}, containerHeight:${containerHeight}');

    return Container(
      height: containerHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        physics: new NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 15,
          childAspectRatio: childAspectRatio,
        ),
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {},
            child: Container(
              decoration: BoxDecoration(
                color: HexColor('#D8D8D8'),
                borderRadius: BorderRadius.circular(3.0),
              ),
              child: Center(
                child: _isLoading
                    ? CircularProgressIndicator()
                    : FadeInImage.assetNetwork(
                        placeholder: 'res/drawable/img_placeholder.jpg',
                        image: "",
                        fit: BoxFit.fill,
                      ),
              ),
            ),
          );
        },
        itemCount: 3,
      ),
    );
  }

  /*Widget _detailView() {
    var itemCount = _detailTextList.length;
    double padding = 15;
    double height = (17.0 + 4.0) * itemCount + 10;
    return Container(
//      color: Colors.red,
      height: height,
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: ListView.builder(
        physics: new NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(bottom: 4),
            child: Text(
              _detailTextList[index],
              textAlign: TextAlign.left,
              style: TextStyle(
                color: HexColor('#333333'),
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          );
        },
        itemCount: itemCount,
      ),
    );
  }*/

  Widget _confirmView() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            child: RaisedButton(
              color: HexColor('#DD4E41'),
              onPressed: () async {
                currentResult = S.of(context).confirm_info_wrong;
                var option = await showConfirmDialog('你认为这个位置信息是不存在或者信息描述有误的，确定提交吗？');
                if (option == true) {
                  _positionBloc.add(ConfirmPositionResultEvent(0, confirmPoiItem));
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    "res/drawable/ic_confirm_button_error.png",
                    width: 15,
                    height: 14,
                  ),
                  Padding(
                      padding: const EdgeInsets.only(left: 8, bottom: 2),
                      child: Text(S.of(context).confirm_info_wrong, style: TextStyles.textCfffS14)),
                ],
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(22)),
              ),
            ),
          ),
          SizedBox(
            width: 25,
          ),
          Container(
            child: RaisedButton(
              color: HexColor('#0F95B0'),
              onPressed: () async {
                currentResult = S.of(context).confirm_info_right;
                var option = await showConfirmDialog('你认为这个位置信息是真实存在并且信息描述完全正确的，确定提交吗？');
                if (option == true) {
                  _positionBloc.add(ConfirmPositionResultEvent(1, confirmPoiItem));
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    "res/drawable/ic_confirm_button_right.png",
                    width: 15,
                    height: 14,
                  ),
                  Padding(
                      padding: const EdgeInsets.only(left: 8, bottom: 2),
                      child: Text(S.of(context).confirm_info_right, style: TextStyles.textCfffS14)),
                ],
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(22)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
