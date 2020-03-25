
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/global.dart';

enum DailyBillsType {
  all,
  buyContract,
  node,
  income,
  recharge,
  withdrawal,
  others,
  none
}


class DailyBillsModel {
  String name;
  DailyBillsType type;
  DailyBillsModel(this.name, this.type);
}

