import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/inject/injector.dart';
import 'package:titan/src/model/poi.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:titan/src/utils/encryption.dart';

import '../../global.dart';
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

  bool loaded = false;

  @override
  void initState() {
    super.initState();

    _searchTextController.text = widget.searchText ?? '';
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

    if (!loaded) {
      _searchBloc = SearchBloc(searchInteractor: Injector.of(context).searchInteractor);
      _searchBloc.add(FetchSearchItemsEvent(isHistory: true));

      loaded = true;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _searchBloc.close();
    _searchTextController.dispose();
    super.dispose();
  }

  void searchTextChangeListener() {
    String currentText = _searchTextController.text.trim();
    if (currentText.isNotEmpty) {
      if (!_visibleCloseIcon) {
        setState(() {
          _visibleCloseIcon = true;
        });
      }
      var event = FetchSearchItemsEvent(
          isHistory: false,
          searchText: currentText,
          center: widget.searchCenter,
          language: Localizations.localeOf(context).languageCode);

      _subscription?.cancel();
      _subscription = null;
      _subscription = Observable.timer(event, Duration(milliseconds: 1000)).listen((data) {
        if (data.searchText == currentText) {
          _searchBloc.add(data);
        }
      });
    } else {
      if (_visibleCloseIcon) {
        setState(() {
          _visibleCloseIcon = false;
        });
      }
      _searchBloc.add(FetchSearchItemsEvent(isHistory: true));
    }
  }

  void handleSearch(textOrPoi) async {
    if(textOrPoi is String) {
      textOrPoi = (textOrPoi as String).trim();
      if((textOrPoi as String).isEmpty) {
        return ;
      }
    }

    if (textOrPoi is String && !isSearchText(textOrPoi)) {
      //encrypt text
      try {
        var poi = await ciphertextToPoi(Injector.of(context).repository, textOrPoi);
        _searchBloc.add(AddSearchItemEvent(textOrPoi));
        Navigator.pop(context, poi);
      } catch(err) {
        logger.e(err);
        Fluttertoast.showToast(msg: err.message);
      }
      return;
    }

    _searchBloc.add(AddSearchItemEvent(textOrPoi));
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
                if (state is SearchLoadedState) {
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
                                  Expanded(
                                      child: Text(S.of(context).search_history, style: TextStyle(color: Colors.grey[600], fontSize: 13))),
                                  FlatButton(
                                    child: Text(
                                      S.of(context).clean_search_history,
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                    onPressed: () {
                                      _searchBloc.add(ClearSearchHisotoryEvent());
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
                                    if (item is PoiEntity) {
                                      return buildPoiItem(item);
                                    } else {
                                      return buildTextItem(item.toString());
                                    }
                                  } else {
                                    //devicer
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
                return buildInit();
              })),
    ])));
  }

  Widget buildInit() {
    return Center(
      child: SizedBox(
        height: 32,
        width: 32,
        child: CircularProgressIndicator(
          strokeWidth: 3,
        ),
      ),
    );
  }

  Widget buildPoiItem(PoiEntity entity) {
    return InkWell(
        onTap: () => handleSearch(entity),
        child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Stack(children: <Widget>[
              Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Icon(entity.isHistory != null && entity.isHistory ? Icons.history : Icons.location_on,
                      color: Colors.grey[600])),
              Positioned(
                  left: 72,
                  right: 48,
                  top: 0,
                  bottom: 0,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(entity.name, overflow: TextOverflow.ellipsis, maxLines: 1),
                        Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(entity.address,
                                style: TextStyle(color: Colors.grey, fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1))
                      ])),
              Positioned(
                  top: 0,
                  bottom: 0,
                  right: 16,
                  child: Center(child: Icon(IconData(0xe612, fontFamily: 'iconfont'), color: Colors.grey, size: 18)))
            ])));
  }

  Widget buildSearchBar() {
    return Material(
      elevation: _searchBarElevation,
      child: Container(
          height: 50,
          margin: EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 8),
          decoration:
              BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[350])),
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
//                  autofocus: true,
                  enableInteractiveSelection: true,
                  textInputAction: TextInputAction.search,
                  focusNode: _searchFocusNode,
                  decoration: InputDecoration(
                      hintText: S.of(context).input_search_keyworod_or_cipher, border: InputBorder.none, hintStyle: TextStyle(color: Colors.grey)),
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
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: Icon(
                Icons.history,
                color: Colors.grey[600],
              )),
          Padding(
            padding: const EdgeInsets.only(left: 72, right: 16, top: 16, bottom: 16),
            child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, ),
          ),
        ]));
  }

  Widget buildTouristGuide() {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, left: 8, right: 8),
      child: Column(
        children: <Widget>[
          Material(
            elevation: 2.0,
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Icon(Icons.enhanced_encryption, color: Colors.grey[600]),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 0, bottom: 16,right: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Text(
                            S.of(context).decrypt_location_cipher_tips,
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(S.of(context).decrypt_location_cipher_tips_context, style: TextStyle(color: Colors.grey, fontSize: 14),softWrap: true,),
                        ),
//                        Padding(
//                          padding: const EdgeInsets.only(top: 16.0),
//                          child: Text(
//                            '位置密文帮助',
//                            style: TextStyle(color: Colors.blue),
//                          ),
//                        )
                      ],
                    ),
                  ),
                )
              ],
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

  bool isSearchText(String text) {
    return (text.indexOf(" ") > 0 || text.length < 30);
  }
}
