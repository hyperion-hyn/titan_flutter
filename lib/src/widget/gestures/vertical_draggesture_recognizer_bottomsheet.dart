import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';

class VerticalDragGestureRecognizerBottomSheet extends OneSequenceGestureRecognizer {
  /// Initialize the object.
  ///
  /// [dragStartBehavior] must not be null.
  ///
  /// {@macro flutter.gestures.gestureRecognizer.kind}
  VerticalDragGestureRecognizerBottomSheet({
    Object debugOwner,
    PointerDeviceKind kind,
    this.dragStartBehavior = DragStartBehavior.start,
  })  : assert(dragStartBehavior != null),
        super(debugOwner: debugOwner, kind: kind);

  /// Configure the behavior of offsets sent to [onStart].
  ///
  /// If set to [DragStartBehavior.start], the [onStart] callback will be called at the time and
  /// position when the gesture detector wins the arena. If [DragStartBehavior.down],
  /// [onStart] will be called at the time and position when a down event was
  /// first detected.
  ///
  /// For more information about the gesture arena:
  /// https://flutter.dev/docs/development/ui/advanced/gestures#gesture-disambiguation
  ///
  /// By default, the drag start behavior is [DragStartBehavior.start].
  ///
  /// ## Example:
  ///
  /// A finger presses down on the screen with offset (500.0, 500.0),
  /// and then moves to position (510.0, 500.0) before winning the arena.
  /// With [dragStartBehavior] set to [DragStartBehavior.down], the [onStart]
  /// callback will be called at the time corresponding to the touch's position
  /// at (500.0, 500.0). If it is instead set to [DragStartBehavior.start],
  /// [onStart] will be called at the time corresponding to the touch's position
  /// at (510.0, 500.0).
  DragStartBehavior dragStartBehavior;

  /// A pointer has contacted the screen and might begin to move.
  ///
  /// The position of the pointer is provided in the callback's `details`
  /// argument, which is a [DragDownDetails] object.
  GestureDragDownCallback onDown;

  /// A pointer has contacted the screen and has begun to move.
  ///
  /// The position of the pointer is provided in the callback's `details`
  /// argument, which is a [DragStartDetails] object.
  ///
  /// Depending on the value of [dragStartBehavior], this function will be
  /// called on the initial touch down, if set to [DragStartBehavior.down] or
  /// when the drag gesture is first detected, if set to
  /// [DragStartBehavior.start].
  GestureDragStartCallback onStart;

  /// A pointer that is in contact with the screen and moving has moved again.
  ///
  /// The distance travelled by the pointer since the last update is provided in
  /// the callback's `details` argument, which is a [DragUpdateDetails] object.
  GestureDragUpdateCallback onUpdate;

  /// A pointer that was previously in contact with the screen and moving is no
  /// longer in contact with the screen and was moving at a specific velocity
  /// when it stopped contacting the screen.
  ///
  /// The velocity is provided in the callback's `details` argument, which is a
  /// [DragEndDetails] object.
  GestureDragEndCallback onEnd;

  /// The pointer that previously triggered [onDown] did not complete.
  GestureDragCancelCallback onCancel;

  /// The minimum distance an input pointer drag must have moved to
  /// to be considered a fling gesture.
  ///
  /// This value is typically compared with the distance traveled along the
  /// scrolling axis. If null then [kTouchSlop] is used.
  double minFlingDistance;

  /// The minimum velocity for an input pointer drag to be considered fling.
  ///
  /// This value is typically compared with the magnitude of fling gesture's
  /// velocity along the scrolling axis. If null then [kMinFlingVelocity]
  /// is used.
  double minFlingVelocity;

  /// Fling velocity magnitudes will be clamped to this value.
  ///
  /// If null then [kMaxFlingVelocity] is used.
  double maxFlingVelocity;

  double minDragDistance;

  bool isChildReachTop = false;
  bool isFrozenChild = true;

  _DragState _state = _DragState.ready;
  Offset _initialPosition;
  Offset _pendingDragOffset;
  Duration _lastPendingEventTimestamp;

  final Map<int, VelocityTracker> _velocityTrackers = <int, VelocityTracker>{};

  @override
  void addAllowedPointer(PointerEvent event) {
    startTrackingPointer(event.pointer);
    _velocityTrackers[event.pointer] = VelocityTracker();
    if (_state == _DragState.ready) {
      _state = _DragState.possible;
      _initialPosition = event.position;
      _pendingDragOffset = Offset.zero;
      _lastPendingEventTimestamp = event.timeStamp;
      if (onDown != null) invokeCallback<void>('onDown', () => onDown(DragDownDetails(globalPosition: _initialPosition)));
    } else if (_state == _DragState.accepted) {
      resolve(GestureDisposition.accepted);
    }
  }

  @override
  void handleEvent(PointerEvent event) {
    assert(_state != _DragState.ready);
    if (!event.synthesized && (event is PointerDownEvent || event is PointerMoveEvent)) {
      final VelocityTracker tracker = _velocityTrackers[event.pointer];
      assert(tracker != null);
      tracker.addPosition(event.timeStamp, event.position);
    }

    if (event is PointerMoveEvent) {
      final Offset delta = event.delta;
      if (_state == _DragState.accepted) {
        if (onUpdate != null) {
          invokeCallback<void>(
              'onUpdate',
              () => onUpdate(DragUpdateDetails(
                    sourceTimeStamp: event.timeStamp,
                    delta: _getDeltaForDetails(delta),
                    primaryDelta: _getPrimaryValueFromOffset(delta),
                    globalPosition: event.position,
                  )));
        }
      } else {
        _pendingDragOffset += delta;
        _lastPendingEventTimestamp = event.timeStamp;
        if (_hasSufficientPendingDragDeltaToAccept) resolve(GestureDisposition.accepted);
      }
    }
    stopTrackingIfPointerNoLongerDown(event);
  }

  @override
  void acceptGesture(int pointer) {
    if (_state != _DragState.accepted) {
      _state = _DragState.accepted;
      final Offset delta = _pendingDragOffset;
      final Duration timestamp = _lastPendingEventTimestamp;
      Offset updateDelta;
      switch (dragStartBehavior) {
        case DragStartBehavior.start:
          _initialPosition = _initialPosition + delta;
          updateDelta = Offset.zero;
          break;
        case DragStartBehavior.down:
          updateDelta = _getDeltaForDetails(delta);
          break;
      }
      _pendingDragOffset = Offset.zero;
      _lastPendingEventTimestamp = null;
      if (onStart != null) {
        invokeCallback<void>(
            'onStart',
            () => onStart(DragStartDetails(
                  sourceTimeStamp: timestamp,
                  globalPosition: _initialPosition,
                )));
      }
      if (updateDelta != Offset.zero && onUpdate != null) {
        invokeCallback<void>(
            'onUpdate',
            () => onUpdate(DragUpdateDetails(
                  sourceTimeStamp: timestamp,
                  delta: updateDelta,
                  primaryDelta: _getPrimaryValueFromOffset(updateDelta),
                  globalPosition: _initialPosition + updateDelta, // Only adds delta for down behaviour
                )));
      }
    }
  }

  @override
  void rejectGesture(int pointer) {
    stopTrackingPointer(pointer);
//    acceptGesture(pointer);
  }

  @override
  void didStopTrackingLastPointer(int pointer) {
    if (_state == _DragState.possible) {
      resolve(GestureDisposition.rejected);
      _state = _DragState.ready;
      if (onCancel != null) invokeCallback<void>('onCancel', onCancel);
      return;
    }
    final bool wasAccepted = _state == _DragState.accepted;
    _state = _DragState.ready;
    if (wasAccepted && onEnd != null) {
      final VelocityTracker tracker = _velocityTrackers[pointer];
      assert(tracker != null);

      final VelocityEstimate estimate = tracker.getVelocityEstimate();
      if (estimate != null && _isFlingGesture(estimate)) {
        final Velocity velocity = Velocity(pixelsPerSecond: estimate.pixelsPerSecond)
            .clampMagnitude(minFlingVelocity ?? kMinFlingVelocity, maxFlingVelocity ?? kMaxFlingVelocity);
        invokeCallback<void>(
            'onEnd',
            () => onEnd(DragEndDetails(
                  velocity: velocity,
                  primaryVelocity: _getPrimaryValueFromOffset(velocity.pixelsPerSecond),
                )), debugReport: () {
          return '$estimate; fling at $velocity.';
        });
      } else {
        invokeCallback<void>(
            'onEnd',
            () => onEnd(DragEndDetails(
                  velocity: Velocity.zero,
                  primaryVelocity: 0.0,
                )), debugReport: () {
          if (estimate == null) return 'Could not estimate velocity.';
          return '$estimate; judged to not be a fling.';
        });
      }
    }
    _velocityTrackers.clear();
  }

  @override
  void dispose() {
    _velocityTrackers.clear();
    super.dispose();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty<DragStartBehavior>('start behavior', dragStartBehavior));
  }

  bool _isFlingGesture(VelocityEstimate estimate) {
    final double minVelocity = minFlingVelocity ?? kMinFlingVelocity;
    final double minDistance = minFlingDistance ?? kTouchSlop;
    return estimate.pixelsPerSecond.dy.abs() > minVelocity && estimate.offset.dy.abs() > minDistance;
  }

  var dyThreshold = 8.0;
  bool get _hasSufficientPendingDragDeltaToAccept {
    if (_pendingDragOffset.dy.abs() > dyThreshold) {
      if (isFrozenChild) {
        return true;
      }
    }
    if (isChildReachTop) {
      if (_pendingDragOffset.dy > dyThreshold) {
        return true;
      }
    }
    return _pendingDragOffset.dy.abs() > minDragDistance ?? kTouchSlop;
  }

  Offset _getDeltaForDetails(Offset delta) => Offset(0.0, delta.dy);

  double _getPrimaryValueFromOffset(Offset value) => value.dy;

  String get debugDescription => 'vertical drag';
}

enum _DragState {
  ready,
  possible,
  accepted,
}
