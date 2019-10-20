import 'package:flutter/material.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/business/me/model/user_level_info.dart';
import 'package:titan/src/business/me/service/user_service.dart';
import 'package:titan/src/consts/consts.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/presentation/extends_icon_font.dart';

class GradePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _GradeState();
  }
}

class _GradeState extends State<GradePage> {
  UserService _userService = UserService();

  List<UserLevelInfo> _userLevelInfoList = [];

  @override
  void initState() {
    _getUserLevelList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
//          backgroundColor: Colors.white,
          title: Text(
            "等级",
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
          elevation: 0,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Material(
                elevation: 3,
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 24, horizontal: 24),
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "当前等级",
                        style: TextStyle(color: Color(0xFF9B9B9B), fontSize: 14),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        LOGIN_USER_INFO.level==""?"无等级":LOGIN_USER_INFO.level,
                        style: TextStyle(fontSize: 16, color: Color(0xFF3C94FF)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
//            Padding(
//              padding: const EdgeInsets.all(16.0),
//              child: Text('等级说明', style: TextStyle(color: Colors.grey[600]),),
//            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: ListView.separated(
                  itemBuilder: (context, index) {
                    var levelInfo = _userLevelInfoList[index];
                    return _buildGrade(levelInfo.name,
                        "${Const.DOUBLE_NUMBER_FORMAT.format(levelInfo.rewardRate * 100)}%", levelInfo.description);
                  },
                  itemCount: _userLevelInfoList.length,
                  separatorBuilder: (BuildContext context, int index) {
                    return Divider(
                      height: 0,
                      thickness: 0.5,
                    );
                  },
                ),
              ),
            )
          ],
        ));
  }

  Widget _buildGrade(String level, String award, String require) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.rectangle),
      child: Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        columnWidths: {
          0: FractionColumnWidth(0.1),
          1: FractionColumnWidth(0.9),
        },
        children: [
          TableRow(children: [
            Center(
              child: Icon(
                ExtendsIconFont.dot,
                color: Color(0xFF252525),
                size: 20,
              ),
            ),
            Text(
              level,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ]),
          TableRow(children: [
            Container(),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                "奖励： $award",
                style: TextStyle(color: Color(0xFF6D6D6D)),
              ),
            ),
          ]),
          TableRow(children: [
            Container(),
            Text(
              "要求： $require",
              style: TextStyle(color: Color(0xFF6D6D6D)),
            ),
          ])
        ],
      ),
    );
  }

  Future _getUserLevelList() async {
    _userLevelInfoList = await _userService.getUserLevelInfoList();

    setState(() {});
  }
}
