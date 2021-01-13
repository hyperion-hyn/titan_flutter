import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/utils/format_util.dart';

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
