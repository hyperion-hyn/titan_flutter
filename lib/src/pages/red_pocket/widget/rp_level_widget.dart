import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/components/rp/redpocket_component.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/pages/red_pocket/api/rp_api.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_my_level_info.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_promotion_rule_entity.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';

import '../rp_level_records_page.dart';

class RPLevelWidget extends StatefulWidget {
  RPLevelWidget();

  @override
  State<StatefulWidget> createState() {
    return _RPLevelWidgetState();
  }
}

class _RPLevelWidgetState extends State<RPLevelWidget> {
  RpMyLevelInfo _myLevelInfo;
  RpPromotionRuleEntity _promotionRuleEntity;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _myLevelInfo = RedPocketInheritedModel.of(context).rpMyLevelInfo;
    _promotionRuleEntity = RedPocketInheritedModel.of(context).rpPromotionRule;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int currentLevel = _myLevelInfo?.currentLevel ?? 0;
    int highestLevel = _myLevelInfo?.highestLevel ?? 0;

    var isShowDowngrade = highestLevel > currentLevel;

    var isZeroLevel = currentLevel == 0;

    var hint = isShowDowngrade || isZeroLevel
        ? Padding(
            padding: const EdgeInsets.only(
              top: 4,
            ),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Image.asset(
                  isZeroLevel
                      ? 'res/drawable/error_rounded.png'
                      : 'res/drawable/ic_rp_level_down.png',
                  width: 13,
                ),
                SizedBox(
                  width: 4,
                ),
                Text(
                  isZeroLevel
                      ? S.of(context).current_level_can_not_join_airdrop
                      : S.of(context).level_drop,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          )
        : Text(
            currentLevel < 5
                ? S.of(context).go_level_up
                : S.of(context).go_check,
            style: TextStyle(
              color: Colors.blue,
              fontSize: 13,
            ),
          );
    GlobalKey _toolTipKey = GlobalKey();

    var promotionSupplyRatioValue = double.tryParse(
            _promotionRuleEntity?.supplyInfo?.promotionSupplyRatio ?? '0') ??
        0;

    var currentTotalSupplyValue = double.tryParse(
            _promotionRuleEntity?.supplyInfo?.totalSupplyStr ?? '0') ??
        0;

    var nextYRatio = promotionSupplyRatioValue + 0.05;

    var nextRankSupply = 1000000 * nextYRatio;

    var isShowNextRankY = (nextRankSupply - currentTotalSupplyValue) < 10000 &&
        (nextRankSupply - currentTotalSupplyValue) > 0;

    var currentYPercent = FormatUtil.formatPercent(promotionSupplyRatioValue);

    var nextYPercent = FormatUtil.formatPercent(nextYRatio);

    var yValueHint = RichText(
        text: TextSpan(
      children: [
        TextSpan(
          text: '${S.of(context).current_str}Y',
          style: TextStyle(
            color: Colors.black,
            fontSize: 12,
          ),
        ),
        TextSpan(
          text: '(${S.of(context).rp_supply_ratio})',
          style: TextStyle(
            color: DefaultColors.color999,
            fontSize: 11,
          ),
        ),
        TextSpan(
          text: isShowNextRankY
              ? '${S.of(context).gonna_level_up_to}$nextYPercent'
              : '${S.of(context).is_str}$currentYPercent',
          style: TextStyle(
            color: Colors.black,
            fontSize: 12,
          ),
        ),
      ],
    ));

    return Column(
      children: [
        Row(
          children: [
            Text(
              S.of(context).rp_holding_level,
              style: TextStyle(
                color: HexColor('#333333'),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Expanded(
                child: InkWell(
              onTap: () {
                final dynamic tooltip = _toolTipKey.currentState;
                tooltip?.ensureTooltipVisible();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (isShowNextRankY)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Image.asset(
                        'res/drawable/ic_warning_triangle.png',
                        width: 15,
                        height: 15,
                      ),
                    ),
                  yValueHint,
                  SizedBox(width: 2),
                  Tooltip(
                    key: _toolTipKey,
                    verticalOffset: 16,
                    margin: EdgeInsets.symmetric(horizontal: 32.0),
                    padding: EdgeInsets.all(16.0),
                    message: S.of(context).rp_y_tooltip_content,
                    child: Image.asset(
                      'res/drawable/ic_tooltip.png',
                      width: 10,
                      height: 10,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
        SizedBox(
          height: 16,
        ),
        InkWell(
          onTap: _navToLevel,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(),
              ),
              Expanded(
                flex: 3,
                child: Image.asset(
                  "res/drawable/ic_rp_level_$currentLevel.png",
                  height: 80,
                ),
              ),
              Expanded(
                flex: 2,
                child: SizedBox(),
              )
            ],
          ),
        ),
        SizedBox(
          height: 2,
        ),
        Center(
          child: hint,
        ),
        SizedBox(
          height: 16,
        ),
      ],
    );
  }

  _navToLevel() {
    var activeWallet = WalletInheritedModel.of(context)?.activatedWallet;
    if (activeWallet != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RpLevelRecordsPage(),
        ),
      );
    } else {
      Fluttertoast.showToast(msg: S.of(context).create_or_import_wallet_first);
    }
  }
}
