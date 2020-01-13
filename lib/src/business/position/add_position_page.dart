import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_pickers/Media.dart';
import 'package:image_pickers/UIConfig.dart';
import 'package:image_pickers/image_pickers.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/business/position/bloc/bloc.dart';
import 'package:titan/src/business/position/business_time_page.dart';
import 'package:titan/src/business/position/model/business_time.dart';
import 'package:titan/src/business/position/model/category_item.dart';
import 'package:titan/src/business/position/model/poi_collector.dart';
import 'package:titan/src/business/position/model/poi_data.dart';
import 'package:titan/src/business/position/position_finish_page.dart';
import 'package:titan/src/business/position/select_category_page.dart';
import 'package:titan/src/business/webview/webview.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:titan/src/consts/consts.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/style/titan_sytle.dart';

class AddPositionPage extends StatefulWidget {
  final LatLng userPosition;

  AddPositionPage(this.userPosition);

  @override
  State<StatefulWidget> createState() {
    return _AddPositionState();
  }
}

class _AddPositionState extends State<AddPositionPage> {
  PositionBloc _positionBloc = PositionBloc();

  TextEditingController _addressNameController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _addressHouseNumController = TextEditingController();
  TextEditingController _addressPostcodeController = TextEditingController();
  TextEditingController _detailPhoneNumController = TextEditingController();
  TextEditingController _detailWebsiteController = TextEditingController();

  double _inputHeight = 40.0;
  var _isAcceptSignalProtocol = true;
  var _themeColor = HexColor("#0F95B0");

  String _categoryDefaultText = "";
  String _timeDefaultText = "";

  List<Media> _listImagePaths = List();
  final int _listImagePathsMaxLength = 9;
  CategoryItem _categoryItem;
  String _timeText;
  String _addressText;

  Map<String, dynamic> _openCageData;

  bool _isUploading = false;
  final _addressNameKey = GlobalKey<FormState>();

  bool _isOnPressed = false;

  PublishSubject<int> _filterSubject = PublishSubject<int>();
  int _requestOpenCageDataCount = 0;

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
    _categoryDefaultText = S.of(context).please_select_category_hint;
    _timeDefaultText = S.of(context).please_add_business_hours_hint;
    setState(() {

    });
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
          S.of(context).data_position_adding,
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
    return BlocBuilder<PositionBloc, PositionState>(
      bloc: _positionBloc,
      condition: (PositionState fromState, PositionState state) {
        //print('[add] --> state:${fromState}, toState:${state}');

        if (state is SuccessPostPoiDataState) {
          createWalletPopUtilName = '/data_contribution_page';
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FinishAddPositionPage(FinishAddPositionPage.FINISH_PAGE_TYPE_ADD),
            ),
          );
        } else if (state is FailPostPoiDataState) {
          setState(() {
            _isUploading = false;
          });
          Fluttertoast.showToast(msg: S.of(context).store_failed_hint);
        } else if (state is GetOpenCageState) {
          _openCageData = state.openCageData;

          var country = _openCageData["country"] ?? "";
          var provinces = _openCageData["state"];
          var city = _openCageData["city"];
          var county = _openCageData["county"] ?? "";
          setState(() {
            //_addressText = country + " " + provinces + " " + city + " " + county;
            _addressText = county + "，" + city + "，" + provinces + "，" + country;
            //_addressText = "中国 广东省 广州市 天河区 中山大道 环球都会广场 2601楼";
          });

          var postalCode = _openCageData["postcode"] ?? "";
          _addressPostcodeController.text = postalCode;
        }

        return true;
      },
      builder: (BuildContext context, PositionState state) {
        return _buildBody();
      },
    );
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
      padding: const EdgeInsets.only(top: 16),
      child: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Form(
              key: _addressNameKey,
              child: Column(
                children: <Widget>[
                  _buildCategoryCell(),
                  _buildAddressNameCell(),
                  _buildPhotosCell(),
                  _buildAddressCell(),
                  _buildDetailCell(),
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

  Widget _buildCategoryCell() {
    String _categoryText = "";
    if (_categoryItem == null || _categoryItem.title == null) {
      _categoryText = _categoryDefaultText;
    } else {
      _categoryText = _categoryItem.title;
    }

    return InkWell(
      onTap: () {
        _pushCategory();
      },
      child: Container(
          height: 40,
          decoration: new BoxDecoration(color: Colors.white),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            // // 主轴方向（横向）对齐方式
            crossAxisAlignment: CrossAxisAlignment.center,
            // 交叉轴（竖直）对其方式
            children: <Widget>[
              _buildTitleRow('category', Size(18, 18), S.of(context).category, true, isCategory: true),
              Spacer(),
              Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Text(_categoryText, style: TextStyle(color: DefaultColors.color777, fontSize: 14))),
              Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          )),
    );
  }

  Widget _buildAddressNameCell() {
    return Column(
      children: <Widget>[
        _buildTitleRow('name', Size(18, 18), S.of(context).name, true),
        Container(
          padding: const EdgeInsets.only(left: 15, right: 15),
          decoration: new BoxDecoration(color: Colors.white),
          child: TextFormField(
            controller: _addressNameController,
            validator: (value) {
              if (value.isEmpty) {
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
        _buildTitleRow('camera', Size(19, 15), S.of(context).scene_photographed, true),
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

  Widget _buildAddressCell() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: 8,
        ),
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
          height: 100+_inputHeight,
          decoration: new BoxDecoration(color: Colors.white),
          child: ListView(
            physics: NeverScrollableScrollPhysics(),
            children: <Widget>[
              _buildAddressCellRow(S.of(context).details_of_street, S.of(context).please_add_streets_hint, _addressController, isDetailAddress: true),
              _divider(),
              _buildAddressCellRow(S.of(context).house_number, S.of(context).please_enter_door_number_hint, _addressHouseNumController),
              _divider(),
              _buildAddressCellRow(S.of(context).postal_code, S.of(context).please_enter_postal_code, _addressPostcodeController),
            ],
          ),
        ),
      ],
    );
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
                        Image.asset('res/drawable/add_position_time.png', width: 19, height: 19),
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
              _buildDetailCellRow('phone', S.of(context).phone_number, TextInputType.number, _detailPhoneNumController),
              _divider(),
              _buildDetailCellRow('website', S.of(context).website, TextInputType.emailAddress, _detailWebsiteController),
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
                    Container(
//                      width: 40,
                      child: Text(
                        S.of(context).geographical_position,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: HexColor('#333333'),
                          fontSize: 11,
                        ),
                      ),
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

  Widget _buildAddressCellRow(String title, String hintText, TextEditingController controller,{bool isDetailAddress = false}) {
    return Container(
        height: !isDetailAddress?40:_inputHeight,
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
                maxLines: !isDetailAddress?1:4,
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
            Image.asset('res/drawable/add_position_$imageName.png', width: 19, height: 19),
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

  _pushCategory() async {
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
      setState(() {
        _timeText = _timeItem.timeStr + " " + dayText;
      });
    }
  }

  _uploadPoiData() {
    //print('[add] --> 存储中。。。');

    // 0. 检测地点名称
    if (!_addressNameKey.currentState.validate()) {
      return;
    }

    // 2.检测网络数据
    if (_openCageData == null) {
      _positionBloc.add(GetOpenCageEvent(widget.userPosition));
      return;
    }

    // 1.检测必须类别、图片
    var _isEmptyOfCategory = (_categoryItem == null || _categoryItem.title.length == 0 || _categoryItem.title == "");
    var _isEmptyOfImages = (_listImagePaths.length == 0);

    if (_isEmptyOfCategory) {
      Fluttertoast.showToast(msg: S.of(context).category_cannot_be_empty_hint);
      return;
    }

    if (_isEmptyOfImages) {
      Fluttertoast.showToast(msg: S.of(context).take_pictures_must_not_be_empty_hint);
      return;
    }

    if (!_isAcceptSignalProtocol) {
      Fluttertoast.showToast(msg: S.of(context).poi_upload_protocol_not_accepted_hint);
      return;
    }

    var categoryId = _categoryItem.id;
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

    var collector = PoiCollector(categoryId, widget.userPosition, poiName, countryCode, country, state, city, county,
        poiAddress, "", poiHouseNum, postalCode, _timeText, poiPhoneNum, poiWebsite);

    var model = PoiDataModel(listImagePaths: _listImagePaths, poiCollector: collector);
    _positionBloc.add(StartPostPoiDataEvent(model));
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

    if (count <= 4) {  // use a maximum height of 6 rows
      // height values can be adapted based on the font size
      var newHeight = count < 1 ? 40.0 : 28.0 + (count * 18.0);
      setState(() {
        _inputHeight = newHeight;
        //print('[add] --> newHeight:$newHeight');
      });
    }
  }

}
