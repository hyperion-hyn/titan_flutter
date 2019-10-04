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
    this.topRadius = 16,
    this.draggable = true,
  });

  final DraggableBottomSheetController controller;
  final ScrollController childScrollController;
  final Widget child;
  final double topPadding;
  final double topRadius;
  final bool draggable;

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

  double topRadius = 0;

//  double get _y {
//    return (1 - _animationController.value) * _sheetHeight;
//  }

  @override
  void initState() {
    super.initState();
    widget.childScrollController?.addListener(() {
      var isReachTop = _isChildReachTopCheck();
      if (_isChildReachTop != isReachTop) {
        setState(() {
          _isChildReachTop = isReachTop;
        });
      }
    });

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 20),
      value: 1.0,
      vsync: this,
    );

//    if (widget.controller.initState != null) {
//      SchedulerBinding.instance
//          .addPostFrameCallback((_) => widget.controller.setSheetState(widget.controller.initState));
//    }

//    Future.delayed(Duration(milliseconds: 1000))
//        .then((data) => _animationController.addListener(animationNotifyListener));
  }

  bool inited = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!inited) {
      widget.controller.setInterface(this);
      if(widget.controller.getSheetState() != null) {
        widget.controller.setSheetState(widget.controller.getSheetState());
      } else {
        if (widget.controller.initState != null) {
          widget.controller.setSheetState(widget.controller.initState);
        }
      }

      _animationController.addListener(animationNotifyListener);

      inited = true;
    }
  }

  void animationNotifyListener() {
    if (_animationController.value == 1) {
      //reach top
      if (topRadius != 0) {
        setState(() {
          topRadius = 0;
        });
      }
    } else if (topRadius != widget.topRadius) {
      setState(() {
        topRadius = widget.topRadius;
      });
    }

    double sheetUp = _animationController.value * sheetHeight;
    double sheetY = screenHeight - sheetUp;

//    _y = (1 - _animationController.value) * sheetHeight;
    _y = sheetY;

    widget.controller.bottom = sheetUp;
    widget.controller.sheetY = sheetY;
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
    return false;
  }

  @protected
  @mustCallSuper
  void reassemble() {
    super.reassemble();
    widget.controller.setInterface(this);
  }

  double get screenHeight {
    return MediaQuery.of(context).size.height;
  }

  double get sheetHeight {
    if (_draggableSheepKey.currentContext != null) {
      final RenderBox renderBox = _draggableSheepKey.currentContext.findRenderObject();
      return renderBox.size.height - widget.topPadding;
    }
//    return 1;
//    if (_bottomSheetHeight != null) {
//      return _bottomSheetHeight;
//    } else {
//      final RenderBox renderBox = _draggableSheepKey.currentContext.findRenderObject();
//      return renderBox.size.height;
//    }
    return MediaQuery.of(context).size.height -
        widget.topPadding; // - MediaQuery.of(context).padding.bottom - MediaQuery.of(context).padding.top;
  }

  void _handleDragStart(DragStartDetails details) {
    widget.controller.setSheetState(DraggableBottomSheetState.DRAGGING);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (_animationController.isAnimating) return;

    double value = details.primaryDelta / (sheetHeight ?? details.primaryDelta);
    _animationController.value -= value;
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_animationController.isAnimating) return;

    final double flingVelocity = details.velocity.pixelsPerSecond.dy / sheetHeight;
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
      var target = widget.controller.collapsedHeight / sheetHeight;
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
          final double panelHeight = constraints.biggest.height - widget.topPadding;
          var hiddenRelative = RelativeRect.fromLTRB(0.0, constraints.biggest.height, 0.0, -panelHeight);
          var expandedRelative = RelativeRect.fromLTRB(0.0, widget.topPadding, 0.0, 0.0);
          final Animation<RelativeRect> panelAnimation = _animationController.drive(
            RelativeRectTween(
              begin: hiddenRelative,
              end: expandedRelative,
            ),
          );

          Widget content;
          if (widget.draggable) {
            content = buildDraggableContent(context);
          } else {
            content = buildContent(context);
          }
          return Container(
            key: _draggableSheepKey,
            child: Stack(
              children: <Widget>[
                PositionedTransition(
                  child: content,
                  rect: panelAnimation,
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildDraggableContent(context) {
    return RawGestureDetector(
      gestures: {
        VerticalDragGestureRecognizerBottomSheet:
            GestureRecognizerFactoryWithHandlers<VerticalDragGestureRecognizerBottomSheet>(
                () => VerticalDragGestureRecognizerBottomSheet(), (VerticalDragGestureRecognizerBottomSheet instance) {
          instance.isChildReachTop = widget.draggable ? _isChildReachTop : true;
          instance.isFrozenChild = widget.draggable ? _isChildFrozen : true;
          instance.onStart = widget.draggable ? _handleDragStart : null;
          instance.onUpdate = widget.draggable ? _handleDragUpdate : null;
          instance.onEnd = widget.draggable ? _handleDragEnd : null;
        })
      },
      child: buildContent(context),
    );
  }

  Widget buildContent(context) {
    return Material(
      elevation: 2.0,
      borderRadius: BorderRadius.vertical(top: Radius.circular(widget.draggable ? topRadius : 0)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
        if (widget.draggable)
          Container(
            margin: EdgeInsets.only(top: 8.0),
            constraints: BoxConstraints.tightFor(width: 40.0, height: 4.0),
            decoration: BoxDecoration(color: Color(0xffdcdcdc), borderRadius: BorderRadius.all(Radius.circular(4.0))),
          ),
        Expanded(
          child: NotificationListener<HeaderHeightNotification>(
              onNotification: _handleSheetHeaderNotification, child: widget.child),
        ),
      ]),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    widget.controller?.setInterface(null);
    super.dispose();
  }

  @override
  void setSheetState(DraggableBottomSheetState state) {
    print('xxx');
    print(state);
    print(_state);
    print('xxx1');
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
        target = widget.controller.anchorHeight / sheetHeight;
      } else if (state == DraggableBottomSheetState.COLLAPSED) {
        target = widget.controller.collapsedHeight / sheetHeight;
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

  double get anchorY => screenHeight - widget.controller.anchorHeight;

  double get collapsedY => screenHeight - widget.controller.collapsedHeight;

  bool get _isBellowAnchor {
    return _y > anchorY;
  }

  bool get _isBellowCollapsed {
    return _y > collapsedY;
  }

  bool get _isInAnchorArea {
    double up = (screenHeight - anchorY) / 2;
    double down = (widget.controller.anchorHeight - widget.controller.collapsedHeight) / 2 + anchorY;
    return _y > up && _y < down;
  }

  bool get _isTopOfAnchorArea {
    double up = (screenHeight - anchorY) / 2;
    return _y <= up;
  }

  bool get _isBellowAnchorArea {
    double down = (widget.controller.anchorHeight - widget.controller.collapsedHeight) / 2 + anchorY;
    return _y > down;
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
