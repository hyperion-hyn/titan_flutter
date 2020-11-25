import 'package:decimal/decimal.dart';
import 'package:titan/src/pages/market/model/asset_type.dart';

class AssetList {
  AssetType USDT;
  AssetType HYN;
  AssetType ETH;
  AssetType BTC;
  AssetType RP;

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
    if (json.containsKey('RP')) {
      RP = AssetType.fromJson(json['RP']);
    }
  }

  Map<String, dynamic> toJson() {
    var ret = Map<String, dynamic>();
    ret['USDT'] = USDT.toJson();
    ret['HYN'] = HYN.toJson();
    ret['ETH'] = ETH.toJson();
    ret['BTC'] = BTC.toJson();
    ret['RP'] = RP.toJson();
    return ret;
  }

  AssetType getAsset(String type) {
    if (type == 'HYN') {
      return HYN;
    } else if (type == 'HYN ERC20') {
      return HYN;
    } else if (type == 'USDT') {
      return USDT;
    } else if (type == 'ETH') {
      return ETH;
    } else if (type == 'RP') {
      return RP;
    } else {
      return null;
    }
  }

  Decimal getTotalUsdt() {
    var total;
    try {
      Decimal usdt = Decimal.parse(USDT.usdt);
      Decimal hynToUsdt = Decimal.parse(HYN.usdt);
      total = usdt + hynToUsdt;
      //Decimal rpToUsdt = Decimal.parse(RP.usdt);
      //total = usdt + hynToUsdt + rpToUsdt;

    } catch (e) {}
    return total;
  }

  Decimal getTotalHyn() {
    var total;
    try {
      Decimal usdtToHyn = Decimal.parse(USDT.hyn);
      //Decimal rpToHyn = Decimal.parse(RP.hyn);
      Decimal hyn = Decimal.parse(HYN.hyn);
      //total = usdtToHyn + rpToHyn + hyn;
      total = usdtToHyn + hyn;
    } catch (e) {}
    return total;
  }

  String getWithdrawFee(String type) {
    if (type == 'HYN') {
      return HYN.withdrawFee;
    } else if (type == 'USDT') {
      return USDT.withdrawFee;
    } else if (type == 'ETH') {
      return ETH.withdrawFee;
    } else if (type == 'RP') {
      return RP.withdrawFee;
    } else {
      return '';
    }
  }
}
