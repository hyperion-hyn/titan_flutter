import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/widget/animation/custom_shake_animation_widget.dart';
import 'package:titan/src/widget/animation/shake_animation_type.dart';

import '../rp_my_rp_records_page.dart';

enum AirdropState {
  Waiting,
  NotReceived,
  Received,
}

class RPAirdropWidget extends StatefulWidget {
  RPAirdropWidget();

  @override
  State<StatefulWidget> createState() {
    return _RPAirdropWidgetState();
  }
}

class _RPAirdropWidgetState extends State<RPAirdropWidget>
    with SingleTickerProviderStateMixin {
  Timer _airdropInfoTimer;
  Timer _countDownTimer;

  AnimationController _pulseController;
  AnimationController _zoomInController;

  AnimationController _rouletteController;

  AirdropState _currentAirdropState = AirdropState.Waiting;

  int _airdropRemainTime = 0;
  int _nextRoundStartTime = 0;
  int _nextRoundEndTime = 0;

  @override
  void initState() {
    super.initState();
    _getLatestAirdropInfo();
    _setUpTimer();
    _setUpController();
  }

  _setUpTimer() {
    _airdropInfoTimer = Timer.periodic(Duration(seconds: 30), (t) {
      _getLatestAirdropInfo();
      _updateAirdropState();
    });

    _countDownTimer = Timer.periodic(Duration(seconds: 1), (t) {
      ///
      _pulseController?.reset();
      _pulseController?.forward();

      _zoomInController?.reset();
      _zoomInController?.forward();

      _rouletteController?.reset();
      _rouletteController?.forward();

      ///
      if (_airdropRemainTime >= 1) {
        _airdropRemainTime--;
      }
      _updateAirdropState();
      if (mounted) setState(() {});
    });
  }

  _setUpController() {}

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    if (_airdropInfoTimer != null) {
      if (_airdropInfoTimer.isActive) {
        _airdropInfoTimer.cancel();
      }
    }

    if (_countDownTimer != null) {
      if (_countDownTimer.isActive) {
        _countDownTimer.cancel();
      }
    }

    _pulseController?.dispose();
    _zoomInController?.dispose();
    _rouletteController?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: Stack(
        children: [
          Column(
            children: [
              _airdropAnim(),
              _airdropDetailView(),
              _rpInfoView(),
            ],
          ),
        ],
      ),
    );
  }

  ///views

  _airdropAnim() {
    if (_currentAirdropState == AirdropState.Waiting) {
      return _waitingView();
    } else if (_currentAirdropState == AirdropState.NotReceived) {
      return _airdropNotReceivedView();
    } else if (_currentAirdropState == AirdropState.Received) {
      return _airdropReceivedView();
    } else {
      return Container();
    }
  }

  _waitingView() {
    var nextRoundText = '下轮预估 ${FormatUtil.formatTimer(_airdropRemainTime)}';
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 160,
            child: Stack(
              children: [
                Center(
                  child: Image.asset(
                    'res/drawable/bg_rp_airdrop.png',
                  ),
                ),
                Center(
                  child: Text(
                    '尚未空投',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          _airdropRemainTime != 0 ? Text(nextRoundText) : SizedBox()
        ],
      ),
    );
  }

  _airdropReceivedView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        height: 160,
        child: Stack(
          children: [
            Center(
              child: Image.asset(
                'res/drawable/bg_rp_airdrop.png',
              ),
            ),
            Center(
              child: Pulse(
                manualTrigger: true,
                controller: (controller) {
                  _pulseController = controller;
                },
                child: Image.asset(
                  'res/drawable/red_pocket_logo.png',
                  width: 40,
                  height: 40,
                ),
              ),
            ),
            Center(
              child: Lottie.asset(
                'res/lottie/lottie_firework.json',
              ),
            )
          ],
        ),
      ),
    );
  }

  _airdropNotReceivedView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        height: 160,
        child: Stack(
          children: [
            Center(
              child: Image.asset(
                'res/drawable/bg_rp_airdrop.png',
              ),
            ),
            Center(
              child: Roulette(
                manualTrigger: true,
                controller: (controller) {
                  _rouletteController = controller;
                },
                child: ZoomIn(
                  manualTrigger: true,
                  controller: (controller) {
                    _zoomInController = controller;
                  },
                  child: Image.asset(
                    'res/drawable/red_pocket_logo.png',
                    width: 40,
                    height: 40,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _countDownView() {
    var nextRoundTime = '';
    return Container(
      width: double.infinity,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('12：00'),
              Text('下一轮 $nextRoundTime'),
            ],
          ),
        ],
      ),
    );
  }

  _airdropDetailView() {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 16.0,
        horizontal: 8.0,
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
            color: HexColor('#FFFFF5F5'),
            borderRadius: BorderRadius.circular(4.0)),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ),
          child: Row(
            children: [
              Image.asset(
                'res/drawable/red_pocket.png',
                width: 50,
                height: 50,
              ),
              SizedBox(
                width: 16.0,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '我获得10个红包 共 200 RP',
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      '本轮已空投 600RP',
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  _rpInfoView() {
    var rpTodayStr = '-- RP';
    var rpYesterdayStr = '-- RP';

    //var rpTodayStr = '${_rpStatistics?.airdropInfo?.todayAmountStr} RP';
    //var rpYesterdayStr =
    //    '${_rpStatistics?.airdropInfo?.yesterdayRpAmountStr} RP';
    //var rpMissedStr = '${_rpStatistics?.airdropInfo?.missRpAmountStr} RP';

    return InkWell(
      onTap: _navToMyRpRecords,
      child: Row(
        children: [
          Expanded(
            child: _contentColumn(
              rpTodayStr,
              S.of(context).rp_today_rp,
            ),
          ),
          _verticalLine(),
          Expanded(
            child: _contentColumn(
              rpYesterdayStr,
              S.of(context).rp_yesterday_rp,
            ),
          ),
          // _verticalLine(),
          // Expanded(
          //   child: _contentColumn(
          //       rpMissedStr, S.of(context).rp_missed),
          // ),
        ],
      ),
    );
  }

  _updateAirdropState() {
    int _systemTime = DateTime.now().millisecondsSinceEpoch;

    if (_systemTime > _nextRoundStartTime && _systemTime < _nextRoundEndTime) {
      _currentAirdropState = AirdropState.NotReceived;
    } else {
      _currentAirdropState = AirdropState.Waiting;
    }
  }

  _getLatestAirdropInfo() {
    try {} catch (e) {}
  }

  _navToMyRpRecords() {
    var activeWallet = WalletInheritedModel.of(context)?.activatedWallet;
    if (activeWallet != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RpMyRpRecordsPage(),
        ),
      );
    } else {
      Fluttertoast.showToast(msg: S.of(context).create_or_import_wallet_first);
    }
  }
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

Widget _verticalLine({
  bool havePadding = false,
}) {
  return Center(
    child: Container(
      height: 20,
      width: 0.5,
      color: HexColor('#000000').withOpacity(0.2),
      margin: havePadding
          ? const EdgeInsets.only(
              right: 4.0,
              left: 4.0,
            )
          : null,
    ),
  );
}
