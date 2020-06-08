import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:titan/src/components/scaffold_map/scaffold_map.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/click_oval_button.dart';

class ContributorMortgagePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ContributorMortgagePageState();
  }
}

class ContributorAssets {
  var name = 'Lance';
  double totalHyn = 3100;
  var coins = 300;
  var quota = 10;
  double energy = 230;
  var hyn = 10;
  double mortgage = 3000;
  double notMortgagedReward = 1020;
  var contribute = 10;
  var lastReward = '昨日奖励 2HYN';
}

class _ContributorMortgagePageState extends State<ContributorMortgagePage> {
  ContributorAssets contributorAssets = ContributorAssets();
  var chartName = '全球杯周赛';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(
        children: <Widget>[
          _statusBarPadding(),
          _contributorAssets(),
          _globalChart(),
          _contributorTrophies(),
          _contributedPoiList(),
          _contributedRecords(),
          _bottomPadding()
        ],
      ),
    ));
  }

  _contributorAssets() {
    return Container(
      color: Theme.of(context).primaryColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    "res/drawable/map3_node_default_avatar.png",
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        'Lance',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    Container(
                      color: Colors.grey[400],
                      padding: EdgeInsets.all(4.0),
                      child: Text(
                        '贡献值 ${contributorAssets.contribute}',
                        style: TextStyle(color: Colors.grey[700], fontSize: 10),
                      ),
                    )
                  ],
                ),
                Spacer(),
                Row(
                  children: <Widget>[
                    Icon(Icons.account_balance_wallet),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '${contributorAssets.quota}',
                        maxLines: 2,
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  width: 8.0,
                ),
                Row(
                  children: <Widget>[
                    Icon(Icons.monetization_on),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '${FormatUtil.doubleFormatNum(contributorAssets.energy)}',
                        maxLines: 2,
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          Center(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.end,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.all(4.0),
                  padding: EdgeInsets.all(2.0),
                  color: Colors.grey[200],
                  child: Text(
                    ' 资产 ',
                    style: TextStyle(color: Colors.black, fontSize: 11),
                  ),
                ),
                Text.rich(
                  TextSpan(children: [
                    TextSpan(
                        text:
                            '${FormatUtil.doubleFormatNum(contributorAssets.totalHyn)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                          color: Colors.white,
                        )),
                    TextSpan(
                        text: ' HYN',
                        style: TextStyle(
                          color: Colors.white,
                        ))
                  ]),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              contributorAssets.lastReward,
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 13,
              ),
            ),
          ),
          SizedBox(
            height: 16.0,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: 32,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '抵押中（HYN）',
                      style: TextStyle(color: Colors.grey[300], fontSize: 13),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        '${FormatUtil.doubleFormatNum(contributorAssets.mortgage)}',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                width: 32,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '贡献奖励（HYN）',
                      style: TextStyle(color: Colors.grey[300], fontSize: 13),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.only(top: 8.0, bottom: 8.0, right: 8.0),
                      child: Row(
                        children: <Widget>[
                          Text(
                            '${FormatUtil.doubleFormatNum(contributorAssets.notMortgagedReward)}',
                            maxLines: 2,
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Spacer()
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                  child: Text(
                    '当前抵押权益：+1 地点 ≈ 0.1 HYN',
                    style: TextStyle(color: Colors.grey[300], fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('数据贡献细则>>',
                    style: TextStyle(
                      color: Colors.lightBlueAccent,
                    )),
              )
            ],
          )
        ],
      ),
    );
  }

  _globalChart() {
    return _cardView(
        'iconPath',
        chartName,
        ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (ctx, index) {
              return _contributorItem(index);
            }),
        () {},
        childHeight: 120);
  }

  _contributorItem(int index) {
    return Stack(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                "res/drawable/map3_node_default_avatar.png",
                width: 44,
                height: 44,
                fit: BoxFit.cover,
              ),
              Text(
                '第一名',
                style: TextStyle(fontSize: 14),
              ),
              Container(
                margin: EdgeInsets.all(4.0),
                padding: EdgeInsets.all(2.0),
                color: Colors.grey[200],
                child: Text(
                  ' +10 地点 ',
                  style: TextStyle(color: Colors.black, fontSize: 11),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: 12,
          top: 12,
          child: Text('${index + 1}'),
        )
      ],
    );
  }

  _contributorTrophies() {
    return _cardView(
        'iconPath',
        '我的奖杯',
        ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (ctx, index) {
              return _trophyItem();
            }),
        () {});
  }

  _trophyItem() {
    return Stack(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                "res/drawable/map3_node_default_avatar.png",
                width: 44,
                height: 44,
                fit: BoxFit.cover,
              ),
              Text(
                '第一名',
                style: TextStyle(fontSize: 14),
              ),
              Container(
                margin: EdgeInsets.all(4.0),
                padding: EdgeInsets.all(2.0),
                color: Colors.grey[200],
                child: Text(
                  ' +30 HYN ',
                  style: TextStyle(color: Colors.black, fontSize: 11),
                ),
              ),
              Text(
                '2020-10-01',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              )
            ],
          ),
        ),
        Positioned(
          right: 8,
          top: 16,
          child: Text(
            '全球杯周赛',
            style: TextStyle(fontSize: 11),
          ),
        )
      ],
    );
  }

  _contributedPoiList() {
    return _cardView(
        'iconPath',
        '评优地点',
        Column(
          children: _contributedPoiItem(),
        ),
        () {},
        childHeight: 160);
  }

  _contributedPoiItem() {
    return List.generate(
        2,
        (index) => Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Image.asset(
                      "res/drawable/atlas_logo.png",
                      fit: BoxFit.cover,
                      width: 80,
                      height: 60,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: 8.0,
                        ),
                        Text(
                          '麦当劳',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 8.0,
                        ),
                        Text(
                          '广州珠江新城xxxx号路',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        )
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      SizedBox(
                        height: 8.0,
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            '+${FormatUtil.doubleFormatNum(12000)}',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Icon(Icons.monetization_on)
                        ],
                      ),
                      SizedBox(
                        height: 8.0,
                      ),
                      Text(
                        '2020-01-20',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    width: 8.0,
                  )
                ],
              ),
            ));
  }

  _contributedRecords() {
    return _cardView(
      'iconPath',
      '贡献记录',
      Container(),
      () {},
      childHeight: 0,
      isIconDetail: true,
    );
  }

  _cardView(String iconPath, String title, Widget child, Function onDetail,
      {double childHeight, bool isIconDetail}) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Icon(Icons.local_cafe),
                  ),
                  Text(
                    title,
                    style: TextStyle(fontSize: 16),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: onDetail,
                    child: isIconDetail != null
                        ? Icon(Icons.arrow_forward_ios)
                        : Text(
                            '查看全部',
                            style: TextStyle(
                                fontSize: 16, color: Colors.blueAccent),
                          ),
                  ),
                ],
              ),
            ),
            Container(
              height: childHeight != null ? childHeight : 140,
              child: child,
            )
          ],
        ),
      ),
    );
  }

  _statusBarPadding() {
    return Container(
      color: Theme.of(context).primaryColor,
      height: UiUtil.isIPhoneX(context) ? 40.0 : 20.0,
    );
  }

  _bottomPadding() {
    return SizedBox(
      height: 32.0,
    );
  }
}
