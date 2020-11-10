
import 'package:k_chart/flutter_k_chart.dart';

class TradeInfoEntity {
  int date;
  String price;
  String amount;
  String actionType; // sell, buy
  TradeInfoEntity({this.date, this.price, this.amount, this.actionType});
}

/*class DepthInfoEntity {
  String price;
  String amount;
  String actionType; // sell, buy
  DepthInfoEntity({this.price, this.amount, this.actionType='sell'});
}*/

class DepthInfoEntity extends DepthEntity {

  DepthInfoEntity({this.actionType, double price, double amount}) : super(price, amount);

  @override
  String toString() {
    return 'Data{price: $price, amount: $vol}, actionType:$actionType';
  }

  String actionType;

}

class PeriodInfoEntity {
  final String name;
  final String value;
  PeriodInfoEntity({this.name, this.value});
}


// MainState
MainState enumMainStateFromString(String fruit) {
  fruit = 'MainState.$fruit';
  return MainState.values.firstWhere((f) => f.toString() == fruit, orElse: () => null);
}

// SecondaryState
SecondaryState enumSecondaryStateFromString(String fruit) {
  fruit = 'SecondaryState.$fruit';
  return SecondaryState.values.firstWhere((f) => f.toString() == fruit, orElse: () => null);
}
