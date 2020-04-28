import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/scaffold_map/bottom_panels/user_poi_panel.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/contribution/add_poi/api/position_api.dart';
import 'package:titan/src/pages/contribution/add_poi/bloc/bloc.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/widget/all_page_state/all_page_state.dart';
import 'package:titan/src/widget/all_page_state/all_page_state_container.dart';
import 'package:titan/src/widget/load_data_widget.dart';
import '../add_poi/position_finish_page.dart';
import '../../../data/entity/poi/user_contribution_poi.dart';

class VerifyPoiPage extends StatefulWidget {
  final LatLng userPosition;

  VerifyPoiPage({this.userPosition});

  @override
  State<StatefulWidget> createState() {
    return _VerifyPoiPageState();
  }
}

class _VerifyPoiPageState extends BaseState<VerifyPoiPage> {
  PositionApi _positionApi = PositionApi();

  PositionBloc _positionBloc = PositionBloc();
  MapboxMapController mapController;
  double defaultZoom = 16;

  UserContributionPoi confirmPoiItem;

  bool _isLoadingPageData = true;
  bool _isLoadPageDataEmpty = false;
  bool _isLoadPageDataFail = false;

  bool _isPostingData = false;
  String language;
  String address;

  @override
  void onCreated() {
    _loadOnePoiNeedToBeVerify(widget.userPosition);
    language = SettingInheritedModel.of(context).languageCode;
    address = WalletInheritedModel.of(context).activatedWallet.wallet.accounts[0].address;

    _positionBloc.add(ConfirmPositionLoadingEvent());
    _positionBloc.add(ConfirmPositionPageEvent(widget.userPosition,language,address));
  }

  @override
  void initState() {

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
          Application.router.navigateTo(context,Routes.contribute_position_finish
              + '?entryRouteName=${Uri.encodeComponent(Routes.contribute_tasks_list)}&pageType=${FinishAddPositionPage.FINISH_PAGE_TYPE_CONFIRM}');
//          Navigator.pushReplacement(
//            context,
//            MaterialPageRoute(
//                builder: (context) => FinishAddPositionPage(FinishAddPositionPage.FINISH_PAGE_TYPE_CONFIRM)),
//          );
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

  void _loadOnePoiNeedToBeVerify(LatLng position) async {
    var userPosition = position;
    var language = SettingInheritedModel.of(context).languageCode;
    if (language.startsWith('zh')) language = "zh-Hans";

    var activatedHynAddress = WalletInheritedModel.of(context).activatedHynAddress();
    var _confirmPoiItem = await _positionApi
        .getConfirmData(activatedHynAddress, userPosition.longitude, userPosition.latitude, lang: language);
    setState(() {
      confirmPoiItem = _confirmPoiItem;
    });
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
                    _isPostingData = true;
//                    _positionBloc.add(ConfirmPositionResultLoadingEvent());
                    Navigator.of(context).pop(true);
                  },
                  child: Text(S.of(context).confirm))
            ],
          );
        },
        barrierDismissible: true);
  }

  Widget _buildView() {
//    return LoadDataWidget(
//      isLoading: _isLoadingPageData,
//      child: _buildListBody(),
//    );
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
            _isPostingData = false;
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
//            return buildWidgetByNormalState(context, state);
            return AllPageStateContainer(state,(){
              _positionBloc.add(ConfirmPositionLoadingEvent());
              _positionBloc.add(ConfirmPositionPageEvent(widget.userPosition,language,address));
            });
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
                  if (confirmPoiItem.images != null) buildPicList(picItemWidth, 10, confirmPoiItem.images),
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Divider(
                      height: 1.0,
                      color: HexColor('#E9E9E9'),
                    ),
                  ),
                  buildBottomInfoList(context, confirmPoiItem),
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
      visible: _isPostingData,
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
//    return Container();
    var style;
    if (SettingInheritedModel.of(context).areaModel.isChinaMainland) {
      style = Const.kWhiteMapStyleCn;
    } else {
      style = Const.kWhiteMapStyle;
    }
    var languageCode = Localizations.localeOf(context).languageCode;

    return SizedBox(
      height: 160,
      child: MapboxMap(
        compassEnabled: false,
        initialCameraPosition: CameraPosition(
          target: Application.recentlyLocation,
          zoom: defaultZoom,
        ),
        styleString: style,
        onMapCreated: (controller) {
          Future.delayed(Duration(milliseconds: 500)).then((value) {
            onStyleLoaded(controller);
          });
        },
        myLocationTrackingMode: MyLocationTrackingMode.None,
        rotateGesturesEnabled: false,
        tiltGesturesEnabled: false,
        enableLogo: false,
        enableAttribution: false,
        minMaxZoomPreference: MinMaxZoomPreference(1.1, 21.0),
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
      padding: EdgeInsets.only(left: 15, right: 15, top: 15),
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
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 16,
          ),
          buildHeadItem(context, Icons.location_on, confirmPoiItem.address, hint: S.of(context).no_detail_address),
        ],
      ),
    );
  }

  Widget _confirmView() {
//    return Container();
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
                var option = await showConfirmDialog(S.of(context).poi_confirm_title_error);
                if (option == true) {
                  _positionBloc.add(ConfirmPositionResultEvent(0, confirmPoiItem,address));
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
                var option = await showConfirmDialog(S.of(context).poi_confirm_title_hint);
                if (option == true) {
                  _positionBloc.add(ConfirmPositionResultEvent(1, confirmPoiItem,address));
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
