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
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/contribution/add_poi/model/poi_data.dart';
import 'package:titan/src/pages/discover/dapp/ncov/model/ncov_poi_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:titan/src/pages/contribution/add_poi/bloc/bloc.dart';
import 'package:titan/src/pages/webview/webview.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/widget/all_page_state/all_page_state.dart';
import 'package:titan/src/widget/grouped_buttons/grouped_buttons.dart';

class AddNcovPage extends StatefulWidget {
  final LatLng userPosition;

  AddNcovPage(this.userPosition);

  @override
  State<StatefulWidget> createState() {
    return _AddNcovState();
  }
}

class _AddNcovState extends State<AddNcovPage> {
  PositionBloc _positionBloc = PositionBloc();

  TextEditingController _addressNameController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _addressHouseNumController = TextEditingController();
  TextEditingController _addressPostcodeController = TextEditingController();
  TextEditingController _numbersController = TextEditingController();
  TextEditingController _categoryController = TextEditingController();
  TextEditingController _tripController = TextEditingController();
  TextEditingController _recordController = TextEditingController();
  TextEditingController _safeController = TextEditingController();
  TextEditingController _descController = TextEditingController();

  double _inputHeight = 40.0;
  var _isAcceptSignalProtocol = true;
  var _themeColor = HexColor("#0F95B0");

  List<String> _isolationTextList = [];
  String _isolationText = "";

  List<String> _isolationHouseTypeTextList = [];
  String _isolationHouseTypeText = "";

  List<String> _symptomsDefaultList = [];
  List<String> _symptomsList = [];

  List<Media> _listImagePaths = List();
  final int _listImagePathsMaxLength = 9;

  String _addressText;

  Map<String, dynamic> _openCageData;

  bool _isUploading = false;
  final _addressNameKey = GlobalKey<FormState>();

  bool _isOnPressed = false;

  PublishSubject<int> _filterSubject = PublishSubject<int>();
  int _requestOpenCageDataCount = 0;

  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _addressController.addListener(_checkInputHeight);

    _positionBloc.add(GetOpenCageEvent(widget.userPosition));
    _filterSubject.debounceTime(Duration(seconds: 1)).listen((count) {
      //print('[add] ---> count:$count, _requestOpenCageDataCount:$_requestOpenCageDataCount');
      _positionBloc.add(GetOpenCageEvent(widget.userPosition));
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _setupData();
    super.didChangeDependencies();
  }

  void _setupData() {
    _isolationTextList = [
      S.of(context).isolation_yes,
      S.of(context).isolation_no,
      S.of(context).isolation_unknown,
    ];
    _isolationText = _isolationTextList.first;

    _isolationHouseTypeTextList = [
      S.of(context).isolation_type_home,
      S.of(context).isolation_type_rent,
      S.of(context).isolation_type_stay,
      S.of(context).isolation_type_hotel,
      S.of(context).add_ncov_others,
    ];
    _isolationHouseTypeText = _isolationHouseTypeTextList.first;

    _symptomsDefaultList = <String>[
      S.of(context).symptoms_weak,
      S.of(context).symptoms_hots,
      S.of(context).symptoms_cough,
      S.of(context).symptoms_stuffy,
      S.of(context).symptoms_nose_running,
      S.of(context).symptoms_diarrhea,
      S.of(context).symptoms_breathing_difficult,
    ];
//    _symptomsList = _symptomsDefaultList.sublist(0, 1);
  }

  @override
  void dispose() {
    _positionBloc.close();
    _filterSubject.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          S.of(context).add_ncov_confirmed_info,
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: _buildView(context),
    );
  }

  // build view
  Widget _buildView(BuildContext context) {
    return BlocBuilder<PositionBloc, AllPageState>(
      bloc: _positionBloc,
      condition: (AllPageState fromState, AllPageState state) {
        //print('[add] --> state:${fromState}, toState:${state}');

        if (state is SuccessPostPoiNcovDataState) {
          //TODO
//          createWalletPopUtilName = '/data_contribution_page';
//          Navigator.push(
//            context,
//            MaterialPageRoute(
//              builder: (context) => FinishAddPositionPage(FinishAddPositionPage.FINISH_PAGE_TYPE_ADD),
//            ),
//          );
        } else if (state is FailPostPoiNcovDataState) {
          setState(() {
            _isUploading = false;
          });
          var hint = S.of(context).add_failed_exist_hint;
          Fluttertoast.showToast(msg: state.code == -409 ? hint : S.of(context).add_failed_hint);
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
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Stack(
        children: <Widget>[
          SingleChildScrollView(
            controller: _scrollController,
            child: Form(
              key: _addressNameKey,
              child: Column(
                children: <Widget>[
                  _buildAddressNameCell(),
                  _buildAddressCell(),
                  _buildPhotosCell(),
                  _buildNumbersCell(),
                  _buildCategoryCell(),
                  _buildIsolationCell(),
                  _buildPropertyCell(),
                  _buildSymptomsCell(),
                  _buildTripCell(),
                  _buildRecordCell(),
                  _buildSafeCell(),
                  _buildSubmitView(),
                ],
              ),
            ),
          ),
          _buildLoading(),
        ],
      ),
    );
  }

  Widget _buildAddressNameCell() {
    return Column(
      children: <Widget>[
        _buildTitleRow('landmark', Size(20, 13), S.of(context).ncov_cell_title_name, true),
        Container(
          padding: const EdgeInsets.only(left: 15, right: 15),
          decoration: new BoxDecoration(color: Colors.white),
          child: TextFormField(
            controller: _addressNameController,
            validator: (value) {
              if (value == null || value.trim().length == 0) {
                return S.of(context).ncov_cell_hint_name_not_empty;
              } else {
                return null;
              }
            },
            onChanged: (String inputText) {
              //print('[add] --> inputText:${inputText}');
            },
            style: TextStyle(fontSize: 13),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: S.of(context).ncov_cell_hint_name,
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

    return Column(
      children: <Widget>[
        _buildTitleRow('camera', Size(19, 15), S.of(context).ncov_cell_title_scene_images, false),
        Container(
          height: containerHeight,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 2),
          child: GridView.builder(
            physics: new NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 15,
              childAspectRatio: childAspectRatio,
            ),
            itemBuilder: (context, index) {
              if (index == itemCount - 1 && _listImagePaths.length < _listImagePathsMaxLength) {
                return InkWell(
                  onTap: () {
                    _selectImages();
                  },
                  child: Container(
                    child: Center(
                      child: Image.asset(
                        'res/drawable/add_position_add.png',
                        width: 20,
                        height: 20,
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
                    ImagePickers.previewImagesByMedia(_listImagePaths, index);
                  },
                  child: Stack(
                    children: <Widget>[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: Image.file(File(_listImagePaths[index].path), width: itemWidth, fit: BoxFit.cover),
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
                              _listImagePaths.removeAt(index);
                            });
                          },
                        ),
                      ),
                    ],
                  ));
            },
            itemCount: itemCount,
          ),
        ),
      ],
    );
  }

  Widget _buildNumbersCell() {
    return Column(
      children: <Widget>[
        _buildTitleRow('numbers', Size(18, 18), S.of(context).ncov_cell_title_numbers, false),
        Container(
          padding: const EdgeInsets.only(left: 15, right: 15),
          decoration: new BoxDecoration(color: Colors.white),
          child: TextFormField(
            controller: _numbersController,
            //style:  TextStyle(fontSize: 13),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: S.of(context).ncov_cell_hint_numbers,
              hintStyle: TextStyle(fontSize: 13, color: DefaultColors.color777),
            ),
            keyboardType: TextInputType.number,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCell() {
    return Column(
      children: <Widget>[
        _buildTitleRow('category', Size(18, 18), S.of(context).ncov_cell_title_category, false),
        Container(
          padding: const EdgeInsets.only(left: 15, right: 15),
          decoration: new BoxDecoration(color: Colors.white),
          child: TextFormField(
            controller: _categoryController,
            style: TextStyle(fontSize: 13),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: S.of(context).ncov_cell_hint_category,
              hintStyle: TextStyle(fontSize: 13, color: DefaultColors.color777),
            ),
            keyboardType: TextInputType.text,
          ),
        ),
      ],
    );
  }

  Widget _buildIsolationCell() {
    return Column(
      children: <Widget>[
        _buildDetailTitleRow(S.of(context).ncov_cell_title_isolation),
        RadioButtonGroup(
          orientation: GroupedButtonsOrientation.HORIZONTAL,
          picked: _isolationText,
          labels: _isolationTextList,
          labelStyle: TextStyle(
            color: DefaultColors.color333,
            fontWeight: FontWeight.w400,
            fontSize: 12,
          ),
          activeColor: Theme.of(context).primaryColor,
          onChange: (String label, int index) => print("label: $label index: $index"),
          onSelected: (String label) {
            _isolationText = label;
          },
        ),
      ],
    );
  }

  Widget _buildPropertyCell() {
    return Column(
      children: <Widget>[
        _buildDetailTitleRow(S.of(context).ncov_cell_title_property),
        RadioButtonGroup(
          picked: _isolationHouseTypeText,
          labels: _isolationHouseTypeTextList,
          labelStyle: TextStyle(
            color: DefaultColors.color333,
            fontWeight: FontWeight.w400,
            fontSize: 12,
          ),
          activeColor: Theme.of(context).primaryColor,
          onChange: (String label, int index) => print("label: $label index: $index"),
          onSelected: (String label) {
            _isolationHouseTypeText = label;
          },
        ),
      ],
    );
  }

  Widget _buildSymptomsCell() {
    return Column(
      children: <Widget>[
        _buildDetailTitleRow(S.of(context).ncov_cell_title_symptoms),
        CheckboxGroup(
          checked: _symptomsList,
          labels: _symptomsDefaultList,
          labelStyle: TextStyle(
            color: DefaultColors.color333,
            fontWeight: FontWeight.w400,
            fontSize: 12,
          ),
          onChange: (bool isChecked, String label, int index) =>
              print("isChecked: $isChecked   label: $label  index: $index"),
          onSelected: (List<String> checked) {
            _symptomsList = checked;
            var _symptomsText = checked.toString();
            print("checked: ${_symptomsText}");
          },
        ),
        _buildDetailDescRow(S.of(context).ncov_cell_title_desc),
        Container(
          margin: const EdgeInsets.only(left: 15, right: 15, top: 6, bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Theme.of(context).primaryColor, width: 1.0),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 12, right: 12, top: 0, bottom: 8),
            child: TextFormField(
              controller: _descController,
              keyboardType: TextInputType.multiline,
              maxLength: null,
              maxLines: null,
              style: TextStyle(fontSize: 11),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: S.of(context).ncov_cell_hint_input_desc,
                hintStyle: TextStyle(fontSize: 11, color: DefaultColors.color777),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTripCell() {
    return _buildDetailCellRow(S.of(context).ncov_cell_title_trip, S.of(context).ncov_cell_hint_trip, _tripController);
  }

  Widget _buildRecordCell() {
    return _buildDetailCellRow(
        S.of(context).ncov_cell_title_records, S.of(context).ncov_cell_hint_records, _recordController);
  }

  Widget _buildSafeCell() {
    return _buildDetailCellRow(S.of(context).ncov_cell_title_safe, S.of(context).ncov_cell_hint_safe, _safeController);
  }

  Widget _buildAddressCell() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          // // 主轴方向（横向）对齐方式
          crossAxisAlignment: CrossAxisAlignment.start,
          // 交叉轴（竖直）对其方式
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 18, 10, 11),
              child: Image.asset('res/drawable/add_position_address.png', width: 17, height: 21),
            ),
            _openCageData == null
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(0, 18, 4, 6),
                    child: InkWell(
                      child: Text(
                        S.of(context).click_auto_get_hint,
                        overflow: TextOverflow.clip,
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                        ),
                      ),
                      onTap: () {
                        _requestOpenCageDataCount += 1;
                        _filterSubject.sink.add(_requestOpenCageDataCount);
                      },
                    ))
                : Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 18, 8, 6),
                      child: Text(
                        _addressText ?? "",
                        overflow: TextOverflow.clip,
                        style: TextStyle(
                          color: DefaultColors.color333,
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
          ],
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

  Widget _buildSubmitView() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 18, 16, 30),
      //color: Colors.red,
      child: Column(
        children: <Widget>[
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
                      padding: const EdgeInsets.only(left: 5),
                      child: Text(
                        S.of(context).upload_protocol,
                        style: TextStyle(
                          color: HexColor('#333333'),
                          fontSize: 11,
                          decoration: TextDecoration.combine([
                            TextDecoration.underline, // 下划线
                          ]),
                          decorationStyle: TextDecorationStyle.solid,
                          // 装饰样式
                          decorationColor: HexColor('#333333'),
                        ),
                      ),
                    ),
                  ],
                  mainAxisAlignment: MainAxisAlignment.center,
                )),
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
                style: TextStyle(fontSize: 13),
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

  Widget _buildDetailCellRow(String title, String hintText, TextEditingController controller) {
    return Column(
      children: <Widget>[
        _buildDetailTitleRow(title),
        Container(
          padding: const EdgeInsets.only(left: 15, right: 15),
          decoration: new BoxDecoration(color: Colors.white),
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.multiline,
            maxLength: null,
            maxLines: null,
            style: TextStyle(fontSize: 13),
            decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hintText,
                hintStyle: TextStyle(fontSize: 13, color: DefaultColors.color777),
                hintMaxLines: 4),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailTitleRow(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      // // 主轴方向（横向）对齐方式
      crossAxisAlignment: CrossAxisAlignment.center,
      // 交叉轴（竖直）对其方式
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 18, 10, 11),
        ),
        Padding(
            padding: const EdgeInsets.fromLTRB(0, 14, 10, 6),
            child: Text(
              title,
              overflow: TextOverflow.clip,
              style: TextStyle(
                color: DefaultColors.color333,
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
            )),
      ],
    );
  }

  Widget _buildDetailDescRow(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      // // 主轴方向（横向）对齐方式
      crossAxisAlignment: CrossAxisAlignment.center,
      // 交叉轴（竖直）对其方式
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 18, 10, 11),
        ),
        Padding(
            padding: const EdgeInsets.fromLTRB(0, 14, 10, 6),
            child: Text(
              title,
              overflow: TextOverflow.clip,
              style: TextStyle(
                color: DefaultColors.color333,
                fontWeight: FontWeight.w400,
                fontSize: 12,
              ),
            )),
      ],
    );
  }

  Widget _buildTitleRow(String imageName, Size size, String title, bool isVisibleStar, {bool isCategory = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      // // 主轴方向（横向）对齐方式
      crossAxisAlignment: CrossAxisAlignment.center,
      // 交叉轴（竖直）对其方式
      children: <Widget>[
        Padding(
          padding: isCategory ? const EdgeInsets.fromLTRB(15, 0, 10, 0) : const EdgeInsets.fromLTRB(15, 18, 10, 11),
          child: Image.asset('res/drawable/add_position_$imageName.png', width: size.width, height: size.height),
        ),
        Padding(
            padding: isCategory ? const EdgeInsets.only(right: 10) : const EdgeInsets.fromLTRB(0, 14, 10, 6),
            child: Text(
              title,
              overflow: TextOverflow.clip,
              style: TextStyle(
                color: DefaultColors.color333,
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
            )),
        Visibility(
          visible: isVisibleStar,
          child: Padding(
            padding: isCategory ? const EdgeInsets.only(right: 10) : const EdgeInsets.fromLTRB(0, 14, 10, 6),
            child: Image.asset('res/drawable/add_position_star.png', width: 8, height: 9),
          ),
        ),
      ],
    );
  }

  // actions
  Future<void> _selectImages() async {
    var tempListImagePaths = await ImagePickers.pickerPaths(
      galleryMode: GalleryMode.image,
      selectCount: _listImagePathsMaxLength - _listImagePaths.length,
      showCamera: true,
      cropConfig: null,
      compressSize: 500,
      uiConfig: UIConfig(uiThemeColor: Color(0xff0f95b0)),
    );
    setState(() {
      _listImagePaths.addAll(tempListImagePaths);
    });
  }

  _uploadPoiData() {
    //print('[add] --> 存储中。。。');

    // 0. 检测地点名称
    if (!_addressNameKey.currentState.validate()) {
      _scrollController.animateTo(0, duration: Duration(milliseconds: 300, microseconds: 33), curve: Curves.linear);
      return;
    }

    // 2.检测网络数据
    if (_openCageData == null) {
      _positionBloc.add(GetOpenCageEvent(widget.userPosition));
      return;
    }

    // 1.检测必须类别、图片

    if (!_isAcceptSignalProtocol) {
      Fluttertoast.showToast(msg: S.of(context).poi_upload_protocol_not_accepted_hint);
      return;
    }

    /*{
      "location":{"lat":23.1208435,"lon":113.32207890000001},
    "name":"嘉德公管",
    "country":"China",
    "county":"广州",
    "state":"广东省",
    "city":"天河区",
    "road":"花城大道环球都会广场",
    "house_number":"3楼",
    "postcode":"510066",
    "confirmed_count":5,
    "confirmed_type":"本地人",
    "isolation":"是",
    "isolation_house_type":"居家自主",
    "symptoms":["发热","呼吸轻困难"],
    "symptoms_detail":"全身无力，呼吸轻困难，头疼",
    "trip":"1月20号从武汉出差回来，先回去天河科韵路公司开会，下班后乘坐地铁3号回家，休息两日后出现症状",
    "security_measures":"居家隔离，所有楼全栋消毒",
    "contact_records":"地铁3号线大概6: 50分去番禺广场"
    }*/

    var id = "";
    Location location = Location([widget.userPosition.latitude, widget.userPosition.longitude], "ncov");
    var name = _maxLengthLimit(_addressNameController);
    var country = _openCageData["country"] ?? "";
    var county = _openCageData["city"];
    var state = _openCageData["state"];
    var city = _openCageData["county"];
    var address = _maxLengthLimit(_addressController, isDetailAddress: true);
    List<String> images = [];
    var road = address;
    var houseNumber = _maxLengthLimit(_addressHouseNumController);
    var postCode = _maxLengthLimit(_addressPostcodeController);
    int confirmedCount = 0;
    if (_numbersController.text.length > 0) {
      confirmedCount = int.parse(_numbersController.text);
    }
    var confirmedType = _maxLengthLimit(_categoryController);
    var isolation = _isolationText;
    var isolationHouseType = _isolationHouseTypeText;
    var symptoms = _symptomsList;
    var symptomsDetail = _maxLengthLimit(_descController, isDetailAddress: true);
    var trip = _maxLengthLimit(_tripController, isDetailAddress: true);
    var securityMeasures = _maxLengthLimit(_safeController, isDetailAddress: true);
    var contactRecords = _maxLengthLimit(_recordController, isDetailAddress: true);

    var collector = NcovPoiEntity(
        id,
        country,
        county,
        state,
        city,
        name,
        address,
        location,
        images,
        road,
        houseNumber,
        postCode,
        confirmedCount,
        confirmedType,
        isolation,
        isolationHouseType,
        symptoms,
        symptomsDetail,
        trip,
        securityMeasures,
        contactRecords);
    var model = PoiNcovDataModel(listImagePaths: _listImagePaths, poiCollector: collector);
    _positionBloc.add(StartPostPoiNcovDataEvent(model));
    setState(() {
      _isUploading = true;
    });
  }

  String _maxLengthLimit(TextEditingController controller, {bool isDetailAddress = false}) {
    String text = controller.text.trim() ?? "";
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
