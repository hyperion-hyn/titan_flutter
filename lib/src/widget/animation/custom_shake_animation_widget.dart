import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:titan/src/widget/animation/shake_animation_builder.dart';
import 'package:titan/src/widget/animation/shake_animation_controller.dart';
import 'package:titan/src/widget/animation/shake_animation_type.dart';

/// 创建人： Created by zhaolong
/// 创建时间：Created by  on 2020/7/17.
///
/// 可关注公众号：我的大前端生涯   获取最新技术分享
/// 可关注网易云课堂：https://study.163.com/instructor/1021406098.htm
/// 可关注博客：https://blog.csdn.net/zl18603543572
///
/// lib/demo/shake/shake_animation_widget.dart
/// 抖动效果的组件
class CustomShakeAnimationWidget extends StatefulWidget {
  ///[child] 执行动画的组件
  final Widget child;

  ///抖动的范围配置
  final double shakeRange;

  ///抖动的类型
  final ShakeAnimationType shakeAnimationType;

  ///抖动次数 0 为无限抖动
  final shakeCount;

  ///随机动画时抖动的波动范围
  final double randomValue;

  final int delayForward;

  ///抖动动画控制器
  final ShakeAnimationController shakeAnimationController;

  ///是否自动执行抖动
  final bool isForward;

  CustomShakeAnimationWidget(
      {@required this.child,
        this.shakeRange = 0.1,
        this.shakeCount = 0,
        this.shakeAnimationType = ShakeAnimationType.RoateShake,
        this.shakeAnimationController,
        this.isForward = true,
        this.delayForward = 0,
        this.randomValue = 4});

  @override
  State<StatefulWidget> createState() {
    return _ShakeAnimationState();
  }
}

class _ShakeAnimationState extends State<CustomShakeAnimationWidget>
    with SingleTickerProviderStateMixin {
  ///动画控制器
  AnimationController _animationController;

  ///旋转弧度动画
  Animation<double> _angleAnimation;

  ///抖动执行次数
  int _shakeTotalCount = 0;

  ///当前抖动执行次数
  int _shakeCurrentCount = 0;

  ///抖动的范围配置
  double _shakeRange;

  /// lib/demo/shake/shake_animation_widget.dart
  @override
  void initState() {
    super.initState();

    ///抖动的执行次数
    _shakeTotalCount = widget.shakeCount;

    ///抖动的范围
    _shakeRange = widget.shakeRange;
    if (_shakeRange <= 0) {
      _shakeRange = 0;
    } else if (_shakeRange > 1.0) {
      _shakeRange = 1.0;
    }

    ///1、创建动画控制器
    _animationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);

    ///2、创建串行动画
    _angleAnimation = TweenSequence<double>([
      ///TweenSequenceItem来组合其他的Tween
      TweenSequenceItem<double>(
          tween: Tween(begin: 0, end: _shakeRange), weight: 1),
      TweenSequenceItem<double>(
          tween: Tween(begin: _shakeRange, end: 0), weight: 1),
      TweenSequenceItem<double>(
          tween: Tween(begin: 0, end: -_shakeRange), weight: 1),
      TweenSequenceItem<double>(
          tween: Tween(begin: -_shakeRange, end: 0), weight: 1),
    ]).animate(_animationController);

    ///----------------------------------------------------------------
    ///添加动画状态监听
    _angleAnimation.addStatusListener(statusListener);

    ///----------------------------------------------------------------
    ///添加动画控制器
    /*if (widget.shakeAnimationController != null) {
      ///参数一 isOpen 为true 是为打开动画
      ///参数二 shakeCount默认为1 执行一次抖动
      widget.shakeAnimationController.setShakeListener(shakeListener);
    }*/
    if (widget.isForward) {
      Future.delayed(Duration(milliseconds: widget.delayForward),(){
        ///正向执行
        _animationController.forward();
        if (widget.shakeAnimationController != null) {
          widget.shakeAnimationController.animationRunging = true;
        }
      });
    }
  }

  /// lib/demo/shake/shake_animation_widget.dart
  ///抖动动画控制器监听
  void shakeListener(isOpen, shakeCount) {
    if (isOpen) {
      ///赋值抖动次数
      _shakeTotalCount = shakeCount;
      _animationController.reset();
      _animationController.forward();
    } else {
      ///重置抖动次数
      _shakeTotalCount = widget.shakeCount;

      ///停止抖动动画
      _animationController.stop();
    }
  }

  /// lib/demo/shake/shake_animation_widget.dart
  ///动画执行状态监听
  void statusListener(status) {
    if (status == AnimationStatus.completed) {
      ///无次数限定执行
      if (_shakeTotalCount == 0) {
        ///反向执行完毕后立刻正向执行
        _animationController.reset();
        _animationController.forward();
      } else {
        ///有次数限定执行
        if (_shakeCurrentCount < _shakeTotalCount) {
          ///未执行够次数时继续执行
          _animationController.reset();
          _animationController.forward();
        } else {
          if (widget.shakeAnimationController != null) {
            widget.shakeAnimationController.animationRunging = false;
          }
        }

        ///动画执行次数自增
        _shakeCurrentCount++;
      }
    }
  }

  /// lib/demo/shake/shake_animation_widget.dart
  @override
  void dispose() {
    ///销毁
    _animationController.dispose();

    ///移动监听
    widget.shakeAnimationController.removeListener();
    super.dispose();
  }

  /// lib/demo/shake/shake_animation_widget.dar
  @override
  Widget build(BuildContext context) {
    return ShakeAnimationBuilder(
      ///执行动画的Widget
      child: widget.child,

      ///动画曲线
      animation: _angleAnimation,

      ///动画类型
      shakeAnimationType: widget.shakeAnimationType,

      ///随机动画时抖动的波动范围
      randomValue: widget.randomValue,
    );
  }
}
