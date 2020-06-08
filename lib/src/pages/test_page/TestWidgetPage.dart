import 'dart:convert';

import 'package:custom_radio_grouped_button/CustomButtons/CustomRadioButton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import 'package:flutter_picker/Picker.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/contribution/add_poi/position_finish_page.dart';
import 'package:titan/src/pages/contribution/contribution_finish_page.dart';
import 'package:titan/src/pages/contribution/new_poi/add_poi_done_page.dart';
import 'package:titan/src/pages/contribution/new_poi/add_poi_page.dart';
import 'package:titan/src/pages/contribution/new_poi/contributor_mortgage_page.dart';
import 'package:titan/src/pages/contribution/new_poi/request_mortgage_page.dart';
import 'package:titan/src/pages/contribution/new_poi/contributor_mortgage_broadcast_done_page.dart';
import 'package:titan/src/pages/contribution/new_poi/verify_poi_done_page.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/click_oval_button.dart';
import 'package:titan/src/widget/click_rectangle_button.dart';
import 'package:titan/src/widget/picker_data/PickerData.dart';
import 'package:titan/src/widget/stepper/poi_stepper.dart';

class TestWidgetPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TestWidgetPageState();
  }
}

class _TestWidgetPageState extends State<TestWidgetPage>
    with TickerProviderStateMixin {
  TabController _tabController;
  String radioValue = "First";
  List<String> tabStrList = ["请选择"];
  List<List<String>> testStrList = [
    ["哈哈哈", "哈哈哈", "哈哈哈", "哈哈哈"],
    ["嗯嗯嗯", "嗯嗯嗯", "嗯嗯嗯", "嗯嗯嗯"]
  ];

//  RadioBuilder<String, double> simpleBuilder;
  StateSetter businessSheetState;

  bool _is24hrsOpen = false;
  int current_step = 0;

  List<PoiStep> verify_steps = [
    PoiStep(
      title: Text("名称"),
      content: Column(
        children: <Widget>[
          Text.rich(
            TextSpan(
              children: <TextSpan>[
                TextSpan(
                    text: '地图上的 ',
                    style: TextStyle(fontStyle: FontStyle.normal)),
                TextSpan(
                    text: '天河城广场',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                TextSpan(
                    text: ' 地点存在吗',
                    style: TextStyle(fontStyle: FontStyle.normal)),
              ],
            ),
          ),
        ],
      ),
      isActive: true,
    ),
    PoiStep(
      title: Text("位置"),
      content: Column(
        children: <Widget>[
          Text.rich(
            TextSpan(
              children: <TextSpan>[
                TextSpan(
                    text: '地图上的 ',
                    style: TextStyle(fontStyle: FontStyle.normal)),
                TextSpan(
                    text: '天河城广场',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                TextSpan(
                    text: ' 地点准确吗',
                    style: TextStyle(fontStyle: FontStyle.normal)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              children: <Widget>[
                RadioListTile(
                  title: Text('准确'),
                  onChanged: (value) {},
                  value: 1,
                  groupValue: null,
                ),
                RadioListTile(
                  title: Text('不准确'),
                  onChanged: (value) {},
                  value: 2,
                  groupValue: null,
                )
              ],
            ),
          )
        ],
      ),
      isActive: true,
    ),
    PoiStep(
      title: Text("类别"),
      content: Column(
        children: <Widget>[
          Text.rich(
            TextSpan(
              children: <TextSpan>[
                TextSpan(
                    text: '该地点的类别是 ',
                    style: TextStyle(fontStyle: FontStyle.normal)),
                TextSpan(
                    text: '美食-中国餐',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                TextSpan(
                    text: ' 吗', style: TextStyle(fontStyle: FontStyle.normal)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              children: <Widget>[
                RadioListTile(
                  title: Text('是'),
                  onChanged: (value) {},
                  value: 1,
                  groupValue: null,
                ),
                RadioListTile(
                  title: Text('否'),
                  onChanged: (value) {},
                  value: 2,
                  groupValue: null,
                )
              ],
            ),
          )
        ],
      ),
      isActive: true,
    ),
    PoiStep(
      title: Text('图片'),
      content: Column(
        children: <Widget>[
          Text('以下图片是否是该地点的现场照片？'),
          Image.asset("res/drawable/atlas_logo.png"),
          RadioListTile(
            title: Text('是'),
            onChanged: (value) {},
            value: 1,
            groupValue: null,
          ),
          RadioListTile(
            title: Text('否'),
            onChanged: (value) {},
            value: 2,
            groupValue: null,
          )
        ],
      ),
      isActive: true,
    ),
    PoiStep(
      title: Text("该地点的营业时间是以下的时间段吗?"),
      content: Column(
        children: <Widget>[
          RadioListTile(
            title: Text('是'),
            onChanged: (value) {},
            value: 1,
            groupValue: null,
          ),
          RadioListTile(
            title: Text('否'),
            onChanged: (value) {},
            value: 2,
            groupValue: null,
          )
        ],
      ),
      isActive: true,
    ),
  ];

  @override
  void initState() {
    _tabController = new TabController(vsync: this, length: tabStrList.length);

    /*simpleBuilder = (BuildContext context, List<double> animValues, Function updateState, String value) {
      final alpha = (animValues[0] * 255).toInt();
      return GestureDetector(
          onTap: () {
            if (businessSheetState != null) {
              businessSheetState(() {
                radioValue = value;
              });
            }
          },
          child: Container(
              padding: EdgeInsets.all(32.0),
              margin: EdgeInsets.symmetric(horizontal: 2.0, vertical: 12.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).primaryColor.withAlpha(alpha),
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withAlpha(255 - alpha),
                    width: 4.0,
                  )),
              child: Text(
                value,
                style: Theme.of(context).textTheme.body1.copyWith(fontSize: 20.0),
              )));
    };*/
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Wallet Demo1"),
        ),
        body: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.all(16),
            children: <Widget>[
              RaisedButton(
                onPressed: () async {
                  showPub();
                },
                child: Text('选择类型'),
              ),
              Divider(
                height: 16,
              ),
              RaisedButton(
                onPressed: () async {
                  showBusinessTime();
                },
                child: Text('营业时间'),
              ),
              Divider(
                height: 16,
              ),
              RaisedButton(
                onPressed: () async {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AddPoiPage()));
                },
                child: Text('添加poi页'),
              ),
              Divider(
                height: 16,
              ),
              RaisedButton(
                onPressed: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddPOIDonePage()));
                },
                child: Text('添加poi成功页'),
              ),
              Divider(
                height: 16,
              ),
              RaisedButton(
                onPressed: () async {
                  showVerifySite();
                },
                child: Text('校验poi'),
              ),
              Divider(
                height: 16,
              ),
              RaisedButton(
                onPressed: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => VerifyPOIDonePage()));
                },
                child: Text('校验poi成功页'),
              ),
              Divider(
                height: 16,
              ),
              RaisedButton(
                onPressed: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ContributorMortgagePage()));
                },
                child: Text('贡献者的抵押'),
              ),
              Divider(
                height: 16,
              ),
              RaisedButton(
                onPressed: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RequestMortgagePage()));
                },
                child: Text('数据贡献者申请抵押'),
              ),
              Divider(
                height: 16,
              ),
              RaisedButton(
                onPressed: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ContributorMortgageBroadcastDonePage()));
                },
                child: Text('抵押广播成功页'),
              ),
              Divider(
                height: 16,
              ),
              RaisedButton(
                onPressed: () async {
                  _showKChart();
                },
                child: Text('K线图'),
              ),
              Divider(
                height: 16,
              ),
              RaisedButton(
                onPressed: () async {
                  _showVerifyConfirmDialog(context);
                },
                child: Text('其他'),
              ),
              Divider(
                height: 16,
              )
            ]));
  }

  _showKChart() {
    var option = '''
 {
    backgroundColor: '#21202D',
    legend: {
        data: ['日K'],
        inactiveColor: '#777',
        textStyle: {
            color: '#fff'
        }
    },
    tooltip: {
        trigger: 'axis',
        axisPointer: {
            animation: false,
            type: 'cross',
            lineStyle: {
                color: '#376df4',
                width: 2,
                opacity: 1
            }
        }
    },
    xAxis: {
        type: 'category',
        data: ['2015/12/31', '2015/12/31'],
        axisLine: { lineStyle: { color: '#8392A5' } }
    },
    yAxis: {
        scale: true,
        axisLine: { lineStyle: { color: '#8392A5' } },
        splitLine: { show: false }
    },
    grid: {
        bottom: 80
    },
    dataZoom: [{
        textStyle: {
            color: '#8392A5'
        },
        handleIcon: 'M10.7,11.9v-1.3H9.3v1.3c-4.9,0.3-8.8,4.4-8.8,9.4c0,5,3.9,9.1,8.8,9.4v1.3h1.3v-1.3c4.9-0.3,8.8-4.4,8.8-9.4C19.5,16.3,15.6,12.2,10.7,11.9z M13.3,24.4H6.7V23h6.6V24.4z M13.3,19.6H6.7v-1.4h6.6V19.6z',
        handleSize: '80%',
        dataBackground: {
            areaStyle: {
                color: '#8392A5'
            },
            lineStyle: {
                opacity: 0.8,
                color: '#8392A5'
            }
        },
        handleStyle: {
            color: '#fff',
            shadowBlur: 3,
            shadowColor: 'rgba(0, 0, 0, 0.6)',
            shadowOffsetX: 2,
            shadowOffsetY: 2
        }
    }, {
        type: 'inside'
    }],
    animation: false,
    series: [
        {
            type: 'candlestick',
            name: '日K',
            data: [['2015/12/31','3570.47','3539.18','-33.69','-0.94%','3538.35','3580.6','176963664','25403106','-'],['2015/12/30','3566.73','3572.88','9.14','0.26%','3538.11','3573.68','187889600','26778766','-']],
            itemStyle: {
                color: '#FD1050',
                color0: '#0CF49B',
                borderColor: '#FD1050',
                borderColor0: '#0CF49B'
            }
        }
    ]
}



''';
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return Echarts(
            option: option,
          );
        });
  }

  void _showVerifyConfirmDialog(context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('提交提示'),
            content: Wrap(
              children: <Widget>[
                Text(
                  '请确定你已如实回答校验问题。',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '本次校验将会冻结你的10个积分，如果社区博弈结果和你回答的吻合，将会解除冻结并额外奖励10个积分，否将没收冻结的积分！',
                  style: TextStyle(fontSize: 14),
                )
              ],
            ),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(S.of(context).cancel)),
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(S.of(context).confirm))
            ],
          );
        },
        barrierDismissible: true);
  }

  void showPub() {
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
                      tabs: getTabList(),
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: getTabContentList(() {
                        sheetState(() {
                          _tabController = new TabController(
                              vsync: this, length: tabStrList.length);
                          _tabController.animateTo(1);
                        });
                      }),
                    ),
                  ),
                ]);
          });
        });
  }

  void showBusinessTime() {
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
                getBusinessDay(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text("营业时段"),
                ),
                getBusinessTimeGap(),
                Checkbox(
                  value: _is24hrsOpen,
                  onChanged: (value) {
                    setState(() {
                      _is24hrsOpen = value;
                    });
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

  List<Tab> getTabList() {
    List<Tab> tabWidgetList = [];
    tabStrList.forEach((element) {
      tabWidgetList.add(Tab(
        text: element,
      ));
    });
    return tabWidgetList;
  }

  List<ListView> getTabContentList(Function refresh) {
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
        tabContentListView.add(ListView(
          children: textList,
        ));
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

  void showVerifySite() {
    /*showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return CustomStepper(
            steps: ['提交任务', '本金返款', '评价返佣金', '追评返佣金', '任务完结', '追评返佣金', '任务完结']
                .map(
                  (s) => CustomStep(title: Text(s), content: Container(), isActive: true),
                )
                .toList(),
            type: CustomStepperType.horizontal,
          );
        });*/
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context1, sheetState) {
            return new Container(
              child: new PoiStepper(
                currentStep: this.current_step,
                steps: verify_steps,
                type: PoiStepperType.vertical,
//                onStepTapped: (step) {
//                  sheetState(() {
//                    current_step = step;
//                  });
//                },
                onStepCancel: () {
                  sheetState(() {
                    if (current_step > 0) {
                      current_step = current_step - 1;
                    } else {
                      current_step = 0;
                    }
                  });
                },
                onStepContinue: () {
                  sheetState(() {
                    if (current_step < verify_steps.length - 1) {
                      current_step = current_step + 1;
                    } else {
                      current_step = 0;
                    }
                  });
                },
              ),
            );
          });
        });
  }

  Widget getBusinessDay() {
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

  showPickerNumber(BuildContext context) {
    Picker(
        adapter: NumberPickerAdapter(data: [
          NumberPickerColumn(
              begin: 0,
              end: 999,
              postfix: Text("\$"),
              suffix: Icon(Icons.insert_emoticon)),
          NumberPickerColumn(begin: 200, end: 100, jump: -10),
          NumberPickerColumn(begin: 200, end: 100, jump: -10),
        ]),
        delimiter: [
          PickerDelimiter(
              child: Container(
            width: 30.0,
            alignment: Alignment.center,
            child: Icon(Icons.more_vert),
          ))
        ],
        hideHeader: true,
        title: Text("Please Select"),
        selectedTextStyle: TextStyle(color: Colors.blue),
        onConfirm: (Picker picker, List value) {
          print(value.toString());
          print(picker.getSelectedValues());
        }).showDialog(context);
  }
}
