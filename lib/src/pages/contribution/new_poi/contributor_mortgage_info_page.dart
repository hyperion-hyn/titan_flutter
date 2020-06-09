import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:titan/src/components/scaffold_map/scaffold_map.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/click_oval_button.dart';
import 'package:titan/src/widget/click_rectangle_button.dart';

class ContributorMortgageInfoPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ContributorMortgageInfoPageState();
  }
}

class ContributorAssets {
  var name = 'Lance';
  var walletAddress =
      'AsjdlALIj…flslsl89sjAsjdlALIj…flslsl89sjAsjdlALIj…flslsl89sj';
  double totalHyn = 3100;
  var quota = 10;
  double energy = 230;
  double mortgage = 3000;
  double notMortgagedReward = 1020;
  var lastReward = '昨日奖励 2HYN';
}

class _ContributorMortgageInfoPageState
    extends State<ContributorMortgageInfoPage> {
  ContributorAssets contributorAssets = ContributorAssets();
  var chartName = '全球杯周赛';
  var notEnoughHYN = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('我的抵押'),
        ),
        body: SafeArea(
            child: Stack(
          children: <Widget>[
            SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  //_statusBarPadding(),
                  _contributorAssets(),
                  _introduction(),
//            _globalChart(),
//            _contributorTrophies(),
//            _contributedPoiList(),
//            _contributedRecords(),
                  _bottomPadding()
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: ClickRectangleButton('抵押', () {}),
            )
          ],
        )));
  }

  _contributorAssets() {
    return Container(
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
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                    ),
                    Container(
                      width: 150,
                      child: Text(
                        '钱包地址: ${contributorAssets.walletAddress}',
                        maxLines: 1,
                        style: TextStyle(color: Colors.black, fontSize: 10),
                      ),
                    )
                  ],
                ),
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
                Text.rich(
                  TextSpan(children: [
                    TextSpan(
                        text:
                            '${FormatUtil.doubleFormatNum(contributorAssets.totalHyn)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                          color: Colors.black,
                        )),
                    TextSpan(
                        text: ' (HYN)',
                        style: TextStyle(
                          color: Colors.black,
                        ))
                  ]),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: EdgeInsets.all(4.0),
              color: Colors.grey[200],
              child: Text(
                contributorAssets.lastReward,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 13,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 16.0,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        '${FormatUtil.doubleFormatNum(contributorAssets.mortgage)}',
                        style: TextStyle(color: Colors.black, fontSize: 20),
                      ),
                      Text(
                        '抵押中（HYN）',
                        style: TextStyle(color: Colors.black, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        '${FormatUtil.doubleFormatNum(contributorAssets.notMortgagedReward)}',
                        maxLines: 2,
                        style: TextStyle(color: Colors.black, fontSize: 20),
                      ),
                      Text(
                        '贡献奖励（HYN）',
                        style: TextStyle(color: Colors.black, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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

  _dot() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 7.0,
        height: 7.0,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: DefaultColors.color999,
            border: Border.all(color: DefaultColors.color999, width: 1.0)),
      ),
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

  _introduction() {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                '当前抵押权益:',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              Spacer(),
              Icon(Icons.edit),
              Text(
                '抵押细则 >>',
                style: TextStyle(color: Colors.blue),
              )
            ],
          ),
          SizedBox(
            height: 8.0,
          ),
          notEnoughHYN
              ? Text.rich(TextSpan(children: [
                  TextSpan(
                      text: '! ',
                      style: TextStyle(fontSize: 20, color: Colors.red)),
                  TextSpan(
                      text: '您当前没有抵押金额，最少抵押500HYN可获得收益',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ))
                ]))
              : SizedBox(),
          SizedBox(
            height: 8.0,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                ' 例: ',
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(
                width: 8.0,
              ),
              Text(
                '当前抵押500HYN，可获奖励：\n添加/修改 1 地点 ≈ 0.1 HYN',
                style: TextStyle(),
              )
            ],
          ),
          SizedBox(
            height: 32.0,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _dot(),
              Text(
                '抵押金额上限是5000HYN，添加/修改 1 地点 ≈ 0.5 HYN',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              )
            ],
          ),
          SizedBox(
            height: 8.0,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _dot(),
              Text(
                '抵押金额越多，贡献POI获得的奖励就越多',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  _bottomPadding() {
    return SizedBox(
      height: 32.0,
    );
  }
}
