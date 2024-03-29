
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:titan/env.dart';
import 'package:titan/src/data/cache/memory_cache.dart';
import 'package:titan/src/utils/format_util.dart';

void main() {
  BuildEnvironment.init(channel: BuildChannel.OFFICIAL, buildType: BuildType.DEV);

  test('FormatUtil test', () async {
    double value = 31323.1563392137213;
    var floorStr = FormatUtil.formatPrice(value);
    expect(floorStr, '31,323.15');

    //rounded
    var roundedStr = FormatUtil.formatPrice(value, false);
    expect(roundedStr, '31,323.16');

    var rst = FormatUtil.formatPercent(1.343);
    expect(rst, '134.30%');
  });

  test('FormatUtil truncateDoubleNum test', () async {
    var num = Decimal.parse("0.1");
    var decimals = 18;
    print('num $num $decimals');
    var number = (num * Decimal.fromInt(10).pow(decimals)).toString();
    print("num2 ${number.lastIndexOf(".") + 0 + 1}");
    var dstr = FormatUtil.truncateDecimalNum(num * Decimal.fromInt(10).pow(decimals), 0);
    print('dest $dstr');
  });
}
