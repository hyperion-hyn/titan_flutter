import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/business/home/drawer/purchased_map/bloc/purchased_map_bloc.dart';
import 'package:titan/src/business/home/drawer/purchased_map/bloc/purchased_map_event.dart';
import 'package:titan/src/business/home/drawer/purchased_map/bloc/purchased_map_state.dart';
import 'package:titan/src/business/home/map/bloc/bloc.dart';
import 'package:titan/src/business/map_store/map_store.dart';
import 'package:titan/src/business/map_store/model/purchased_map_item.dart';
import 'package:titan/src/widget/smart_drawer.dart';

class PurchasedMapDrawerScenes extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _PurchasedMapDrawerScenesState();
  }
}

class _PurchasedMapDrawerScenesState extends State<PurchasedMapDrawerScenes> {
  PurchasedMapBloc _purchasedMapBloc;

  @override
  void initState() {
    super.initState();
    _purchasedMapBloc = BlocProvider.of<PurchasedMapBloc>(context);
    _purchasedMapBloc.dispatch(LoadPurchasedMapsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return SmartDrawer(
      widthPercent: 0.72,
      child: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.topLeft,
            color: Colors.black,
            child: Text(
              "您购买的地图",
              style: TextStyle(color: Colors.white),
            ),
          ),
          Expanded(
              child: BlocBuilder<PurchasedMapBloc, PurchasedMapState>(
                  bloc: _purchasedMapBloc,
                  builder: (context, state) {
                    if (state is PurchasedMapLoaded) {
                      if (state.purchasedMaps == null || state.purchasedMaps.length == 0) {
                        return _buildEmptyWidget();
                      } else {
                        return _buildPurcharsedList(state.purchasedMaps);
                      }
                    } else {
                      return Container();
                    }
                  })),
          _buildPurchseMoreToolbar()
        ],
      ),
    );
  }

  Widget _buildPurchseMoreToolbar() {
    return GestureDetector(
      onTap: () {
        _navigateToMapStorePage();
      },
      child: Material(
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: <Widget>[
              Container(
                  height: 35,
                  width: 35,
                  child: SvgPicture.asset("res/drawable/shop_car.svg", color: Colors.grey[700], semanticsLabel: '')),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "购买更多地图",
                  style: TextStyle(color: Colors.grey, fontSize: 15),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  /**
   * 构建未购买任何地图的view
   */
  Widget _buildEmptyWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
            height: 120,
            width: 120,
            child: SvgPicture.asset("res/drawable/empty_box.svg", color: Colors.grey[700], semanticsLabel: '')),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "你尚未购买任何地图",
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
        ),
        GestureDetector(
          onTap: () {
            _navigateToMapStorePage();
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "点击前往购买",
              style: TextStyle(color: Colors.blueAccent, fontSize: 14),
            ),
          ),
        )
      ],
    );
  }

  ///构建已购买的地图ListView
  Widget _buildPurcharsedList(List<PurchasedMap> purchasedMapList) {
    return ListView.separated(
        padding: EdgeInsets.all(0),
        itemBuilder: (BuildContext context, int index) {
          return _buildPurchasedMapItem(purchasedMapList[index]);
        },
        separatorBuilder: (BuildContext context, int index) {
          return Divider(
            color: Colors.grey,
          );
        },
        itemCount: purchasedMapList.length);
  }

  /// 构建单个已购买地图ListViewItem
  Widget _buildPurchasedMapItem(PurchasedMap purchasedMap) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: GestureDetector(
        onTap: () {
          _purchasedMapBloc.dispatch(SelectedPurchasedMapEvent(purchasedMap));
        },
        child: Container(
          decoration: BoxDecoration(
              border: new Border.all(color: purchasedMap.selected ? Colors.blue : Colors.transparent, width: 3),
              // 边色与边宽度
              color: Colors.white,
              // 底色
              borderRadius: new BorderRadius.circular(8)),
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Stack(
                  children: <Widget>[
                    Image.network(
                      purchasedMap.icon,
                      width: 60,
                      height: 60,
                    ),
                    Container(
                      width: 60,
                      height: 60,
                      child: Align(
                          alignment: Alignment.bottomRight,
                          child: Container(
                              height: 15,
                              width: 15,
                              child: CircleAvatar(backgroundColor: HexColor(purchasedMap.color)))),
                    )
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(purchasedMap.name),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          purchasedMap.description,
                          softWrap: true,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                child: Container(
                  child: Icon(
                    Icons.check_circle,
                    color: purchasedMap.selected ? Colors.blue : Colors.transparent,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToMapStorePage() {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context) => MapStorePage()));
  }
}
