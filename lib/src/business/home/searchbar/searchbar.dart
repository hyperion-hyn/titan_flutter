import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/src/model/poi.dart';
import 'package:titan/src/widget/draggable_bottom_sheet_controller.dart';

import 'bloc/bloc.dart';

typedef void OnSearchCallback(String searchText);
typedef void BackToPrvSearchCallback(String searchText, List<dynamic> pois);

class SearchBarPresenter extends StatefulWidget {
  final OnSearchCallback onSearch;
  final VoidCallback onMenu;
  final BackToPrvSearchCallback backToPrvSearch;
  final VoidCallback onExistSearch;

  final DraggableBottomSheetController draggableBottomSheetController;

  SearchBarPresenter(
      {this.onSearch, this.onMenu, this.backToPrvSearch, this.onExistSearch, this.draggableBottomSheetController});

  @override
  State<StatefulWidget> createState() {
    return _SearchBarPresenterState();
  }
}

class _SearchBarPresenterState extends State<SearchBarPresenter> {
  final TextEditingController _textEditingController = TextEditingController();

  bool isTouchSheet = false;

  @override
  void initState() {
    super.initState();

    widget.draggableBottomSheetController
        ?.addListener(() => _handleBottomPadding(widget.draggableBottomSheetController.sheetY));
    //TODO if sheet child scroll > 0, set elevation 2
  }

  void _handleBottomPadding(double sheetY) {
    if (sheetY < MediaQuery.of(context).padding.top + 48 + 8) {
      if (!isTouchSheet) {
        setState(() {
          isTouchSheet = true;
        });
      }
    } else {
      if (isTouchSheet) {
        setState(() {
          isTouchSheet = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchbarBloc, SearchbarState>(
      builder: (BuildContext context, SearchbarState state) {
        if(state is HideSearchBarState) {
          return SizedBox.shrink();
        }

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
        } else if (state is SearchTextState) {
          _textEditingController.text = state.searchText;
        } else {
          _textEditingController.text = '';
        }

        return Material(
          color: isTouchSheet ? Colors.white : Colors.transparent,
//          elevation: isTouchSheet ? 2.0 : 0,
          child: Container(
            margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8, left: 16, right: 16, bottom: 8),
            decoration: BoxDecoration(
//              border: isTouchSheet ? null : Border.all(color: Colors.grey[400]),
//              borderRadius: isTouchSheet ? null : BorderRadius.all(Radius.circular(8)),
              color: Colors.white,
            ),
            child: Material(
//              color: Colors.grey,
              elevation: isTouchSheet ? 0 : 2.0,
              borderRadius: isTouchSheet ? BorderRadius.all(Radius.circular(8)) : null,
              child: Row(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      if (isPrvIsSearchItems) {
                        var st = state as SearchPoiState;
                        if (widget.backToPrvSearch != null) widget.backToPrvSearch(st.prvSearchText, st.prvSearchPois);
                      } else {
                        if (widget.onMenu != null) widget.onMenu();
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
                      if (widget.onSearch != null) widget.onSearch(_textEditingController.text);
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
                  if (state is SearchTextState && state.isLoading)
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                  if (!(state is InitialSearchbarState))
                    InkWell(
                        onTap: widget.onExistSearch,
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
          ),
        );
      },
    );
  }
}
