import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/business/position/api/position_api.dart';
import 'package:titan/src/business/position/bloc/bloc.dart';
import 'package:titan/src/business/position/business_time_page.dart';
import 'package:titan/src/business/position/model/business_time.dart';
import 'package:titan/src/business/position/model/category_item.dart';
import 'package:titan/src/business/position/model/poi_collector.dart';
import 'package:titan/src/business/position/position_finish_page.dart';
import 'package:titan/src/business/position/select_category_page.dart';
import 'package:titan/src/business/webview/webview.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/src/business/wallet/wallet_bloc/wallet_state.dart';
import 'package:image_pickers/image_pickers.dart';
import 'package:flutter/services.dart';
import 'package:image_pickers/Media.dart';
import 'package:image_pickers/UIConfig.dart';
import 'package:titan/src/global.dart';

class AddPositionPage extends StatefulWidget {
  LatLng userPosition;

  AddPositionPage(this.userPosition);

  @override
  State<StatefulWidget> createState() {
    return _AddPositionState();
  }
}

class _AddPositionState extends State<AddPositionPage> {

  PositionApi _service = PositionApi();

  PositionBloc _positionBloc = PositionBloc();

  TextEditingController _addressNameController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _addressHouseNumController = TextEditingController();
  TextEditingController _addressPostcodeController = TextEditingController();
  TextEditingController _detailPhoneNumController = TextEditingController();
  TextEditingController _detailWebsiteController = TextEditingController();

  var _isAcceptSignalProtocol = true;
  var _themeColor = HexColor("#0F95B0");

  List<Media> _listImagePaths = List();
  final int _listImagePathsMaxLength = 9;

  CategoryItem _categoryItem;
  String _timeText;

  String _categoryDefaultText = "";
  String _timeDefaultText = "";

  Map<String, dynamic> _openCageData;

  PoiCollector _poiCollector;

  @override
  void initState() {
    _positionBloc.add(AddPositionEvent());
    _categoryDefaultText = "请选择类别";
    _timeDefaultText = "请添加工作时间";

    _getOpenCageData();

    super.initState();
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
        actions: <Widget>[
          InkWell(
            onTap: () {
              _uploadPoiData();
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              alignment: Alignment.centerRight,
              child: Text(
                S.of(context).data_save,
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          )
        ],
      ),
      body: _buildView(context),
    );
  }

  Widget _buildView(BuildContext context) {
    return BlocBuilder<PositionBloc, PositionState>(
      bloc: _positionBloc,
      builder: (BuildContext context, PositionState state) {
        if (state is InitialPositionState) {
          return _buildLoading(context);
        } else if (state is AddPositionState) {
          return _buildBody();
        } else if (state is ScanWalletLoadingState) {
          return _buildLoading(context);
        } else {
          return Container(
            width: 0.0,
            height: 0.0,
          );
        }
      },
    );
  }

  Widget _buildLoading(context) {
    return Center(
      child: SizedBox(
        height: 40,
        width: 40,
        child: CircularProgressIndicator(
          strokeWidth: 3,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _positionBloc.close();
    super.dispose();
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Column(
              children: <Widget>[
                _buildCategoryCell(),
                _buildAddressNameCell(),
                _buildPhotosCell(),
                _buildAddressCell(),
                _buildDetailCell(),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildProtocolCell(),
          ),
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
        _pushCategoryPage();
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
              Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Text(
                    '类别',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 14),
                  )),
              Image.asset(
                'res/drawable/add_position_star.png',
                width: 8,
                height: 9,
              ),
              Spacer(),
              Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Text(_categoryText,
                      style: TextStyle(color: Color(0xff777777), fontSize: 14))),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Colors.grey,
              ),
            ],
          )),
    );
  }

  Widget _buildAddressNameCell() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          // // 主轴方向（横向）对齐方式
          crossAxisAlignment: CrossAxisAlignment.center,
          // 交叉轴（竖直）对其方式
          children: <Widget>[
            Padding(
                padding: const EdgeInsets.fromLTRB(15, 16, 10, 6),
                child: Text(
                  '地点名',
                  style: TextStyle(color: Color(0xff333333), fontWeight: FontWeight.normal, fontSize: 14),
                )),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 16, 10, 6),
              child: Image.asset('res/drawable/add_position_star.png', width: 8, height: 9),
            ),
          ],
        ),
        Container(
          height: 40,
          padding: const EdgeInsets.only(left: 15, right: 15),
          decoration: new BoxDecoration(color: Colors.white),
          child: TextFormField(
            controller: _addressNameController,
            style: TextStyle(fontSize: 14),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: '该地点名称',
              hintStyle: TextStyle(fontSize: 13, color: Color(0xff777777)),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          // // 主轴方向（横向）对齐方式
          crossAxisAlignment: CrossAxisAlignment.center,
          // 交叉轴（竖直）对其方式
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 18, 10, 11),
              child: Image.asset('res/drawable/add_position_camera.png', width: 19, height: 15),
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(0, 14, 10, 6),
                child: Text(
                  '拍摄图片',
                  style: TextStyle(color: Color(0xff333333), fontWeight: FontWeight.normal, fontSize: 14),
                )),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 14, 10, 6),
              child: Image.asset('res/drawable/add_position_star.png', width: 8, height: 9),
            ),
          ],
        ),
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
//                        fit: BoxFit.scaleDown,
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
//                  ImagePickers.previewImagesByMedia(_listImagePaths,index);
                  setState(() {
                    _listImagePaths.removeAt(index);
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(image: AssetImage(_listImagePaths[index].path), fit: BoxFit.fitWidth),
                    color: HexColor('#D8D8D8'),
                    borderRadius: BorderRadius.circular(3.0),
                  ),
                  child: Container(
                    padding: EdgeInsets.fromLTRB(0, 4, 4, 0),
                    alignment: Alignment.topRight,
                    child: Image.asset(
                      'res/drawable/add_position_delete.png',
                      width: 12,
                      height: 12,
                      fit: BoxFit.scaleDown,
                    ),
                  ),
                ),
              );
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
        Padding(
            padding: const EdgeInsets.fromLTRB(15, 16, 10, 6),
            child: Text(
              '地址',
              style: TextStyle(color: Color(0xff333333), fontWeight: FontWeight.normal, fontSize: 14),
            )),
        Container(
          height: 140,
          width: 400,
          decoration: new BoxDecoration(color: Colors.white),
          child: ListView(
            physics: NeverScrollableScrollPhysics(),
            children: <Widget>[
              InkWell(
                onTap: () {
                  //print('[add] --> 添加地址');
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
                        Image.asset('res/drawable/add_position_address.png', width: 19, height: 19),
                        Padding(
                          padding: const EdgeInsets.only(right: 10, left: 28),
                          child: SizedBox(
                            width: 200,
                            child: TextFormField(
                              controller: _addressController,
                              style: TextStyle(fontSize: 14),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: '添加街道',
                                hintStyle: TextStyle(fontSize: 13, color: Color(0xff777777)),
                              ),
                              keyboardType: TextInputType.text,
                            ),
                          ),
                        ),
                      ],
                    )),
              ),
              _divider(),
              Container(
                  height: 40,
                  padding: const EdgeInsets.only(left: 15, right: 14),
                  decoration: new BoxDecoration(color: Colors.white),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    // // 主轴方向（横向）对齐方式
                    crossAxisAlignment: CrossAxisAlignment.center,
                    // 交叉轴（竖直）对其方式
                    children: <Widget>[
                      SizedBox(width: 19, height: 19),
                      Padding(
                        padding: const EdgeInsets.only(right: 10, left: 28),
                        child: SizedBox(
                          width: 200,
                          child: TextFormField(
                            controller: _addressHouseNumController,
                            style: TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: '门牌号码',
                              hintStyle: TextStyle(fontSize: 13, color: Color(0xff777777)),
                            ),
                            keyboardType: TextInputType.text,
                          ),
                        ),
                      ),
                    ],
                  )),
              _divider(),
              Container(
                  height: 40,
                  padding: const EdgeInsets.only(left: 15, right: 14),
                  decoration: new BoxDecoration(color: Colors.white),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    // // 主轴方向（横向）对齐方式
                    crossAxisAlignment: CrossAxisAlignment.center,
                    // 交叉轴（竖直）对其方式
                    children: <Widget>[
                      SizedBox(width: 19, height: 19),
                      Padding(
                        padding: const EdgeInsets.only(right: 10, left: 28),
                        child: SizedBox(
                          width: 200,
                          child: TextFormField(
                            controller: _addressPostcodeController,
                            style: TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: '邮编',
                              hintStyle: TextStyle(fontSize: 13, color: Color(0xff777777)),
                            ),
                            keyboardType: TextInputType.text,
                          ),
                        ),
                      ),
                    ],
                  )),
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
        Padding(
            padding: const EdgeInsets.fromLTRB(15, 16, 10, 6),
            child: Text(
              '详情',
              style: TextStyle(color: Color(0xff333333), fontWeight: FontWeight.normal, fontSize: 14),
            )),
        Container(
          height: 270,
          decoration: new BoxDecoration(color: Colors.white),
          child: ListView(
            physics: NeverScrollableScrollPhysics(),
            children: <Widget>[
              InkWell(
                onTap: () {
                  _pushTimePage();
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
//                          color: Colors.red,
                          padding: const EdgeInsets.only(left: 28, right: 20),
                          child: Container(
//                            color: Colors.green,
                            width: 230,
                            child: Text(
                              _timeText ?? _timeDefaultText,
                              textAlign: TextAlign.left,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: HexColor('#777777'), fontWeight: FontWeight.normal, fontSize: 13),
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
              Container(
                  height: 40,
                  padding: const EdgeInsets.only(left: 15, right: 14),
                  decoration: new BoxDecoration(color: Colors.white),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    // // 主轴方向（横向）对齐方式
                    crossAxisAlignment: CrossAxisAlignment.center,
                    // 交叉轴（竖直）对其方式
                    children: <Widget>[
                      Image.asset('res/drawable/add_position_phone.png', width: 19, height: 19),
                      Padding(
                        padding: const EdgeInsets.only(right: 10, left: 28),
                        child: SizedBox(
                          width: 200,
                          child: TextFormField(
                            controller: _detailPhoneNumController,
                            style: TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: '电话',
                              hintStyle: TextStyle(fontSize: 13, color: Color(0xff777777)),
                            ),
                            keyboardType: TextInputType.text,
                          ),
                        ),
                      ),
                    ],
                  )),
              _divider(),
              Container(
                  height: 40,
                  padding: const EdgeInsets.only(left: 15, right: 14),
                  decoration: new BoxDecoration(color: Colors.white),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    // // 主轴方向（横向）对齐方式
                    crossAxisAlignment: CrossAxisAlignment.center,
                    // 交叉轴（竖直）对其方式
                    children: <Widget>[
                      Image.asset('res/drawable/add_position_website.png', width: 19, height: 19),
                      Padding(
                        padding: const EdgeInsets.only(right: 10, left: 28),
                        child: SizedBox(
                          width: 200,
                          child: TextFormField(
                            controller: _detailWebsiteController,
                            style: TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: '网址',
                              hintStyle: TextStyle(fontSize: 13, color: Color(0xff777777)),
                            ),
                            keyboardType: TextInputType.text,
                          ),
                        ),
                      ),
                    ],
                  )),
              _divider(),
              Container(
                height: 130,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ],
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

  Widget _buildProtocolCell() {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => WebViewContainer(
                      initUrl: 'https://api.hyn.space/map-collector/upload/privacy-policy',
                      title: S.of(context).scan_signal_upload_protocol,
                    )));
      },
      child: Container(
        color: Color(0x88d8d8d8),
        height: 44,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
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
            Text(
              '地理位置',
              style: TextStyle(
                color: HexColor('#333333'),
                fontSize: 11,
              ),
            ),
            Text(
              '上传协议',
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
          ],
        ),
      ),
    );
  }

  var galleryMode = GalleryMode.image;
  Future<void> _selectImages() async {
    try {
      var tempListImagePaths = await ImagePickers.pickerPaths(
        galleryMode: galleryMode,
        selectCount: _listImagePathsMaxLength - _listImagePaths.length,
        showCamera: true,
        cropConfig: null,
        compressSize: 500,
        uiConfig: UIConfig(uiThemeColor: Color(0xff0f95b0)),
      );
      _listImagePaths.addAll(tempListImagePaths);
      for (var path in _listImagePaths) {
        print('[add] --> path:${path.path}');
      }

      setState(() {});
    } on PlatformException {}
  }

  void _pushTimePage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BusinessTimePage(),
      ),
    );

    if (result is BusinessInfo) {
      setState(() {
        print('[add] --> 添加时间, time:${result.timeStr}, dayCount:${result.dayList.length}');
        String dayText = "";

        for (var item in result.dayList) {
          if (!item.isCheck) continue;
          dayText += "${item.label}、";
        }

        _timeText = result.timeStr + " " + dayText;
      });
    }
  }

  void _pushCategoryPage() async {
    print('[add] --> 添加类目');

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectCategoryPage(),
      ),
    );

    if (result is CategoryItem) {
      setState(() {
        _categoryItem = result;
      });
    }
  }

  void _getOpenCageData() async {
    //widget.userPosition = LatLng(23.12084, 113.32193);
    var query = "${widget.userPosition.latitude},${widget.userPosition.longitude}";
    _openCageData = await _service.getOpenCageData(query, 'zh');
  }

  Future _uploadPoiData() async {

    print('[add] --> 存储中。。。');

    // 1.检测必须选项
    var _isEmptyOfCatogory = (_categoryItem.title.length == 0 || _categoryItem.title == "");
    var _isEmptyOfName = (_addressNameController.text.length == 0 || _addressNameController.text == "");
    var _isEmptyOfImages = (_listImagePaths.length == 0);

    if (_isEmptyOfCatogory || _isEmptyOfName || _isEmptyOfImages) {
      Fluttertoast.showToast(msg: "类别、地点名、拍摄图片不能为空");
      return;
    }

    if (!_isAcceptSignalProtocol) {
      Fluttertoast.showToast(msg: "地理位置上传协议未接受");
      return;
    }

    if (_openCageData == null) {
      Fluttertoast.showToast(msg: "OpenCageData 为空");
      return;
    }

    var categoryId = _categoryItem.id;
    var location = widget.userPosition;
    var name = _addressNameController.text;
    var country = _openCageData["country"] ?? "";
    var state = _openCageData["state"];
    var city = _openCageData["city"] + _openCageData["county"];
    var address1 = _addressController.text ?? "";
    var address2 = "";
    var number = _addressHouseNumController.text ?? "";
    //var postalCode = _addressPostcodeController.text ?? "";
    var postalCode = _openCageData["postcode"];
    var workTime = _timeText ?? "";
    var phone = _detailPhoneNumController.text ?? "";
    var website = _detailWebsiteController.text ?? "";
    var country_code = _openCageData["country_code"] ?? "";
    _poiCollector = PoiCollector(
        categoryId,
        location,
        name,
        country_code,
        country,
        state,
        city,
        address1,
        address2,
        number,
        postalCode,
        workTime,
        phone,
        website
    );

    var address = currentWalletVo.accountList[0].account.address;
    bool isFinish = await _service.postPoiCollector(_listImagePaths,address,_poiCollector);

    if (isFinish) {
      createWalletPopUtilName = '/data_contribution_page';
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FinishAddPositionPage(),
        ),
      );
    } else {
      Fluttertoast.showToast(msg: "存储失败!");
    }
  }

}
