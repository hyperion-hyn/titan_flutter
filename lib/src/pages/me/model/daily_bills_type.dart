
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/global.dart';

enum DailyBillsType {
  all,
  contract,
  node,
  reward,
  inAndOut,
  record,
  none
}


class DailyBillsModel {
  String name;
  DailyBillsType type;
  DailyBillsModel(this.name, this.type);
}

