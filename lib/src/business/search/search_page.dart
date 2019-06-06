import 'dart:convert';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/src/bloc/search_history_bloc.dart';
import 'package:titan/src/model/history_search.dart';
import 'package:titan/src/model/search_poi.dart';
import 'package:titan/src/resource/db/db_provider.dart';
import 'package:toast/toast.dart';

class SearchPage extends StatefulWidget {
  final String searchText;

  SearchPage({this.searchText});

  @override
  State<StatefulWidget> createState() {
    return _SearchPageState();
  }
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _searchTextController = TextEditingController();

  bool _visibleCloseIcon = false;

  @override
  void initState() {
    _searchTextController.addListener(searchTextChangeListener);
    super.initState();
  }

  @override
  void dispose() {
    _searchTextController.dispose();
    super.dispose();
  }

  void searchTextChangeListener() {
    if (_searchTextController.text.length > 0) {
      if (!_visibleCloseIcon) {
        setState(() {
          _visibleCloseIcon = true;
        });
      }
    } else {
      if (_visibleCloseIcon) {
        setState(() {
          _visibleCloseIcon = false;
        });
      }
    }
    //TODO handle search poi
  }

  void handleSearch(String text) {
    Navigator.pop(context, text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Material(
              child: Container(
                  height: 50,
                  margin: EdgeInsets.only(left: 16, right: 16, top: 8),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[350])),
                  child: Row(children: <Widget>[
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(Icons.arrow_back_ios, color: Colors.grey[800]),
                      ),
                    ),
                    Expanded(
                        child: Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: TextField(
                          controller: _searchTextController,
                          onSubmitted: handleSearch,
                          autofocus: true,
                          decoration: InputDecoration(hintText: '输入搜索词 / 密文', border: InputBorder.none, hintStyle: TextStyle(color: Colors.grey)),
                          style: Theme.of(context).textTheme.body1),
                    )),
                    if (_visibleCloseIcon)
                      InkWell(
                        onTap: () {
                          _searchTextController.text = "";
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(Icons.close, color: Colors.grey[800]),
                        ),
                      )
                  ])),
            ),
            RaisedButton(
                onPressed: () {
                  var bloc = BlocProvider.getBloc<SearchHistoryBloc>();
                  var poiEntity = SearchPoiEntity(name: '广州珠江新城', address: '广州天河xxxx', loc: [1223, 4422]);
                  var entity = HistorySearchEntity(searchText: '珠江新城${DateTime.now().millisecondsSinceEpoch}', type: ''.runtimeType.toString());
//                  var entity = HistorySearchEntity(searchText: json.encode(poiEntity.toJson()), type: poiEntity.runtimeType.toString());
//                  entity.type = entity.runtimeType.toString();
                  bloc.addSearchHistory(entity);
                },
                child: Text('点击添加搜索')),
            RaisedButton(
                onPressed: () async {
                  var bloc = BlocProvider.getBloc<SearchHistoryBloc>();
                  var list = await bloc.searchHistoryList();
                  print('list len ${list.length}');

                  var ret = list.map<dynamic>((item) {
                    print(item);
                    if (item.type == SearchPoiEntity().runtimeType.toString()) {
                      var parsedJson = json.decode(item.searchText);
                      var entity = SearchPoiEntity.fromJson(parsedJson);
                      print(entity.runtimeType);
                      return entity;
                    }
                    return item.searchText;
                  }).toList();

                  for (var item in ret) {
                    print('${item.runtimeType} ${item.toString()}');
                  }
                },
                child: Text('点击获取列表')),
            RaisedButton(
                onPressed: () async {
                  await DBProvider.deleteDb();
                  Toast.show('删除成功', context);
                },
                child: Text('删除DB'))
//          ListView.builder(itemBuilder: (BuildContext context, int index) {
//            return null;
//          })
          ],
        ),
      ),
    );
  }
}
