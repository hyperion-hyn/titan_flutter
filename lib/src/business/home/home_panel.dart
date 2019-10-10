import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'dart:math' as math;

import '../../global.dart';
import '../scaffold_map/bloc/bloc.dart';

class HomePanel extends StatelessWidget {
  final ScrollController scrollController;

  //附近的推荐
  final List<dynamic> nearPois;

  HomePanel({this.scrollController, this.nearPois});

  List<dynamic> mockPois = [
    {
      'pic': 'https://ss0.bdstatic.com/70cFuHSh_Q1YnxGkpoWK1HF6hhy/it/u=3925233323,1705701801&fm=26&gp=0.jpg',
      'name': '环球度过广场',
      'tags': '旅游，美食'
    },
    {
      'pic': 'https://ss0.bdstatic.com/70cFuHSh_Q1YnxGkpoWK1HF6hhy/it/u=3925233323,1705701801&fm=26&gp=0.jpg',
      'name': '广东博物馆',
      'tags': '旅游，美食'
    },
    {
      'pic': 'https://ss0.bdstatic.com/70cFuHSh_Q1YnxGkpoWK1HF6hhy/it/u=3925233323,1705701801&fm=26&gp=0.jpg',
      'name': '广州大剧院',
      'tags': '旅游，美食'
    },
  ];

  @override
  Widget build(BuildContext context) {
    var pois = nearPois ?? mockPois;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: CustomScrollView(
        controller: scrollController,
        slivers: <Widget>[
          /* 搜索 */
          SliverToBoxAdapter(
            child: _search(),
          ),
          /* 模式 */
          SliverToBoxAdapter(
            child: _mode(context),
          ),
          SliverToBoxAdapter(
            child: focusArea(context),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Column(
                children: <Widget>[
                  poiRow1(context),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: poiRow2(context),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 24.0, bottom: 16),
              child: Text('附近推荐', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),),
            ),
          ),
          SliverList(
              delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final int itemIndex = index ~/ 2;
                    if (index.isEven) {
                      var poi = pois[itemIndex];
                      return _buildRecommendItem(poi);
                    } else {
                      //devicer
                      return Divider(height: 0);
                    }
                  },
                  childCount: _computeSemanticChildCount(pois.length),
                  semanticIndexCallback: (Widget _, int index) {
                    return index.isEven ? index ~/ 2 : null;
                  })),
        ],
      ),
    );
  }

  Widget _search() {
    return InkWell(
      onTap: () {
        print('on search');
      },
      borderRadius: BorderRadius.all(Radius.circular(31)),
      child: Ink(
        height: 44,
        decoration: BoxDecoration(color: Color(0xfffff4f4fa), borderRadius: BorderRadius.all(Radius.circular(31))),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 8),
              child: Icon(
                Icons.search,
                color: Color(0xff8193AE),
              ),
            ),
            Text(
              '搜索',
              style: TextStyle(
                color: Color(0xff8193AE),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mode(context) {
    return Padding(
      padding: const EdgeInsets.only(top: 32.0),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              InkWell(
                onTap: () {
                  print('TODD 我的账户');
                },
                child: Column(
                  children: <Widget>[
                    Text(
                      '1483.3',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        '我的账户(USDT)',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  print('TODD 我的算力');
                },
                child: Column(
                  children: <Widget>[
                    Text(
                      '1483.3',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        '我的算力(POH)',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  print('TODD 我的抵押');
                },
                child: Column(
                  children: <Widget>[
                    Text(
                      '1483.3',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        '节点抵押(USDT)',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 32.0, left: 16, right: 16),
            child: InkWell(
              onTap: () {
                print('TODO 获得算力');
              },
              child: Ink(
                height: 42,
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor, borderRadius: BorderRadius.all(Radius.circular(31))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset('res/drawable/rock.png', width: 16.0),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        '获得算力',
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget focusArea(context) {
    return Container(
      margin: EdgeInsets.only(top: 32),
      height: 180,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.all(Radius.circular(4.0)),
                    onTap: () {
                      print('TODO 全球节点');
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(4.0)),
                          border: Border.all(color: Color(0xFFE9E9E9), width: 1)),
                      child: Stack(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0, left: 8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  '全球节点',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    '全球地图服务节点',
                                    style: TextStyle(color: Colors.grey, fontSize: 12),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Positioned(
                              top: 15,
                              right: 15,
                              child: Image.asset(
                                'res/drawable/global.png',
                                width: 32,
                                height: 32,
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 12,
                ),
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.all(Radius.circular(4.0)),
                    onTap: () {
                      print('TODO 海伯利安');
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(4.0)),
                          border: Border.all(color: Color(0xFFE9E9E9), width: 1)),
                      child: Stack(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0, left: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  '海伯利安',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    '项目介绍',
                                    style: TextStyle(color: Colors.grey, fontSize: 12),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Positioned(
                              top: 15,
                              right: 15,
                              child: Image.asset(
                                'res/drawable/ic_hyperion.png',
                                width: 32,
                                height: 32,
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 12,
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(4.0)),
                  border: Border.all(color: Color(0xFFE9E9E9), width: 1)),
              child: Stack(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0, left: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          '数据贡献',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            '贡献地图数据获得HYN奖励',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            '即将开放',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFFF82530)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                      top: 36,
                      right: 16,
                      child: Image.asset(
                        'res/drawable/data.png',
                        width: 32,
                        height: 32,
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget poiRow1(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        _buildPoiItem('res/drawable/ic_food.png', '美食'),
        _buildPoiItem('res/drawable/ic_hotel.png', '酒店'),
        _buildPoiItem('res/drawable/ic_scenic_spotx.png', '景点'),
        _buildPoiItem('res/drawable/ic_park.png', '停车场'),
        _buildPoiItem('res/drawable/ic_gas_station.png', '加油站'),
      ],
    );
  }

  Widget poiRow2(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        _buildPoiItem('res/drawable/ic_bank.png', '银行'),
        _buildPoiItem('res/drawable/ic_supermarket.png', '超市'),
        _buildPoiItem('res/drawable/ic_market.png', '商场'),
        _buildPoiItem('res/drawable/ic_cybercafe.png', '网吧'),
        _buildPoiItem('res/drawable/ic_wc.png', '厕所'),
      ],
    );
  }

  Widget _buildPoiItem(String asset, String label) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          //TODO
          print('poi clicked $label');
        },
        child: Ink(
          padding: EdgeInsets.all(8),
          child: Column(
            children: <Widget>[
              Image.asset(
                asset,
                width: 32,
                height: 32,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  label,
                  style: TextStyle(fontSize: 12),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to compute the semantic child count for the separated constructor.
  static int _computeSemanticChildCount(int itemCount) {
    return math.max(0, itemCount * 2 - 1);
  }

  Widget _buildRecommendItem(poi) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            //TODO
            print('poi item click');
          },
          child: Ink(
            child: Row(
//            crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Image.network(
                  poi['pic'],
                  height: 78,
                  width: 110,
                  fit: BoxFit.cover,
                ),
                Container(
//                color: Colors.red,
                  margin: EdgeInsets.only(left: 16, right: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        poi['name'],
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          poi['tags'],
                          style: TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void onSearch() async {
    eventBus.fire(GoSearchEvent());
  }
}
