import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/src/widget/draggable_bottom_sheet_controller.dart';

import 'map/bloc/bloc.dart';

class BottomFabsWidget extends StatefulWidget {
  final DraggableBottomSheetController draggableBottomSheetController;

  BottomFabsWidget({this.draggableBottomSheetController});

  @override
  State<StatefulWidget> createState() {
    return _BottomFasScenesState();
  }
}

class _BottomFasScenesState extends State<BottomFabsWidget> {
  double _fabsBottom = 16;

  @override
  void initState() {
    super.initState();

    widget.draggableBottomSheetController
        ?.addListener(() => _handleBottomPadding(widget.draggableBottomSheetController.bottom));
  }

  void _handleBottomPadding(double bottom) {
    if (bottom > 0 && bottom <= widget.draggableBottomSheetController.anchorHeight) {
      setState(() {
        _fabsBottom = bottom;
      });
    }
  }

  void _showFireModalBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (ctx) {
          return Container(
            margin: EdgeInsets.all(8),
            child: new Wrap(
              children: <Widget>[
                new ListTile(
                    leading: new Icon(IconData(0xe66e, fontFamily: 'iconfont'), color: Color(0xffac2229)),
                    title: new Text('清除痕迹', style: TextStyle(color: Color(0xffac2229), fontWeight: FontWeight.w500)),
                    onTap: () {
                      Fluttertoast.showToast(msg: 'TODO');
                      Navigator.pop(ctx);
                    }),
                new ListTile(
                  leading: new Icon(Icons.close),
                  title: new Text('取消'),
                  onTap: () => Navigator.pop(ctx),
                ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: _fabsBottom,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: <Widget>[
            FloatingActionButton(
              onPressed: () => _showFireModalBottomSheet(context),
              mini: true,
              heroTag: 'cleanData',
              backgroundColor: Colors.white,
              child: Image.asset(
                'res/drawable/ic_logo.png',
                width: 24,
                color: Colors.black87,
              ),
            ),
            Spacer(),
            FloatingActionButton(
              onPressed: () {
                BlocProvider.of<MapBloc>(context).dispatch(MyLocationEvent());
              },
              mini: true,
              heroTag: 'myLocation',
              backgroundColor: Colors.white,
              child: Icon(
                Icons.my_location,
                color: Colors.black87,
                size: 24,
              ),
            )
          ],
        ),
      ),
    );
  }
}
