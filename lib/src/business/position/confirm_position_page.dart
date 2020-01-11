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
  List<String> _detailTextList = List();
  String currentResult = "信息有误";
  ConfirmPoiItem confirmPoiItem;
  bool _isPostData = false;

//  var picItemWidth;
  final List<UserInfoItem> _userInfoList = [
    (UserInfoItem("res/drawable/ic_user_poi_category_name.png", "中餐馆")),
    (UserInfoItem("res/drawable/ic_user_poi_zip_code.png", "510000")),
    (UserInfoItem("res/drawable/ic_user_poi_phone_num.png", "13645793930")),
    (UserInfoItem("res/drawable/ic_user_poi_web_site.png", "www.13645793930")),
    (UserInfoItem("res/drawable/ic_user_poi_business_time.png", "09:00-22:00"))
  ];

  @override
  void initState() {
    _detailTextList = [
      "类别：中餐馆",
      "邮编：510000",
      "电话：13667510000",
      "网址：www13667510000",
      "工作时间：09:00-22:00"
    ];

//    picItemWidth = (MediaQuery.of(context).size.width - 15 * 3.0) / 2.6;
    _positionBloc.add(ConfirmPositionLoadingEvent());
    _positionBloc.add(ConfirmPositionPageEvent(widget.userPosition));
    _positionBloc.listen((state){
      if(state is ConfirmPositionPageState){
        confirmPoiItem = state.confirmPoiItem;
        if(confirmPoiItem == null || (confirmPoiItem != null && confirmPoiItem.name == null)) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("周围没有可验证的位置信息。"),
                actions: <Widget>[
                  FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                      child: Text(S
                          .of(context)
                          .confirm))
                ],
              );
            },
          );
        }
      }else if (state is ConfirmPositionResultState) {
//            createWalletPopUtilName = '/data_contribution_page';
        if (state.confirmResult) {
//              Navigator.of(context).pop();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    FinishAddPositionPage(
                        FinishAddPositionPage.FINISH_PAGE_TYPE_CONFIRM)),
          );
        }
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          "位置信息确认",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        /*actions: <Widget>[
          InkWell(
            onTap: () {
              showConfirmDialog();
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              alignment: Alignment.centerRight,
              child: Text(
                S.of(context).finish,
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          )
        ],*/
      ),
      body: _buildView(),
    );
  }

  void showConfirmDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("位置信息确认"),
            content: Text("是否确认$currentResult"),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(S.of(context).cancel)),
              FlatButton(
                  onPressed: () {
                    int answer;
                    if (currentResult == "信息有误") {
                      answer = 0;
                    } else {
                      answer = 1;
                    }
                    _isPostData = true;
                    _positionBloc.add(ConfirmPositionResultLoadingEvent());
                    Navigator.of(context).pop();
                    _positionBloc.add(
                        ConfirmPositionResultEvent(answer, confirmPoiItem));
//                    _positionBloc.add(
//                        ConfirmPositionResultEvent(answer, confirmPoiItem));

                    /*createWalletPopUtilName = '/data_contribution_page';

                    Navigator.of(context).pop();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FinishAddPositionPage(
                              FinishAddPositionPage.FINISH_PAGE_TYPE_CONFIRM)),
                    );*/
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
            if(confirmPoiItem == null || (confirmPoiItem != null && confirmPoiItem.name == null)){
              /*showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text("周围没有可验证的位置信息。"),
                    actions: <Widget>[
                      FlatButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          },
                          child: Text(S.of(context).confirm))
                    ],
                  );
                },
              );*/
              return Container(
                width: 0.0,
                height: 0.0,
              );
            }else{
              return _buildListBody();
            }
          } else if (state is ConfirmPositionResultLoadingState) {
            return _buildListBody();
          } else if (state is ConfirmPositionResultState) {
//            createWalletPopUtilName = '/data_contribution_page';
            _isPostData = false;
            if (!state.confirmResult) {
              Fluttertoast.showToast(msg: "服务器异常，请重试。");
              /*showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text("您提交的信息有误，请重试。"),
                    actions: <Widget>[
                      FlatButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(S.of(context).confirm))
                    ],
                  );
                },
              );*/
              return _buildListBody();
            }else{
              return Container(
                width: 0.0,
                height: 0.0,
              );
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
        Column(
          children: <Widget>[
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
                    if (confirmPoiItem.images != null)
                      buildPicList(picItemWidth, 10, confirmPoiItem),
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
          ]
        ),
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
      style =
          "https://static.hyn.space/maptiles/see-it-all-boundary-cdn-en.json";
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
//      color: Colors.red,
      padding: EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(bottom: 15),
            child: Text(
              "名称：${confirmPoiItem.name}",
              textAlign: TextAlign.left,
              style: TextStyle(
                color: HexColor('#333333'),
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          Text(
            "位置：${confirmPoiItem.address}",
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
    } else if (_listImagePaths.length > 0 &&
        _listImagePaths.length < _listImagePathsMaxLength) {
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

  Widget _detailView() {
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
  }

  Widget _confirmView() {
    return Container(
//      alignment: Alignment.center,
      color: Colors.white,
      padding: const EdgeInsets.only(top: 15, left: 25, right: 25, bottom: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            height: 44,
            width: 150,
            margin: const EdgeInsets.only(right: 25),
            child: RaisedButton(
              color: HexColor('#DD4E41'),
              onPressed: () {
                currentResult = "信息有误";
                showConfirmDialog();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    "res/drawable/ic_confirm_button_error.png",
                    width: 18,
                    height: 17,
                  ),
                  Padding(
                      padding: const EdgeInsets.only(left: 8, bottom: 2),
                      child: Text("信息有误", style: TextStyles.textCfffS16)),
                ],
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(22)),
              ),
            ),
          ),
          Container(
            height: 44,
            width: 150,
            margin: const EdgeInsets.only(right: 25),
            child: RaisedButton(
              color: HexColor('#0F95B0'),
              onPressed: () {
                currentResult = "信息正确";
                showConfirmDialog();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    "res/drawable/ic_confirm_button_right.png",
                    width: 18,
                    height: 17,
                  ),
                  Padding(
                      padding: const EdgeInsets.only(left: 8, bottom: 2),
                      child: Text("信息正确", style: TextStyles.textCfffS16)),
                ],
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(22)),
              ),
            ),
          ),
        ],
      ),
      /*child: CustomRadioButton(
        enableShape: true,
        hight: 40,
        width: 150,
        buttonColor: Colors.white,
        selectedColor: Theme.of(context).primaryColor,
        buttonLables: [
          '信息有误',
          '信息正确',
        ],
        buttonValues: [
          '信息有误',
          '信息正确',
        ],
        radioButtonValue: (value) {
          currentResult = value;
          print(value);
        },
      ),*/
    );
  }
}
