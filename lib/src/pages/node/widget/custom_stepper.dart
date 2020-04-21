// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

// TODO(dragostis): Missing functionality:
//   * mobile horizontal mode with adding/removing steps
//   * alternative labeling
//   * stepper feedback in the case of high-latency interactions

/// The state of a [Step] which is used to control the style of the circle and
/// text.
///
/// See also:
///
///  * [Step]
enum StepState {
  /// A step that displays its index in its circle.
  indexed,

  /// A step that displays a pencil icon in its circle.
  editing,

  /// A step that displays a tick icon in its circle.
  complete,

  /// A step that is disabled and does not to react to taps.
  disabled,

  /// A step that is currently having an error. e.g. the user has submitted wrong
  /// input.
  error,
}

/// Defines the [Stepper]'s main axis.
enum CustomStepperType {
  /// A vertical layout of the steps with their content in-between the titles.
  vertical,

  /// A horizontal layout of the steps with their content below the titles.
  horizontal,
}

const TextStyle _kStepStyle = TextStyle(
  fontSize: 12.0,
  color: Colors.white,
);
const Color _kErrorLight = Colors.red;
final Color _kErrorDark = Colors.red.shade400;
const Color _kCircleActiveLight = Colors.white;
const Color _kCircleActiveDark = Colors.black87;
const Color _kDisabledLight = Colors.black38;
const Color _kDisabledDark = Colors.white30;
const double _kStepSize = 13.0;
const double _kTriangleHeight = _kStepSize * 0.866025; // Triangle height. sqrt(3.0) / 2.0

/// A material step used in [Stepper]. The step can have a title and subtitle,
/// an icon within its circle, some content and a state that governs its
/// styling.
///
/// See also:
///
///  * [Stepper]
///  * <https://material.io/archive/guidelines/components/steppers.html>
@immutable
class CustomStep {
  /// Creates a step for a [Stepper].
  ///
  /// The [title], [content], and [state] arguments must not be null.
  const CustomStep({
    this.title,
    this.subtitle,
    this.progressHint,
    @required this.content,
    this.state = StepState.indexed,
    this.isActive = false,
  })  : /*assert(title != null),*/
        assert(content != null),
        assert(state != null);

  /// The title of the step that typically describes it.
  final Widget title;

  /// The subtitle of the step that appears below the title and has a smaller
  /// font size. It typically gives more details that complement the title.
  ///
  /// If null, the subtitle is not shown.
  final Widget subtitle;

  final Widget progressHint;

  /// The content of the step that appears below the [title] and [subtitle].
  ///
  /// Below the content, every step has a 'continue' and 'cancel' button.
  final Widget content;

  /// The state of the step which determines the styling of its components
  /// and whether steps are interactive.
  final StepState state;

  /// Whether or not the step is active. The flag only influences styling.
  final bool isActive;
}

/// A material stepper widget that displays progress through a sequence of
/// steps. Steppers are particularly useful in the case of forms where one step
/// requires the completion of another one, or where multiple steps need to be
/// completed in order to submit the whole form.
///
/// The widget is a flexible wrapper. A parent class should pass [currentStep]
/// to this widget based on some logic triggered by the three callbacks that it
/// provides.
///
/// See also:
///
///  * [Step]
///  * <https://material.io/archive/guidelines/components/steppers.html>
class CustomStepper extends StatefulWidget {
  /// Creates a stepper from a list of steps.
  ///
  /// This widget is not meant to be rebuilt with a different list of steps
  /// unless a key is provided in order to distinguish the old stepper from the
  /// new one.
  ///
  /// The [steps], [type], and [currentStep] arguments must not be null.
  const CustomStepper({
    Key key,
    @required this.steps,
    this.tickColor = Colors.red,
    this.tickText = '',
    this.currentStepProgress = 0.0,
    this.physics,
    this.type = CustomStepperType.horizontal,
    this.currentStep = 0,
    this.onStepTapped,
    this.onStepContinue,
    this.onStepCancel,
    this.controlsBuilder,
  })  : assert(steps != null),
        assert(type != null),
        assert(currentStep != null),
        assert(0 <= currentStep && currentStep < steps.length),
        super(key: key);

  /// The steps of the stepper whose titles, subtitles, icons always get shown.
  ///
  /// The length of [steps] must not change.
  final List<CustomStep> steps;

  final Color tickColor;
  final String tickText;
  final double currentStepProgress;

  /// How the stepper's scroll view should respond to user input.
  ///
  /// For example, determines how the scroll view continues to
  /// animate after the user stops dragging the scroll view.
  ///
  /// If the stepper is contained within another scrollable it
  /// can be helpful to set this property to [ClampingScrollPhysics].
  final ScrollPhysics physics;

  /// The type of stepper that determines the layout. In the case of
  /// [CustomStepperType.horizontal], the content of the current step is displayed
  /// underneath as opposed to the [CustomStepperType.vertical] case where it is
  /// displayed in-between.
  final CustomStepperType type;

  /// The index into [steps] of the current step whose content is displayed.
  final int currentStep;

  /// The callback called when a step is tapped, with its index passed as
  /// an argument.
  final ValueChanged<int> onStepTapped;

  /// The callback called when the 'continue' button is tapped.
  ///
  /// If null, the 'continue' button will be disabled.
  final VoidCallback onStepContinue;

  /// The callback called when the 'cancel' button is tapped.
  ///
  /// If null, the 'cancel' button will be disabled.
  final VoidCallback onStepCancel;

  /// The callback for creating custom controls.
  ///
  /// If null, the default controls from the current theme will be used.
  ///
  /// This callback which takes in a context and two functions,[onStepContinue]
  /// and [onStepCancel]. These can be used to control the stepper.
  ///
  /// {@tool snippet --template=stateless_widget_scaffold}
  /// Creates a stepper control with custom buttons.
  ///
  /// ```dart
  /// Widget build(BuildContext context) {
  ///   return Stepper(
  ///     controlsBuilder:
  ///       (BuildContext context, {VoidCallback onStepContinue, VoidCallback onStepCancel}) {
  ///          return Row(
  ///            children: <Widget>[
  ///              FlatButton(
  ///                onPressed: onStepContinue,
  ///                child: const Text('CONTINUE'),
  ///              ),
  ///              FlatButton(
  ///                onPressed: onStepCancel,
  ///                child: const Text('CANCEL'),
  ///              ),
  ///            ],
  ///          );
  ///       },
  ///     steps: const <Step>[
  ///       Step(
  ///         title: Text('A'),
  ///         content: SizedBox(
  ///           width: 100.0,
  ///           height: 100.0,
  ///         ),
  ///       ),
  ///       Step(
  ///         title: Text('B'),
  ///         content: SizedBox(
  ///           width: 100.0,
  ///           height: 100.0,
  ///         ),
  ///       ),
  ///     ],
  ///   );
  /// }
  /// ```
  /// {@end-tool}
  final ControlsWidgetBuilder controlsBuilder;

  @override
  _StepperState createState() => _StepperState();
}

class _StepperState extends State<CustomStepper> with TickerProviderStateMixin {
  List<GlobalKey> _keys;
  List<GlobalKey> _textKeys;
  final Map<int, StepState> _oldStates = <int, StepState>{};

  @override
  void initState() {
    super.initState();
    _keys = List<GlobalKey>.generate(
      widget.steps.length,
      (int i) => GlobalKey(),
    );
    _textKeys = List<GlobalKey>.generate(
      widget.steps.length,
      (int i) => GlobalKey(),
    );

    for (int i = 0; i < widget.steps.length; i += 1) _oldStates[i] = widget.steps[i].state;
  }

  @override
  void didUpdateWidget(CustomStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    assert(widget.steps.length == oldWidget.steps.length);

    for (int i = 0; i < oldWidget.steps.length; i += 1) _oldStates[i] = oldWidget.steps[i].state;
  }

  bool _isFirst(int index) {
    return index == 0;
  }

  bool _isLast(int index) {
    return widget.steps.length - 1 == index;
  }

  bool _isCurrent(int index) {
    return widget.currentStep == index;
  }

  bool _isDark() {
    return Theme.of(context).brightness == Brightness.dark;
  }

  Widget _buildLine(bool visible) {
    return Container(
      width: visible ? 1.0 : 0.0,
      height: 16.0,
      color: Colors.grey.shade400,
    );
  }

  Widget _buildCircleChild(int index, bool oldState) {
    final StepState state = oldState ? _oldStates[index] : widget.steps[index].state;
    final bool isDarkActive = _isDark() && widget.steps[index].isActive;
    assert(state != null);
    switch (state) {
      case StepState.indexed:
      case StepState.disabled:
//        return Text(
//          '${index + 1}',
//          style: isDarkActive ? _kStepStyle.copyWith(color: Colors.black87) : _kStepStyle,
//        );
        return Container();
      case StepState.editing:
        return Icon(
          Icons.edit,
          color: isDarkActive ? _kCircleActiveDark : _kCircleActiveLight,
          size: 18.0,
        );
      case StepState.complete:
        return Icon(
          Icons.check,
          color: isDarkActive ? _kCircleActiveDark : _kCircleActiveLight,
          size: 18.0,
        );
      case StepState.error:
        return const Text('!', style: _kStepStyle);
    }
    return null;
  }

  // todo: test_jison_0420
   Color _circleColor(int index) {
    final ThemeData themeData = Theme.of(context);
    if (!_isDark()) {
      return widget.steps[index].isActive && index <= widget.currentStep ? themeData.primaryColor : Colors.black38;
    } else {
      return widget.steps[index].isActive ? themeData.accentColor : themeData.backgroundColor;
    }
  }
/*
  Color _circleColor(int index) {
    final ThemeData themeData = Theme.of(context);
    if (!_isDark()) {
      return widget.steps[index].isActive && index <= widget.currentStep ?  Colors.black38:themeData.primaryColor;
    } else {
      return widget.steps[index].isActive ?  themeData.backgroundColor:themeData.accentColor;
    }
  }*/

  Widget _buildCircle(int index, bool oldState) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      width: index <= widget.currentStep ? _kStepSize : _kStepSize * 0.8,
      height: index <= widget.currentStep ? _kStepSize : _kStepSize * 0.8,
      child: AnimatedContainer(
        curve: Curves.fastOutSlowIn,
        duration: kThemeAnimationDuration,
        decoration: ShapeDecoration(
//          color: _circleColor(index),
          shape: CircleBorder(side: BorderSide(color: _circleColor(index), style: BorderStyle.solid, width: 2)),
        ),
        child: Center(
          child: _buildCircleChild(index, oldState && widget.steps[index].state == StepState.error),
        ),
      ),
    );
  }

  Widget _buildTriangle(int index, bool oldState) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      width: _kStepSize,
      height: _kStepSize,
      child: Center(
        child: SizedBox(
          width: _kStepSize,
          height: _kTriangleHeight,
          // Height of 24dp-long-sided equilateral triangle.
          child: CustomPaint(
            painter: _TrianglePainter(
              color: _isDark() ? _kErrorDark : _kErrorLight,
            ),
            child: Align(
              alignment: const Alignment(0.0, 0.8),
              // 0.8 looks better than the geometrical 0.33.
              child: _buildCircleChild(index, oldState && widget.steps[index].state != StepState.error),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(int index) {
    if (widget.steps[index].state != _oldStates[index]) {
      return AnimatedCrossFade(
        firstChild: _buildCircle(index, true),
        secondChild: _buildTriangle(index, true),
        firstCurve: const Interval(0.0, 0.6, curve: Curves.fastOutSlowIn),
        secondCurve: const Interval(0.4, 1.0, curve: Curves.fastOutSlowIn),
        sizeCurve: Curves.fastOutSlowIn,
        crossFadeState:
            widget.steps[index].state == StepState.error ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        duration: kThemeAnimationDuration,
      );
    } else {
      if (widget.steps[index].state != StepState.error)
        return _buildCircle(index, false);
      else
        return _buildTriangle(index, false);
    }
  }

  Widget _buildVerticalControls() {
    if (widget.controlsBuilder != null)
      return widget.controlsBuilder(context, onStepContinue: widget.onStepContinue, onStepCancel: widget.onStepCancel);

    Color cancelColor;

    switch (Theme.of(context).brightness) {
      case Brightness.light:
        cancelColor = Colors.black54;
        break;
      case Brightness.dark:
        cancelColor = Colors.white70;
        break;
    }

    assert(cancelColor != null);

    final ThemeData themeData = Theme.of(context);
    final MaterialLocalizations localizations = MaterialLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.only(top: 16.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints.tightFor(height: 48.0),
        child: Row(
          children: <Widget>[
            FlatButton(
              onPressed: widget.onStepContinue,
              color: _isDark() ? themeData.backgroundColor : themeData.primaryColor,
              textColor: Colors.white,
              textTheme: ButtonTextTheme.normal,
              child: Text(localizations.continueButtonLabel),
            ),
            Container(
              margin: const EdgeInsetsDirectional.only(start: 8.0),
              child: FlatButton(
                onPressed: widget.onStepCancel,
                textColor: cancelColor,
                textTheme: ButtonTextTheme.normal,
                child: Text(localizations.cancelButtonLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle _titleStyle(int index) {
    final ThemeData themeData = Theme.of(context);
    final TextTheme textTheme = themeData.textTheme;

    assert(widget.steps[index].state != null);
    switch (widget.steps[index].state) {
      case StepState.indexed:
      case StepState.editing:
      case StepState.complete:
        return textTheme.body2;
      case StepState.disabled:
        return textTheme.body2.copyWith(color: _isDark() ? _kDisabledDark : _kDisabledLight);
      case StepState.error:
        return textTheme.body2.copyWith(color: _isDark() ? _kErrorDark : _kErrorLight);
    }
    return null;
  }

  TextStyle _subtitleStyle(int index) {
    final ThemeData themeData = Theme.of(context);
    final TextTheme textTheme = themeData.textTheme;

    assert(widget.steps[index].state != null);
    switch (widget.steps[index].state) {
      case StepState.indexed:
      case StepState.editing:
      case StepState.complete:
        return textTheme.caption;
      case StepState.disabled:
        return textTheme.caption.copyWith(color: _isDark() ? _kDisabledDark : _kDisabledLight);
      case StepState.error:
        return textTheme.caption.copyWith(color: _isDark() ? _kErrorDark : _kErrorLight);
    }
    return null;
  }

  Widget _buildHeaderText(int index) {
    final List<Widget> children = <Widget>[];

    if (widget.steps[index].title != null) {
      children.add(AnimatedDefaultTextStyle(
        style: _titleStyle(index),
        duration: kThemeAnimationDuration,
        curve: Curves.fastOutSlowIn,
        child: widget.steps[index].title,
      ));
    }

    if (widget.steps[index].subtitle != null)
      children.add(
        Container(
          margin: const EdgeInsets.only(top: 2.0),
          child: AnimatedDefaultTextStyle(
            style: _subtitleStyle(index),
            duration: kThemeAnimationDuration,
            curve: Curves.fastOutSlowIn,
            child: widget.steps[index].subtitle,
          ),
        ),
      );

    return Column(
      key: _textKeys[index],
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }

  Widget _buildVerticalHeader(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: <Widget>[
          Column(
            children: <Widget>[
              // Line parts are always added in order for the ink splash to
              // flood the tips of the connector lines.
              _buildLine(!_isFirst(index)),
              _buildIcon(index),
              _buildLine(!_isLast(index)),
            ],
          ),
          Container(
            margin: const EdgeInsetsDirectional.only(start: 12.0),
            child: _buildHeaderText(index),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalBody(int index) {
    return Stack(
      children: <Widget>[
        PositionedDirectional(
          start: 24.0,
          top: 0.0,
          bottom: 0.0,
          child: SizedBox(
            width: 24.0,
            child: Center(
              child: SizedBox(
                width: _isLast(index) ? 0.0 : 1.0,
                child: Container(
                  color: Colors.grey.shade400,
                ),
              ),
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: Container(height: 0.0),
          secondChild: Container(
            margin: const EdgeInsetsDirectional.only(
              start: 60.0,
              end: 24.0,
              bottom: 24.0,
            ),
            child: Column(
              children: <Widget>[
                widget.steps[index].content,
                _buildVerticalControls(),
              ],
            ),
          ),
          firstCurve: const Interval(0.0, 0.6, curve: Curves.fastOutSlowIn),
          secondCurve: const Interval(0.4, 1.0, curve: Curves.fastOutSlowIn),
          sizeCurve: Curves.fastOutSlowIn,
          crossFadeState: _isCurrent(index) ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: kThemeAnimationDuration,
        ),
      ],
    );
  }

  Widget _buildVertical() {
    final List<Widget> children = <Widget>[];

    for (int i = 0; i < widget.steps.length; i += 1) {
      children.add(Column(
        key: _keys[i],
        children: <Widget>[
          InkWell(
            onTap: widget.steps[i].state != StepState.disabled
                ? () {
                    // In the vertical case we need to scroll to the newly tapped
                    // step.
                    Scrollable.ensureVisible(
                      _keys[i].currentContext,
                      curve: Curves.fastOutSlowIn,
                      duration: kThemeAnimationDuration,
                    );

                    if (widget.onStepTapped != null) widget.onStepTapped(i);
                  }
                : null,
            child: _buildVerticalHeader(i),
          ),
          _buildVerticalBody(i),
        ],
      ));
    }

    return ListView(
      shrinkWrap: true,
      physics: widget.physics,
      children: children,
    );
  }

  Widget _buildHorizontal() {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      final List<Widget> children = <Widget>[];
      final List<Widget> textChildren = <Widget>[];

      var maxWidth = constraints.biggest.width;

      for (int i = 0; i < widget.steps.length; i += 1) {
        textChildren.add(Expanded(
          child: Center(
            child: _buildHeaderText(i),
          ),
        ));

        Widget child;

        if (i == 0) {
          child = Container(
            margin: EdgeInsets.only(left: maxWidth / widget.steps.length / 2 - _kStepSize / 2),
            child: _buildIcon(i),
          );
        } else if (_isLast(i)) {
          child = Container(
            margin: EdgeInsets.only(right: maxWidth / widget.steps.length / 2 - _kStepSize / 2),
            child: _buildIcon(i),
          );
        } else {
          child = _buildIcon(i);
        }
        children.add(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                height: 48,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: child,
                  ),
                ),
              ),
            ],
          ),
        );

        if (!_isLast(i)) {
          children.add(
            Expanded(
              child: Container(
                height: 48,
                child: Stack(
                  children: <Widget>[
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          height: 1.0,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: FractionallySizedBox(
                          //widthFactor: 1,
                          widthFactor: i < widget.currentStep ? 1 : widget.currentStepProgress,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            height: 1.0,
                            // todo: test_jison_0420
//                            color: i <= widget.currentStep ? Colors.grey.shade400:Theme.of(context).primaryColor ,
                           color: i <= widget.currentStep ? Theme.of(context).primaryColor : Colors.grey.shade400,
                          ),
                        ),
                      ),
                    ),
                    if (widget.steps[i].progressHint != null)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: widget.steps[i].progressHint,
                        ),
                      )
                  ],
                ),
              ),
            ),
          );
        }
      }

      Widget leftTick = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 24.0),
            child: Opacity(
              opacity: 0.24,
              child: Container(
//                color: Colors.red,
                width: 12,
                height: 18,
                child: CustomPaint(
                  painter: _TickPainter(bgColor: widget.tickColor, direction: 0),
                ),
              ),
            ),
          ),
          Container(
            child: Text(
              widget.tickText,
              style: TextStyle(color: Colors.white70, fontSize: 11),
            ),
            color: widget.tickColor,
            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          ),
        ],
      );

      Widget rightTick = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            child: Text(
              widget.tickText,
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            color: widget.tickColor,
            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 24.0),
            child: Opacity(
              opacity: 0.24,
              child: Container(
//                color: Colors.red,
                width: 12,
                height: 18,
                child: CustomPaint(
                  painter: _TickPainter(bgColor: widget.tickColor, direction: 1),
                ),
              ),
            ),
          ),
        ],
      );

      var isRightTick = widget.currentStep >= widget.steps.length ~/ 2;
      Widget tick = isRightTick ? rightTick : leftTick;

      double itemWidth = maxWidth / widget.steps.length;
      double tickLeft = itemWidth * (widget.currentStep + 0.5 + widget.currentStepProgress);
      double tickRight = 0;
      if(isRightTick) {
        tickRight = maxWidth - tickLeft;
      }

      return Material(
        color: Colors.white,
        child: Stack(
          children: <Widget>[
            Positioned(
              top: 30,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: children,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: textChildren,
                  ),
                ],
              ),
            ),
            Positioned(
              child: tick,
              left: isRightTick ? null: tickLeft,
              right: isRightTick ? tickRight : null,
              top: 12,
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterial(context));
    assert(debugCheckHasMaterialLocalizations(context));
    assert(() {
      if (context.ancestorWidgetOfExactType(Stepper) != null)
        throw FlutterError('Steppers must not be nested. The material specification advises '
            'that one should avoid embedding steppers within steppers. '
            'https://material.io/archive/guidelines/components/steppers.html#steppers-usage');
      return true;
    }());
    assert(widget.type != null);
    switch (widget.type) {
      case CustomStepperType.vertical:
        return _buildVertical();
      case CustomStepperType.horizontal:
        return _buildHorizontal();
    }
    return null;
  }
}

// Paints a triangle whose base is the bottom of the bounding rectangle and its
// top vertex the middle of its top.
class _TrianglePainter extends CustomPainter {
  _TrianglePainter({
    this.color,
  });

  final Color color;

  @override
  bool hitTest(Offset point) => true; // Hitting the rectangle is fine enough.

  @override
  bool shouldRepaint(_TrianglePainter oldPainter) {
    return oldPainter.color != color;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double base = size.width;
    final double halfBase = size.width / 2.0;
    final double height = size.height;
    final List<Offset> points = <Offset>[
      Offset(0.0, height),
      Offset(base, height),
      Offset(halfBase, 0.0),
    ];

    canvas.drawPath(
      Path()..addPolygon(points, true),
      Paint()..color = color,
    );
  }
}

class _TickPainter extends CustomPainter {
  final Color bgColor;
  final int direction; // 0: 左边， 1： right
  _TickPainter({this.bgColor, this.direction = 0});

  @override
  bool hitTest(Offset point) => true; // Hitting the rectangle is fine enough.

  @override
  void paint(Canvas canvas, Size size) {
    Paint _paint = Paint()
      ..color = bgColor //画笔颜色
      ..strokeCap = StrokeCap.square //画笔笔触类型
      ..isAntiAlias = true //是否启动抗锯齿
      ..strokeWidth = 1.4; //画笔的宽度

    //canvas.drawLine(new Offset(size.width, 0), new Offset(size.width / 4, size.height), _paint);

    if (direction == 0) {
      //print("[pain] --0000, left");
      canvas.drawLine(Offset(size.width, 0), Offset(size.width/4, size.height), _paint);
    } else {
      //print("[pain] --1111, right");
      canvas.drawLine(Offset(0, 0), Offset(size.width, size.height), _paint);
    }
  }

  @override
  bool shouldRepaint(_TickPainter oldDelegate) {
    return oldDelegate.bgColor != bgColor;
  }
}
