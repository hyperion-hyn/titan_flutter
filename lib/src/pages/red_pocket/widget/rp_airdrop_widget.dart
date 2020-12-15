import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';

import '../rp_my_rp_records_page.dart';

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
      color: Colors.white,
      child: Stack(
        children: [
          Column(
            children: [
              _airdropAnim(),
              _airdropDetail(),
              _rpInfo(),
            ],
          ),
        ],
      ),
    );
  }

  ///views

  _airdropAnim() {
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
          Container(
            width: double.infinity,
            child: Stack(
              children: [
                Center(
                  child: Image.asset(
                    'res/drawable/rp_airdrop_anim.gif',
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

  _airdropDetail() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
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

  _rpInfo() {
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

  ///
  _setUpTimer() {
    _timer = Timer.periodic(Duration(seconds: 2), (t) {
      _getLatestAirdrop();
      _getLatestRedPocket();
    });
  }

  _getLatestAirdrop() {}

  _getLatestRedPocket() {}

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
