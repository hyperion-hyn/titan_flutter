import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_pickers/Media.dart';
import 'package:image_pickers/UIConfig.dart';
import 'package:image_pickers/image_pickers.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/contribution/add_poi/add_position_image_page.dart';
import 'package:titan/src/pages/contribution/add_poi/bloc/bloc.dart';
import 'package:titan/src/pages/contribution/add_poi/business_time_page.dart';
import 'package:titan/src/pages/contribution/add_poi/model/business_time.dart';
import 'package:titan/src/pages/contribution/add_poi/model/category_item.dart';
import 'package:titan/src/pages/contribution/add_poi/model/poi_collector.dart';
import 'package:titan/src/pages/contribution/add_poi/model/poi_data.dart';
import 'package:titan/src/pages/contribution/add_poi/position_finish_page.dart';
import 'package:titan/src/pages/contribution/add_poi/select_category_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:titan/src/pages/contribution/add_poi/select_position_page.dart';
import 'package:titan/src/pages/contribution/verify_poi/verify_poi_page_v2.dart';
import 'package:titan/src/pages/mine/api/contributions_api.dart';
import 'package:titan/src/pages/webview/webview.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/log_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/all_page_state/all_page_state.dart';

class AddPositionPageV2 extends StatefulWidget {
  final LatLng userPosition;

  AddPositionPageV2({this.userPosition});

  @override
  State<StatefulWidget> createState() {
    return _AddPositionStateV2();
  }
}

class _AddPositionStateV2 extends BaseState<AddPositionPageV2> {
  PositionBloc _positionBloc = PositionBloc();

  var _addMarkerSubject = PublishSubject<dynamic>();
  PublishSubject<int> _filterSubject = PublishSubject<int>();
  MapboxMapController _mapController;

  TextEditingController _addressNameController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _addressHouseNumController = TextEditingController();
  TextEditingController _addressPostcodeController = TextEditingController();
  TextEditingController _detailPhoneNumController = TextEditingController();
  TextEditingController _detailWebsiteController = TextEditingController();

  double _inputHeight = 40.0;
  var _isAcceptSignalProtocol = true;
  //Color _themeColor = HexColor("#0F95B0");
  Color _themeColor = HexColor("#EDBB52");

  String _categoryDefaultText = "";
  String _timeDefaultText = "";

  List<Media> _outListImagePaths = List();
  final int _outListImagePathsMaxLength = 3;

  List<Media> _inListImagePaths = List();
  final int _inListImagePathsMaxLength = 6;

  CategoryItem _categoryItem;
  String _timeText;
  String _addressText;

  Map<String, dynamic> _openCageData;

  bool _isUploading = false;
  final _addressNameKey = GlobalKey<FormState>();

  bool _isOnPressed = false;
  bool _isLoadingOpenCage = false;

  int _requestOpenCageDataCount = 0;
  String language;
  String address;

  LatLng _selectedPosition;
  LatLng _initSelectedPosition;

  ScrollController _scrollController = ScrollController();


  @override
  void onCreated() {
    _initSelectedPosition = widget.userPosition;

    language = SettingInheritedModel.of(context).languageCode;
    address = WalletInheritedModel.of(context).activatedWallet.wallet.accounts[0].address;

    //_positionBloc.add(GetOpenCageEvent(widget.userPosition, language));
    _filterSubject.debounceTime(Duration(seconds: 1)).listen((count) {
      //print('[add] ---> count:$count, _requestOpenCageDataCount:$_requestOpenCageDataCount');
      _positionBloc.add(GetOpenCageEvent(_selectedPosition, language));
    });

    _addMarkerSubject.debounceTime(Duration(milliseconds: 500)).listen((_) {
      var latlng = _selectedPosition;
      //print("[Verify] add, name:${confirmPoiItem.name}, latlng:$latlng");

      var poiName = _maxLengthLimit(_addressNameController);

      _mapController?.clearSymbols();
      _mapController?.addSymbol(
        SymbolOptions(
          textField: poiName,
          textOffset: Offset(0, 1),
          textColor: "#333333",
          textSize: 16,
          geometry: latlng,
          iconImage: "hyn_marker_big",
          iconAnchor: "bottom",
          //iconOffset: Offset(0.0, 3.0),
        ),
      );
      _mapController?.animateCamera(CameraUpdate.newLatLng(latlng));
    });

    _addMarkerAndMoveToPoi();

    _themeColor = Theme.of(context).primaryColor;
    super.onCreated();
  }

  @override
  void initState() {
    _addressController.addListener(_checkInputHeight);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _setupData();
    super.didChangeDependencies();
  }

  void _setupData() {
    setState(() {
      _categoryDefaultText = S.of(context).please_select_category_hint;
      _timeDefaultText = S.of(context).please_add_business_hours_hint;
    });
  }

  @override
  void dispose() {
    _positionBloc.close();
    _filterSubject.close();
    _addMarkerSubject.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        baseTitle: S.of(context).data_position_adding,
        backgroundColor: Colors.white,
      ),
      body: _buildView(context),
    );
  }

  Future _finishCheckIn(String successTip) async {
    var address =
    WalletInheritedModel.of(Keys.rootKey.currentContext)?.activatedWallet?.wallet?.getEthAccount()?.address ?? "";

    if (address?.isEmpty ?? true) return;

    try {
      var coordinates = [_selectedPosition.latitude, _selectedPosition.longitude];
      await ContributionsApi().postCheckIn('postPOI', coordinates, []);
      UiUtil.toast(successTip);
    } catch (e) {
      print('$runtimeType --> e:$e');
      LogUtil.process(e);
    }
  }

  // build view
  Widget _buildView(BuildContext context) {
    return BlocBuilder<PositionBloc, AllPageState>(
      bloc: _positionBloc,
      condition: (AllPageState fromState, AllPageState state) {
        if (state is PostPoiDataV2ResultSuccessState) {
          _finishCheckIn(S.of(context).thank_you_for_contribute_data);

          Application.router.navigateTo(
              context,
              Routes.contribute_position_finish +
                  '?entryRouteName=${Uri.encodeComponent(Routes.contribute_tasks_list)}&pageType=${FinishAddPositionPage.FINISH_PAGE_TYPE_ADD}');
        } else if (state is PostPoiDataV2ResultFailState) {
          setState(() {
            _isUploading = false;
          });

          var msg = S.of(context).add_failed_hint + "," + S.of(context).error_code_func(state.code);
          if (state.code == -409) {
            msg = S.of(context).add_failed_exist_hint;
          } else if (state.code == -1) {
            msg = S.of(context).network_connection_timeout_please_try_again_later_toast;
          } else if (state.code == -10004) {
            msg = S.of(context).picture_format_is_not_supported_yet_toast;
          }
          Fluttertoast.showToast(msg: msg);
        } else if (state is GetOpenCageState) {
          _openCageData = state.openCageData;

          var country = _openCageData["country"] ?? "";
          var provinces = _openCageData["state"];
          var city = _openCageData["city"];
          var county = _openCageData["county"] ?? "";
          String countryCode = _openCageData["country_code"] ?? "CN";
          _saveCountryCode(countryCode: countryCode.toUpperCase());

          setState(() {
            //_addressText = country + " " + provinces + " " + city + " " + county;
            _addressText = county + "，" + city + "，" + provinces + "，" + country;
            //_addressText = "中国 广东省 广州市 天河区 中山大道 环球都会广场 2601楼";
          });

          String road = _openCageData["road"] ?? "";
          String building = _openCageData["building"] ?? "";
          if (road.length > 0 || building.length > 0) {
            _addressController.text = road + " " + building;
          }

          String postalCode = _openCageData["postcode"] ?? "";
          if (postalCode.length > 0) {
            _addressPostcodeController.text = postalCode;
          }
        }

        return true;
      },
      builder: (BuildContext context, AllPageState state) {
        if (state is GetOpenCageLoadingState) {
          _isLoadingOpenCage = true;
        } else if (state is GetOpenCageState) {
          _isLoadingOpenCage = false;
        }
        return _buildBody();
      },
    );
  }

  void _saveCountryCode({String countryCode = "CN"}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(PrefsKey.mapboxCountryCode, countryCode);
  }

  Widget _buildLoading() {
    return Visibility(
      visible: _isUploading,
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

  Widget _buildBody() {
    return Stack(
      children: <Widget>[
        BaseGestureDetector(
          context: context,
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Form(
              key: _addressNameKey,
              child: Column(
                children: <Widget>[
                  _buildAddressNameCell(),
                  _buildCategoryCell(),
                  _buildAddressCell(),
                  _buildPhotosCell(),
                  _buildDetailCell(),
                  Container(
                    height: 10,
                  ),
                  _buildTipsView(),
                  Container(
                    height: 10,
                  ),
                  _buildSubmitView(),
                ],
              ),
            ),
          ),
        ),
        _buildLoading(),
      ],
    );
  }

  Widget _buildCategoryCell() {
    String _categoryText = "";
    if (_categoryItem == null || _categoryItem.title == null) {
      _categoryText = _categoryDefaultText;
    } else {
      _categoryText = _categoryItem.title;
    }

    return Column(
      children: <Widget>[
        _buildTitleRow('category', Size(18, 18), S.of(context).category, true, isFirstRow: false),
        Container(
            padding: const EdgeInsets.all(16),
            decoration: new BoxDecoration(color: Colors.white),
            child: InkWell(
              onTap: () {
                _pushCategory();
              },
              child: Row(
                children: <Widget>[
                  Text(
                    _categoryText,
                    style: TextStyle(color: HexColor("#333333"), fontSize: 15),
                  ),
                  Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.grey,
                  )
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildAddressNameCell() {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 22),
          child: _buildTitleRow('name', Size(18, 18), S.of(context).place_name, true, isFirstRow: true),
        ),
        Container(
          padding: const EdgeInsets.only(left: 15, right: 15),
          decoration: new BoxDecoration(color: Colors.white),
          child: TextFormField(
            controller: _addressNameController,
            validator: (value) {
              if (value == null || value.trim().length == 0) {
                return S.of(context).place_name_cannot_be_empty_hint;
              } else {
                return null;
              }
            },
            onChanged: (String inputText) {
              //print('[add] --> inputText:${inputText}');
            },
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: S.of(context).please_enter_name_of_location_hint,
              hintStyle: TextStyle(fontSize: 13, color: DefaultColors.color777),
            ),
            keyboardType: TextInputType.text,
          ),
        ),
      ],
    );
  }

  Widget _buildPhotosCell() {
    var size = MediaQuery.of(context).size;
    var itemWidth = (size.width - 16 * 2.0 - 15 * 2.0) / 3.0;
    var childAspectRatio = (105.0 / 74.0);
    var itemHeight = itemWidth / childAspectRatio;

    var inItemCount = 1;
    if (_inListImagePaths.length == 0) {
      inItemCount = 1;
    } else if (_inListImagePaths.length > 0 && _inListImagePaths.length < _inListImagePathsMaxLength) {
      inItemCount = 1 + _inListImagePaths.length;
    } else if (_inListImagePaths.length >= _inListImagePathsMaxLength) {
      inItemCount = _inListImagePathsMaxLength;
    }
    double inContainerHeight = 16 + (16 + itemHeight) * ((inItemCount / 3).ceil());

    var outItemCount = 1;
    if (_outListImagePaths.length == 0) {
      outItemCount = 1;
    } else if (_outListImagePaths.length > 0 && _outListImagePaths.length < _outListImagePathsMaxLength) {
      outItemCount = 1 + _outListImagePaths.length;
    } else if (_outListImagePaths.length >= _outListImagePathsMaxLength) {
      outItemCount = _outListImagePathsMaxLength;
    }
    double outContainerHeight = 16 + (16 + itemHeight) * ((outItemCount / 3).ceil());
    var supportFormat = S.of(context).support_format;

    return Column(
      children: <Widget>[
        _buildTitleRow('camera', Size(19, 15), S.of(context).scene_photographed, true),
        _buildImageTitleRow(S.of(context).outdoor,
            "(${S.of(context).unit_zhang("1-$_outListImagePathsMaxLength")},$supportFormat)", true),
        Container(
          color: Colors.white,
          height: outContainerHeight,
          padding: const EdgeInsets.all(16),
          child: GridView.builder(
            physics: new NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 15,
              childAspectRatio: childAspectRatio,
            ),
            itemBuilder: (context, index) {
              if (index == outItemCount - 1 && _outListImagePaths.length < _outListImagePathsMaxLength) {
                return InkWell(
                  onTap: () {
                    _selectOutImages();
                  },
                  child: Container(
                    child: Center(
                      child: Image.asset(
                        'res/drawable/add_position_add.png',
                        width: 20,
                        height: 20,
                        color: Colors.white,
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: HexColor('#D8D8D8'),
                      borderRadius: BorderRadius.circular(3.0),
                    ),
                  ),
                );
              }
              return InkWell(
                  onTap: () {
                    ImagePickers.previewImagesByMedia(_outListImagePaths, index);
                  },
                  child: Stack(
                    children: <Widget>[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: Image.file(File(_outListImagePaths[index].path), width: itemWidth, fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: InkWell(
                          child: Container(
                            width: 24,
                            height: 24,
                            padding: EdgeInsets.all(6),
                            child: Image.asset(
                              'res/drawable/add_position_delete.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              _outListImagePaths.removeAt(index);
//                              images.removeAt(index);
                            });
                          },
                        ),
                      ),
                    ],
                  ));
            },
            itemCount: outItemCount,
          ),
        ),
        _buildImageTitleRow(S.of(context).indoor,
            "（${S.of(context).most} ${S.of(context).unit_zhang("$_inListImagePathsMaxLength")}）", false),
        Container(
          color: Colors.white,
          height: inContainerHeight,
          padding: const EdgeInsets.all(16),
          child: GridView.builder(
            physics: new NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 15,
              childAspectRatio: childAspectRatio,
            ),
            itemBuilder: (context, index) {
              if (index == inItemCount - 1 && _inListImagePaths.length < _inListImagePathsMaxLength) {
                return InkWell(
                  onTap: () {
                    _selectInImages();
                  },
                  child: Container(
                    child: Center(
                      child: Image.asset(
                        'res/drawable/add_position_add.png',
                        width: 20,
                        height: 20,
                        color: Colors.white,
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: HexColor('#D8D8D8'),
                      borderRadius: BorderRadius.circular(3.0),
                    ),
                  ),
                );
              }
              return InkWell(
                  onTap: () {
                    ImagePickers.previewImagesByMedia(_inListImagePaths, index);
                  },
                  child: Stack(
                    children: <Widget>[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: Image.file(File(_inListImagePaths[index].path), width: itemWidth, fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: InkWell(
                          child: Container(
                            width: 24,
                            height: 24,
                            padding: EdgeInsets.all(6),
                            child: Image.asset(
                              'res/drawable/add_position_delete.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              _inListImagePaths.removeAt(index);
//                              images.removeAt(index);
                            });
                          },
                        ),
                      ),
                    ],
                  ));
            },
            itemCount: inItemCount,
          ),
        ),
      ],
    );
  }

  Widget _buildAddressCell() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildTitleRow('address', Size(17, 20), S.of(context).address, true),
        _mapView(),
        Container(
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            // // 主轴方向（横向）对齐方式
            crossAxisAlignment: CrossAxisAlignment.start,
            // 交叉轴（竖直）对其方式
            children: <Widget>[
              (_selectedPosition != null)
                  ? _openCageData == null
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(16, 18, 4, 6),
                          child: InkWell(
                            child: Text(
                              S.of(context).click_auto_get_hint,
                              overflow: TextOverflow.clip,
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                            onTap: () {
                              if (_selectedPosition != null) {
                                _requestOpenCageDataCount += 1;
                                _filterSubject.sink.add(_requestOpenCageDataCount);
                              } else {
                                _pushPosition();
                              }
                            },
                          ))
                      : Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 18, 8, 6),
                            child: Text(
                              _addressText ?? "",
                              overflow: TextOverflow.clip,
                              style: TextStyle(
                                color: DefaultColors.color333,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        )
                  : SizedBox(
                      height: 8,
                    ),
            ],
          ),
        ),
        Container(
          height: 100 + _inputHeight,
          decoration: new BoxDecoration(color: Colors.white),
          child: ListView(
            physics: NeverScrollableScrollPhysics(),
            children: <Widget>[
              _buildAddressCellRow(
                  S.of(context).details_of_street, S.of(context).please_add_streets_hint, _addressController,
                  isDetailAddress: true),
              _divider(),
              _buildAddressCellRow(
                  S.of(context).house_number, S.of(context).please_enter_door_number_hint, _addressHouseNumController),
              _divider(),
              _buildAddressCellRow(
                  S.of(context).postal_code, S.of(context).please_enter_postal_code, _addressPostcodeController),
            ],
          ),
        ),
      ],
    );
  }

  Widget _mapView() {
    var style;
    if (SettingInheritedModel.of(context)?.areaModel?.isChinaMainland ?? true) {
      style = Const.kWhiteWithoutMapStyleCn;
    } else {
      style = Const.kWhiteWithoutMapStyle;
    }
    var languageCode = Localizations.localeOf(context).languageCode;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          InkWell(
            onTap: _pushPosition,
            child: Padding(
              padding: const EdgeInsets.only(top: 15, bottom: 12),
              child: RichText(
                text: TextSpan(
                  text: S.of(context).location_on_the_map,
                  style: TextStyle(color: HexColor('#333333'), fontSize: 14),
                  children: [
                    TextSpan(
                      text: (_selectedPosition != null) ? S.of(context).edit_location : "",
                      style: TextStyle(color: HexColor('#1F81FF'), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
          (_selectedPosition == null)
              ? InkWell(
                  onTap: _pushPosition,
                  child: clipRRectWidget(
                    child: Stack(
                      children: <Widget>[
                        Container(
                            width: double.infinity,
                            height: 125,
                            child: Image.asset(
                              'res/drawable/add_position_map_background.png',
                              fit: BoxFit.cover,
                            )),
                        Container(
                          width: double.infinity,
                          height: 125,
                          color: Colors.black.withOpacity(0.30),
                          child: Center(
                            child: Text(
                              _isLoadingOpenCage ? "" : S.of(context).click_where_to_edit,
                              style: TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: _isLoadingOpenCage,
                          child: Container(
                            width: double.infinity,
                            height: 125,
                            child: SizedBox(
                              height: 25,
                              width: 25,
                              child: Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  strokeWidth: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SizedBox(
                  height: 150,
                  child: clipRRectWidget(
                    child: MapboxMap(
                      compassEnabled: false,
                      initialCameraPosition: CameraPosition(
                        target: Application.recentlyLocation,
                        zoom: 16,
                      ),
                      styleString: style,
                      onMapCreated: (controller) {
                        Future.delayed(Duration(milliseconds: 500)).then((value) {
                          _onStyleLoaded(controller);
                        });
                      },
                      myLocationTrackingMode: MyLocationTrackingMode.None,
                      rotateGesturesEnabled: false,
                      scrollGesturesEnabled: false,
                      zoomGesturesEnabled: false,
                      tiltGesturesEnabled: false,
                      enableLogo: false,
                      enableAttribution: false,
                      minMaxZoomPreference: MinMaxZoomPreference(1.1, 21.0),
                      myLocationEnabled: false,
                      languageCode: languageCode,
                    ),
                  )),
        ],
      ),
    );
  }

  void _onStyleLoaded(MapboxMapController controller) {
    _mapController = controller;
    _addMarkerAndMoveToPoi();
  }

  void _addMarkerAndMoveToPoi() {
    if (_mapController != null) {
      _addMarkerSubject.sink.add(1);
    }
  }

  Widget _buildDetailCell() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildTitleRow('detail', Size(18, 18), S.of(context).detail, false),
        Container(
          height: 140,
          decoration: new BoxDecoration(color: Colors.white),
          child: ListView(
            physics: NeverScrollableScrollPhysics(),
            children: <Widget>[
              InkWell(
                onTap: () {
                  _pushTime();
                },
                child: Container(
                    height: 40,
                    padding: const EdgeInsets.only(left: 15, right: 14),
                    decoration: new BoxDecoration(color: Colors.white),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      // // 主轴方向（横向）对齐方式
                      crossAxisAlignment: CrossAxisAlignment.center,
                      // 交叉轴（竖直）对其方式
                      children: <Widget>[
                        Image.asset('res/drawable/ic_user_poi_business_time.png', width: 19, height: 19),
                        Container(
                          padding: const EdgeInsets.only(left: 28, right: 20),
                          child: Container(
                            width: 230,
                            child: Text(
                              _timeText ?? _timeDefaultText,
                              textAlign: TextAlign.left,
                              overflow: TextOverflow.clip,
                              style:
                                  TextStyle(color: DefaultColors.color777, fontWeight: FontWeight.normal, fontSize: 13),
                            ),
                          ),
                        ),
                        Spacer(),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: Colors.grey,
                        ),
                      ],
                    )),
              ),
              _divider(),
              _buildDetailCellRow(
                  'ic_user_poi_phone_num', S.of(context).phone_number, TextInputType.number, _detailPhoneNumController),
              _divider(),
              _buildDetailCellRow(
                  'ic_user_poi_web_site', S.of(context).website, TextInputType.emailAddress, _detailWebsiteController),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTipsView() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            S.of(context).prompt,
            style: TextStyle(
              color: HexColor("#333333"),
              fontSize: 12,
            ),
          ),
          SizedBox(
            width: 8,
          ),
          Expanded(
            child: Text(
              S.of(context).add_position_page_prompt,
              style: TextStyle(
                color: HexColor("#999999"),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitView() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 30),
      color: Colors.white,
      child: Column(
        children: <Widget>[
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => WebViewContainer(
                            initUrl: Const.POI_POLICY,
                            title: S.of(context).poi_upload_protocol,
                          )));
            },
            child: SizedBox(
                //width: 200,
                height: 40,
                child: Row(
                  children: <Widget>[
                    Checkbox(
                      value: _isAcceptSignalProtocol,
                      activeColor: _themeColor, //选中时的颜色
                      onChanged: (value) {
                        setState(() {
                          _isAcceptSignalProtocol = value;
                        });
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 0),
                      child: RichText(
                        text: TextSpan(
                          text: S.of(context).agree,
                          style: TextStyle(color: HexColor('#252525'), fontSize: 12),
                          children: [
                            TextSpan(
                              text: S.of(context).upload_protocol,
                              style: TextStyle(color: HexColor('#1F81FF'), fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  mainAxisAlignment: MainAxisAlignment.center,
                )),
          ),
          Container(
            //margin: EdgeInsets.symmetric(vertical: 16),
            constraints: BoxConstraints.expand(height: 48),
            child: RaisedButton(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              disabledColor: Colors.grey[600],
              color: Theme.of(context).primaryColor,
              textColor: Colors.white,
              disabledTextColor: Colors.white,
              onPressed: _isOnPressed
                  ? null
                  : () {
                      setState(() {
                        _isOnPressed = true;
                      });
                      Future.delayed(Duration(seconds: 1), () {
                        setState(() {
                          _isOnPressed = false;
                        });
                      });
                      _uploadPoiData();
                    },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      S.of(context).submit,
                      style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 8,
        color: HexColor('#E9E9E9'),
      ),
    );
  }

  Widget _buildAddressCellRow(String title, String hintText, TextEditingController controller,
      {bool isDetailAddress = false}) {
    return Container(
        height: !isDetailAddress ? 40 : _inputHeight,
        padding: const EdgeInsets.only(left: 15, right: 14),
        decoration: new BoxDecoration(color: Colors.white),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          // // 主轴方向（横向）对齐方式
          crossAxisAlignment: CrossAxisAlignment.center,
          // 交叉轴（竖直）对其方式
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Text(
                title,
                textAlign: TextAlign.left,
                style: TextStyle(color: DefaultColors.color777, fontWeight: FontWeight.normal, fontSize: 13),
              ),
            ),
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: controller,
                style: TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: hintText,
                  hintStyle: TextStyle(fontSize: 13, color: DefaultColors.color777),
                ),
                keyboardType: TextInputType.text,
                maxLines: !isDetailAddress ? 1 : 4,
                //maxLength: !isDetailAddress?50:200,
              ),
            ),
          ],
        ));
  }

  Widget _buildDetailCellRow(
      String imageName, String hintText, TextInputType keyboardType, TextEditingController controller) {
    return Container(
        height: 40,
        padding: const EdgeInsets.only(left: 15, right: 14),
        decoration: new BoxDecoration(color: Colors.white),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          // // 主轴方向（横向）对齐方式
          crossAxisAlignment: CrossAxisAlignment.center,
          // 交叉轴（竖直）对其方式
          children: <Widget>[
            Image.asset('res/drawable/$imageName.png', width: 19, height: 19),
            Padding(
              padding: const EdgeInsets.only(right: 10, left: 28),
              child: SizedBox(
                width: 200,
                child: TextFormField(
                  controller: controller,
                  style: TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: hintText,
                    hintStyle: TextStyle(fontSize: 13, color: DefaultColors.color777),
                  ),
                  keyboardType: keyboardType,
                ),
              ),
            ),
          ],
        ));
  }

  Widget _buildImageTitleRow(String title, String subTitle, bool isVisibleStar) {
    return Container(
      color: Colors.white,
      child: Row(
        children: <Widget>[
          Padding(
              padding: EdgeInsets.fromLTRB(14, isVisibleStar ? 18 : 8, 8, 0),
              child: RichText(
                text: TextSpan(
                  text: title,
                  style: TextStyle(
                    color: HexColor("#333333"),
                    fontSize: 14,
                  ),
                ),
              )),
          Visibility(
            visible: isVisibleStar,
            child: Padding(
              padding: const EdgeInsets.only(top: 18, right: 8),
              child: Image.asset('res/drawable/add_position_star.png', width: 8, height: 9),
            ),
          ),
          Expanded(
            child: Padding(
                padding: EdgeInsets.only(top: isVisibleStar ? 18 : 8, right: 8),
                child: RichText(
                  text: TextSpan(children: [
                    TextSpan(
                        text: subTitle,
                        style: TextStyle(
                          color: HexColor("#999999"),
                          fontSize: 12,
                        ))
                  ]),
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleRow(String imageName, Size size, String title, bool isVisibleStar, {bool isFirstRow = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      // // 主轴方向（横向）对齐方式
      crossAxisAlignment: CrossAxisAlignment.center,
      // 交叉轴（竖直）对其方式
      children: <Widget>[
        Padding(
          padding: isFirstRow ? const EdgeInsets.fromLTRB(15, 0, 10, 10) : const EdgeInsets.fromLTRB(15, 18, 10, 11),
          child: Image.asset(
            'res/drawable/add_position_$imageName.png',
            width: size.width,
            height: size.height,
            color: imageName == "detail" ? null : _themeColor,
          ),
        ),
        Padding(
            padding:
                isFirstRow ? const EdgeInsets.only(right: 10, bottom: 10) : const EdgeInsets.fromLTRB(0, 14, 10, 6),
            child: Text(
              title,
              overflow: TextOverflow.clip,
              style: TextStyle(
                color: DefaultColors.color333,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            )),
        Visibility(
          visible: isVisibleStar,
          child: Padding(
            padding:
                isFirstRow ? const EdgeInsets.only(right: 10, bottom: 10) : const EdgeInsets.fromLTRB(0, 14, 10, 6),
            child: Image.asset('res/drawable/add_position_star.png', width: 8, height: 9),
          ),
        ),
        Visibility(
          visible: title == S.of(context).scene_photographed,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 10, 6),
            child: InkWell(
              onTap: _pushImageExplanationView,
              child: Row(
                children: <Widget>[
                  Text(
                    S.of(context).photo_specification,
                    style: TextStyle(
                      color: HexColor("#1F81FF"),
                      fontSize: 12,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Image.asset('res/drawable/add_position_image_detail.png', width: 10, height: 11),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // actions
  Future<void> _selectInImages() async {
    _selectImages(_inListImagePathsMaxLength, _inListImagePaths);
  }

  Future<void> _selectOutImages() async {
    _selectImages(_outListImagePathsMaxLength, _outListImagePaths);
  }

  Future<void> _selectImages(int maxLength, List<Media> imagePaths) async {
    var tempListImagePaths = await ImagePickers.pickerPaths(
      galleryMode: GalleryMode.image,
      selectCount: maxLength - imagePaths.length,
      showCamera: true,
      cropConfig: null,
      compressSize: 500,
      uiConfig: UIConfig(uiThemeColor: Theme.of(context).primaryColor),
      //uiConfig: UIConfig(uiThemeColor: Color(0xff0f95b0)),
    );

    var supports = ["jpg", "jpeg", "png", "gif", "heic", "webp"];
    List<Media> newListImagePaths = [];
    bool isNotSupport = false;
    tempListImagePaths.forEach((element) {
      var path = element.path;
      String suffix = path.split(".").last;
      bool isContainer = supports.contains(suffix);
      if (isContainer) {
        newListImagePaths.add(element);
      } else {
        if (!isNotSupport) {
          isNotSupport = true;
        }
      }
    });

    if (isNotSupport) {
      Fluttertoast.showToast(msg: S.of(context).unsupported_image_formats_will_be_removed_selected_toast);
    }

    if (newListImagePaths.isNotEmpty) {
      setState(() {
        imagePaths.addAll(newListImagePaths);
      });
    }
  }

  _pushPosition() async {
    FocusScope.of(context).requestFocus(FocusNode());

    var position = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectPositionPage(
          initLocation: _selectedPosition != null ? _selectedPosition : _initSelectedPosition,
          type: SelectPositionPage.SELECT_PAGE_TYPE_POI,
        ),
      ),
    );

    if (position == null) {
      return;
    }

    var isSame = false;
    if (_selectedPosition != null) {
      if ((_selectedPosition != position) &&
          (position is LatLng) &&
          position.latitude != _selectedPosition.latitude &&
          position.longitude != _selectedPosition.longitude) {
        _selectedPosition = position;
      } else {
        isSame = true;
      }
    } else {
      _selectedPosition = position;
    }

    if (!isSame) {
      _addMarkerAndMoveToPoi();

      _requestOpenCageDataCount += 1;
      _filterSubject.sink.add(_requestOpenCageDataCount);
    }
  }

  _pushImageExplanationView() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPositionImagePage(),
      ),
    );
  }

  _pushCategory() async {
    FocusScope.of(context).requestFocus(FocusNode());

    var categoryItem = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectCategoryPage(),
      ),
    );
    if (categoryItem is CategoryItem) {
      setState(() {
        _categoryItem = categoryItem;
      });
    }
  }

  _pushTime() async {
    FocusScope.of(context).requestFocus(FocusNode());

    var _timeItem = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BusinessTimePage(),
      ),
    );

    if (_timeItem is BusinessInfo) {
      String dayText = "";
      for (var item in _timeItem.dayList) {
        if (!item.isCheck) continue;
        dayText += "${item.label}、";
      }
      dayText = dayText.replaceFirst("、", "", dayText.length - 1);
      setState(() {
        _timeText = _timeItem.timeStr + " " + dayText;
      });
    }
  }

  _uploadPoiData() async {
    print('[add] --> 存储中。。。');

    // 0. 检测地点名称
    if (!_addressNameKey.currentState.validate()) {
      _scrollController.animateTo(0, duration: Duration(milliseconds: 300, microseconds: 33), curve: Curves.linear);
      return;
    }

    // 1.检测必须类别、图片
    var _isEmptyOfCategory = (_categoryItem == null || _categoryItem.title.length == 0 || _categoryItem.title == "");

    if (_isEmptyOfCategory) {
      Fluttertoast.showToast(msg: S.of(context).category_cannot_be_empty_hint);
      _scrollController.animateTo(0, duration: Duration(milliseconds: 300, microseconds: 33), curve: Curves.linear);
      return;
    }

    // 2.检测网络数据
    if (_openCageData == null) {
      _positionBloc.add(GetOpenCageEvent(_selectedPosition, language));
      Fluttertoast.showToast(msg: S.of(context).please_edit_location_hint);
      _scrollController.animateTo(0, duration: Duration(milliseconds: 300, microseconds: 33), curve: Curves.linear);
      return;
    }

    // 3.检测图片数据
    var _isEmptyOfImages = (_outListImagePaths.length == 0);

    if (_isEmptyOfImages) {
      Fluttertoast.showToast(msg: S.of(context).take_pictures_must_not_be_empty_hint);
      _scrollController.animateTo(0, duration: Duration(milliseconds: 300, microseconds: 33), curve: Curves.linear);
      return;
    }

    if (!_isAcceptSignalProtocol) {
      Fluttertoast.showToast(msg: S.of(context).poi_upload_protocol_not_accepted_hint);
      return;
    }

    var option =
        await showConfirmDialog(context, S.of(context).add_location_data_please_confirm_actual_situation_toast);
    if (!option) return;

    var categoryId = _categoryItem.id;
    var category = _categoryItem.title;
    var country = _openCageData["country"] ?? "";
    var state = _openCageData["state"];
    var city = _openCageData["county"];
    var county = _openCageData["city"];
//    var city = _openCageData["city"];
//    var county = _openCageData["county"];
    //var postalCode = _openCageData["postcode"];
    var countryCode = _openCageData["country_code"] ?? "";
    var poiName = _maxLengthLimit(_addressNameController);
    var poiAddress = _maxLengthLimit(_addressController, isDetailAddress: true);
    var poiHouseNum = _maxLengthLimit(_addressHouseNumController);
    var poiPhoneNum = _maxLengthLimit(_detailPhoneNumController);
    var poiWebsite = _maxLengthLimit(_detailWebsiteController);
    var postalCode = _maxLengthLimit(_addressPostcodeController);

    var collector = PoiCollector(categoryId, _selectedPosition, poiName, countryCode, country, state, city, county,
        poiAddress, "", poiHouseNum, postalCode, _timeText, poiPhoneNum, poiWebsite, category);

    var model = PoiDataV2Model(
        inListImagePaths: _inListImagePaths, outListImagePaths: _outListImagePaths, poiCollector: collector);
    _positionBloc.add(PostPoiDataV2Event(model, address));
    setState(() {
      _isUploading = true;
    });
  }

  String _maxLengthLimit(TextEditingController controller, {bool isDetailAddress = false}) {
    String text = controller.text ?? "";
    if (isDetailAddress) {
      if (text.length > 200) {
        text = text.substring(0, 200);
      }
    } else {
      if (text.length > 50) {
        text = text.substring(0, 50);
      }
    }
    return text;
  }

  void _checkInputHeight() async {
//    int count = _addressController.text.split('\n').length;
    int length = _addressController.text.length;
    double count = _addressController.text.length / 20;

    //print('[add] --> count:$count, length:$length');

    if (count < 1) {
      return;
    }

    if (count <= 4) {
      // use a maximum height of 6 rows
      // height values can be adapted based on the font size
      var newHeight = count < 1 ? 40.0 : 28.0 + (count * 18.0);
      setState(() {
        _inputHeight = newHeight;
        //print('[add] --> newHeight:$newHeight');
      });
    }
  }
}

Widget clipRRectWidget({Widget child, double width, double height}) {
  return Card(
    clipBehavior: Clip.antiAlias,
    shadowColor: Colors.white,
    shape: RoundedRectangleBorder(
      side: const BorderSide(width: 0.5, color: Colors.white),
      borderRadius: BorderRadius.all(
        Radius.circular(12.0),
      ),
    ),
    child: child,
  );
}
