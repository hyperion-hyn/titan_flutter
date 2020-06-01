import 'dart:convert';

import 'package:custom_radio_grouped_button/CustomButtons/CustomRadioButton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_picker/Picker.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/pages/node/widget/custom_stepper.dart';
import 'package:titan/src/widget/picker_data/PickerData.dart';

class TestWidgetPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TestWidgetPageState();
  }
}

class _TestWidgetPageState extends State<TestWidgetPage> with TickerProviderStateMixin {
  TabController _tabController;
  String radioValue = "First";
  List<String> tabStrList = ["请选择"];
  List<List<String>> testStrList = [
    ["哈哈哈", "哈哈哈", "哈哈哈", "哈哈哈"],
    ["嗯嗯嗯", "嗯嗯嗯", "嗯嗯嗯", "嗯嗯嗯"]
  ];
//  RadioBuilder<String, double> simpleBuilder;
  StateSetter businessSheetState;

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
        body: ListView(shrinkWrap: true, padding: EdgeInsets.all(16), children: <Widget>[
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
              showVerifySite();
            },
            child: Text('校验地点'),
          ),
          Divider(
            height: 16,
          ),
          RaisedButton(
            onPressed: () async {

            },
            child: Text('其他'),
          ),
          Divider(
            height: 16,
          )
        ]));
  }

  void showPub() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context1, sheetState) {
            return Column(children: <Widget>[
              Text("选择分类"),
              Container(
                alignment: Alignment.centerLeft,
                child: TabBar(
                  controller: _tabController,
                  labelColor: Colors.black,
                  isScrollable: true,
                  labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
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
                      _tabController = new TabController(vsync: this, length: tabStrList.length);
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
    /*showModalBottomSheet(context: context, backgroundColor: Colors.transparent, builder: (context) {
      return Material(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
          child: Container(
            padding: const EdgeInsets.only(top: 4),
            child: getBusinessTimeGap(),
          )
      );
    });*/

    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Column(
            children: <Widget>[
              Text("营业日"),
              getBusinessDay(),
              Text("营业时段"),
              getBusinessTimeGap()
            ],
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
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return CustomStepper(
            steps: ['提交任务', '本金返款', '评价返佣金', '追评返佣金', '任务完结', '追评返佣金', '任务完结', '追评返佣金', '任务完结']
                .map(
                  (s) => CustomStep(title: Text(s), content: Container(), isActive: true),
                )
                .toList(),
            type: CustomStepperType.horizontal,
          );
        });
  }

  Widget getBusinessDay() {
    return CustomRadioButton(
      enableShape: true,
      customShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      buttonColor: Theme.of(context).canvasColor,
      buttonLables: [
        "Student",
        "Parent/Teacher",
      ],
      buttonValues: [
        "STUDENT",
        "TEACHER",
      ],
      radioButtonValue: (value) => print(value),
      selectedColor: Theme.of(context).accentColor,
    );
    /*return StatefulBuilder(builder: (context1, sheetState) {
      businessSheetState = sheetState;
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CustomRadio<String, double>(
              value: 'First',
              groupValue: radioValue,
              duration: Duration(milliseconds: 500),
              animsBuilder: (AnimationController controller) =>
                  [CurvedAnimation(parent: controller, curve: Curves.easeInOut)],
              builder: simpleBuilder),
          CustomRadio<String, double>(
              value: 'Second',
              groupValue: radioValue,
              duration: Duration(milliseconds: 500),
              animsBuilder: (AnimationController controller) =>
                  [CurvedAnimation(parent: controller, curve: Curves.easeInOut)],
              builder: simpleBuilder),
          CustomRadio<String, double>(
              value: 'Third',
              groupValue: radioValue,
              duration: Duration(milliseconds: 500),
              animsBuilder: (AnimationController controller) =>
                  [CurvedAnimation(parent: controller, curve: Curves.easeInOut)],
              builder: simpleBuilder),
        ],
      );
    });*/
  }

  Widget getBusinessTimeGap(){
    return Padding(
      padding: const EdgeInsets.only(left:20,right: 20),
      child: Picker(
          adapter: PickerDataAdapter<String>(
            pickerdata: JsonDecoder().convert(TimePickerData),
            isArray: true,
          ),
          delimiter: [
            PickerDelimiter(column: 2, child: Container(
              width: 100.0,
              alignment: Alignment.center,
              child: Text('至', style: TextStyle(fontWeight: FontWeight.bold)),
              color: Colors.white,
            ))
          ],
          hideHeader: true,
          selecteds: [3, 0, 2, 0],
          title: Text("Please Select"),
          selectedTextStyle: TextStyle(color: Colors.blue),
          cancel: FlatButton(onPressed: () {
            Navigator.pop(context);
          }, child: Icon(Icons.child_care)),
          onConfirm: (Picker picker, List value) {
            print(value.toString());
            print(picker.getSelectedValues());
          }
      ).makePicker(null, true),
    );
  }

  showPickerNumber(BuildContext context) {
    Picker(
        adapter: NumberPickerAdapter(data: [
          NumberPickerColumn(begin: 0, end: 999, postfix: Text("\$"), suffix: Icon(Icons.insert_emoticon)),
          NumberPickerColumn(begin: 200, end: 100, jump: -10),
          NumberPickerColumn(begin: 200, end: 100, jump: -10),
        ]),
        delimiter: [
          PickerDelimiter(child: Container(
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
        }
    ).showDialog(context);
  }
}
