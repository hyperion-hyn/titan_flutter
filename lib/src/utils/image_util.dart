import 'package:flutter/material.dart';
import 'package:titan/src/components/wallet/vo/coin_view_vo.dart';
import 'package:titan/src/plugins/wallet/cointype.dart';
import 'package:titan/src/plugins/wallet/config/tokens.dart';

class ImageUtil {
  static Widget getChainIcon(CoinViewVo coin, double size) {
    Widget chainIcon = SizedBox();
    if (coin.coinType == CoinType.HYN_ATLAS && coin.symbol != 'HYN') {
      chainIcon = Container(
        alignment: Alignment.center,
        width: size,
        height: size,
        child: ImageUtil.getCoinImage(DefaultTokenDefine.HYN_Atlas.logo),
      );
    } else if (coin.coinType == CoinType.ETHEREUM && coin.symbol != 'ETH') {
      chainIcon = Container(
        alignment: Alignment.center,
        width: size,
        height: size,
        child: ImageUtil.getCoinImage(DefaultTokenDefine.ETHEREUM.logo),
      );
    } else if (coin.coinType == CoinType.HB_HT && coin.symbol != 'HT') {
      chainIcon = Container(
        alignment: Alignment.center,
        width: size,
        height: size,
        child: ImageUtil.getCoinImage(DefaultTokenDefine.HT.logo),
      );
    }
    return chainIcon;
  }

  static Widget getCoinImage(String imageUrl, {String placeholder}) {
    var isNetworkUrl = imageUrl.contains("http");
    if (!isNetworkUrl) {
      return Image.asset(imageUrl);
    }
    return FadeInImage.assetNetwork(
      placeholder: placeholder != null ? placeholder : 'res/drawable/img_placeholder_circle.png',
      image: imageUrl,
      fit: BoxFit.cover,
    );
  }

  static String getGeneralTokenLogo(String token) {
    return 'res/drawable/ic_token_${token?.toLowerCase()}.png';
  }

  static String getGeneralChainLogo(String chain) {
    return 'res/drawable/ic_chain_${chain?.toLowerCase()}.png';
  }
}
