import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/src/business/scaffold_map/scaffold_map.dart';
import 'package:titan/src/utils/utile_ui.dart';

class TopBar extends StatefulWidget {
//  final DraggableBottomSheetController bottomPanelController;
  final HeightCallBack heightCallBack;
  final String title;
  VoidCallback onBack;
  VoidCallback onClose;

  TopBar({
    Key key,
//    this.bottomPanelController,
    this.heightCallBack,
    this.title,
    this.onClose,
    this.onBack,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _TopBarState();
  }
}

class _TopBarState extends State<TopBar> {
  GlobalKey rootKey = GlobalKey(debugLabel: 'topBar');
  double selfHeight = 0;
  double _selfTop = 0;

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      selfHeight = UtilUi.getRenderObjectHeight(rootKey);
      if (widget.heightCallBack != null) {
        widget.heightCallBack(selfHeight);
      }
      setState(() {
        _selfTop = -selfHeight;
      });
    });
//    widget.bottomPanelController?.addListener(onDragUpdate);
  }

//  void onDragUpdate() {
//    if (selfHeight > 0) {
//      var sheetY = widget.bottomPanelController.sheetY;
//      if (sheetY < 2 * selfHeight) {
//        //触发移动
//        double max = 0;
//        double min = -selfHeight;
//        double top = selfHeight - sheetY;
//        if (top >= min && top <= max) {
//          setState(() {
//            _selfTop = top;
//          });
//        } else if (_selfTop != 0) {
//          setState(() {
//            _selfTop = 0;
//          });
//        }
//      } else if (_selfTop != -selfHeight) {
//        setState(() {
//          _selfTop = -selfHeight;
//        });
//      }
//    }
//  }

  @override
  void dispose() {
//    widget.bottomPanelController.removeListener(onDragUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: _selfTop,
      child: Material(
        key: rootKey,
        elevation: 2,
        color: Colors.white,
        child: Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          height: MediaQuery.of(context).padding.top + 56,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: <Widget>[
              Align(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: widget.onBack,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.arrow_back_ios),
                    ),
                  ),
                ),
                alignment: Alignment.centerLeft,
              ),
              Align(
                alignment: Alignment.center,
                child: Text(
                  widget.title ?? '',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ),
              Align(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: widget.onClose,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.close, color: Colors.black54,),
                    ),
                  ),
                ),
                alignment: Alignment.centerRight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
