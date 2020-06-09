import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:titan/src/components/scaffold_map/scaffold_map.dart';
import 'package:titan/src/pages/contribution/new_poi/contribution_record_page.dart';
import 'package:titan/src/pages/contribution/new_poi/contributor_mortgage_info_page.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/click_oval_button.dart';
import 'package:titan/src/widget/click_rectangle_button.dart';

class ContributorPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ContributorPageState();
  }
}

class ContributorInfo {
  var name = 'Lance';
  var walletAddress = 'AsjdlALIflslsl89sjAsjdlALIjflslsl89sjAsjdlALIflslsl89sj';
  double totalReward = 3100;
  var quota = 10;
  double energy = 230;
  var hyn = 10;
  double mortgage = 3000;
  double notMortgagedReward = 1020;
  int createPoiCount = 3001;
  int modifyPoiCount = 100;
  int verifyPoiCount = 100;
  int scanCount = 3001;
}

class _ContributorPageState extends State<ContributorPage> {
  ContributorInfo contributorInfo = ContributorInfo();
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
          title: Text('我的贡献'),
        ),
        body: SafeArea(
            child: Stack(
          children: <Widget>[
            SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  _contributorInfo(),
                  _lastestContribution(),
                  _goodContribution(),
                  _bottomPadding()
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: ClickRectangleButton('查看抵押', () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ContributorMortgageInfoPage()));
                    }),
                  ),
                  Expanded(
                    flex: 1,
                    child: ClickRectangleButton('去贡献', () {}),
                  ),
                ],
              ),
            )
          ],
        )));
  }

  _contributorInfo() {
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                    ),
                    Container(
                      width: 150,
                      child: Row(
                        children: <Widget>[
                          Text(
                            '钱包地址：',
                            style: TextStyle(color: Colors.black, fontSize: 10),
                          ),
                          Expanded(
                            child: Text(
                              '${contributorInfo.walletAddress}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  TextStyle(color: Colors.black, fontSize: 10),
                            ),
                          ),
                        ],
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
                        '${contributorInfo.quota}',
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
                        '${FormatUtil.doubleFormatNum(contributorInfo.energy)}',
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
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: <Widget>[
                Text(
                  '我的贡献',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ContributionRecordPage()));
                  },
                  child: Row(
                    children: <Widget>[
                      Text(
                        '贡献记录 ',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey,
                        size: 11,
                      )
                    ],
                  ),
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
                            '${FormatUtil.doubleFormatNum(contributorInfo.totalReward)}',
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
                '累计贡献收益',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 13,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
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
                          '${FormatUtil.formatNum(contributorInfo.createPoiCount)}',
                          style: TextStyle(color: Colors.black, fontSize: 20),
                        ),
                        SizedBox(
                          height: 4.0,
                        ),
                        Text(
                          '累计添加',
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
                          '${FormatUtil.formatNum(contributorInfo.modifyPoiCount)}',
                          maxLines: 2,
                          style: TextStyle(color: Colors.black, fontSize: 20),
                        ),
                        SizedBox(
                          height: 4.0,
                        ),
                        Text(
                          '累计修改',
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
                          '${FormatUtil.formatNum(contributorInfo.verifyPoiCount)}',
                          maxLines: 2,
                          style: TextStyle(color: Colors.black, fontSize: 20),
                        ),
                        SizedBox(
                          height: 4.0,
                        ),
                        Text(
                          '累计检验',
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
                          '${FormatUtil.formatNum(contributorInfo.scanCount)}',
                          maxLines: 2,
                          style: TextStyle(color: Colors.black, fontSize: 20),
                        ),
                        SizedBox(
                          height: 4.0,
                        ),
                        Text(
                          '累计扫描',
                          style: TextStyle(color: Colors.black, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _lastestContribution() {
    return _cardView(
        'iconPath',
        '最新贡献',
        Column(
          children: _contributedPoiItem(),
        ),
        () {},
        childHeight: 160);
  }

  _goodContribution() {
    return _cardView(
        'iconPath',
        '优质贡献',
        Column(
          children: _contributedPoiItem(),
        ),
        () {},
        isShowMore: true,
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

  _cardView(String iconPath, String title, Widget child, Function onDetail,
      {double childHeight, bool isIconDetail, bool isShowMore}) {
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
                    child: isShowMore != null
                        ? isIconDetail != null
                            ? Icon(Icons.arrow_forward_ios)
                            : Text(
                                '查看全部',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.blueAccent),
                              )
                        : SizedBox(),
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

  _bottomPadding() {
    return SizedBox(
      height: 64.0,
    );
  }
}
