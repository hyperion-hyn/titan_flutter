
import 'package:titan/src/pages/market/entity/trade_info_entity.dart';

class ExcDetailEntity{
  int viewType;
  int leftPercent;
  int rightPercent;

  DepthInfoEntity depthEntity;

  ExcDetailEntity(this.viewType,this.leftPercent,this.rightPercent,{this.depthEntity});
}