import 'dart:convert';
import 'dart:io';

import 'package:custom_radio_grouped_button/CustomButtons/CustomRadioButton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_picker/Picker.dart';
import 'package:image_pickers/Media.dart';
import 'package:image_pickers/UIConfig.dart';
import 'package:image_pickers/image_pickers.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/contribution/add_poi/model/category_item.dart';
import 'package:titan/src/pages/contribution/new_poi/bloc/add_poi_bloc.dart';
import 'package:titan/src/pages/contribution/new_poi/bloc/add_poi_event.dart';
import 'package:titan/src/pages/contribution/new_poi/bloc/add_poi_state.dart';
import 'package:titan/src/pages/webview/webview.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/widget/click_oval_button.dart';
import 'package:titan/src/widget/click_rectangle_button.dart';
import 'package:titan/src/widget/picker_data/PickerData.dart';

class AddPoiPage extends StatefulWidget {
  final LatLng userPosition;

  AddPoiPage({this.userPosition});

  @override
  State<StatefulWidget> createState() {
    return _AddPoiPageState();
  }
}

class _AddPoiPageState extends State<AddPoiPage> with TickerProviderStateMixin {
  double _inputHeight = 40.0;

  TextEditingController _addressNameController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _addressHouseNumController = TextEditingController();
  TextEditingController _addressPostcodeController = TextEditingController();
  TextEditingController _detailPhoneNumController = TextEditingController();
  TextEditingController _detailWebsiteController = TextEditingController();

  List<Media> _listImagePaths = List();
  final int _listImagePathsMaxLength = 9;
  CategoryItem _categoryItem;
  String _categoryDefaultText = "";
  TabController _tabController;
  String radioValue = "First";
  List<String> tabStrList = ["请选择"];
  List<List<String>> testStrList = [
    ["哈哈哈", "哈哈哈", "哈哈哈", "哈哈哈"],
    ["嗯嗯嗯", "嗯嗯嗯", "嗯嗯嗯", "嗯嗯嗯"]
  ];
  bool _isAcceptPoiProtocol = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = new TabController(vsync: this, length: tabStrList.length);
  }

  @override
  Widget build(BuildContext ctx) {
    return BlocBuilder<AddPoiBloc, AddPoiBlocState>(
      bloc: AddPoiBloc(),
      builder: (BuildContext ctx, AddPoiBlocState state) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            title: Text('添加地点'),
          ),
          body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  _poiNameCell(),
                  _categoryCell(ctx),
                  _addressCell(),
                  _photoCell(),
                  _businessTimeCell(),
                  _websiteCell(),
                  _uploadProtocolBox(),
                  _divider(),
                  ClickRectangleButton('上传', () {}),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _businessTimeCell() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _titleRow(
          'business_time',
          Size(19, 15),
          S.of(context).business_time,
          false,
        ),
        Text(
          '周一～周五： 9；30 - 18：30',
          style: TextStyle(fontSize: 13, color: DefaultColors.color777),
        ),
        GestureDetector(
          onTap: () {
            _shoBusinessTimeDialog(context);
          },
          child: Row(
            children: <Widget>[
              Icon(Icons.add),
              Text(
                '添加营业时间',
                style: TextStyle(fontSize: 13, color: DefaultColors.color777),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _photoCell() {
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

    return Column(
      children: <Widget>[
        _titleRow(
          'camera',
          Size(19, 15),
          S.of(context).scene_photographed,
          true,
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
              if (index == itemCount - 1 &&
                  _listImagePaths.length < _listImagePathsMaxLength) {
                return InkWell(
                  onTap: () {
                    _pickImages();
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
                        child: Image.file(File(_listImagePaths[index].path),
                            width: itemWidth, fit: BoxFit.cover),
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

  Widget _poiNameCell() {
    return Column(
      children: <Widget>[
        _titleRow('name', Size(18, 18), S.of(context).name, true),
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

  Widget _categoryCell(BuildContext ctx) {
    return Column(
      children: <Widget>[
        _titleRow('category', Size(18, 18), S.of(context).category, true),
        GestureDetector(
          onTap: () {
            _showCategoryPicker();
          },
          child: Container(
            width: double.infinity,
            child: DropdownButton(
              isExpanded: true,
              hint: Text('请选择地点类别'),
              onChanged: (value) {},
              items: <DropdownMenuItem<dynamic>>[],
            ),
          ),
        ),
      ],
    );
  }

  Widget _addressCell() {
    return Column(
      children: <Widget>[
        _titleRow('address', Size(18, 18), '地址', true),
        Container(
          height: 100 + _inputHeight,
          decoration: new BoxDecoration(color: Colors.white),
          child: ListView(
            physics: NeverScrollableScrollPhysics(),
            children: <Widget>[
              _addressEditRow(S.of(context).details_of_street,
                  S.of(context).please_add_streets_hint, _addressController,
                  isDetailAddress: true),
              _divider(),
              _addressEditRow(
                  S.of(context).house_number,
                  S.of(context).please_enter_door_number_hint,
                  _addressHouseNumController),
              _divider(),
              _addressEditRow(
                  S.of(context).postal_code,
                  S.of(context).please_enter_postal_code,
                  _addressPostcodeController),
            ],
          ),
        ),
      ],
    );
  }

  Widget _addressEditRow(
    String title,
    String hintText,
    TextEditingController controller, {
    bool isDetailAddress = false,
  }) {
    return Container(
        height: !isDetailAddress ? 40 : _inputHeight,
        padding: const EdgeInsets.only(left: 15, right: 14),
        decoration: new BoxDecoration(color: Colors.white),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Text(
                title,
                textAlign: TextAlign.left,
                style: TextStyle(
                    color: DefaultColors.color777,
                    fontWeight: FontWeight.normal,
                    fontSize: 13),
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
                  hintStyle:
                      TextStyle(fontSize: 13, color: DefaultColors.color777),
                ),
                keyboardType: TextInputType.text,
                maxLines: !isDetailAddress ? 1 : 4,
                //maxLength: !isDetailAddress?50:200,
              ),
            ),
          ],
        ));
  }

  Widget _titleRow(
    String imageName,
    Size size,
    String title,
    bool isImportant, {
    bool isCategory = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
            padding: isCategory
                ? const EdgeInsets.only(right: 10)
                : const EdgeInsets.fromLTRB(0, 14, 0, 6),
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
          visible: isImportant,
          child: Padding(
            padding: isCategory
                ? const EdgeInsets.only(right: 10)
                : const EdgeInsets.fromLTRB(10, 14, 10, 6),
            child: Image.asset('res/drawable/add_position_star.png',
                width: 8, height: 9),
          ),
        ),
      ],
    );
  }

  Widget _websiteCell() {
    return Column(
      children: <Widget>[
        _titleRow('website', Size(18, 18), S.of(context).website, false),
        Container(
          padding: const EdgeInsets.only(left: 15, right: 15),
          decoration: new BoxDecoration(color: Colors.white),
          child: TextFormField(
            controller: _detailWebsiteController,
            validator: (value) {
              if (value == null || value.trim().length == 0) {
                return S.of(context).place_name_cannot_be_empty_hint;
              } else {
                return null;
              }
            },
            onChanged: (String inputText) {},
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: '请输入服务网址',
              hintStyle: TextStyle(fontSize: 13, color: DefaultColors.color777),
            ),
            keyboardType: TextInputType.text,
          ),
        ),
      ],
    );
  }

  void _shoBusinessTimeDialog(BuildContext ctx) {
    bool is24hrsOpen = false;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    '营业时间',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text("营业日"),
                ),
                _businessDayRadioBtn(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text("营业时段"),
                ),
                getBusinessTimeGap(),
                Checkbox(
                  value: is24hrsOpen,
                  onChanged: (value) {
                    is24hrsOpen = value;
                  },
                ),
                Center(
                  child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ClickOvalButton('提交', () {})),
                )
              ],
            ),
          );
        });
  }

  Widget _businessDayRadioBtn() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CustomRadioButton(
        enableShape: true,
        customShape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        buttonColor: Theme.of(context).canvasColor,
        buttonLables: ['每天', '节假日', '工作日'],
        buttonValues: ["everyday", 'weekends', 'workdays'],
        radioButtonValue: (value) => print(value),
        selectedColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget getBusinessTimeGap() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Picker(
          adapter: PickerDataAdapter<String>(
            pickerdata: JsonDecoder().convert(TimePickerData),
            isArray: true,
          ),
          delimiter: [
            PickerDelimiter(
                column: 2,
                child: Container(
                  width: 50.0,
                  alignment: Alignment.center,
                  child:
                      Text('至', style: TextStyle(fontWeight: FontWeight.bold)),
                  color: Colors.white,
                ))
          ],
          hideHeader: true,
          selecteds: [3, 0, 2, 0],
          title: Text("Please Select"),
          selectedTextStyle: TextStyle(color: Theme.of(context).primaryColor),
          cancel: FlatButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Icon(Icons.child_care)),
          onConfirm: (Picker picker, List value) {
            print(value.toString());
            print(picker.getSelectedValues());
          }).makePicker(null, true),
    );
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context1, sheetState) {
            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      '请选择类型',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: TabBar(
                      controller: _tabController,
                      labelColor: Colors.black,
                      isScrollable: true,
                      labelStyle: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                      indicatorSize: TabBarIndicatorSize.label,
                      indicatorColor: Colors.black,
                      indicatorWeight: 3,
                      indicatorPadding: EdgeInsets.only(bottom: 2),
                      unselectedLabelColor: HexColor("#aa000000"),
                      tabs: _getTabList(),
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: _getTabContentList(() {
                        sheetState(() {
                          _tabController = TabController(
                            vsync: this,
                            length: tabStrList.length,
                          );
                          _tabController.animateTo(1);
                        });
                      }),
                    ),
                  ),
                ]);
          });
        });
  }

  List<Tab> _getTabList() {
    List<Tab> tabWidgetList = [];
    tabStrList.forEach((element) {
      tabWidgetList.add(
        Tab(
          text: element,
        ),
      );
    });
    return tabWidgetList;
  }

  List<ListView> _getTabContentList(Function refresh) {
    List<ListView> tabContentListView = [];
    for (int i = 0; i < tabStrList.length; i++) {
      if (i == 0) {
        List<InkWell> textList = [];
        testStrList.forEach((subElement) {
          subElement.forEach((element) {
            if (subElement.indexOf(element) == 0) {
              textList.add(InkWell(
                  onTap: () {
                    tabStrList.insert(0, element);
                    refresh();
                  },
                  child: Text(element)));
            }
          });
        });
        tabContentListView.add(
          ListView(
            children: textList,
          ),
        );
      }
      if (i == 1) {
        List<InkWell> textList = [];
        testStrList.forEach((subElement) {
          subElement.forEach((element) {
            if (subElement.indexOf(element) == 0) {
              textList.add(InkWell(
                  onTap: () {
                    tabStrList.insert(0, element);
                    refresh();
                  },
                  child: Text(element)));
            }
          });
        });
        tabContentListView.add(ListView(
          children: textList,
        ));
      }
    }

    return tabContentListView;
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

  Widget _uploadProtocolBox() {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => WebViewContainer(
                      initUrl: Const.POI_POLICY,
                      title: S.of(context).poi_upload_protocol,
                    )));
      },
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Checkbox(
                value: _isAcceptPoiProtocol,
                activeColor: Theme.of(context).primaryColor,
                onChanged: (value) {
                  setState(() {
                    _isAcceptPoiProtocol = value;
                  });
                },
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5.0),
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
          ),
          Container(
            width: 300,
            child: Text(
              '切勿提交违反地方法规的地点，如军事基地、政治敏感位置等',
              style: TextStyle(
                fontSize: 13,
                color: DefaultColors.color777,
              ),
            ),
          )
        ],
      ),
    );
  }

  ///
  Future<void> _pickImages() async {
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
}
