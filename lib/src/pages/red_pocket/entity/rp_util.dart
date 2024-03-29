import 'package:decimal/decimal.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_my_rp_record_entity.dart';
import 'package:titan/src/utils/format_util.dart';

/// BigInt
String bigIntToEtherWithFormat(
  String bigIntValue, {
  int decimal = 4,
}) {
  if (bigIntValue == null) return '0';
  try {
    var value = FormatUtil.weiToEtherStr(bigIntValue);
    var result = FormatUtil.stringFormatCoinNum(
      value,
      decimal: decimal,
    );
    return (result ?? '0');
  } catch (e) {
    return '0';
  }
}

/// 过滤方法
List<RpOpenRecordEntity> filterRpOpenDataList(List<RpOpenRecordEntity> dataList) {
  List<RpOpenRecordEntity> tempList = dataList?.where((element) {
        var amountValue = Decimal.tryParse(element?.amountStr ?? '0') ?? Decimal.zero;
        var luckState = RpLuckState.values[(element?.luck ?? 0)];
        return !(luckState == RpLuckState.MISS && amountValue <= Decimal.zero);
      })?.toList() ??
      [];

  return tempList;
}

/// 红包状态
class RpStateInfoModel extends Object {
  final String desc;
  final String amount;

  RpStateInfoModel({this.desc, this.amount});
}

RpStateInfoModel getRpLuckStateInfo(RpOpenRecordEntity entity) {
  if (entity == null) return RpStateInfoModel(desc: '', amount: '');

  RedPocketType rpType = RedPocketType.values[entity.type];

  var desc = '';

  var amount = '--';
  String amountStr = FormatUtil.stringFormatCoinNum(
        entity?.amountStr ?? '0',
        decimal: 4,
      ) ??
      '--';
  amountStr += ' RP';

  var luckState = RpLuckState.values[(entity?.luck ?? 0)];
  switch (luckState) {
    case RpLuckState.MISS:
      desc = '${S.of(Keys.rootKey.currentContext).rp_missed} $amountStr';
      amount = '0 RP';
      break;

    case RpLuckState.BEST:
      desc = S.of(Keys.rootKey.currentContext).rp_best;
      amount = amountStr;
      break;

    case RpLuckState.LUCKY:
      if (rpType == RedPocketType.LUCKY) {
        desc = S.of(Keys.rootKey.currentContext).rp_hit;
      } else {
        desc = '';
      }
      amount = amountStr;
      break;

    case RpLuckState.LUCKY_BEST:
      desc = S.of(Keys.rootKey.currentContext).rp_hit_and_best;
      amount = amountStr;
      break;

    case RpLuckState.LUCKY_MISS_QUOTA:
      desc = S.of(Keys.rootKey.currentContext).rp_run_out_open_times;
      amount = amountStr;
      break;

    case RpLuckState.GET:
      desc = '';
      amount = amountStr;
      break;

    default:
      desc = '';
      amount = '';
      break;
  }
  return RpStateInfoModel(desc: desc, amount: amount);
}

// 1、燃烧 2、管理费 3、正常
enum RpAddressRoleType {
  ZERO,
  BURN,
  MANAGE_FEE,
  NORMAL,
}

// 0:Lucky 1:Level 2:Promotion
enum RedPocketType {
  LUCKY,
  LEVEL,
  PROMOTION,
}

enum RpLuckState {
  MISS, // 错过：0
  GET, // 获取：1
  BEST, // 最佳：2
  LUCKY, // 砸中：3
  LUCKY_BEST, // 砸中且最佳：4
  LUCKY_MISS_QUOTA, // 可拆次数用尽：5
}

HexColor getStateColor(int status) {
  HexColor stateColor = HexColor('#999999');
  if (status == null) {
    return stateColor;
  }
  //1:确认中 2:失败 3:成功 4:释放中 5:释放结束 6:可取回 7:取回中 8: 已提取

  switch (status) {
    case 1:
      stateColor = HexColor('#FFC500');
      break;

    case 2:
      stateColor = HexColor('#999999');
      break;

    case 3:
      stateColor = HexColor('#333333');
      break;

    case 4:
      stateColor = HexColor('#FFC500');
      break;

    case 5:
      stateColor = HexColor('#333333');
      break;

    case 6:
      stateColor = HexColor('#00C081');
      break;

    case 7:
      stateColor = HexColor('#FFC500');
      break;

    case 8:
      stateColor = HexColor('#999999');
      break;

    default:
      stateColor = HexColor('#999999');
      break;
  }
  return stateColor;
}

String getStateDesc(int status) {
  if (status == null) {
    return '';
  }

  String stateDesc = '';

  //1:确认中 2:失败 3:成功 4:释放中 5:释放结束 6:可取回 7:取回中 8: 已提取

  switch (status) {
    case 1:
      stateDesc = S.of(Keys.rootKey.currentContext).rp_staking_state_1;
      break;

    case 2:
      stateDesc = S.of(Keys.rootKey.currentContext).rp_staking_state_2;
      break;

    case 3:
      stateDesc = S.of(Keys.rootKey.currentContext).rp_staking_state_3;
      break;

    case 4:
      stateDesc = S.of(Keys.rootKey.currentContext).rp_staking_state_4;
      break;

    case 5:
      stateDesc = S.of(Keys.rootKey.currentContext).rp_staking_state_5;
      break;

    case 6:
      stateDesc = S.of(Keys.rootKey.currentContext).rp_staking_state_6;
      break;

    case 7:
      stateDesc = S.of(Keys.rootKey.currentContext).rp_staking_state_7;
      break;

    case 8:
      stateDesc = S.of(Keys.rootKey.currentContext).rp_staking_state_8;
      break;

    default:
      stateDesc = '';
      break;
  }
  return stateDesc;
}

/// 量级红包
String levelValueToLevelName(int levelValue) {
  if (levelValue == null) return '--';

  String level = '';
  switch (levelValue) {
    case 5:
      level = 'E';
      break;

    case 4:
      level = 'D';
      break;

    case 3:
      level = 'C';
      break;

    case 2:
      level = 'B';
      break;

    case 1:
      level = 'A';
      break;

    default:
      level = '0';
      break;
  }
  return level;
}

int levelNameToLevelValue(String levelName) {
  int level;
  switch (levelName) {
    case 'E':
      level = 5;
      break;

    case 'D':
      level = 4;
      break;

    case 'C':
      level = 3;
      break;

    case 'B':
      level = 2;
      break;

    case 'A':
      level = 1;
      break;
  }
  return level;
}

/// 分享红包
enum RedPocketShareType {
  NORMAL,
  LOCATION,
}

/*
waitForTX: 待转账
Pending: 已转账，待确认
expires: 已过期
allGot: 已全部领取完
ongoing: 进行中
*/
class RpShareState {
  static const String waitForTX = 'waitForTX';
  static const String pending = 'Pending';
  static const String expires = 'expires';
  static const String allGot = 'allGot';
  static const String ongoing = 'ongoing';
  static const String refunded = 'refunded';
  static const String refundOngoing = 'refundOngoing';
}

String shareStateToName(String state) {
  if (state == null) return '--';

  String name = '';
  switch (state) {
    case RpShareState.waitForTX:
      name = '${S.of(Keys.rootKey.currentContext).rp_share_state_wait_for_tx}...';
      break;

    case RpShareState.pending:
      name = '${S.of(Keys.rootKey.currentContext).rp_share_state_pending}...';
      break;

    case RpShareState.expires:
      name = '${S.of(Keys.rootKey.currentContext).rp_share_state_expires}';
      break;

    case RpShareState.ongoing:
      name = '${S.of(Keys.rootKey.currentContext).rp_share_state_ongoing}...';
      break;

    case RpShareState.allGot:
      name = '${S.of(Keys.rootKey.currentContext).rp_share_state_all_got}';
      break;

    case RpShareState.refunded:
      name = '${S.of(Keys.rootKey.currentContext).rp_share_state_refunded}';
      break;

    case RpShareState.refundOngoing:
      name = '${S.of(Keys.rootKey.currentContext).rp_share_state_refund_ongoing}...';
      break;

    default:
      name = '--';
      break;
  }
  return name;
}

class RpShareType {
  static const String normal = 'normal';
  static const String location = 'location';
}

class RpShareTypeEntity {
  final int index;
  final String nameZh;
  final String nameEn;
  final String desc;
  final String fullNameZh;
  final String fullDesc;

  const RpShareTypeEntity({
    this.index,
    this.nameZh,
    this.nameEn,
    this.desc,
    this.fullNameZh,
    this.fullDesc,
  });
}

class SupportedShareType {
  static RpShareTypeEntity normal() {
    return RpShareTypeEntity(
      index: 0,
      nameZh: S.of(Keys.rootKey.currentContext).newbee,
      nameEn: RpShareType.normal,
      desc: S.of(Keys.rootKey.currentContext).collect_friends,
      fullNameZh: S.of(Keys.rootKey.currentContext).newbee_red_pocket,
      fullDesc: S.of(Keys.rootKey.currentContext).only_newbee_can_collect,
    );
  }

  static RpShareTypeEntity location() {
    return RpShareTypeEntity(
      index: 1,
      nameZh: S.of(Keys.rootKey.currentContext).position,
      nameEn: RpShareType.location,
      desc: S.of(Keys.rootKey.currentContext).collect_red_pocket_nearby,
      fullNameZh: S.of(Keys.rootKey.currentContext).position_red_pocket,
      fullDesc: S.of(Keys.rootKey.currentContext).only_can_collect_red_pocket_nearby,
    );
  }
}

enum RedPocketShareActionType {
  SEND,
  GET,
}
