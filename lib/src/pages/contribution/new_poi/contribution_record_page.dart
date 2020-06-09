import 'package:flutter/material.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/utils/format_util.dart';

class ContributionRecordPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ContributionRecordPageState();
  }
}

class _ContributionRecordPageState extends State<ContributionRecordPage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    _tabController = new TabController(initialIndex: 0, vsync: this, length: 3);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          color: Theme.of(context).primaryColor,
          child: SafeArea(
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              isScrollable: true,
              labelStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              indicatorSize: TabBarIndicatorSize.label,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              indicatorPadding: EdgeInsets.only(bottom: 2),
              unselectedLabelColor: HexColor("#aaffffff"),
              tabs: [
                Tab(
                  text: '添加/修改',
                ),
                Tab(
                  text: '检验',
                ),
                Tab(
                  text: '扫描',
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Container(
            child: ListView.builder(
                itemCount: 5,
                itemBuilder: (ctx, index) {
                  return _contributedPoiItem();
                }),
          ),
          Container(
            color: Colors.blue,
          ),
          Container(color: Colors.lightBlueAccent)
        ],
      ),
    );
  }

  _contributedPoiItem() {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
    );
  }
}
