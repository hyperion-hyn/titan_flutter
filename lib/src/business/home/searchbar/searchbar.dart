import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/src/model/poi.dart';

import 'bloc/bloc.dart';

typedef void OnSearchCallback(String searchText);
typedef void BackToPrvSearchCallback(String searchText, List<dynamic> pois);

class SearchBarPresenter extends StatelessWidget {
  final OnSearchCallback onSearch;
  final VoidCallback onMenu;
  final BackToPrvSearchCallback backToPrvSearch;
  final VoidCallback onExistSearch;

  SearchBarPresenter({
    this.onSearch,
    this.onMenu,
    this.backToPrvSearch,
    this.onExistSearch,
  });

  final TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchbarBloc, SearchbarState>(
      builder: (BuildContext context, SearchbarState state) {
        if (state is SearchTextState) {
          return buildSearchTextBar(context, state);
        } else {
          return buildSearchPoiBar(context, state);
        }
      },
    );
  }

  Widget buildSearchPoiBar(BuildContext context, SearchbarState state) {
    bool isPrvIsSearchItems =
        (state is SearchPoiState) && (state.prvSearchPois != null && state.prvSearchPois.length > 0);
    Widget barIcon = isPrvIsSearchItems
        ? Icon(Icons.arrow_back_ios, color: Colors.grey[600])
        : Icon(Icons.menu, color: Colors.grey[600]);

    if (state is SearchPoiState) {
      if (isPrvIsSearchItems) {
        _textEditingController.text = state.prvSearchText;
      } else {
        if (state.poi is PoiEntity) {
          _textEditingController.text = (state.poi as PoiEntity).name;
        }
        //TODO support more poi type name show
      }
    } else {
      _textEditingController.text = '';
    }

    return Container(
      margin: EdgeInsets.only(top: 48, left: 16, right: 16),
      constraints: BoxConstraints.tightForFinite(height: 48),
      child: Material(
        borderRadius: BorderRadius.all(Radius.circular(4)),
        elevation: 2.0,
        child: Row(
          children: <Widget>[
            GestureDetector(
              onTap: () {
                if (isPrvIsSearchItems) {
                  var st = state as SearchPoiState;
                  if (backToPrvSearch != null) backToPrvSearch(st.prvSearchText, st.prvSearchPois);
                } else {
                  if (onMenu != null) onMenu();
                }
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 8),
                child: barIcon,
              ),
            ),
            Expanded(
                child: GestureDetector(
              onTap: () {
                if (onSearch != null) onSearch(_textEditingController.text);
              },
              child: Container(
                margin: EdgeInsets.only(left: 16, right: 16),
                color: Colors.transparent,
                child: TextField(
                    controller: _textEditingController,
                    enabled: false,
                    decoration: InputDecoration(hintText: '搜索 / 解码', border: InputBorder.none),
                    style: Theme.of(context).textTheme.body1),
              ),
            )),
            if (state is SearchPoiState)
              InkWell(
                  onTap: onExistSearch,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.close,
                      color: Colors.grey[600],
                    ),
                  ))
          ],
        ),
      ),
    );
  }

  Widget buildSearchTextBar(BuildContext context, SearchTextState state) {
    _textEditingController.text = state.searchText;

    return Material(
      elevation: 2.0,
      child: Container(
        margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top, left: 16, right: 16, bottom: 16),
        constraints: BoxConstraints.tightForFinite(height: 48),
        child: Row(
          children: <Widget>[
            GestureDetector(
              onTap: onMenu,
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 8),
                child: Icon(Icons.menu, color: Colors.grey[600]),
              ),
            ),
            Expanded(
                child: GestureDetector(
              onTap: () {
                if (onSearch != null) onSearch(_textEditingController.text);
              },
              child: Container(
                margin: EdgeInsets.only(left: 16, right: 16),
                color: Colors.transparent,
                child: TextField(
                    controller: _textEditingController,
                    enabled: false,
                    decoration: InputDecoration(hintText: '搜索 / 解码', border: InputBorder.none),
                    style: Theme.of(context).textTheme.body1),
              ),
            )),
            if (state.isLoading)
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            InkWell(
                onTap: onExistSearch,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.close,
                    color: Colors.grey[600],
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
