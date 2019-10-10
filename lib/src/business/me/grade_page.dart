import 'package:flutter/material.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/business/me/model/user_level_info.dart';
import 'package:titan/src/business/me/service/user_service.dart';
import 'package:titan/src/consts/consts.dart';
import 'package:titan/src/global.dart';

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
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          title: Text("等级"),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Row(
                children: <Widget>[
                  Text(
                    "当前等级",
                    style: TextStyle(color: Colors.black54),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Text(
                      LOGIN_USER_INFO.level,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
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
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.rectangle),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              level,
              style: TextStyle(fontSize: 16),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                  width: 40,
                  child: Text(
                    "奖励",
                    style: TextStyle(color: Colors.black54),
                  )),
              Text(
                "$award",
              )
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                  width: 40,
                  child: Text(
                    "要求",
                    style: TextStyle(color: Colors.black54),
                  )),
              Text(
                "$require",
              )
            ],
          ),
        ],
      ),
    );
  }

  Future _getUserLevelList() async {
    _userLevelInfoList = await _userService.getUserLevelInfoList();

    setState(() {});
  }
}
