import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';

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

  var isShowRedPocketZoom = false;

  @override
  void initState() {
    super.initState();
    _setUpTimer();
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
          Padding(
            padding: const EdgeInsets.only(
              top: 16.0,
              bottom: 8.0,
            ),
            child: Container(
              height: 150,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 16.0,
                    ),
                    child: Image.asset(
                      'res/drawable/bg_rp_airdrop.png',
                      height: 150,
                    ),
                  ),
                  Center(
                    child: SpinPerfect(
                      duration: const Duration(milliseconds: 400),
                      infinite: true,
                      child: Image.asset(
                        'res/drawable/rp_airdrop_vertex.png',
                        width: 100,
                        height: 100,
                      ),
                    ),
                  ),
                  Center(
                    child: Image.asset(
                      'res/drawable/red_pocket_logo.png',
                      width: 50,
                      height: 50,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 8,
          ),
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
    _timer = Timer.periodic(Duration(seconds: 2), (t) {
      _getLatestAirdrop();
      _getLatestRedPocket();
    });
  }

  _getLatestAirdrop() {}

  _getLatestRedPocket() {}
}

Widget _contentColumn(
  String content,
  String subContent, {
  double contentFontSize = 14,
  double subContentFontSize = 10,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          '$content',
          style: TextStyle(
            fontSize: contentFontSize,
            color: Colors.black,
          ),
        ),
        SizedBox(
          height: 4.0,
        ),
        Text(
          subContent,
          style: TextStyle(
            fontSize: subContentFontSize,
            color: DefaultColors.color999,
          ),
        ),
      ],
    ),
  );
}
