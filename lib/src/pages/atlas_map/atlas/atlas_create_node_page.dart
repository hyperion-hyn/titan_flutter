import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/pages/atlas_map/atlas/atlas_create_info_page.dart';
import 'package:titan/src/pages/node/map3page/map3_node_pronounce_page.dart';
import 'package:titan/src/pages/wallet/wallet_setting.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/widget/click_oval_button.dart';
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

  int _currentIndex;
  var _localImagePath = "";
  List<String> _detailList = [
    "",
    "派大星",
    "PB2020",
    "www.hyn.space",
    "12345678901",
    "HYN加油"
  ];

  bool _canProceedNextStep = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Column(
            children: <Widget>[
              _appBar(),
              _currentStep == Step.launch ? _launchTutorial() : _nodeSetup(),
            ],
          ),
        ),
      ),
    );
  }

  _appBar() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        Expanded(
          child: Text(
            '创建ATLAS节点',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
            ),
            textAlign: TextAlign.start,
          ),
        ),
        Padding(
            padding: EdgeInsets.all(16.0),
            child: InkWell(
              onTap: () {},
              child: Text(
                '介绍文档',
                style: TextStyle(
                  color: Colors.blue,
                ),
              ),
            ))
      ],
    );
  }

  _steps() {
    return Row(
      children: <Widget>[
        InkWell(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                Text(
                  '启动节点',
                  style: TextStyle(
                    fontWeight: _currentStep == Step.launch
                        ? FontWeight.bold
                        : FontWeight.w400,
                  ),
                ),
                SizedBox(
                  height: 16.0,
                ),
                Text(
                  '第一步',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                )
              ],
            ),
          ),
          onTap: () {
            setState(() {
              _currentStep = Step.launch;
            });
          },
        ),
        InkWell(
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                Text(
                  '完善设置',
                  style: TextStyle(
                    fontWeight: _currentStep != Step.launch
                        ? FontWeight.bold
                        : FontWeight.w400,
                  ),
                ),
                SizedBox(
                  height: 16.0,
                ),
                Text(
                  '第二步',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  _launchTutorial() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _steps(),
          _divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32.0),
            child: Image.asset(
              'res/drawable/ic_computer.png',
              width: 100,
              height: 83,
            ),
          ),
          Container(
            width: 350,
            child: Text(
              '请在电脑端按照文档指示启动一个Atlas节点，启动之后，你会获得一个bls key，然后进入下一步操作',
              style: TextStyle(height: 1.8),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32.0),
            child: InkWell(
              child: Text(
                '前往操作>>',
                style: TextStyle(
                  color: Colors.blue,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              '已启动且有bls key，直接下一步',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          ClickOvalButton('下一步', () {
            setState(() {
              _currentStep = Step.info;
            });
          })
        ],
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
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
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
    var _selectedMap3NodeValue = 'map3Node1';
    List<DropdownMenuItem> _map3NodeItems = List();
    _map3NodeItems.add(
      DropdownMenuItem(
        value: 'map3Node1',
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
        value: 'map3Node2',
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
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
            ),
            child: DropdownButtonFormField(
              decoration: InputDecoration(
                  filled: true,
                  fillColor: HexColor('#FFF2F2F2'),
                  border: InputBorder.none),
              onChanged: (value) {
                setState(() {
                  _selectedMap3NodeValue = value;
                });
              },
              value: _selectedMap3NodeValue,
              items: _map3NodeItems,
            ),
          )
        ],
      ),
    );
  }

  _basicInfo() {
    return ListView.separated(
      itemBuilder: (context, index) {
        var title = "图标";
        var subTitle = "（选填）";
        var detail = "";

        switch (index) {
          case 0:
            title = "图标";
            subTitle = "";
            detail = _localImagePath.isEmpty ? "请编辑节点Icon" : "";

            break;

          case 1:
            title = "名称";
            subTitle = "";
            detail = "派大星";
            break;

          case 2:
            title = "节点号";
            subTitle = "";
            detail = "PB2020";
            break;

          case 3:
            title = "网址";
            subTitle = "（选填）";
            detail = "www.hyn.space";
            break;

          case 4:
            title = "安全联系";
            subTitle = "（选填）";
            detail = "17876894078";
            break;

          case 5:
            title = "描述";
            subTitle = "";
            detail = "大家快来参与我的节点吧";
            break;
        }

        detail = _detailList[index];

        return Material(
          child: Ink(
            child: InkWell(
              splashColor: Colors.blue,
              onTap: () async {
                if (index == 0) {
                  EditIconSheet(context, (path) {
                    setState(() {
                      _localImagePath = path;
                    });
                  });
                  return;
                }
                _currentIndex = index;
                String text = await Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            Map3NodePronouncePage(
                              title: title,
                            )));
                if (text.isNotEmpty) {
                  setState(() {
                    _detailList[index] = text;
                  });
                }
              },
              child: Container(
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: detail.isNotEmpty ? 18 : 14, horizontal: 14),
                  child: Row(
                    children: <Widget>[
                      Text(
                        title,
                        style:
                            TextStyle(color: HexColor("#333333"), fontSize: 16),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Text(
                          subTitle,
                          style: TextStyle(
                              color: HexColor("#999999"), fontSize: 12),
                        ),
                      ),
                      Spacer(),
                      detail.isNotEmpty
                          ? Text(
                              detail,
                              style: TextStyle(
                                  color: HexColor("#999999"), fontSize: 14),
                            )
                          : Image.asset(
                              _localImagePath ??
                                  "res/drawable/ic_map3_node_item_2.png",
                              width: 36,
                              height: 36,
                              fit: BoxFit.cover,
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
            ),
          ),
        );
      },
      separatorBuilder: (context, index) {
        return Divider(
          height: 0.5,
          color: HexColor("#F2F2F2"),
        );
      },
      itemCount: _detailList.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
    );
  }

  _fees() {
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
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
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
          ),
        ],
      ),
    );
  }

  _bls() {
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
          Text('设置bls key'),
          SizedBox(
            height: 16,
          ),
          new RoundBorderTextField(
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
          ),
          SizedBox(
            height: 16,
          ),
          Row(
            children: <Widget>[
              Text('设置bls签名'),
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
          new RoundBorderTextField(
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
          ),
          SizedBox(
            height: 16,
          ),
        ],
      ),
    );
  }

  _checkCanProceedNextStep() {
    return false;
  }

  _nextStep() {
    if (_currentStep == Step.info) {
      _currentStep = Step.fee;
    } else if (_currentStep == Step.fee) {
      _currentStep = Step.bls;
    } else if (_currentStep == Step.bls) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AtlasCreateInfoPage()),
      );
    }
    setState(() {});
  }

  _lastStep() {
    return InkWell(
      child: Text('上一步'),
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
    );
  }

  _bottomButton() {
    return Container(
      width: 200,
      height: 38,
      child: RaisedButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        disabledColor: HexColor('#dedede'),
        color: Theme.of(context).primaryColor,
        textColor: Colors.white,
        disabledTextColor: HexColor('#FFFFFFFF'),
        onPressed: _canProceedNextStep ? _nextStep : null,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                _currentStep != Step.bls ? '下一步' : '提交',
                style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _divider() {
    return Container(
      height: 16,
      color: Colors.grey[200],
    );
  }
}

enum Step { launch, info, fee, bls }
