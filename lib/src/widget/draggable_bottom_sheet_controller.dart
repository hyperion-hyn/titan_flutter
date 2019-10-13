import 'package:flutter/widgets.dart';

const kAnchorPoiHeight = 400.0;
const kAnchorSearchHeight = 300.0;
const kCollapsedHeight = 112.0;

enum DraggableBottomSheetState { DRAGGING, SETTLING, ANCHOR_POINT, EXPANDED, COLLAPSED, HIDDEN }

abstract class DraggableBottomSheetControllerInterface {
  void setSheetState(DraggableBottomSheetState state, {bool forceUpdate = false});

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

  DraggableBottomSheetState _sheetState;
  bool _isFrozen;

  DraggableBottomSheetController(
      {this.anchorHeight = kAnchorPoiHeight,
      this.collapsedHeight = kCollapsedHeight,
      this.initState = DraggableBottomSheetState.HIDDEN});

  void setInterface(DraggableBottomSheetControllerInterface mDraggableBottomSheetControllerInterface) {
    _interface = mDraggableBottomSheetControllerInterface;
//    if (_sheetState != null) {
//      _interface?.setSheetState(_sheetState);
//    }
//    if (_isFrozen != null) {
//      _interface?.isChildFrozen = _isFrozen;
//    }
  }

  DraggableBottomSheetControllerInterface getInterface() {
    return _interface;
  }

  void setSheetState(DraggableBottomSheetState state, {bool forceUpdate = false}) {
    _interface?.setSheetState(state, forceUpdate: forceUpdate);
    _sheetState = state;
  }

  DraggableBottomSheetState getSheetState() {
    var st = _interface?.getSheetState();
    return st ?? _sheetState;
  }

  void setFrozenState(bool isFrozen) {
    _interface?.isChildFrozen = isFrozen;
    _isFrozen = isFrozen;
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
  }
}
