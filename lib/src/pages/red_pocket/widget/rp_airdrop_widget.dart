import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/pages/red_pocket/api/rp_api.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_airdrop_round_info.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_statistics.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';

import '../rp_my_rp_records_page.dart';
import '../rp_record_tab_page.dart';

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

class _RPAirdropWidgetState extends BaseState<RPAirdropWidget>
    with SingleTickerProviderStateMixin {
  Timer _airdropInfoTimer;
  Timer _countDownTimer;
  Timer _animTimer;

  AnimationController _pulseController;
  AnimationController _spinController;
  AnimationController _fadeAnimController;

  // AirdropState _currentAirdropState = AirdropState.Waiting;

  StreamController<AirdropState> rpMachineStreamController =
      StreamController.broadcast();
  StreamController<int> nextRoundStreamController =
      StreamController.broadcast();
  StreamController<int> currentRoundStreamController =
      StreamController.broadcast();
  StreamController<bool> machineLightOnController =
      StreamController.broadcast();

  int _nextRoundRemainTime = 0; // 下一轮剩余时间
  int _currentRoundRemainTime = 0;

  RpAirdropRoundInfo _latestRoundInfo;
  RPStatistics _rpStatistics;

  int _lastMinuteRpCount = 0; //最近一次获得的rp总奖励
  int _lastTimeCelebrateBegin = 0;
  final _rpCelebrateDuration = 6;

  var _lastAirdropState;
  var _isLightOn = false;

  RPApi _rpApi = RPApi();

  final rewardAudio = Audio("res/voice/coin.mp3"); //中奖
  // final rewardAudioPlayer = AssetsAudioPlayer();
  // bool rewardAudioPlayerPlaying = false;
  // final bgmAudio = Audio("res/voice/rp_bgm.mp3"); //背景音乐
  // final bgmAudioPlayer = AssetsAudioPlayer();
  // bool bgmAudioPlayerPlaying = false;

  @override
  void initState() {
    //_setUpController();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _latestRoundInfo = widget.rpAirdropRoundInfo;
    _rpStatistics = widget.rpStatistics;

    _resetNextRoundTime();
    _updateAirdropState();

    super.didChangeDependencies();
  }

  @override
  void onCreated() async {
    //await _mockReqTime();
    await _requestData();

    _setUpController();
    _setUpTimer();

    // rewardAudioPlayer.open(rewardAudio, autoStart: false, loopMode: LoopMode.single);
    // bgmAudioPlayer.open(bgmAudio, autoStart: false, loopMode: LoopMode.single);
  }

  // Future _mockReqTime() async {
  //   _lastMinuteRpCount = 0;
  //   _lastTimeCelebrateBegin = 0;
  //   _rpApi.count = 0;
  //   _rpApi.startTime = DateTime.now().millisecondsSinceEpoch ~/ 1000 + 10;
  //   _rpApi.endTime = DateTime.now().millisecondsSinceEpoch ~/ 1000 + 30;
  //
  //   await _requestData();
  //   _resetNextRoundTime();
  // }

  _setUpTimer() {
    // 定时检查是否获得新红包
    _airdropInfoTimer = Timer.periodic(Duration(seconds: 30), (t) async {
      await _requestData();
      _resetNextRoundTime();
    });

    // 倒计时、切换空投机状态
    _countDownTimer = Timer.periodic(Duration(seconds: 1), (t) {
      /// 刷新倒计时
      if (_nextRoundRemainTime >= 1) {
        _nextRoundRemainTime--;
        nextRoundStreamController.add(_nextRoundRemainTime);

        if (_nextRoundRemainTime == 0) {
          rpMachineStreamController.add(AirdropState.NotReceived);
        }
      }

      // ///
      // if (_nextRoundRemainTime == 0) {
      //   _requestData();
      // }

      if (_currentRoundRemainTime >= 1) {
        _currentRoundRemainTime--;
        currentRoundStreamController.add(_currentRoundRemainTime);
      }

      _isLightOn = !_isLightOn;
      machineLightOnController.add(_isLightOn);

      _updateAirdropState();
      // if (mounted) setState(() {});
    });

    _animTimer = Timer.periodic(Duration(seconds: 2), (t) async {
      _pulseController?.reset();
      _pulseController?.forward();

      _fadeAnimController?.reset();
      _fadeAnimController?.forward();

      _spinController?.reset();
      _spinController?.forward();
    });
  }

  void _resetNextRoundTime() {
    var now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    var currentRoundStartTime = _latestRoundInfo?.startTime ?? 0;
    var currentRoundEndTime = _latestRoundInfo?.endTime ?? 0;
    var nextRoundStartTime = _latestRoundInfo?.nextRoundStartTime ?? 0;

    if (currentRoundStartTime - now > 0) {
      _nextRoundRemainTime = currentRoundStartTime - now;
      nextRoundStreamController.add(_nextRoundRemainTime);
    }

    if (currentRoundEndTime > now) {
      _currentRoundRemainTime = currentRoundEndTime - now;
      currentRoundStreamController.add(_currentRoundRemainTime);
    }

    ///已过当前轮，使用下一轮的startTime
    if (now > currentRoundEndTime && now < nextRoundStartTime) {
      _nextRoundRemainTime = nextRoundStartTime - now;
      nextRoundStreamController.add(_nextRoundRemainTime);
    }

    if (mounted) setState(() {});
  }

  _setUpController() {
    _fadeAnimController = AnimationController(
        vsync: this,
        duration: Duration(
          milliseconds: 2000,
        ));
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
    if (_animTimer != null) {
      if (_animTimer.isActive) {
        _animTimer.cancel();
      }
    }

    _pulseController?.dispose();
    _fadeAnimController?.dispose();
    _spinController?.dispose();

    rpMachineStreamController?.close();
    nextRoundStreamController?.close();
    currentRoundStreamController?.close();
    machineLightOnController?.close();

    // rewardAudioPlayer.dispose();
    // bgmAudioPlayer.dispose();

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
              _globalStaticsView(),
              _airdropAnim(),
              _airdropDetailView(),
              _rpInfoView(),
            ],
          ),
        ],
      ),
    );
  }

  // @override
  // void reassemble() {
  //   super.reassemble();
  //
  //   _pulseController?.dispose();
  //   _pulseController = null;
  //   _zoomInController?.dispose();
  //   _zoomInController = null;
  // }

  ///views

  _globalStaticsView() {
    var airDropPercent = _rpStatistics?.rpContractInfo?.dropOnPercent ?? '--';
    var alreadyAirdrop = '--';

    try {
      alreadyAirdrop = FormatUtil.stringFormatCoinNum(
        _rpStatistics?.airdropInfo?.totalAmountStr ?? '0',
        decimal: 4,
      );
    } catch (e) {}

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '红包',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: HexColor('#333333'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 4,
            ),
            child: Text(
              S.of(context).rp_total_amount_percent(airDropPercent),
              style: TextStyle(
                color: DefaultColors.color999,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                '已累计红包(RP): $alreadyAirdrop ',
                style: TextStyle(
                  color: DefaultColors.color999,
                  fontSize: 12,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  _airdropAnim() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: StreamBuilder<AirdropState>(
          stream: rpMachineStreamController.stream,
          builder: (context, snapshot) {
            _pulseController = null;
            _spinController = null;
            _lastAirdropState = snapshot.data;
            var _currentAirdropState = snapshot.data;
            /*if (_currentAirdropState == AirdropState.Waiting) {
              return _waitingView();
            } else */
            if (_currentAirdropState == AirdropState.NotReceived) {
              // if (!bgmAudioPlayerPlaying) {
              //   bgmAudioPlayer.play();
              //   bgmAudioPlayerPlaying = true;
              // }
              // if (rewardAudioPlayerPlaying) {
              //   rewardAudioPlayer.pause();
              //   rewardAudioPlayerPlaying = false;
              // }
              return _airdropNotReceivedView();
            } else if (_currentAirdropState == AirdropState.Received) {
              // if (bgmAudioPlayerPlaying) {
              //   bgmAudioPlayer.pause();
              //   bgmAudioPlayerPlaying = false;
              // }
              // if (!rewardAudioPlayerPlaying) {
              //   rewardAudioPlayer.seek(Duration(milliseconds: 0));
              //   rewardAudioPlayer.play();
              //   rewardAudioPlayerPlaying = true;
              // }
              return _airdropReceivedView();
            } else if (_currentAirdropState == AirdropState.Waiting) {
              // if (bgmAudioPlayerPlaying) {
              //   bgmAudioPlayer.pause();
              //   bgmAudioPlayerPlaying = false;
              // }
              // if (rewardAudioPlayerPlaying) {
              //   rewardAudioPlayer.pause();
              //   rewardAudioPlayerPlaying = false;
              // }
              return _waitingView();
            } else {
              return _loadingView();
            }
          }),
    );
  }

  _loadingView() {
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
                child: Text(
              '加载中...',
              style: TextStyle(color: Colors.white),
            )),
          ],
        ),
      ),
    );
  }

  _waitingView() {
    var now = DateTime.now().millisecondsSinceEpoch;
    var _nextRoundStartTimeMillieSecond = 0;

    if (now > (_latestRoundInfo?.endTime ?? 0)) {
      _nextRoundStartTimeMillieSecond =
          (_latestRoundInfo?.nextRoundStartTime ?? 0) * 1000;
    } else {
      _nextRoundStartTimeMillieSecond =
          (_latestRoundInfo?.startTime ?? 0) * 1000;
    }

    var _nextRoundTimeText = _nextRoundStartTimeMillieSecond != 0
        ? FormatUtil.formatMinuteDate(
            _nextRoundStartTimeMillieSecond,
          )
        : '--';

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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '下一轮',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 4),
                      Text(
                        '$_nextRoundTimeText',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 8,
          ),
          StreamBuilder(
              stream: nextRoundStreamController.stream,
              builder: (context, snapshot) {
                if (snapshot?.data == null || snapshot?.data == 0) {
                  return SizedBox();
                } else {
                  var nextRoundText = '下轮预估 ${FormatUtil.formatTimer(
                    _nextRoundRemainTime,
                  )}';
                  return Text(nextRoundText);
                }
              }),
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
              child: StreamBuilder(
                  stream: machineLightOnController.stream,
                  builder: (context, snapshot) {
                    var imgPath = 'res/drawable/bg_rp_airdrop_light_on.png';
                    if ((snapshot?.data ?? false)) {
                      imgPath = 'res/drawable/bg_rp_airdrop_light_off.png';
                    }
                    return Image.asset(imgPath);
                  }),
            ),
            //SpinVertexAnim(),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 160,
            child: Stack(
              children: [
                Center(
                  child: StreamBuilder(
                      stream: machineLightOnController.stream,
                      builder: (context, snapshot) {
                        var imgPath = 'res/drawable/bg_rp_airdrop_light_on.png';
                        if ((snapshot?.data ?? false)) {
                          imgPath = 'res/drawable/bg_rp_airdrop_light_off.png';
                        }
                        return Image.asset(imgPath);
                      }),
                ),
                Center(
                  child: FadeAnimRP(
                    controller: _fadeAnimController,
                  ),
                ),
              ],
            ),
          ),
          Text('正在空投中...'),
          SizedBox(
            height: 4,
          ),
          StreamBuilder(
              stream: currentRoundStreamController.stream,
              builder: (context, snapshot) {
                if (snapshot?.data == null || snapshot?.data == 0) {
                  return SizedBox();
                } else {
                  var currentRoundText = '本轮剩余 ${FormatUtil.formatMinuteTimer(
                    _currentRoundRemainTime,
                  )}';
                  return Text(currentRoundText);
                }
              }),
        ],
      ),
    );
  }

  _airdropDetailView() {
    var myRpCount = _latestRoundInfo?.myRpCount ?? '--';
    var myRpAmount = '--';
    var totalAmount = '--';
    try {
      myRpAmount = FormatUtil.stringFormatCoinNum(
        _latestRoundInfo?.myRpAmountStr ?? '0',
        decimal: 4,
      );
      totalAmount = FormatUtil.stringFormatCoinNum(
        _latestRoundInfo?.totalRpAmountStr ?? '0',
        decimal: 4,
      );
    } catch (e) {}

    var activeWallet = WalletInheritedModel.of(context).activatedWallet;

    var now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    var _currentRoundStartTime = _latestRoundInfo?.startTime ?? 0;
    var _currentRoundEndTime = _latestRoundInfo?.endTime ?? 0;

    var airdropRoundText =
        _currentRoundStartTime < now && now < _currentRoundEndTime
            ? '本轮已空投'
            : '最近一轮';

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 16.0,
        horizontal: 16.0,
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
              InkWell(
                onTap: () {
                  //_mockReqTime();
                },
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 8, top: 8, bottom: 8, right: 8),
                  child: Image.asset(
                    'res/drawable/red_pocket.png',
                    width: 40,
                    height: 40,
                  ),
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
                          text: ' $airdropRoundText ( $totalAmount RP)',
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
    var rpToday = '--';
    var rpYesterday = '--';

    try {
      rpToday = FormatUtil.stringFormatCoinNum(
        _rpStatistics?.airdropInfo?.todayAmountStr ?? '0',
        decimal: 4,
      );
      rpYesterday = FormatUtil.stringFormatCoinNum(
        _rpStatistics?.airdropInfo?.yesterdayRpAmountStr ?? '0',
        decimal: 4,
      );
    } catch (e) {}

    var rpTodayStr = '$rpToday RP';
    var rpYesterdayStr = '$rpYesterday RP';

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

  /// 更新空投机器状态
  _updateAirdropState() {
    int _now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    int _currentRoundStartTime = _latestRoundInfo?.startTime ?? 0;
    int _currentRoundEndTime = _latestRoundInfo?.endTime ?? 0;
    int _nextRoundStartTime = _latestRoundInfo?.nextRoundStartTime;
    int _currentRoundReceivedCount =
        _latestRoundInfo?.myRpCount ?? 0; // 该轮获得红包数据
    if (_currentRoundReceivedCount > _lastMinuteRpCount) {
      _lastMinuteRpCount = _currentRoundReceivedCount;
      _lastTimeCelebrateBegin = _now;
    }

    // 在showtime时间段内
    if (_now >= _currentRoundStartTime && _now < _currentRoundEndTime) {
      if ((_now - _lastTimeCelebrateBegin) < _rpCelebrateDuration) {
        if (_lastAirdropState != null &&
            _lastAirdropState != AirdropState.Received) {
          AssetsAudioPlayer.playAndForget(rewardAudio);
          rpMachineStreamController.add(AirdropState.Received);
        }
      } else {
        rpMachineStreamController.add(AirdropState.NotReceived);
      }
    } else if (_nextRoundStartTime != null && _now > _nextRoundStartTime) {
      rpMachineStreamController.add(AirdropState.NotReceived);
    } else if (_lastAirdropState != AirdropState.Waiting) {
      rpMachineStreamController.add(AirdropState.Waiting);
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

      _updateAirdropState();

      if (mounted) setState(() {});
    } catch (e) {
      logger.e(e);
    }
  }

  _navToMyRpRecords() {
    var activeWallet = WalletInheritedModel.of(context)?.activatedWallet;
    if (activeWallet != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RpRecordTabPage(),
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

class FadeAnimRP extends StatelessWidget {
  final Animation<double> controller;
  final Animation<double> bezier;
  final Animation<double> size;

  FadeAnimRP({Key key, this.controller})
      : bezier = Tween<double>(
          begin: 1.0,
          end: 0.0,
        ).animate(CurvedAnimation(
          parent: controller,
          curve: Interval(0.2, 1, curve: Curves.fastOutSlowIn),
        )),
        size = Tween<double>(
          begin: 0.0,
          end: 50.0,
        ).animate(CurvedAnimation(
          parent: controller,
          curve: Interval(0.1, 0.2, curve: Curves.ease),
        )),
        super(key: key);

  Widget _buildAnimation(BuildContext context, Widget child) {
    return Container(
      child: Opacity(
        opacity: bezier.value,
        child: Container(
          width: size.value,
          height: size.value,
          child: Image.asset(
            'res/drawable/red_pocket_logo.png',
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      builder: _buildAnimation,
      animation: controller,
    );
  }
}

class SpinVertexAnim extends StatefulWidget {
  SpinVertexAnim({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _SpinVertexAnimState createState() => _SpinVertexAnimState();
}

class _SpinVertexAnimState extends State<SpinVertexAnim>
    with TickerProviderStateMixin {
  AnimationController controller;
  Animation animation;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(duration: const Duration(seconds: 3), vsync: this);
    animation = Tween(begin: 0.0, end: 0.25).animate(controller);
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        controller.forward();
      } else if (status == AnimationStatus.forward) {
      } else if (status == AnimationStatus.reverse) {}
    });
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      alignment: Alignment.center,
      turns: animation,
      child: Image.asset(
        'res/drawable/rp_airdrop_vertex.png',
        height: 50,
        width: 50,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }
}
