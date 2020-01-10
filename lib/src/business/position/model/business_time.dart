abstract class BusinessEntity {
  const BusinessEntity();
}

class BusinessInfo extends BusinessEntity{
  List<BusinessDayItem> dayList;
  String timeStr;

  BusinessInfo({this.dayList, this.timeStr});
}

class BusinessDayItem extends BusinessEntity{
  String label;
  bool isCheck;

  BusinessDayItem({this.label, this.isCheck = false});
}

class BusinessTimeItem extends BusinessEntity{
  String label;
  bool isCheck;

  BusinessTimeItem({this.label, this.isCheck = false});
}
