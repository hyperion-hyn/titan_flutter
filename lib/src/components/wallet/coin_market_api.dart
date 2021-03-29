import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:titan/config.dart';
import 'package:titan/src/basic/http/entity.dart';
import 'package:titan/src/basic/http/http.dart';
import 'package:titan/src/basic/http/http_exception.dart';
import 'package:titan/src/components/wallet/model.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_http.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';

import '../../../env.dart';
import 'entity/tokens_price_entity.dart';
import 'vo/token_price_view_vo.dart';

class CoinMarketApi {
  /// 历史行情数据
  Future<List<TokenPriceViewVo>> quotes(int timestamp) async {
    var response = await AtlasHttpCore.instance.postEntity(
        'v1/wallet/quotes',
        EntityFactory<TokensPriceEntity>(
          (json) => TokensPriceEntity.fromJson(json),
        ),
        params: {
          "ts": timestamp,
        },
        options: RequestOptions(contentType: "application/json"));

    List<TokenPriceViewVo> list = [];
    var cnyLegalSign = SupportedLegal.of('CNY');
    var usdLegalSign = SupportedLegal.of('USD');
    var btcVo1 = TokenPriceViewVo(
        symbol: "BTC",
        legal: cnyLegalSign,
        price: response.btcCnyPrice,
        percentChange24h: response.btcPercentChangeCny24h);
    list.add(btcVo1);
    var btcVo2 = TokenPriceViewVo(
        symbol: "BTC",
        legal: usdLegalSign,
        price: response.btcUsdPrice,
        percentChange24h: response.btcPercentChangeUsd24h);
    list.add(btcVo2);

    var ethVo1 = TokenPriceViewVo(
        symbol: "ETH",
        legal: cnyLegalSign,
        price: response.ethCnyPrice,
        percentChange24h: response.ethPercentChangeCny24h);
    list.add(ethVo1);
    var ethVo2 = TokenPriceViewVo(
        symbol: "ETH",
        legal: usdLegalSign,
        price: response.ethUsdPrice,
        percentChange24h: response.ethPercentChangeUsd24h);
    list.add(ethVo2);

    var hynVo1 = TokenPriceViewVo(
        symbol: "HYN",
        legal: cnyLegalSign,
        price: response.hynCnyPrice,
        percentChange24h: response.hynPercentChangeCny24h);
    list.add(hynVo1);
    var hynVo2 = TokenPriceViewVo(
        symbol: "HYN",
        legal: usdLegalSign,
        price: response.hynUsdPrice,
        percentChange24h: response.hynPercentChangeUsd24h);
    list.add(hynVo2);

    var usdtVo1 = TokenPriceViewVo(
        symbol: "USDT",
        legal: cnyLegalSign,
        price: response.usdtCnyPrice,
        percentChange24h: response.usdtPercentChangeCny24h);
    list.add(usdtVo1);
    var usdtVo2 = TokenPriceViewVo(
        symbol: "USDT",
        legal: usdLegalSign,
        price: response.usdtUsdPrice,
        percentChange24h: response.usdtPercentChangeUsd24h);
    list.add(usdtVo2);

    var rpVo1 = TokenPriceViewVo(
        symbol: "RP",
        legal: cnyLegalSign,
        price: response.rpCnyPrice,
        percentChange24h: response.rpPercentChangeCny24h);
    list.add(rpVo1);
    var rpVo2 = TokenPriceViewVo(
        symbol: "RP",
        legal: usdLegalSign,
        price: response.rpUsdPrice,
        percentChange24h: response.rpPercentChangeUsd24h);
    list.add(rpVo2);

    return list;
  }

  /// 最新汇率数据
  Future<double> getRate() async {
    var res = await HttpCore.instance.get(
        'https://jisuhuilv.market.alicloudapi.com/exchange/convert?amount=1&from=USD&to=CNY',
        options: RequestOptions(headers: {
          "Authorization": 'APPCODE e72ad7e637aa49698e0852587fea1c1f',
          "Accept": "application/json"
        }));
    var responseEntity = ResponseEntity<Map>.fromJson(res, factory: EntityFactory((json) => json));

    print("[Coin_market_api] data:${responseEntity.data}, code:${responseEntity.code}");

    if (responseEntity.msg == 'ok') {
      var resultMap = responseEntity.data;
      return double?.tryParse(resultMap["rate"]) ?? 6.5;
    }

    throw HttpResponseCodeNotSuccess(responseEntity.code, responseEntity.msg);
  }

  Future<List<TokenPriceViewVo>> quotesLatest(List<String> quoteConverts) async {
    var response = await HttpCore.instance.get('api/v1/market/prices/latest',
        options: RequestOptions(headers: {
          "X-CMC_PRO_API_KEY": Config.COINMARKETCAP_PRVKEY,
          "Accept": "application/json"
        })) as Map;

    print("[Coin_market_api] response:$response");

    double hynUSD;
    double hynCNY;
    double rpUSD;
    double rpCNY;

    // hyn
    if (env.buildType == BuildType.PROD) {
      // usd -> cny
      var rate = await getRate();
      //print("[Home_pannel_mdex] rate:$rate");

      hynUSD = await WalletUtil.getPrice(
        coinType: 'HYN',
        contractAddress: '0x8e6a7d6bd250d207df3b9efafc6c715885eda94e',
      );

      hynCNY = hynUSD * rate;
      //print("[Home_pannel_mdex] hynUSD:$hynUSD, hynCNY:$hynCNY");

      // rp
      rpUSD = await WalletUtil.getPrice(
        coinType: 'RP',
        contractAddress: '0x2241E4D5cd6408E120974EDA698801eAA4bdc294',
      );

      rpCNY = rpUSD * rate;
      //print("[Home_pannel_mdex] rpUSD:$rpUSD, rpCNY:$rpCNY");
    }

    var status = response['state'];
    if (status['error_code'] == 0) {
      List<TokenPriceViewVo> list = [];
      var datas = response["data"] as Map;
      var keys = datas.keys;
      for (var key in keys) {
        for (var convert in quoteConverts) {
          var legalSign = SupportedLegal.of(convert);
          if (legalSign != null) {
            var price = datas[key]["quote"][convert]["price"];

            if (key == "HYN") {
              if (legalSign.legal == "CNY") {
                price = hynCNY;
                //print("1, hynCNY, price:$price");
              } else {
                price = hynUSD;
                //print("2, hynUSD, price:$price");
              }
            } else if (key == "RP") {
              if (legalSign.legal == "CNY") {
                price = rpCNY;
                //print("3, rpCNY, price:$price");
              } else {
                price = rpUSD;
                //print("4, rpUSD, price:$price");
              }
            }
            var percentChange24h = datas[key]["quote"][convert]["percent_change_24h"];
            var vo = TokenPriceViewVo(
                symbol: key,
                legal: legalSign,
                price: price,
                percentChange24h: Decimal.tryParse(percentChange24h.toString()).toDouble());
            list.add(vo);
          }
        }
      }
      return list;
    }

    throw HttpResponseCodeNotSuccess(status['error_code'], status['error_message']);
  }
}
