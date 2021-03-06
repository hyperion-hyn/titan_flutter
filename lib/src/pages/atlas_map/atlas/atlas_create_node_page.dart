import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/wallet/vo/wallet_view_vo.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
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
import 'package:titan/src/widget/round_border_textField.dart';

import 'atlas_stake_list_page.dart';

typedef TextChangeCallback = void Function(String text);

class AtlasCreateNodePage extends StatefulWidget {
  AtlasCreateNodePage();

  @override
  State<StatefulWidget> createState() {
    return _AtlasCreateNodePageState();
  }
}


class _AtlasCreateNodePageState extends BaseState<AtlasCreateNodePage> {
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

  WalletViewVo activatedWallet;

  @override
  void onCreated() {
    activatedWallet = WalletInheritedModel.of(context).activatedWallet;
    _getMap3Nodes();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        baseTitle: S.of(context).create_atlas_node,
        actions: [
          InkWell(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
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
            ),
          )
        ],
      ),
      body: Container(
        color: Colors.white,
        height: double.infinity,
        child: _currentStep == Step.launch
            ? _launchNodeTutorial()
            : _nodeOptionsSetup(),
      ),
    );
  }

  _getMap3Nodes() async {
    try {
//      _map3NodeList = await _atlasApi.getMap3NodeList(
//        activatedWallet?.wallet?.getAtlasAccount()?.address,
//      );

      _map3NodeList.add(
        Map3InfoEntity.onlyId(1)
          ..name = 'Lance的Map3-1'
          ..address = 'sdkfjslkgn',
      );

      _map3NodeList.add(
        Map3InfoEntity.onlyId(2)
          ..name = 'Lance的Map3-2'
          ..address = 'dsgsjgkls',
      );

      _map3NodeList.add(
        Map3InfoEntity.onlyId(3)
          ..name = 'Lance的Map3-3'
          ..address = 'fksjgncodf',
      );

      ///select first map3 node on default
      _selectedMap3NodeIndex = 0;
      _createAtlasPayLoad.map3Address =
          _map3NodeList[_selectedMap3NodeIndex]?.address;

      setState(() {});
    } catch (e) {}
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
                      fontSize: 12,
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
                      fontSize: 12,
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

  _launchNodeTutorial() {
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
                  style: TextStyle(
                    height: 1.8,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.left,
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
                    fontSize: 14,
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
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
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
              fontSize: 18,
            ),
            SizedBox(
              height: 32,
            )
          ],
        ),
      ),
    );
  }

  _nodeOptionsSetup() {
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
    if (_map3NodeList.length == 0) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text("抵押Atlas节点，你需要先拥有Map3节点，现在你可以进行以下操作参与抵押Atlas节点：",
                style: TextStyles.textC333S14),
            Padding(
              padding: const EdgeInsets.only(top: 28, bottom: 10),
              child: Text("1、创建并启动一个Map3节点，然后抵押到Atlas节点并享受节点出块奖励",
                  style: TextStyles.textC333S12),
            ),
            Text("马上创建Map3节点",
                style: TextStyle(color: HexColor("#1F81FF"), fontSize: 12)),
          ],
        ),
      );
    }
    List<DropdownMenuItem> _map3NodeItems = List();

    for (int i = 0; i < _map3NodeList.length; i++) {
      _map3NodeItems.add(
        DropdownMenuItem(
          value: i,
          child: Text(
            _map3NodeList[i].name,
            style: TextStyle(
              fontSize: 14,
            ),
          ),
        ),
      );
    }

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
                  _createAtlasPayLoad.map3Address = _map3NodeList.isNotEmpty
                      ? _map3NodeList[_selectedMap3NodeIndex]?.address
                      : null;
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
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          _basicInfoItem(
            '图标',
            '',
            _createAtlasPayLoad.pic,
            (data) {
              setState(() {
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
            builder: (BuildContext context) => OptionEditPage(
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
                style: TextStyle(
                  color: HexColor("#333333"),
                  fontSize: 14,
                ),
              ),
              if (isEssential)
                Text(
                  ' * ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: HexColor("#FFFF4C3B"),
                    fontSize: 14,
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
                            color: HexColor("#999999"),
                            fontSize: 14,
                          ),
                        )
                      : Text(
                          hint,
                          style: TextStyle(
                            color: HexColor("#999999"),
                            fontSize: 14,
                          ),
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
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 16,
          ),
          Text(
            '费率',
            style: TextStyle(
              fontSize: 14,
            ),
          ),
          SizedBox(
            height: 16,
          ),
          Container(
            height: 42,
            child: RoundBorderTextField(
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
          ),
          SizedBox(
            height: 16,
          ),
          Row(
            children: <Widget>[
              Text(
                '最大费率',
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
              SizedBox(
                width: 4,
              ),
              Text(
                '(设置过后不可以更改)',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              )
            ],
          ),
          SizedBox(
            height: 16,
          ),
          Container(
            height: 42,
            child: RoundBorderTextField(
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
          ),
          SizedBox(
            height: 16,
          ),
          Row(
            children: <Widget>[
              Text(
                '费率幅度',
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
              SizedBox(
                width: 4,
              ),
              Text(
                '(设置过后不可以更改)',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              )
            ],
          ),
          SizedBox(
            height: 16,
          ),
          Container(
            height: 42,
            child: RoundBorderTextField(
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
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 16,
          ),
          Text(
            'bls key',
            style: TextStyle(
              fontSize: 14,
            ),
          ),
          SizedBox(
            height: 16,
          ),
          Container(
            height: 42,
            child: RoundBorderTextField(
              onChanged: (text) {
                setState(() {
                  _createAtlasPayLoad.blsAddKey = text;
                });
              },
              controller: _blsKeyTextController,
              isDense: false,
            ),
          ),
          SizedBox(
            height: 16,
          ),
          Row(
            children: <Widget>[
              Text(
                'bls签名',
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
              SizedBox(
                width: 4,
              ),
              Text(
                '(设置过后不可以更改)',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              )
            ],
          ),
          SizedBox(
            height: 16,
          ),
          Container(
            height: 42,
            child: RoundBorderTextField(
              onChanged: (text) {
                setState(() {
                  _createAtlasPayLoad.blsAddSign = text;
                });
              },
              controller: _blsSignTextController,
              isDense: false,
            ),
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
      if (_createAtlasPayLoad.map3Address != null) {
        var selectedMap3NameEncoded = FluroConvertUtils.fluroCnParamsEncode(
          _map3NodeList[_selectedMap3NodeIndex]?.name,
        );
        Application.router.navigateTo(
          context,
          Routes.atlas_create_node_info_page +
              '?createAtlasPayload=${FluroConvertUtils.object2string(_createAtlasPayLoad)}&selectedMap3NodeName=$selectedMap3NameEncoded',
        );
      } else {
        Fluttertoast.showToast(msg: '请先选择Map3节点');
      }
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
            width: 200,
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

enum Step { launch, info, fee, bls }
