import 'dart:io';

import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/atlas_map/atlas/atlas_option_edit_page.dart';
import 'package:titan/src/pages/atlas_map/entity/create_atlas_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_info_entity.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_public_widget.dart';
import 'package:titan/src/pages/webview/webview.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'package:titan/src/widget/round_border_textfield.dart';

typedef TextChangeCallback = void Function(String text);

class AtlasCreateNodePage extends StatefulWidget {
  AtlasCreateNodePage();

  @override
  State<StatefulWidget> createState() {
    return _AtlasCreateNodePageState();
  }
}

class _AtlasCreateNodePageState extends State<AtlasCreateNodePage> {
  var _currentStep = Step.launch;

  CreateAtlasPayload _createAtlasPayLoad = CreateAtlasPayload.fromJson({});

  TextEditingController _feeTextController = TextEditingController();
  TextEditingController _maxFeeTextController = TextEditingController();
  TextEditingController _feeExtentTextController = TextEditingController();
  TextEditingController _blsKeyTextController = TextEditingController();
  TextEditingController _blsSignTextController = TextEditingController();

  AtlasApi _atlasApi = AtlasApi();
  List<Map3InfoEntity> _map3NodeList = List();
  var _selectedMap3NodeIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getMap3Nodes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        baseTitle: S.of(context).create_atlas_node,
        actions: [
          InkWell(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: InkWell(
                onTap: () {
                  AtlasApi.goToAtlasMap3HelpPage(context);
                },
                child: Text(
                  '介绍文档',
                  style: TextStyle(
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            _currentStep == Step.launch ? _launchTutorial() : _nodeSetup(),
          ],
        ),
      ),
    );
  }

  _getMap3Nodes() {
    _atlasApi.getMap3NodeList('address');
  }

  _steps() {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 5,
          child: InkWell(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      width: 30,
                      height: 30,
                      child: Stack(
                        children: <Widget>[
                          Container(
                              decoration: new BoxDecoration(
                            gradient: _currentStep == Step.launch
                                ? LinearGradient(
                                    colors: <Color>[
                                      Color(0xff15B2D2),
                                      Color(0xff1097B4)
                                    ],
                                  )
                                : LinearGradient(
                                    colors: <Color>[
                                      Color(0xffDEDEDE),
                                      Color(0xffDEDEDE)
                                    ],
                                  ),
                            shape: BoxShape.circle,
                          )),
                          Center(
                            child: Text(
                              '1',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Text(
                    '启动节点',
                    style: TextStyle(
                      fontWeight: _currentStep == Step.launch
                          ? FontWeight.bold
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            onTap: () {
              setState(() {
                _currentStep = Step.launch;
              });
            },
          ),
        ),
        Expanded(
          flex: 1,
          child: Icon(
            Icons.arrow_forward,
            size: 30,
            color: HexColor('#FFDEDEDE'),
          ),
        ),
        Expanded(
          flex: 5,
          child: InkWell(
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      width: 30,
                      height: 30,
                      child: Stack(
                        children: <Widget>[
                          Container(
                              decoration: new BoxDecoration(
                            gradient: _currentStep != Step.launch
                                ? LinearGradient(
                                    colors: <Color>[
                                      Color(0xff15B2D2),
                                      Color(0xff1097B4)
                                    ],
                                  )
                                : LinearGradient(
                                    colors: <Color>[
                                      Color(0xffDEDEDE),
                                      Color(0xffDEDEDE)
                                    ],
                                  ),
                            shape: BoxShape.circle,
                          )),
                          Center(
                            child: Text(
                              '2',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Text(
                    '完善设置',
                    style: TextStyle(
                      fontWeight: _currentStep != Step.launch
                          ? FontWeight.bold
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  _launchTutorial() {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _steps(),
            _divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 48.0),
              child: Image.asset(
                'res/drawable/ic_computer.png',
                width: 100,
                height: 83,
              ),
            ),
            Container(
              width: 350,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  '请在电脑端按照文档指示启动一个Atlas节点，启动之后，你会获得一个bls key，然后进入下一步操作',
                  style: TextStyle(height: 1.8),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32.0),
              child: InkWell(
                child: Text(
                  '前往操作 >>',
                  style: TextStyle(
                    color: Colors.blue,
                  ),
                ),
                onTap: () {
                  AtlasApi.goToAtlasMap3HelpPage(context);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                '已启动且有bls key，直接下一步',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
            ClickOvalButton(
              '创建提交',
              () {
                setState(
                  () {
                    _currentStep = Step.info;
                  },
                );
              },
              width: 300,
              height: 46,
            ),
            SizedBox(
              height: 32,
            )
          ],
        ),
      ),
    );
  }

  _nodeSetup() {
    var child;
    if (_currentStep == Step.info) {
      child = _basicInfo();
    } else if (_currentStep == Step.fee) {
      child = _fees();
    } else if (_currentStep == Step.bls) {
      child = _bls();
    }
    return Expanded(
      child: BaseGestureDetector(
        context: context,
        child: CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: _steps(),
            ),
            SliverToBoxAdapter(
              child: _divider(),
            ),
            SliverToBoxAdapter(
              child: _map3NodeSelection(),
            ),
            SliverToBoxAdapter(
              child: _divider(),
            ),
            SliverToBoxAdapter(
              child: child,
            ),
          ],
        ),
      ),
    );
  }

  _map3NodeSelection() {
    List<DropdownMenuItem> _map3NodeItems = List();

    for (int i = 0; i < _map3NodeList.length; i++) {
      _map3NodeItems.add(
        DropdownMenuItem(
          value: i,
          child: Text(
            _map3NodeList[i]?.name,
            style: TextStyle(
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    _map3NodeItems.add(
      DropdownMenuItem(
        value: 0,
        child: Text(
          'Lance的Map3节点-1',
          style: TextStyle(
            fontSize: 14,
          ),
        ),
      ),
    );
    _map3NodeItems.add(
      DropdownMenuItem(
        value: 1,
        child: Text(
          'Lance的Map3节点-2',
          style: TextStyle(
            fontSize: 14,
          ),
        ),
      ),
    );
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('选择复抵押的Map3节点'),
          SizedBox(
            height: 16,
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: DropdownButtonFormField(
              decoration: InputDecoration(
                  filled: true,
                  fillColor: HexColor('#FFF2F2F2'),
                  border: InputBorder.none),
              onChanged: (value) {
                setState(() {
                  _selectedMap3NodeIndex = value;
                });
              },
              value: _selectedMap3NodeIndex,
              items: _map3NodeItems,
            ),
          )
        ],
      ),
    );
  }

  _basicInfo() {
    var _isCanNextStep = _createAtlasPayLoad.pic != null &&
        _createAtlasPayLoad.name != null &&
        _createAtlasPayLoad.nodeId != null;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 8,
          ),
          Text(
            '填写基本信息',
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          _basicInfoItem(
            '图标',
            '',
            _createAtlasPayLoad.pic,
            (data) {
              setState(() {
                _uploadImage(data);
                _createAtlasPayLoad.pic = data;
              });
            },
            isLogo: true,
          ),
          Divider(
            height: 1,
          ),
          _basicInfoItem('名称', '请输入节点名称', _createAtlasPayLoad.name, (text) {
            setState(() {
              _createAtlasPayLoad.name = text;
            });
          }),
          Divider(
            height: 1,
          ),
          _basicInfoItem('节点号', '请输入节点号', _createAtlasPayLoad.nodeId, (text) {
            setState(() {
              _createAtlasPayLoad.nodeId = text;
            });
          }),
          Divider(
            height: 1,
          ),
          _basicInfoItem(
            '最大抵押量',
            '节点允许的最大抵押量',
            _createAtlasPayLoad.maxStaking != null
                ? '${_createAtlasPayLoad.maxStaking}'
                : null,
            (text) {
              setState(() {
                _createAtlasPayLoad.maxStaking = text;
              });
            },
            isEssential: false,
            subTitle: ' (选填) ',
            keyboardType: TextInputType.number,
          ),
          Divider(
            height: 1,
          ),
          _basicInfoItem(
            '网址',
            '请输入节点网址',
            _createAtlasPayLoad.home,
            (text) {
              setState(() {
                _createAtlasPayLoad.home = text;
              });
            },
            isEssential: false,
            subTitle: ' (选填) ',
          ),
          Divider(
            height: 1,
          ),
          _basicInfoItem(
            '安全联系',
            '请输入节点的联系方式',
            _createAtlasPayLoad.contact,
            (text) {
              setState(() {
                _createAtlasPayLoad.contact = text;
              });
            },
            isEssential: false,
            subTitle: ' (选填) ',
          ),
          Divider(
            height: 1,
          ),
          _basicInfoItem(
            '描述',
            '请输入节点描述',
            _createAtlasPayLoad.describe,
            (text) {
              setState(() {
                _createAtlasPayLoad.describe = text;
              });
            },
            isEssential: false,
            subTitle: ' (选填) ',
          ),
          SizedBox(
            height: 36,
          ),
          _bottomButtons(_isCanNextStep),
          SizedBox(
            height: 36,
          ),
        ],
      ),
    );
  }

  _basicInfoItem(
    String title,
    String hint,
    String content,
    TextChangeCallback callback, {
    bool isEssential = true,
    bool isLogo = false,
    String subTitle = '',
    TextInputType keyboardType = TextInputType.text,
  }) {
    return InkWell(
      splashColor: Colors.blue,
      onTap: () async {
        if (isLogo) {
          editIconSheet(context, (path) {
            setState(() {
              callback(path);
            });
          });
          return;
        }
        String text = await Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) => AtlasOptionEditPage(
                  title: title,
                  content: content,
                  hint: hint,
                  keyboardType: keyboardType,
                )));
        if (text.isNotEmpty) {
          setState(() {
            callback(text);
          });
        }
      },
      child: Container(
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.symmetric(
              vertical: content != null ? 18 : 14, horizontal: 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(color: HexColor("#333333"), fontSize: 16),
              ),
              if (isEssential)
                Text(
                  ' * ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: HexColor("#FFFF4C3B"),
                    fontSize: 16,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  subTitle,
                  style: TextStyle(color: HexColor("#999999"), fontSize: 12),
                ),
              ),
              Spacer(),
              isLogo
                  ? _createAtlasPayLoad.pic != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Container(
                            width: 36,
                            height: 36,
                            child: Image.file(
                              File(content),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: HexColor('#FFDEDEDE'),
                          ),
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                        )
                  : content != null
                      ? Text(
                          content,
                          style: TextStyle(
                              color: HexColor("#999999"), fontSize: 14),
                        )
                      : Text(
                          hint,
                          style: TextStyle(
                              color: HexColor("#999999"), fontSize: 14),
                        ),
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Icon(
                  Icons.chevron_right,
                  color: DefaultColors.color999,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _fees() {
    var _isCanNextStep = _feeTextController.text.isNotEmpty &&
        _maxFeeTextController.text.isNotEmpty &&
        _feeExtentTextController.text.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 8,
          ),
          Text(
            '设置费率',
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          SizedBox(
            height: 16,
          ),
          Text('费率'),
          SizedBox(
            height: 16,
          ),
          RoundBorderTextField(
            keyboardType: TextInputType.number,
            suffixIcon: Container(
              width: 10,
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  '%',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            onChanged: (text) {
              setState(() {
                _createAtlasPayLoad.feeRate = text;
              });
            },
            controller: _feeTextController,
            isDense: false,
          ),
          SizedBox(
            height: 16,
          ),
          Row(
            children: <Widget>[
              Text('最大费率'),
              SizedBox(
                width: 4,
              ),
              Text(
                '(设置过后不可以更改)',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                ),
              )
            ],
          ),
          SizedBox(
            height: 16,
          ),
          RoundBorderTextField(
            keyboardType: TextInputType.number,
            suffixIcon: Container(
              width: 10,
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  '%',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
            onChanged: (text) {
              setState(() {
                _createAtlasPayLoad.feeRateMax = text;
              });
            },
            controller: _maxFeeTextController,
            isDense: false,
          ),
          SizedBox(
            height: 16,
          ),
          Row(
            children: <Widget>[
              Text('费率幅度'),
              SizedBox(
                width: 4,
              ),
              Text(
                '(设置过后不可以更改)',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                ),
              )
            ],
          ),
          SizedBox(
            height: 16,
          ),
          RoundBorderTextField(
            keyboardType: TextInputType.number,
            suffixIcon: Container(
              width: 10,
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  '%',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
            onChanged: (text) {
              setState(() {
                _createAtlasPayLoad.feeRateTrim = text;
              });
            },
            controller: _feeExtentTextController,
            isDense: false,
          ),
          SizedBox(
            height: 36,
          ),
          _bottomButtons(_isCanNextStep),
        ],
      ),
    );
  }

  _bls() {
    var _isCanNextStep = _blsKeyTextController.text.isNotEmpty &&
        _blsSignTextController.text.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 8,
          ),
          Text(
            'bls参数',
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          SizedBox(
            height: 16,
          ),
          Text('bls key'),
          SizedBox(
            height: 16,
          ),
          RoundBorderTextField(
            onChanged: (text) {
              setState(() {
                _createAtlasPayLoad.blsAddKey = text;
              });
            },
            controller: _blsKeyTextController,
            isDense: false,
          ),
          SizedBox(
            height: 16,
          ),
          Row(
            children: <Widget>[
              Text('bls签名'),
              SizedBox(
                width: 4,
              ),
              Text(
                '(设置过后不可以更改)',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                ),
              )
            ],
          ),
          SizedBox(
            height: 16,
          ),
          RoundBorderTextField(
            onChanged: (text) {
              setState(() {
                _createAtlasPayLoad.blsAddSign = text;
              });
            },
            controller: _blsSignTextController,
            isDense: false,
          ),
          SizedBox(
            height: 36,
          ),
          _bottomButtons(_isCanNextStep),
        ],
      ),
    );
  }

  _nextStep() {
    if (_currentStep == Step.info) {
      _currentStep = Step.fee;
    } else if (_currentStep == Step.fee) {
      _currentStep = Step.bls;
    } else if (_currentStep == Step.bls) {
      Application.router.navigateTo(
        context,
        Routes.atlas_create_node_info_page +
            '?createAtlasPayload=${FluroConvertUtils.object2string(_createAtlasPayLoad)}',
      );
    }
    setState(() {});
  }

  _lastStep() {
    return Center(
      child: InkWell(
        child: Text(
          S.of(context).last_step,
          style: TextStyle(
            fontSize: 14,
            color: Colors.blue,
          ),
        ),
        onTap: () {
          if (_currentStep == Step.bls) {
            _currentStep = Step.fee;
          } else if (_currentStep == Step.fee) {
            _currentStep = Step.info;
          } else if (_currentStep == Step.info) {
            _currentStep = Step.launch;
          }
          setState(() {});
        },
      ),
    );
  }

  _bottomButtons(bool isCanNext) {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 1,
          child: _lastStep(),
        ),
        Expanded(
          flex: 2,
          child: Container(
            height: 38,
            decoration: BoxDecoration(
              gradient: isCanNext
                  ? LinearGradient(
                      colors: <Color>[Color(0xff15B2D2), Color(0xff1097B4)],
                    )
                  : LinearGradient(
                      colors: <Color>[Color(0xffDEDEDE), Color(0xffDEDEDE)],
                    ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: FlatButton(
              textColor: Colors.white,
              disabledTextColor: HexColor('#FFFFFFFF'),
              onPressed: isCanNext ? _nextStep : null,
              child: Text(
                _currentStep != Step.bls
                    ? S.of(context).next_step
                    : S.of(context).submit,
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(),
        )
      ],
    );
  }

  _divider() {
    return Container(
      height: 10,
      color: HexColor('#FFF4F4F4'),
    );
  }
}

///update icon
_uploadImage(String path) {}

enum Step { launch, info, fee, bls }
