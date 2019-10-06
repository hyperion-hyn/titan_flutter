import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/draggable_bottom_sheet_controller.dart';

import 'bloc/bloc.dart';

class SearchBar extends StatefulWidget {
  final DraggableBottomSheetController bottomPanelController;

  final String searchText;

  SearchBar({Key key, this.bottomPanelController, this.searchText}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SearchBarState();
  }
}

class _SearchBarState extends State<SearchBar> {
  GlobalKey rootKey = GlobalKey(debugLabel: 'searchBar');
  double selfHeight = 0;

  double _selfTop = 0;

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      selfHeight = UtilUi.getRenderObjectHeight(rootKey);
    });
    widget.bottomPanelController.addListener(onDragUpdate);
  }

  void onDragUpdate() {
    if (selfHeight > 0) {
      var sheetY = widget.bottomPanelController.sheetY;
      var threshold = 10;
      var activeY = widget.bottomPanelController.anchorHeight - threshold;
      if (sheetY < activeY) {
        double top = sheetY - activeY;
        if (top < -selfHeight) {
          top = -selfHeight;
        }
        if (_selfTop != top) {
          setState(() {
            _selfTop = top;
          });
        }
      } else if (_selfTop != 0) {
        setState(() {
          _selfTop = 0;
        });
      }
    }
  }

  @override
  void dispose() {
    widget.bottomPanelController.removeListener(onDragUpdate);
    super.dispose();
  }

//  _draggableBottomSheetController.addListener(onDragUpdate);
//
//  SchedulerBinding.instance.addPostFrameCallback((_) {
//  searchBarHeight = UtilUi.getRenderObjectHeight(searchBarKey);
//  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: _selfTop,
      left: 0,
      right: 0,
      child: Container(
        key: rootKey,
        margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8, left: 8, right: 8),
        child: SizedBox(
          height: 48,
          child: Material(
            borderRadius: BorderRadius.all(Radius.circular(4)),
            elevation: 2,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                InkWell(
                  onTap: () {
                    //back to search
                    eventBus.fire(GoSearchEvent());
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.black54,
                    ),
                  ),
                ),
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: InkWell(
                    onTap: () {
                      //back to search
                      eventBus.fire(GoSearchEvent(searchText: widget.searchText));
                    },
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.searchText ?? '',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                )),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 16),
                  width: 1,
                  height: 16,
                  color: Colors.grey[400],
                ),
                InkWell(
                  onTap: () {
                    BlocProvider.of<ScaffoldMapBloc>(context).dispatch(InitMapEvent());
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Icon(
                      Icons.close,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
