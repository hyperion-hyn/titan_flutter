import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/red_pocket/api/rp_api.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_airdrop_round_info.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_statistics.dart';
import 'package:titan/src/routes/routes.dart';
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
  final RpAirdropRoundInfo rpAirdropRoundInfo;
  final RPStatistics rpStatistics;

  RPAirdropWidget({
    this.rpAirdropRoundInfo,
    this.rpStatistics,
  });

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

  AirdropState _currentAirdropState = AirdropState.Waiting;

  int _nextRoundRemainTime = 0;
  int _previousRoundStartTime = 0;

  RpAirdropRoundInfo _latestRoundInfo;
  RPStatistics _rpStatistics;

  RPApi _rpApi = RPApi();

  @override
  void initState() {
    super.initState();
    _latestRoundInfo = widget.rpAirdropRoundInfo;
    _rpStatistics = widget.rpStatistics;

    _requestData();
    _setUpTimer();
    _setUpController();
  }

  _setUpTimer() {
    _airdropInfoTimer = Timer.periodic(Duration(seconds: 30), (t) {
      _requestData();
      _updateAirdropState();
    });

    _countDownTimer = Timer.periodic(Duration(seconds: 1), (t) {
      ///
      _pulseController?.reset();
      _pulseController?.forward();

      _zoomInController?.reset();
      _zoomInController?.forward();

      ///
      if (_nextRoundRemainTime >= 1) {
        _nextRoundRemainTime--;
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
    var nextRoundText = '下轮预估 ${FormatUtil.formatTimer(_nextRoundRemainTime)}';
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
                    '暂未空投',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          _nextRoundRemainTime != 0 ? Text(nextRoundText) : SizedBox()
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
          ],
        ),
      ),
    );
  }

  _airdropDetailView() {
    var myRpCount = _latestRoundInfo?.myRpCount ?? '--';
    var myRpAmount = _latestRoundInfo?.myRpAmountStr ?? '--';
    var totalAmount = _latestRoundInfo?.totalRpAmountStr ?? '--';
    var activeWallet = WalletInheritedModel.of(context).activatedWallet;
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
            vertical: 4.0,
          ),
          child: Row(
            children: [
              Padding(
                padding:
                    const EdgeInsets.only(left: 8, top: 8, bottom: 8, right: 8),
                child: Image.asset(
                  'res/drawable/red_pocket.png',
                  width: 40,
                  height: 40,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(TextSpan(children: [
                        TextSpan(
                          text: '幸运红包',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: ' 最近一轮 ( ${totalAmount} RP)',
                          style: TextStyle(fontSize: 13),
                        )
                      ])),
                      SizedBox(
                        height: 4,
                      ),
                      activeWallet != null
                          ? Text.rich(TextSpan(children: [
                              TextSpan(
                                text: '我获得',
                                style: TextStyle(fontSize: 13),
                              ),
                              TextSpan(
                                text: ' $myRpCount ',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: '个红包 共',
                                style: TextStyle(fontSize: 13),
                              ),
                              TextSpan(
                                text: ' $myRpAmount ',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: 'RP',
                                style: TextStyle(fontSize: 13),
                              )
                            ]))
                          : Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    Application.router
                                        .navigateTo(
                                          context,
                                          Routes.wallet_manager,
                                        )
                                        .then((value) => () {
                                              if (mounted) {
                                                setState(() {});
                                              }
                                            });
                                  },
                                  child: Text(
                                    ' 创建/导入 ',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                                Text(
                                  '钱包后参与领红包',
                                  style: TextStyle(
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  _rpInfoView() {
    var rpTodayStr = '${_rpStatistics?.airdropInfo?.todayAmountStr ?? '--'} RP';
    var rpYesterdayStr =
        '${_rpStatistics?.airdropInfo?.yesterdayRpAmountStr ?? '--'} RP';
    //var rpMissedStr = '${rpStatistics?.airdropInfo?.missRpAmountStr} RP';

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
    int _systemTime = DateTime.now().second;
    int _latestRoundStartTime = _latestRoundInfo?.startTime ?? 0;
    int _latestRoundEndTime = _latestRoundInfo?.endTime ?? 0;
    int _remainTime = _latestRoundStartTime - _systemTime;
    bool _isReceived = (_latestRoundInfo?.myRpCount ?? 0) > 0;

    if (_latestRoundStartTime > _systemTime &&
        _previousRoundStartTime != _latestRoundStartTime) {
      _nextRoundRemainTime = _remainTime;
    }
    if (_systemTime > _latestRoundStartTime &&
        _systemTime < _latestRoundEndTime) {
      if (_isReceived) {
        _currentAirdropState = AirdropState.Received;
      } else {
        _currentAirdropState = AirdropState.NotReceived;
      }
    } else {
      _currentAirdropState = AirdropState.Waiting;
    }
  }

  _requestData() async {
    try {
      var _address = WalletInheritedModel.of(context)
          .activatedWallet
          ?.wallet
          ?.getAtlasAccount()
          ?.address;

      if (_address != null) {
        _latestRoundInfo = await _rpApi.getLatestRpAirdropRoundInfo(
          _address,
        );
        _rpStatistics = await _rpApi.getRPStatistics(
          _address,
        );
      }
    } catch (e) {}
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
