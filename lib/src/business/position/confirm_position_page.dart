import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/business/my/app_area.dart';
import 'package:titan/src/business/scaffold_map/bottom_panels/user_poi_panel.dart';
import 'package:titan/src/consts/consts.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/tools/empty_fail_loading_state.dart';
import 'package:titan/src/widget/all_page_state/all_page_state.dart';
import 'package:titan/src/widget/all_page_state/all_page_state_container.dart';
import 'package:titan/src/widget/load_data_widget.dart';
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

class _ConfirmPositionState extends State<ConfirmPositionPage> with EmptyFailLoadingState {
  PositionBloc _positionBloc = PositionBloc();
  MapboxMapController mapController;
  double defaultZoom = 17;
  String currentResult = S.of(globalContext).confirm_info_wrong;
  ConfirmPoiItem confirmPoiItem;
  bool _isPostData = false;


  @override
  void initState() {

    _positionBloc.add(ConfirmPositionLoadingEvent());
    _positionBloc.add(ConfirmPositionPageEvent(widget.userPosition));
    _positionBloc.listen((state) {
      if (state is ConfirmPositionPageState) {
        confirmPoiItem = state.confirmPoiItem;
        if (confirmPoiItem?.name == null) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(S.of(context).no_verifiable_poi_around_hint),
                actions: <Widget>[
                  FlatButton(
                      onPressed: () {
                        Navigator.of(context)..pop()..pop();
                      },
                      child: Text(S.of(context).confirm))
                ],
              );
            },
          );
        } else {
          addMarkerAndMoveToPoi();
        }
      } else if (state is ConfirmPositionResultState) {
        if (state.confirmResult) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => FinishAddPositionPage(FinishAddPositionPage.FINISH_PAGE_TYPE_CONFIRM)),
          );
        }
      }
    });

    _addMarkerSubject.debounceTime(Duration(milliseconds: 500)).listen((_) {
      var latlng = LatLng(confirmPoiItem.location.coordinates[1], confirmPoiItem.location.coordinates[0]);
      mapController?.addSymbol(
        SymbolOptions(
          geometry: latlng,
          iconImage: "hyn_marker_big",
          iconAnchor: "bottom",
          iconOffset: Offset(0.0, 3.0),
        ),
      );
      mapController?.animateCamera(CameraUpdate.newLatLng(latlng));
    });

    super.initState();
  }

  var _addMarkerSubject = PublishSubject<dynamic>();
  void addMarkerAndMoveToPoi() {
    if (mapController != null && confirmPoiItem?.name != null) {
      _addMarkerSubject.sink.add(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          S.of(context).check_poi_item_title,
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
            title: Text(S.of(context).post_my_check),
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
                  },
                  child: Text(S.of(context).confirm))
            ],
          );
        },
        barrierDismissible: true);
  }

  Widget _buildView() {
    return BlocBuilder<PositionBloc, AllPageState>(
        bloc: _positionBloc,
        builder: (BuildContext context, AllPageState state) {
          if (state is ConfirmPositionLoadingState) {
            return LoadDataWidget(
              isLoading: true,
            );
          } else if (state is ConfirmPositionPageState) {
            confirmPoiItem = state.confirmPoiItem;
            if (confirmPoiItem?.name == null) {
              return Container(
                width: 0.0,
                height: 0.0,
              );
            } else {
              return _buildListBody();
            }
          } else if (state is ConfirmPositionResultLoadingState) {
            return _buildListBody();
          } else if (state is ConfirmPositionResultState) {
            _isPostData = false;
            if (!state.confirmResult) {
              Fluttertoast.showToast(msg: state.errorMsg);
              return _buildListBody();
            } else {
              return Container(
                width: 0.0,
                height: 0.0,
              );
            }
          } else {
            return buildWidgetByNormalState(context, state);
//            return AllPageStateContainer(state,(){
//              _positionBloc.add(ConfirmPositionLoadingEvent());
//              _positionBloc.add(ConfirmPositionPageEvent(widget.userPosition));
//            });
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
                padding: EdgeInsets.only(bottom: 16),
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
                  buildBottomInfoList(context,confirmPoiItem),
                ],
              ),
            ),
          ),
          Divider(
            height: 0.5,
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
    _addMarkerSubject.close();
    super.dispose();
  }

  Widget _mapView() {
    var style;
    if (currentAppArea.key == AppArea.MAINLAND_CHINA_AREA.key) {
      style = Const.kWhiteMapStyleCn;
    } else {
      style = Const.kWhiteMapStyle;
    }
    var languageCode = Localizations.localeOf(context).languageCode;

    return SizedBox(
      height: 150,
      child: MapboxMap(
        compassEnabled: false,
        initialCameraPosition: CameraPosition(
          target: recentlyLocation,
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
        languageCode: languageCode,
      ),
    );
  }

  void onStyleLoaded(MapboxMapController controller) {
    mapController = controller;
    addMarkerAndMoveToPoi();
  }

  Widget _nameView() {
    return Container(
      padding: EdgeInsets.only(left: 15,right: 15,top: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 8,
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  confirmPoiItem.name,
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 16,
          ),
          buildHeadItem(context,
              Icons.location_on, confirmPoiItem.address,
              hint: S.of(context).no_detail_address),
        ],
      ),
    );
  }

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
                var option = await showConfirmDialog(S.of(context).poi_confirm_title_error);
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
                var option = await showConfirmDialog(S.of(context).poi_confirm_title_hint);
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
