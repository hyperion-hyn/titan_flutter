import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/src/inject/injector.dart';
import 'package:titan/src/model/search_poi.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import 'bloc/bloc.dart';

class SearchPage extends StatefulWidget {
  final String searchText;
  final LatLng searchCenter;

  SearchPage({this.searchText, this.searchCenter});

  @override
  State<StatefulWidget> createState() {
    return _SearchPageState();
  }
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _searchTextController = TextEditingController();
  ScrollController _scrollController = ScrollController();

  bool _visibleCloseIcon = false;
  FocusNode _searchFocusNode = FocusNode();

  SearchBloc _searchBloc;

  double _searchBarElevation = 0;

  StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();

    _searchTextController.text = widget.searchText;
    _searchTextController.addListener(searchTextChangeListener);

    _scrollController.addListener(() {
      if (_scrollController.offset > 0 && _searchBarElevation == 0) {
        setState(() {
          _searchBarElevation = 2.0;
        });
      } else if (_scrollController.offset <= 0 && _searchBarElevation != 0) {
        setState(() {
          _searchBarElevation = 0;
        });
      }

      if (_searchFocusNode.hasFocus) {
        _searchFocusNode.unfocus();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _searchBloc = SearchBloc(searchInteractor: Injector.of(context).searchInteractor);
    _searchBloc.dispatch(FetchSearchItemsEvent(isHistory: true));
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _searchBloc.dispose();
    _searchTextController.dispose();
    super.dispose();
  }

  void searchTextChangeListener() {
    if (_searchTextController.text.isNotEmpty) {
      if (!_visibleCloseIcon) {
        setState(() {
          _visibleCloseIcon = true;
        });
      }
      var event = FetchSearchItemsEvent(
          isHistory: false,
          searchText: _searchTextController.text,
          center: '${widget.searchCenter.longitude},${widget.searchCenter.latitude}',
          language: Localizations.localeOf(context).languageCode);

      _subscription?.cancel();
      _subscription = null;
      _subscription = Observable.timer(event, Duration(milliseconds: 1000)).listen((data) {
        if (data.searchText == _searchTextController.text) {
          _searchBloc.dispatch(data);
        }
      });
    } else {
      if (_visibleCloseIcon) {
        setState(() {
          _visibleCloseIcon = false;
        });
      }
      _searchBloc.dispatch(FetchSearchItemsEvent(isHistory: true));
    }
  }

  void handleSearch(textOrPoi) async {
    _searchBloc.dispatch(AddSearchItemEvent(textOrPoi));
    Navigator.pop(context, textOrPoi);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
      buildSearchBar(), //search bar
      Expanded(
          child: BlocBuilder(
              bloc: _searchBloc,
              builder: (context, SearchState state) {
                if (state is InitialSearchState) {
                  return buildTouristGuide();
                } else if (state is SearchLoadedState) {
                  if (state.items != null && state.items.isNotEmpty) {
                    return CustomScrollView(
                      controller: _scrollController,
                      slivers: <Widget>[
                        if (state.isHistory)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8, left: 16, right: 8, bottom: 0),
                              child: Row(
                                children: <Widget>[
                                  Expanded(child: Text('历史搜索', style: TextStyle(color: Colors.grey[600], fontSize: 13))),
                                  FlatButton(
                                    child: Text(
                                      '清除记录',
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                    onPressed: () {
                                      _searchBloc.dispatch(ClearSearchHisotoryEvent());
                                    },
                                  )
                                ],
                              ),
                            ),
                          ),
                        SliverList(
                            delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final int itemIndex = index ~/ 2;
                                  if (index.isEven) {
                                    var item = state.items[itemIndex];
                                    if (item is SearchPoiEntity) {
                                      return buildPoiItem(item);
                                    } else {
                                      return buildTextItem(item.toString());
                                    }
                                  } else {
                                    return Padding(
                                      padding: const EdgeInsets.only(left: 72.0),
                                      child: Divider(height: 0),
                                    );
                                  }
                                },
                                childCount: _computeSemanticChildCount(state.items.length),
                                semanticIndexCallback: (Widget _, int index) {
                                  return index.isEven ? index ~/ 2 : null;
                                })),
                      ],
                    );
                  } else {
                    return buildTouristGuide();
                  }
                }
              })),
    ])));
  }

  Widget buildPoiItem(SearchPoiEntity entity) {
    return InkWell(
        onTap: () => handleSearch(entity),
        child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Stack(children: <Widget>[
              Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Icon(entity.isHistory != null && entity.isHistory ? Icons.history : Icons.location_on, color: Colors.grey[600])),
              Positioned(
                  left: 72,
                  right: 48,
                  top: 0,
                  bottom: 0,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                    Text(entity.name, overflow: TextOverflow.ellipsis, maxLines: 1),
                    Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(entity.address, style: TextStyle(color: Colors.grey, fontSize: 13), overflow: TextOverflow.ellipsis, maxLines: 1))
                  ])),
              Positioned(
                  top: 0, bottom: 0, right: 16, child: Center(child: Icon(IconData(0xe612, fontFamily: 'iconfont'), color: Colors.grey, size: 18)))
            ])));
  }

  Widget buildSearchBar() {
    return Material(
      elevation: _searchBarElevation,
      child: Container(
          height: 50,
          margin: EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 8),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[350])),
          child: Row(children: <Widget>[
            InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.arrow_back_ios, color: Colors.grey[700]),
              ),
            ),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: TextField(
                  controller: _searchTextController,
                  onSubmitted: handleSearch,
                  autofocus: true,
                  textInputAction: TextInputAction.search,
                  focusNode: _searchFocusNode,
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
                  child: Icon(Icons.close, color: Colors.grey[700]),
                ),
              )
          ])),
    );
  }

  Widget buildTextItem(String text) {
    return InkWell(
        onTap: () => handleSearch(text),
        child: Stack(children: <Widget>[
          Padding(padding: const EdgeInsets.all(16.0), child: Icon(Icons.history, color: Colors.grey[600])),
          Positioned(left: 72, right: 48, top: 0, bottom: 0, child: Align(alignment: Alignment.centerLeft, child: Text(text)))
        ]));
  }

  Widget buildTouristGuide() {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, left: 8, right: 8),
      child: Column(
        children: <Widget>[
//            GestureDetector(
//              onTap: () {
//                FocusScope.of(context).requestFocus(_searchFocusNode);
//              },
//              child: Material(
//                elevation: 2,
//                child: Row(
//                  children: <Widget>[
//                    Padding(
//                      padding: const EdgeInsets.all(16.0),
//                      child: Icon(Icons.search, color: Colors.grey[600]),
//                    ),
//                    Padding(
//                      padding: const EdgeInsets.only(top: 16, bottom: 16),
//                      child: Column(
//                        crossAxisAlignment: CrossAxisAlignment.start,
//                        children: <Widget>[
//                          Text('搜索位置', style: TextStyle(fontWeight: FontWeight.w600)),
//                          Padding(
//                            padding: const EdgeInsets.only(top: 8),
//                            child: Text('请输入你感兴趣的位置，点击搜索。', style: TextStyle(color: Colors.grey, fontSize: 14)),
//                          ),
//                        ],
//                      ),
//                    )
//                  ],
//                ),
//              ),
//            ),
//            SizedBox(
//              height: 8,
//            ),
          Material(
            elevation: 2.0,
            child: InkWell(
              onTap: () {
                Fluttertoast.showToast(msg: 'TODO');
              },
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Icon(Icons.enhanced_encryption, color: Colors.grey[600]),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 0, bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Text(
                            '怎么解码位置密文？',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text('请粘贴位置密文，点击搜索即可解码密文。', style: TextStyle(color: Colors.grey, fontSize: 14)),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Text(
                            '位置密文帮助',
                            style: TextStyle(color: Colors.blue),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          Expanded(child: Container(color: Colors.transparent))
        ],
      ),
    );
  }

  // Helper method to compute the semantic child count for the separated constructor.
  static int _computeSemanticChildCount(int itemCount) {
    return math.max(0, itemCount * 2 - 1);
  }
}
