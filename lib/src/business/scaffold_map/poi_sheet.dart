import 'package:flutter/cupertino.dart';
import 'package:titan/src/widget/draggable_bottom_sheet_controller.dart';

class PoiSheet extends StatefulWidget {
  final DraggableBottomSheetController draggableBottomSheetController;

  PoiSheet({this.draggableBottomSheetController});

  @override
  State<StatefulWidget> createState() {
    return _PoiSheetState();
  }

}

class _PoiSheetState extends State<PoiSheet> {
  @override
  Widget build(BuildContext context) {
    //TODO
    return Container();
  }

}