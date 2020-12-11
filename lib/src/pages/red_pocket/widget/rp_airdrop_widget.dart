import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';
import 'package:titan/src/basic/utils/hex_color.dart';

class RPAirdropWidget extends StatefulWidget {
  RPAirdropWidget();

  @override
  State<StatefulWidget> createState() {
    return _RPAirdropWidgetState();
  }
}

class _RPAirdropWidgetState extends State<RPAirdropWidget>
    with SingleTickerProviderStateMixin {
  Timer _timer;

  AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      value: 0,
      vsync: this,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    if (_timer != null) {
      if (_timer.isActive) {
        _timer.cancel();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Stack(
        children: [
          _content(),
          Lottie.asset(
            'res/lottie/rp_airdrop.json',
          ),
          Container(
            width: double.infinity,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: _redPocketDetail(),
            ),
          )
        ],
      ),
    );
  }

  ///views

  _content() {
    var isAirdropping = true;
    if (isAirdropping) {
      return _airdropView();
    } else {
      return _countDownView();
    }
  }

  _airdropView() {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '正在空投',
          ),
          SizedBox(
            height: 8,
          ),
          Text('已投600,000 RP')
        ],
      ),
    );
  }

  _countDownView() {
    var nextRoundTime = '';
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('12：00'),
          Text('下一轮 $nextRoundTime'),
        ],
      ),
    );
  }

  _redPocketDetail() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4.0)),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8.0,
            horizontal: 16.0,
          ),
          child: Wrap(
            children: [
              Row(
                children: [
                  Text(
                    '我获得的红包 ',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                  Spacer(),
                  Text(
                    '+100 RP ',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    '本轮已空投 600RP',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  ///

  _setUpTimer() {
    _timer = Timer.periodic(Duration(seconds: 5), (t) {
      _getLatestAirdrop();
      _getLatestRedPocket();
    });
  }

  _getLatestAirdrop() {}

  _getLatestRedPocket() {}
}
