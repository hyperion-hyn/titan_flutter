import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sprintf/sprintf.dart';
import 'package:titan/env.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/business/map_store/bloc/bloc.dart';
import 'package:titan/src/business/map_store/bloc/map_store_order_bloc.dart';
import 'package:titan/src/business/map_store/map_store_network_repository.dart';
import 'package:titan/src/business/map_store/model/map_store_item.dart';
import 'package:titan/src/business/map_store/pay_dialog.dart';
import 'package:titan/src/domain/firebase.dart';
import 'package:titan/src/global.dart';

class MapStorePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _MapStorePageState();
  }
}

class _MapStorePageState extends State<MapStorePage> {
  MapStoreBloc _mapStoreBloc;

  MapStoreNetworkRepository _mapStoreNetworkRepository;

  Widget divider = Divider(
    color: Colors.grey,
  );

  @override
  void initState() {
    _mapStoreNetworkRepository = MapStoreNetworkRepository();

    _mapStoreBloc = MapStoreBloc(context: context, mapStoreNetworkRepository: _mapStoreNetworkRepository);

    _mapStoreBloc.dispatch(LoadMapStoreItemsEvent(channel: "", language: ""));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).map_store),
      ),
      body: BlocBuilder<MapStoreBloc, MapStoreState>(
        bloc: _mapStoreBloc,
        builder: (context, state) {
          if (state is MapStoreLoaded) {
            return ListView.separated(
              itemBuilder: (BuildContext context, int index) {
                return _buildMapStoreItem(state.mapStoreItems[index]);
              },
              itemCount: state.mapStoreItems.length,
              separatorBuilder: (BuildContext context, int index) {
                return divider;
              },
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }

  Widget _buildMapStoreItem(MapStoreItem mapStoreItem) {
    print(mapStoreItem);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8.0),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Image.network(
                  mapStoreItem.config.icon,
                  width: 70,
                  height: 70,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      mapStoreItem.title,
                      style: TextStyle(fontSize: 15),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        mapStoreItem.publisher,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    )
                  ],
                ),
              ),
              Column(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black87, width: 3), // 边色与边宽度
                        color: Colors.black87, // 底色
                        borderRadius: BorderRadius.circular(6)),
                    height: 40,
                    child: MaterialButton(
                      elevation: 0,
                      highlightElevation: 0,
                      minWidth: 60,
                      onPressed: () {
                        if (!mapStoreItem.isPurchased) {
                          _handlePayClick(context, mapStoreItem);
                        }
                      },
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      textColor: Color(0xddffffff),
                      highlightColor: mapStoreItem.isPurchased ? Colors.grey : Colors.black,
                      splashColor: Colors.white10,
                      child: Row(
                        children: <Widget>[
                          Text(
                            mapStoreItem.isPurchased ? "已购买" : mapStoreItem.isFree ? "获取" : "购买",
                            style: TextStyle(fontSize: 14, color: Color(0xddffffff)),
                          )
                        ],
                      ),
                    ),
                  ),
                  Text(mapStoreItem.showPrice)
                ],
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Stack(
              children: <Widget>[
                Text(
                  mapStoreItem.preview,
                  softWrap: true,
                  style: TextStyle(color: Colors.grey[600], fontSize: 17),
                ),
                if (!mapStoreItem.isShowMore)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: () {
                        mapStoreItem.isShowMore = true;
                        setState(() {});
                      },
                      child: Container(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          child: Text(
                            S.of(context).more,
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ),
                    ),
                  )
              ],
            ),
          ),
          if (mapStoreItem.isShowMore)
            Text(
              mapStoreItem.description,
              softWrap: true,
              style: TextStyle(color: Colors.grey[600], fontSize: 17),
            )
        ],
      ),
    );
  }

  void _handlePayClick(BuildContext context, MapStoreItem mapStoreItem) async {
    await FireBaseLogic.of(context).analytics.logEvent(name: 'ClickBuy');
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return BlocProvider<MapStoreOrderBloc>(
            builder: (context) => MapStoreOrderBloc(),
            child: WillPopScope(
              child: PayDialog(
                mapStoreItem: mapStoreItem,
              ),
              onWillPop: () => Future.value(false),
            ),
          );
        });
  }
}
