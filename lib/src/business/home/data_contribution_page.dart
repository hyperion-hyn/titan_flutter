import 'package:flutter/material.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/business/home/contribution_page.dart';

class DataContributionPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _DataContributionState();
  }
}

class _DataContributionState extends State<DataContributionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          "数据贡献",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: ListView(
        children: <Widget>[
          _wallet(),
          _divider(),
          _buildItem('signal', '扫描附近信号数据', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ContributionPage(),
              ),
            );
          }, isOpen: true),
          _divider(),
          _buildItem('position', '添加地理位置信息', () {}),
          _divider(),
          _buildItem('check', '校验地理位置信息', () {}),
          _divider(),
        ],
      ),
    );
  }

  Widget _wallet() {
    return Container(
      height: 80,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
              padding: const EdgeInsets.fromLTRB(15, 4, 10, 0),
              child: Image.asset(
                'res/drawable/data_contribution_wallet.png',
                width: 40,
                height: 40,
              )),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 14, 10, 12),
                child: GestureDetector(
                  onTap: () {
                    print('[data] --> 导入钱包');
                  },
                  child: Row(
                    children: <Widget>[
                      Text(
                        '创建/导入钱包',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontWeight: FontWeight.w500, color: HexColor('#333333')),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Text(
                          '即将开放',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: Color(0xFFF82530)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: <Widget>[
                  Text(
                    '将以“钱包”HYN地址身份贡献数据',
                    style: TextStyle(
                        fontWeight: FontWeight.normal,
                        color: HexColor('#333333'),
                        fontSize: 12),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: GestureDetector(
                      onTap: () {
                        print('[data] --> 切换主钱包');
                      },
                      child: Text(
                        '切换主钱包',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: HexColor('#333333')),
                      ),
                    ),
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildItem(String iconName, String title, Function ontap,
      {bool isOpen = false}) {
    return InkWell(
      onTap: ontap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
              padding: const EdgeInsets.fromLTRB(15, 12, 12, 12),
              child: Image.asset(
                'res/drawable/data_contribution_$iconName.png',
                width: 22,
                height: 22,
              )),
          Text(
            title,
            style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 14,
                color: HexColor('#333333')),
          ),
          Visibility(
            visible: !isOpen,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Text(
                '即将开放',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: Color(0xFFF82530)),
              ),
            ),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Icon(
              Icons.chevron_right,
              color: HexColor('#E9E9E9'),
            ),
          )
        ],
      ),
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 0.5,
        color: HexColor('#E9E9E9'),
      ),
    );
  }
}
