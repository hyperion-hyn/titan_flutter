import 'package:decimal/decimal.dart';
import 'package:titan/src/pages/market/model/asset_type.dart';

class AssetList {
  AssetType USDT;
  AssetType HYN;
  AssetType ETH;
  AssetType BTC;

  AssetList();

  AssetList.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('USDT')) {
      USDT = AssetType.fromJson(json['USDT']);
    }
    if (json.containsKey('HYN')) {
      HYN = AssetType.fromJson(json['HYN']);
    }
    if (json.containsKey('ETH')) {
      ETH = AssetType.fromJson(json['ETH']);
    }
    if (json.containsKey('BTC')) {
      BTC = AssetType.fromJson(json['BTC']);
    }
  }

  Map<String, dynamic> toJson() {
    var ret = Map<String, dynamic>();
    ret['USDT'] = USDT.toJson();
    ret['HYN'] = HYN.toJson();
    ret['ETH'] = ETH.toJson();
    ret['BTC'] = BTC.toJson();
    return ret;
  }

  AssetType getAsset(String type) {
    if (type == 'HYN') {
      return HYN;
    } else if (type == 'USDT') {
      return USDT;
    } else if (type == 'ETH') {
      return ETH;
    } else {
      return null;
    }
  }

  Decimal getTotalEth() {
    var total;
    try {
      Decimal usdtToEth = Decimal.parse(USDT.eth);
      Decimal hynToEth = Decimal.parse(HYN.eth);
      Decimal eth = Decimal.parse(ETH.eth);
      total = usdtToEth + hynToEth + eth;
    } catch (e) {}
    return total;
  }
}
