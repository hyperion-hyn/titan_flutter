import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/pages/me/mortgage_page.dart';
import 'package:titan/src/pages/me/node_mortgage/node_bloc/bloc.dart';
import 'package:titan/src/pages/me/node_mortgage/snap_up_bloc/bloc.dart';
import 'package:titan/src/pages/me/service/user_service.dart';

import '../model/mortgage_info_v2.dart';
import '../mortgage_snap_up_page.dart';
import 'snap_up_bloc/snap_up_state.dart';

class NodeMortgagePageV2 extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NodeMortgagePageV2();
  }
}

class _NodeMortgagePageV2 extends State<NodeMortgagePageV2> {
  UserService _userService = UserService();

  List<MortgageInfoV2> _mortgageList = [MortgageInfoV2(0, "", "", "", 0, "", 0, 0, 0)];

  int selectedIndex = 0;

  NumberFormat DOUBLE_NUMBER_FORMAT = new NumberFormat("#,###.#####");

  NodeBloc _nodeBloc;

  SnapUpBloc _snapUpBloc;

  @override
  void initState() {
    super.initState();
    _nodeBloc = NodeBloc(_userService);
    _nodeBloc.add(LoadNodes());

    _snapUpBloc = SnapUpBloc(_userService, _nodeBloc);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          brightness: Brightness.light,
          title: Text(
            S.of(context).node_martgage,
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: IconThemeData(color: Colors.white),
          centerTitle: true,
          elevation: 0,
        ),
        body: BlocBuilder<NodeBloc, NodeState>(
            bloc: _nodeBloc,
            builder: (BuildContext context, NodeState nodeState) {
              if (nodeState is LoadedState) {
                _mortgageList = nodeState.mortgageInfoList;
              } else if (nodeState is NodeSwitchedState) {
                selectedIndex = nodeState.index;
              }

              return BlocBuilder<SnapUpBloc, SnapUpState>(
                  bloc: _snapUpBloc,
                  builder: (BuildContext context, SnapUpState snapUpState) {
                    if (snapUpState is SnapUpOverRangeState) {
                      Fluttertoast.showToast(msg: S.of(context).node_has_squat_hint);
                    }

                    if (snapUpState is SnapSuccessState) {
                      _snapUpBloc.add(ResetToInit());
                      SchedulerBinding.instance.addPostFrameCallback((_) {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => MortgageSnapUpPage(_mortgageList[selectedIndex])));
                        return;
                      });
                    }

                    return Stack(
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Expanded(
                              flex: 2,
                              child: Container(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            Expanded(
                              flex: 8,
                              child: Container(),
                            ),
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            Material(
                              child: Container(
                                color: Color(0xFFFFF8EA),
                                child: Row(
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      child: Text(
                                        S.of(context).node_mortgage_in_out_hint,
                                        style: TextStyle(color: Color(0xFFCE9D40)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: Container(
                                child: CarouselSlider(
                                  onPageChanged: _onPageChanged,
                                  height: 280.0,
                                  enlargeCenterPage: true,
                                  items: _mortgageList.map((_mortgageInfoTemp) {
                                    return Builder(
                                      builder: (BuildContext context) {
                                        return Container(
                                            width: MediaQuery.of(context).size.width,
                                            margin: EdgeInsets.symmetric(horizontal: 5.0),
                                            padding: EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                                color: Colors.white, borderRadius: BorderRadius.circular(16)),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Expanded(
                                                  child: Center(
                                                    child: Image.network(
                                                      _mortgageInfoTemp.icon,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 16,
                                                ),
                                                Row(
                                                  children: <Widget>[
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: <Widget>[
                                                        Text(
                                                          _mortgageInfoTemp.name,
                                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                                        ),
                                                        Row(
                                                          children: <Widget>[
                                                            Text(
                                                              DOUBLE_NUMBER_FORMAT.format(_mortgageInfoTemp.amount),
                                                              style: TextStyle(
                                                                  color: Color(0xFFf6927f),
                                                                  fontSize: 18,
                                                                  fontWeight: FontWeight.bold),
                                                            ),
                                                            Text(
                                                              " USDT",
                                                              style: TextStyle(
                                                                color: Color(0xFFf6927f),
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                    Spacer(),
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: <Widget>[
                                                        Text(
                                                          S.of(context).income_func(
                                                              '${_mortgageList[selectedIndex].incomeCycle}'),
                                                          style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                                                        ),
                                                        Row(
                                                          children: <Widget>[
                                                            Text(
                                                              _mortgageList[selectedIndex].incomeRate,
                                                              style: TextStyle(
                                                                  color: Color(0xFFf6927f),
                                                                  fontSize: 18,
                                                                  fontWeight: FontWeight.bold),
                                                            ),
//                                                            Text("")
                                                          ],
                                                        )
                                                      ],
                                                    )
                                                  ],
                                                )
                                              ],
                                            ));
                                      },
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: Container(
                                margin: EdgeInsets.only(left: 32, right: 32, bottom: 16, top: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Text(
                                          S.of(context).node_introduction,
                                          style:
                                              TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Expanded(
                                      child: SingleChildScrollView(
                                        child: Text(
                                          _mortgageList[selectedIndex].description,
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        Expanded(
                                          child: RaisedButton(
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                            color: Theme.of(context).primaryColor,
                                            onPressed: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) => MortgagePage(
                                                            _mortgageList[selectedIndex],
                                                          )));
                                            },
                                            child: Container(
                                              height: 48,
                                              alignment: Alignment.center,
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 8),
                                                child: Text(
                                                  S.of(context).mortgage,
                                                  style: TextStyle(
                                                      color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 16,
                                        ),
                                        Expanded(
                                          child: RaisedButton(
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                            color: Color(0xFFBF3330),
                                            onPressed: snapUpState is SnapUpIngState
                                                ? null
                                                : (_mortgageList[selectedIndex].snapUpStocks == 0 ? null : snapUpOnTap),
                                            child: Container(
                                              height: 48,
                                              alignment: Alignment.center,
                                              child: Padding(
                                                padding: const EdgeInsets.only(left: 0, top: 8, bottom: 8, right: 0),
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    Text(
                                                      S.of(context).cybersquatting,
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.bold),
                                                    ),
                                                    Text(
                                                      S
                                                          .of(context)
                                                          .stay_func('${_mortgageList[selectedIndex].snapUpStocks}'),
                                                      style: TextStyle(
                                                          color: Color(0xFFFFC500),
                                                          fontSize: SettingInheritedModel.of(context)
                                                                      .languageModel
                                                                      .locale
                                                                      ?.languageCode
                                                                      ?.startsWith('ko') ==
                                                                  true
                                                              ? 8
                                                              : 12,
                                                          fontWeight: FontWeight.normal),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    );
                  });
            }));
  }

  Future _onPageChanged(int index) {
    _nodeBloc.add(SwitchNode(index));
  }

  void snapUpOnTap() async {
    _snapUpBloc.add(SnapUpNode(selectedIndex));
  }
}
