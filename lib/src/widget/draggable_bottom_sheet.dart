import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'draggable_bottom_sheet_controller.dart';
import 'gestures/vertical_draggesture_recognizer_bottomsheet.dart';

class DraggableBottomSheet extends StatefulWidget {
  DraggableBottomSheet({
    this.controller,
    this.child,
    this.childScrollController,
    this.topPadding = 0,
  });

  final DraggableBottomSheetController controller;
  final ScrollController childScrollController;
  final Widget child;
  final double topPadding;

  @override
  State<StatefulWidget> createState() {
    return _DraggableState();
  }
}

class _DraggableState extends State<DraggableBottomSheet>
    with SingleTickerProviderStateMixin
    implements DraggableBottomSheetControllerInterface {
  bool _isChildFrozen;
  bool _isChildReachTop;

  final GlobalKey _draggableSheepKey = GlobalKey(debugLabel: 'draggableSheepKey');

  DraggableBottomSheetState _state;

  AnimationController _animationController;

  double _y;
  double topPadding = 0;

  double topRadius = 16;

//  double get _y {
//    return (1 - _animationController.value) * _sheetHeight;
//  }

  @override
  void initState() {
    super.initState();
    widget.controller.setInterface(this);
    widget.childScrollController?.addListener(() {
      var isReachTop = _isChildReachTopCheck();
      if (_isChildReachTop != isReachTop) {
        setState(() {
          _isChildReachTop = isReachTop;
        });
      }
    });

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 10),
      value: 1.0,
      vsync: this,
    );

    if (widget.controller.initState != null) {
      SchedulerBinding.instance
          .addPostFrameCallback((_) => widget.controller.setSheetState(widget.controller.initState));
    }

    Future.delayed(Duration(milliseconds: 1000))
        .then((data) => _animationController.addListener(animationNotifyListener));
  }

  void animationNotifyListener() {
    _y = (1 - _animationController.value) * bottomSheetHeight;
    if (_animationController.value == 1) {
      //reach top
      if (topRadius != 0) {
        setState(() {
          topRadius = 0;
        });
      }
    } else if (topRadius != 16) {
      setState(() {
        topRadius = 16;
      });
    }
    widget.controller.bottom = bottomSheetHeight - _y;
    widget.controller.notifyListeners();
  }

  bool _isChildReachTopCheck() {
    if (widget.childScrollController != null) {
      if (!widget.childScrollController.hasClients) {
        return true;
      } else if (widget.childScrollController.offset <= widget.childScrollController.position.minScrollExtent &&
          !widget.childScrollController.position.outOfRange) {
        return true;
      }
    }
    return true;
  }

  @protected
  @mustCallSuper
  void reassemble() {
    super.reassemble();
    widget.controller.setInterface(this);
  }

  double get bottomSheetHeight {
    if (_draggableSheepKey.currentContext != null) {
      final RenderBox renderBox = _draggableSheepKey.currentContext.findRenderObject();
      return renderBox.size.height - topPadding;
    }
//    return 1;
//    if (_bottomSheetHeight != null) {
//      return _bottomSheetHeight;
//    } else {
//      final RenderBox renderBox = _draggableSheepKey.currentContext.findRenderObject();
//      return renderBox.size.height;
//    }
    return MediaQuery.of(context).size.height -
        topPadding; // - MediaQuery.of(context).padding.bottom - MediaQuery.of(context).padding.top;
  }

  void _handleDragStart(DragStartDetails details) {
    widget.controller.setSheetState(DraggableBottomSheetState.DRAGGING);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (_animationController.isAnimating) return;

    double value = details.primaryDelta / (bottomSheetHeight ?? details.primaryDelta);
    _animationController.value -= value;
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_animationController.isAnimating) return;

    final double flingVelocity = details.velocity.pixelsPerSecond.dy / bottomSheetHeight;
    if (flingVelocity < 0.0) {
      //up
      if (_isBellowCollapsed) {
        widget.controller.setSheetState(DraggableBottomSheetState.COLLAPSED);
      } else if (_isBellowAnchor) {
        widget.controller.setSheetState(DraggableBottomSheetState.ANCHOR_POINT);
      } else {
        widget.controller.setSheetState(DraggableBottomSheetState.EXPANDED);
//    math.max(2.0, -flingVelocity)
      }
    } else if (flingVelocity > 0.0) {
      //down
      if (!_isBellowAnchor) {
        widget.controller.setSheetState(DraggableBottomSheetState.ANCHOR_POINT);
      } else {
        widget.controller.setSheetState(DraggableBottomSheetState.COLLAPSED);
      }
//      _animationController.fling(velocity: math.min(-2.0, -flingVelocity));
    } else {
      //not a fling
      if (_isTopOfAnchorArea) {
        widget.controller.setSheetState(DraggableBottomSheetState.EXPANDED);
      } else if (_isInAnchorArea) {
        widget.controller.setSheetState(DraggableBottomSheetState.ANCHOR_POINT);
      } else {
        widget.controller.setSheetState(DraggableBottomSheetState.COLLAPSED);
      }
//      _animationController.fling(velocity: _animationController.value < 0.5 ? -2.0 : 2.0);
    }
  }

  bool _handleSheetHeaderNotification(HeaderHeightNotification notification) {
    if (notification.height > 0 && _state == DraggableBottomSheetState.COLLAPSED) {
      var reallyHeight = notification.height + 12; //drag height: hack a number
      widget.controller.collapsedHeight = reallyHeight;
      var target = widget.controller.collapsedHeight / bottomSheetHeight;
      if (_animationController.value != target) {
        _animationController.animateTo(target, duration: Duration(milliseconds: 100), curve: Curves.linearToEaseOut);
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: _state != DraggableBottomSheetState.HIDDEN,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double panelHeight = constraints.biggest.height - topPadding;
          var hiddenRelative = RelativeRect.fromLTRB(0.0, constraints.biggest.height, 0.0, -panelHeight);
          var expandedRelative = RelativeRect.fromLTRB(0.0, topPadding, 0.0, 0.0);
          final Animation<RelativeRect> panelAnimation = _animationController.drive(
            RelativeRectTween(
              begin: hiddenRelative,
              end: expandedRelative,
            ),
          );

          return Container(
            key: _draggableSheepKey,
            child: Stack(
              children: <Widget>[
                PositionedTransition(
                  child: RawGestureDetector(
                    gestures: {
                      VerticalDragGestureRecognizerBottomSheet:
                          GestureRecognizerFactoryWithHandlers<VerticalDragGestureRecognizerBottomSheet>(
                              () => VerticalDragGestureRecognizerBottomSheet(),
                              (VerticalDragGestureRecognizerBottomSheet instance) {
                        instance.isChildReachTop = _isChildReachTop;
                        instance.isFrozenChild = _isChildFrozen;
                        instance.onStart = _handleDragStart;
                        instance.onUpdate = _handleDragUpdate;
                        instance.onEnd = _handleDragEnd;
                      })
                    },
                    child: Material(
                        elevation: 2.0,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(topRadius)),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(top: 8.0),
                            constraints: BoxConstraints.tightFor(width: 40.0, height: 4.0),
                            decoration: BoxDecoration(
                                color: Color(0xffdcdcdc), borderRadius: BorderRadius.all(Radius.circular(4.0))),
                          ),
                          Expanded(
                            child: NotificationListener<HeaderHeightNotification>(
                                onNotification: _handleSheetHeaderNotification, child: widget.child),
                          )
                        ])),
                  ),
                  rect: panelAnimation,
                )
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void setSheetState(DraggableBottomSheetState state) {
    if (_state == state) {
      return;
    }

    setState(() {
      _state = state;
    });

    if (state == DraggableBottomSheetState.COLLAPSED ||
        state == DraggableBottomSheetState.EXPANDED ||
        state == DraggableBottomSheetState.ANCHOR_POINT ||
        state == DraggableBottomSheetState.HIDDEN) {
      setState(() {
        _isChildFrozen = state != DraggableBottomSheetState.EXPANDED;
      });

      Duration animationDuration = Duration(milliseconds: 250);
      double target = 0;
      if (state == DraggableBottomSheetState.EXPANDED) {
        target = 1;
        var isReachTop = _isChildReachTopCheck();
        if (_isChildReachTop != isReachTop) {
          setState(() {
            _isChildReachTop = isReachTop;
          });
        }
      } else if (state == DraggableBottomSheetState.ANCHOR_POINT) {
        target = widget.controller.anchorHeight / bottomSheetHeight;
      } else if (state == DraggableBottomSheetState.COLLAPSED) {
        print('widget.controller.collapsedHeight ${widget.controller.collapsedHeight}');
        target = widget.controller.collapsedHeight / bottomSheetHeight;
      } else {
        //hidden
        target = 0;
      }

//      if (duration > 0) {
//        _animationController.animateTo(target, duration: animationDuration, curve: Curves.linearToEaseOut);
//      } else {
//        _animationController.value = target;
//      }
      _animationController.animateTo(target, duration: animationDuration, curve: Curves.linearToEaseOut);
    }
  }

  bool get _isBellowAnchor {
    return _y > (bottomSheetHeight - widget.controller.anchorHeight);
  }

  bool get _isBellowCollapsed {
    return _y > bottomSheetHeight - widget.controller.collapsedHeight;
  }

  bool get _isInAnchorArea {
    double sheetHeight = bottomSheetHeight;
    return (sheetHeight - widget.controller.anchorHeight) / 2 < _y &&
        _y < sheetHeight - (widget.controller.anchorHeight - widget.controller.collapsedHeight) / 2;
  }

  bool get _isTopOfAnchorArea {
    return _y <= (bottomSheetHeight - widget.controller.anchorHeight) / 2;
  }

  bool get _isBellowAnchorArea {
    return _y > bottomSheetHeight - (widget.controller.anchorHeight - widget.controller.collapsedHeight) / 2;
  }

  @override
  DraggableBottomSheetState getSheetState() {
    return _state;
  }

  @override
  set isChildFrozen(isFrozen) {
    setState(() {
      _isChildFrozen = isFrozen;
    });
  }

  @override
  bool get isChildFrozen {
    return _isChildFrozen;
  }
}

class HeaderHeightNotification extends Notification {
  final double height;

  HeaderHeightNotification({this.height});
}
