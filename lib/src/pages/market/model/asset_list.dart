import 'package:decimal/decimal.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/pages/market/model/asset_type.dart';

class AssetList {
  AssetType USDT;
  AssetType HYN;
  AssetType ETH;
  AssetType BTC;
  AssetType RP;

  AssetList();

  AssetList.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('USDT') && json['USDT'] != null) {
      USDT = AssetType.fromJson(json['USDT']);
    }
    if (json.containsKey('HYN') && json['HYN'] != null) {
      HYN = AssetType.fromJson(json['HYN']);
    }
    if (json.containsKey('RP') && json['RP'] != null) {
      RP = AssetType.fromJson(json['RP']);
    }
    if (json.containsKey('ETH') && json['ETH'] != null) {
      ETH = AssetType.fromJson(json['ETH']);
    }
    if (json.containsKey('BTC') && json['BTC'] != null) {
      BTC = AssetType.fromJson(json['BTC']);
    }
  }

  Map<String, dynamic> toJson() {
    var ret = Map<String, dynamic>();
    ret['USDT'] = USDT?.toJson();
    ret['HYN'] = HYN?.toJson();
    ret['RP'] = RP?.toJson();
    ret['ETH'] = ETH?.toJson();
    ret['BTC'] = BTC?.toJson();
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

  Decimal getTotalUSDT() {
    var total;
    try {
      Decimal usdt = Decimal.parse(USDT.usdt);
      Decimal hynToUsdt = Decimal.parse(HYN.usdt);
      total = usdt + hynToUsdt;
      Decimal rpToUsdt = Decimal.parse(RP.usdt);
      total = usdt + hynToUsdt + rpToUsdt;
    } catch (e) {}
    return total;
  }

  Decimal getTotalHYN() {
    var total;
    try {
      Decimal usdtToHyn = Decimal.parse(USDT.hyn);
      Decimal rpToHyn = Decimal.parse(RP.hyn);
      Decimal hyn = Decimal.parse(HYN.hyn);
      total = usdtToHyn + rpToHyn + hyn;
    } catch (e) {
      logger.e(e);
    }
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

class AssetListV2 {
  List<AssetToken> tokenList = List();

  AssetListV2.fromJson(Map<String, dynamic> json) {
    json.forEach((key, value) {
      tokenList.add(AssetToken(key, AssetType.fromJson(value)));
    });
  }

  AssetType getTokenAsset(String tokenName) {
    var result;
    tokenList.forEach((element) {
      if (element.name == tokenName) {
        result = element.detail;
      }
    });

    return result;
  }

  Decimal totalByUSDT() {
    Decimal total = Decimal.zero;
    tokenList.forEach((token) {
      total = total + Decimal.parse(token.detail?.usdt) ?? Decimal.zero;
    });
    return total;
  }

  Decimal totalByHYN() {
    Decimal total = Decimal.zero;
    tokenList.forEach((token) {
      total = total + Decimal.parse(token.detail?.hyn) ?? Decimal.zero;
    });
    return total;
  }

}

class AssetToken {
  String name;
  AssetType detail;

  AssetToken(this.name, this.detail);
}
