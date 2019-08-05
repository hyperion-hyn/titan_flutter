import 'package:flutter/widgets.dart';

const kAnchorHeight = 400.0;
const kCollapsedHeight = 112.0;

enum DraggableBottomSheetState { DRAGGING, SETTLING, ANCHOR_POINT, EXPANDED, COLLAPSED, HIDDEN }

abstract class DraggableBottomSheetControllerInterface {
  void setSheetState(DraggableBottomSheetState state);

  DraggableBottomSheetState getSheetState();

  bool isChildFrozen;
}

class DraggableBottomSheetController extends ChangeNotifier {
  DraggableBottomSheetControllerInterface _interface;

  double anchorHeight;
  double collapsedHeight;

  double bottom;
  double sheetY;

  DraggableBottomSheetState initState;

  DraggableBottomSheetController(
      {this.anchorHeight = kAnchorHeight, this.collapsedHeight = kCollapsedHeight, this.initState = DraggableBottomSheetState.HIDDEN});

  void setInterface(DraggableBottomSheetControllerInterface mDraggableBottomSheetControllerInterface) {
    _interface = mDraggableBottomSheetControllerInterface;
  }

  void setSheetState(DraggableBottomSheetState state) {
    _interface?.setSheetState(state);
  }

  DraggableBottomSheetState getSheetState() {
    return _interface?.getSheetState();
  }

  void setFrozenState(bool isFrozen) {
    _interface?.isChildFrozen = isFrozen;
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
  }
}
