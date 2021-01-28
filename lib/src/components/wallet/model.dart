import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import 'package:titan/src/plugins/wallet/config/bitcoin.dart';
import 'package:titan/src/plugins/wallet/config/ethereum.dart';
import 'package:titan/src/plugins/wallet/config/heco.dart';
import 'package:titan/src/plugins/wallet/config/hyperion.dart';

import 'vo/token_price_view_vo.dart';
import 'package:json_annotation/json_annotation.dart';

part 'model.g.dart';

/// 行情数据（实时）
@JsonSerializable()
class QuotesModel extends Equatable {
  // 行情数据，包括所有支持的法币
  final List<TokenPriceViewVo> quotes;

  // final int lastUpdateTime;

  QuotesModel({/*this.symbolStr, */ this.quotes /*, this.lastUpdateTime*/
      });

  @override
  List<Object> get props => [
        /*symbolStr, */ quotes /*, lastUpdateTime*/
      ];

  factory QuotesModel.fromJson(Map<String, dynamic> srcJson) => _$QuotesModelFromJson(srcJson);

  Map<String, dynamic> toJson() => _$QuotesModelToJson(this);
}

/// 法币计价
@JsonSerializable()
class LegalSign extends Object {
  @JsonKey(name: 'legal')
  String legal;

  @JsonKey(name: 'sign')
  String sign;

  LegalSign({this.legal, this.sign});

  LegalSign clone() => LegalSign(sign: sign, legal: this.legal);

  factory LegalSign.fromJson(Map<String, dynamic> srcJson) => _$LegalSignFromJson(srcJson);

  Map<String, dynamic> toJson() => _$LegalSignToJson(this);
}

// class ActiveQuoteVoAndSign {
//   final TokenPriceViewVo quoteVo;
//   final LegalSign sign;
//
//   ActiveQuoteVoAndSign({this.quoteVo, this.sign});
// }

/// 支持的法币
class SupportedLegal {
  static LegalSign usd = LegalSign(legal: 'USD', sign: '\$');
  static LegalSign cny = LegalSign(legal: 'CNY', sign: '¥');

  static List<LegalSign> all = [usd, cny];

  static LegalSign of(String legal) {
    for (var legalSign in all) {
      if (legalSign.legal == legal) {
        return legalSign.clone();
      }
    }
    return null;
  }
}

// @JsonSerializable()
class GasPriceRecommend extends Object {
  @JsonKey(name: 'fast')
  Decimal fast;

  @JsonKey(name: 'fastWait')
  double fastWait;

  @JsonKey(name: 'average')
  Decimal average;

  @JsonKey(name: 'avgWait')
  double avgWait;

  @JsonKey(name: 'safeLow')
  Decimal safeLow;

  @JsonKey(name: 'safeLowWait')
  double safeLowWait;

  GasPriceRecommend(
    this.fast,
    this.fastWait,
    this.average,
    this.avgWait,
    this.safeLow,
    this.safeLowWait,
  );

  BigInt get averageBigInt => BigInt.from(average?.toInt() ?? 0);

  BigInt get fastBigInt => BigInt.from(fast?.toInt() ?? 0);

  BigInt get safeLowBigInt => BigInt.from(safeLow?.toInt() ?? 0);

  factory GasPriceRecommend.fromJson(Map<String, dynamic> srcJson) => _$GasPriceRecommendFromJson(srcJson);

  Map<String, dynamic> toJson() => _$GasPriceRecommendToJson(this);

  GasPriceRecommend.ethDefaultValue() {
    this.fast = Decimal.fromInt(EthereumGasPrice.SUPER_FAST_SPEED);
    this.average = Decimal.fromInt(EthereumGasPrice.FAST_SPEED);
    this.safeLow = Decimal.fromInt(EthereumGasPrice.LOW_SPEED);
    this.fastWait = 0.5;
    this.avgWait = 3;
    this.safeLowWait = 30;
  }

  GasPriceRecommend.btcDefaultValue() {
    this.fast = Decimal.fromInt(BitcoinGasPrice.BTC_SUPER_FAST_SPEED);
    this.average = Decimal.fromInt(BitcoinGasPrice.BTC_FAST_SPEED);
    this.safeLow = Decimal.fromInt(BitcoinGasPrice.BTC_LOW_SPEED);
    this.fastWait = 15;
    this.avgWait = 45;
    this.safeLowWait = 70;
  }

  GasPriceRecommend.hecoDefaultValue() {
    this.fast = Decimal.fromInt(HecoGasPrice.SUPER_FAST_SPEED);
    this.average = Decimal.fromInt(HecoGasPrice.FAST_SPEED);
    this.safeLow = Decimal.fromInt(HecoGasPrice.LOW_SPEED);
    this.fastWait = 0.1;
    this.avgWait = 0.2;
    this.safeLowWait = 1;
  }

  GasPriceRecommend.hyperionDefaultValue() {
    this.fast = Decimal.fromInt(HyperionGasPrice.SUPER_FAST_SPEED);
    this.average = Decimal.fromInt(HyperionGasPrice.FAST_SPEED);
    this.safeLow = Decimal.fromInt(HyperionGasPrice.LOW_SPEED);
    this.fastWait = 0.1;
    this.avgWait = 0.2;
    this.safeLowWait = 1;
  }
}

GasPriceRecommend _$GasPriceRecommendFromJson(Map<String, dynamic> json) {
  return GasPriceRecommend(
    Decimal.parse(json['fast']),
    (json['fastWait'] as num)?.toDouble(),
    Decimal.parse(json['average']),
    (json['avgWait'] as num)?.toDouble(),
    Decimal.parse(json['safeLow']),
    (json['safeLowWait'] as num)?.toDouble(),
  );
}

Map<String, dynamic> _$GasPriceRecommendToJson(GasPriceRecommend instance) => <String, dynamic>{
      'fast': instance.fast.toString(),
      'fastWait': instance.fastWait,
      'average': instance.average.toString(),
      'avgWait': instance.avgWait,
      'safeLow': instance.safeLow.toString(),
      'safeLowWait': instance.safeLowWait,
    };
